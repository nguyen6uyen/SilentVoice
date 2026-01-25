import os
import sys
from pathlib import Path

# Add the project root to sys.path so that 'pipelines' and 'chaplin' can be imported
root_dir = Path(__file__).resolve().parent.parent
if str(root_dir) not in sys.path:
    sys.path.append(str(root_dir))

import asyncio
import tempfile
from typing import Optional

import torch
from fastapi import FastAPI, File, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from ollama import AsyncClient
from pydantic import BaseModel

from chaplin import ChaplinOutput
from pipelines.pipeline import InferencePipeline


class TranscriptionResponse(BaseModel):
    raw_output: str
    corrected_text: str
    list_of_changes: str


app = FastAPI(title="Chaplin VSR API", version="1.0.0")

# CORS middleware to allow frontend access
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify your frontend domain
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Global VSR model instance (loaded once at startup)
vsr_model: Optional[InferencePipeline] = None
ollama_client = AsyncClient()


@app.on_event("startup")
async def load_model():
    """Load the VSR model at startup to avoid reloading for each request."""
    global vsr_model
    
    config_filename = "./configs/LRS3_V_WER19.1.ini"
    device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
    
    print(f"Loading VSR model on {device}...")
    vsr_model = InferencePipeline(
        config_filename,
        device=device,
        detector="mediapipe",
        face_track=True
    )
    print("✅ VSR Model loaded successfully!")


import json


# Define the output model locally to avoid version conflicts with chaplin.py
class ChaplinOutput(BaseModel):
    list_of_changes: str
    corrected_text: str

async def correct_output_async(output: str) -> dict:
    """Use Ollama to correct the raw VSR output with manual parsing for robustness."""
    try:
        response = await ollama_client.chat(
            model='qwen3:4b',
            messages=[
                {
                    'role': 'system',
                    'content': (
                        "You are an assistant that helps make corrections to the output of a lipreading model. "
                        "Return the corrected text in a JSON format with 'list_of_changes' and 'corrected_text' keys."
                    )
                },
                {
                    'role': 'user',
                    'content': f"Transcription to fix:\n\n{output}"
                }
            ],
            format={'type': 'object', 'properties': {'list_of_changes': {'type': 'string'}, 'corrected_text': {'type': 'string'}}, 'required': ['list_of_changes', 'corrected_text']}
        )
        
        # Manually parse the content to be safe
        content = response['message']['content']
        data = json.loads(content)
        
        corrected_text = data.get('corrected_text', output.capitalize()).strip()
        if corrected_text and corrected_text[-1] not in ['.', '?', '!']:
            corrected_text += '.'
            
        return {
            "corrected_text": corrected_text,
            "list_of_changes": data.get('list_of_changes', "Standard correction")
        }
    except Exception as e:
        print(f"⚠️ LLM Correction failed: {str(e)}", flush=True)
        return {
            "corrected_text": output.capitalize() + ".",
            "list_of_changes": "LLM unavailable, used raw output"
        }

@app.post("/process-video", response_model=TranscriptionResponse)
async def process_video(video: UploadFile = File(...)):
    """Process a video file and return the transcribed text."""
    if not vsr_model:
        raise HTTPException(status_code=503, detail="VSR model not loaded")
    
    # Save uploaded file to temporary location
    with tempfile.NamedTemporaryFile(delete=False, suffix='.mp4') as tmp_file:
        content = await video.read()
        tmp_file.write(content)
        tmp_path = tmp_file.name
    
    try:
        # Perform VSR inference
        raw_output = vsr_model(tmp_path)
        print(f"Raw VSR Output: {raw_output}", flush=True)
        
        # Get correction (this function now handles its own errors)
        correction_data = await correct_output_async(raw_output)
        
        return TranscriptionResponse(
            raw_output=raw_output,
            corrected_text=correction_data["corrected_text"],
            list_of_changes=correction_data["list_of_changes"]
        )
    
    except Exception as e:
        print(f"❌ Critical Processing error: {str(e)}", flush=True)
        # Even on critical error, try to return something so the frontend doesn't hang
        return TranscriptionResponse(
            raw_output="Error",
            corrected_text="I'm sorry, there was an error processing the video.",
            list_of_changes=str(e)
        )
    
    finally:
        # Clean up temporary file
        if os.path.exists(tmp_path):
            os.remove(tmp_path)


@app.get("/health")
async def health_check():
    """Health check endpoint."""
    return {
        "status": "healthy",
        "model_loaded": vsr_model is not None,
        "device": str(vsr_model.model.device) if vsr_model else "N/A"
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
