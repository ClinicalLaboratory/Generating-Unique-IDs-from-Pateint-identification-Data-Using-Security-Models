#!/bin/bash
# Stop Script for Speech Translation System

echo "========================================"
echo "Stopping Speech Translation System"
echo "========================================"
echo ""

echo "[1/4] Stopping n8n container..."
docker stop n8n-speech-translation &> /dev/null
docker rm n8n-speech-translation &> /dev/null
echo "n8n stopped"
echo ""

echo "[2/4] Stopping Whisper service..."
if [ -f .whisper_pid ]; then
    PID=$(cat .whisper_pid)
    kill $PID &> /dev/null
    rm .whisper_pid
    echo "Whisper service stopped (PID: $PID)"
else
    # Fallback: kill by process name
    pkill -f whisper_service.py
    echo "Whisper service stopped"
fi
echo ""

echo "[3/4] Stopping Translation service..."
if [ -f .translation_pid ]; then
    PID=$(cat .translation_pid)
    kill $PID &> /dev/null
    rm .translation_pid
    echo "Translation service stopped (PID: $PID)"
else
    # Fallback: kill by process name
    pkill -f translation_service.py
    echo "Translation service stopped"
fi
echo ""

echo "[4/4] Stopping web server..."
if [ -f .web_pid ]; then
    PID=$(cat .web_pid)
    kill $PID &> /dev/null
    rm .web_pid
    echo "Web server stopped (PID: $PID)"
else
    # Fallback: kill by process name
    pkill -f "http.server 8000"
    echo "Web server stopped"
fi
echo ""

echo "========================================"
echo "All Services Stopped!"
echo "========================================"
echo ""
