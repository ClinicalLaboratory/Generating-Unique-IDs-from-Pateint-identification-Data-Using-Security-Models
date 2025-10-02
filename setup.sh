#!/bin/bash
# Setup Script for Speech Translation System
# For Linux/Mac systems

echo "========================================"
echo "Speech Translation System Setup"
echo "========================================"
echo ""

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "ERROR: Python 3 is not installed"
    echo "Please install Python 3.8 or later"
    exit 1
fi

echo "[1/6] Python found!"
echo ""

# Check if Docker is running
if ! docker ps &> /dev/null; then
    echo "ERROR: Docker is not running"
    echo "Please start Docker and try again"
    exit 1
fi

echo "[2/6] Docker is running!"
echo ""

# Check if FFmpeg is installed
if ! command -v ffmpeg &> /dev/null; then
    echo "WARNING: FFmpeg is not installed"
    echo "Please install FFmpeg:"
    echo "  Ubuntu/Debian: sudo apt-get install ffmpeg"
    echo "  macOS: brew install ffmpeg"
    echo ""
    read -p "Press Enter to continue..."
fi

echo "[3/6] FFmpeg found!"
echo ""

# Create virtual environment
echo "[4/6] Creating Python virtual environment..."
python3 -m venv venv
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to create virtual environment"
    exit 1
fi

echo "Virtual environment created!"
echo ""

# Activate virtual environment and install dependencies
echo "[5/6] Installing Python dependencies..."
echo "This may take several minutes..."
source venv/bin/activate

pip install --upgrade pip
pip install -r requirements.txt

if [ $? -ne 0 ]; then
    echo "ERROR: Failed to install dependencies"
    exit 1
fi

echo ""
echo "[6/6] Dependencies installed successfully!"
echo ""

echo "========================================"
echo "Setup Complete!"
echo "========================================"
echo ""
echo "Next steps:"
echo "1. Make sure Docker is running"
echo "2. Run ./start_system.sh to start all services"
echo ""
