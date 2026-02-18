# Use an official Python runtime as a parent image
FROM python:3.11-slim

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# Set the working directory in the container
WORKDIR /app

# Install system dependencies
# wget: for downloading models
# git: for potential git dependencies
# ffmpeg: for audio/video processing
# libsm6, libxext6, libgl1-mesa-glx: for OpenCV/MediaPipe
RUN apt-get update && apt-get install -y \
    wget \
    git \
    ffmpeg \
    libsm6 \
    libxext6 \
    libgl1-mesa-glx \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements files
COPY requirements.txt .
COPY backend_requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir -r backend_requirements.txt

# Copy the application code
COPY . .

# Download the VSR models
# This ensures self-contained deployment
RUN chmod +x setup.sh && ./setup.sh

# Expose the port the app runs on
EXPOSE 8000

# Command to run the application
# Assumes build context is the project root
CMD ["python", "backend/main.py"]
