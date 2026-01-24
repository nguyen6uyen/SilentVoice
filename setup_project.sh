#!/bin/bash

# Project Name
PROJECT_NAME="project-silentvoice"

echo "🚀 Initializing Project SilentVoice Architecture..."

# 1. Create Root Directory
mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME" || exit

# 2. Initialize Git
git init
echo "# Project SilentVoice" > README.md
echo "Real-Time Visual Speech Recognition (VSR) Application for the Hackathon." >> README.md
echo "" >> README.md
echo "## Architecture" >> README.md
echo "Please refer to [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for the full breakdown." >> README.md

# 3. Create Root .gitignore
cat <<EOT >> .gitignore
.DS_Store
node_modules/
dist/
coverage/
.env
__pycache__/
*.py[cod]
.ipynb_checkpoints/
venv/
.vscode/
EOT

# -----------------------------------------------------------------------------
# 4. Set up ML-ENGINE (Python/Data Science)
# -----------------------------------------------------------------------------
echo "📂 Creating ML Engine structure..."
mkdir -p ml-engine/data
mkdir -p ml-engine/notebooks
mkdir -p ml-engine/src
mkdir -p ml-engine/trained_models
mkdir -p ml-engine/tfjs_converter

# Create empty .keep files for empty dirs so git tracks them
touch ml-engine/data/.keep
touch ml-engine/notebooks/.keep
touch ml-engine/trained_models/.keep

# Create specific ML .gitignore
cat <<EOT >> ml-engine/.gitignore
# Ignore large datasets and heavy models
data/*
!data/.keep
trained_models/*
!trained_models/.keep
__pycache__/
EOT

# Create Placeholder Python Scripts
cat <<EOT >> ml-engine/src/preprocess.py
import cv2
import numpy as np

def extract_landmarks(video_path):
    """
    TODO: [ML TEAM]
    1. Load video using cv2
    2. Initialize MediaPipe Face Mesh
    3. Iterate frames and extract lip landmarks (indexes: 61, 146, 91, 181, etc.)
    4. Return numpy array of shape (frames, 40, 2)
    """
    pass
EOT

cat <<EOT >> ml-engine/src/model_arch.py
import tensorflow as tf
from tensorflow.keras import layers

def build_model(input_shape, num_classes):
    """
    TODO: [ML TEAM]
    Define the architecture (e.g., Conv3D or LSTM)
    """
    model = tf.keras.Sequential([
        layers.Input(shape=input_shape),
        layers.LSTM(64, return_sequences=False),
        layers.Dense(num_classes, activation='softmax')
    ])
    return model
EOT

cat <<EOT >> ml-engine/src/train.py
import os
from preprocess import extract_landmarks
from model_arch import build_model

"""
TODO: [ML TEAM]
1. Load data from ../data/
2. Preprocess
3. Train model
4. Save to ../trained_models/
"""
print("Training script initialized.")
EOT

# -----------------------------------------------------------------------------
# 5. Set up WEB-CLIENT (React/Vite)
# -----------------------------------------------------------------------------
echo "📂 Creating Web Client structure..."
mkdir -p web-client/public/models
mkdir -p web-client/public/assets
mkdir -p web-client/src/components
mkdir -p web-client/src/core
mkdir -p web-client/src/hooks

# Create Web .gitignore
cat <<EOT >> web-client/.gitignore
node_modules
dist
.env.local
EOT

# Create Core Logic Placeholders
cat <<EOT >> web-client/src/core/mediapipe.js
/**
 * TODO: [WEB TEAM - CORE]
 * Initialize MediaPipe FaceMesh here.
 * Export a function that accepts a video frame and returns landmarks.
 */
export const initFaceMesh = async () => {
    console.log("Initializing MediaPipe...");
};
EOT

cat <<EOT >> web-client/src/core/inference.js
import * as tf from '@tensorflow/tfjs';

/**
 * TODO: [WEB TEAM - CORE]
 * Load the model.json from /public/models/
 * Run tf.predict() on the landmark data
 */
export const loadModel = async () => {
    // const model = await tf.loadGraphModel('/models/model.json');
    console.log("Loading TensorFlow Model...");
};
EOT

cat <<EOT >> web-client/src/core/landmarkUtils.js
/**
 * TODO: [WEB TEAM - CORE]
 * Math functions to normalize coordinates relative to face size
 * (Distance between nose and chin)
 */
export const normalizeLandmarks = (rawLandmarks) => {
    return rawLandmarks;
};
EOT

# Create UI Component Placeholders
cat <<EOT >> web-client/src/components/CameraFeed.jsx
import React from 'react';

const CameraFeed = () => {
    return (
        <div className="relative w-full max-w-lg mx-auto bg-black rounded-xl overflow-hidden">
            <video id="video-feed" autoPlay playsInline muted className="w-full h-full transform -scale-x-100"></video>
            {/* Overlay Canvas for Face Mesh drawing goes here */}
        </div>
    );
};
export default CameraFeed;
EOT

cat <<EOT >> web-client/src/components/OutputConsole.jsx
import React from 'react';

const OutputConsole = ({ text, confidence }) => {
    return (
        <div className="bg-slate-900 p-6 rounded-xl border-t-4 border-teal-500 mt-4">
            <h3 className="text-teal-400 text-xs font-bold uppercase">Decoded Output</h3>
            <div className="text-white text-3xl font-mono mt-2 min-h-[60px]">
                {text || "Listening..."}
            </div>
            <div className="text-slate-500 text-xs mt-2">Confidence: {confidence}%</div>
        </div>
    );
};
export default OutputConsole;
EOT

# Create simple package.json for web-client
cat <<EOT >> web-client/package.json
{
  "name": "silentvoice-web",
  "version": "0.1.0",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "@mediapipe/face_mesh": "^0.4.1633559619",
    "@tensorflow/tfjs": "^4.10.0",
    "chart.js": "^4.4.0",
    "react-chartjs-2": "^5.2.0"
  },
  "devDependencies": {
    "@vitejs/plugin-react": "^4.0.0",
    "vite": "^4.3.9",
    "tailwindcss": "^3.3.0",
    "postcss": "^8.4.0",
    "autoprefixer": "^10.4.0"
  }
}
EOT

# -----------------------------------------------------------------------------
# 6. Documentation
# -----------------------------------------------------------------------------
echo "📂 Creating Documentation..."
mkdir -p docs
touch docs/ARCHITECTURE.md
touch docs/API_REFERENCE.md

# -----------------------------------------------------------------------------
# 7. Final Git Commit
# -----------------------------------------------------------------------------
git add .
git commit -m "Initial commit: Project SilentVoice Architecture Setup"

echo ""
echo "✅ SUCCESS! Project structure created at ./$PROJECT_NAME"
echo ""
echo "---------------------------------------------------------"
echo "NEXT STEPS TO PUSH TO GITHUB:"
echo "1. Go to https://github.com/new"
echo "2. Create a repository named '$PROJECT_NAME'"
echo "3. Run the following commands inside the folder:"
echo ""
echo "   cd $PROJECT_NAME"
echo "   git remote add origin https://github.com/YOUR_USERNAME/$PROJECT_NAME.git"
echo "   git branch -M main"
echo "   git push -u origin main"
echo ""
echo "---------------------------------------------------------"
