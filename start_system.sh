#!/bin/bash
# Start Script for Speech Translation System

echo "========================================"
echo "Starting Speech Translation System"
echo "========================================"
echo ""

# Check if virtual environment exists
if [ ! -f "venv/bin/activate" ]; then
    echo "ERROR: Virtual environment not found"
    echo "Please run ./setup.sh first"
    exit 1
fi

# Check if Docker is running
if ! docker ps &> /dev/null; then
    echo "ERROR: Docker is not running"
    echo "Please start Docker and try again"
    exit 1
fi

echo "[1/4] Starting n8n in Docker..."
echo ""

# Stop any existing n8n container
docker stop n8n-speech-translation &> /dev/null
docker rm n8n-speech-translation &> /dev/null

# Start n8n container
docker run -d \
  --name n8n-speech-translation \
  -p 5678:5678 \
  -v ~/.n8n:/home/node/.n8n \
  --add-host=host.docker.internal:host-gateway \
  n8nio/n8n

if [ $? -ne 0 ]; then
    echo "ERROR: Failed to start n8n container"
    exit 1
fi

echo "n8n started successfully on http://localhost:5678"
echo ""

# Wait for n8n to be ready
echo "Waiting for n8n to be ready..."
sleep 10

echo "[2/4] Starting Whisper service..."
echo ""

# Activate virtual environment and start Whisper service
source venv/bin/activate
nohup python whisper_service.py > whisper_service.log 2>&1 &
WHISPER_PID=$!
echo $WHISPER_PID > .whisper_pid

echo "Whisper service starting on http://localhost:9000 (PID: $WHISPER_PID)"
echo ""

# Wait for Whisper to load
sleep 5

echo "[3/4] Starting Translation service..."
echo ""

# Start Translation service
nohup python translation_service.py > translation_service.log 2>&1 &
TRANSLATION_PID=$!
echo $TRANSLATION_PID > .translation_pid

echo "Translation service starting on http://localhost:9001 (PID: $TRANSLATION_PID)"
echo ""

# Wait for services to be ready
sleep 5

echo "[4/4] Starting web interface..."
echo ""

# Start simple HTTP server for web interface
nohup python -m http.server 8000 > web_server.log 2>&1 &
WEB_PID=$!
echo $WEB_PID > .web_pid

echo "Web interface starting on http://localhost:8000 (PID: $WEB_PID)"
echo ""

sleep 3

echo "========================================"
echo "All Services Started!"
echo "========================================"
echo ""
echo "Service URLs:"
echo "  - Web Interface:  http://localhost:8000"
echo "  - n8n Dashboard:  http://localhost:5678"
echo "  - Whisper API:    http://localhost:9000"
echo "  - Translation API: http://localhost:9001"
echo ""
echo "IMPORTANT: On first run, you need to:"
echo "1. Go to http://localhost:5678 and set up n8n"
echo "2. Import the workflow from speech_translation_workflow.json"
echo ""
echo "Logs are available in:"
echo "  - whisper_service.log"
echo "  - translation_service.log"
echo "  - web_server.log"
echo ""
echo "To stop the system, run ./stop_system.sh"
echo ""
