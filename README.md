Project SilentVoice

Real-Time Visual Speech Recognition (VSR) Interface

Project SilentVoice is an accessibility tool designed to translate silent speech (lip movements without sound) into text in real-time. It utilizes computer vision and deep learning to decipher phonemes directly from video input.

📂 Repository Structure

The project is divided into two distinct workspaces to allow the Machine Learning team and the Web/Frontend team to work in parallel.

1. ml-engine/ (Python)

The training ground for the AI.

Goal: Train a neural network to recognize lip sequences.

Key Files:

src/preprocess.py: Extracts facial landmarks from video datasets.

src/model_arch.py: Defines the Neural Network architecture.

src/train.py: Handles the training loop and saving .h5 / .pth files.

Output: A JSON-compatible model file for the web client.

2. web-client/ (JavaScript / React)

The user-facing application.

Goal: Run the AI model in the browser using the webcam.

Stack: React, Vite, Tailwind CSS, TensorFlow.js, MediaPipe.

Key Files:

src/core/mediapipe.js: Real-time face tracking.

src/core/inference.js: Runs the prediction logic.

src/components/: UI elements for the dashboard.

🚀 Getting Started

For the Web Team

cd web-client

npm install

npm run dev

For the ML Team

cd ml-engine

Create a virtual environment: python -m venv venv

Install dependencies (create a requirements.txt first).

🤝 Contributing

Please verify which directory you are working in (ml-engine vs web-client) before pushing changes.
