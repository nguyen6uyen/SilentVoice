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
# libgl1: replaced libgl1-mesa-glx for Debian Bookworm
# libglib2.0-0: required for opencv
RUN apt-get update && apt-get install -y \
    wget \
    git \
    ffmpeg \
    libsm6 \
    libxext6 \
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements files
COPY requirements.txt .
COPY backend_requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir -r backend_requirements.txt

# Create a non-root user
RUN useradd -m -u 1000 user

# Copy the application code
COPY --chown=user . .

# Download the VSR models (as root, but chown to user)
RUN chmod +x setup.sh && ./setup.sh && \
    chown -R user:user /app

# Switch to non-root user
USER user

# Set home to writable directory for cache
ENV HOME=/home/user

# Expose the port (HuggingFace Spaces uses 7860)
EXPOSE 7860

# Command to run the application
# Assumes build context is the project root
CMD ["uvicorn", "backend.main:app", "--host", "0.0.0.0", "--port", "7860"]
