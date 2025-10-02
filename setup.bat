@echo off
REM Setup Script for Speech Translation System on Microsoft Surface
REM This script installs all required dependencies

echo ========================================
echo Speech Translation System Setup
echo ========================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not installed or not in PATH
    echo Please install Python 3.8 or later from https://www.python.org/
    pause
    exit /b 1
)

echo [1/6] Python found!
echo.

REM Check if Docker Desktop is running
docker ps >nul 2>&1
if errorlevel 1 (
    echo ERROR: Docker is not running
    echo Please start Docker Desktop and try again
    pause
    exit /b 1
)

echo [2/6] Docker is running!
echo.

REM Check if FFmpeg is installed
ffmpeg -version >nul 2>&1
if errorlevel 1 (
    echo WARNING: FFmpeg is not installed
    echo Please install FFmpeg from https://ffmpeg.org/download.html
    echo and add it to your system PATH
    echo.
    echo You can also use Chocolatey: choco install ffmpeg
    pause
)

echo [3/6] FFmpeg found!
echo.

REM Create virtual environment
echo [4/6] Creating Python virtual environment...
python -m venv venv
if errorlevel 1 (
    echo ERROR: Failed to create virtual environment
    pause
    exit /b 1
)

echo Virtual environment created!
echo.

REM Activate virtual environment and install dependencies
echo [5/6] Installing Python dependencies...
echo This may take several minutes...
call venv\Scripts\activate.bat

python -m pip install --upgrade pip
pip install -r requirements.txt

if errorlevel 1 (
    echo ERROR: Failed to install dependencies
    pause
    exit /b 1
)

echo.
echo [6/6] Dependencies installed successfully!
echo.

echo ========================================
echo Setup Complete!
echo ========================================
echo.
echo Next steps:
echo 1. Make sure Docker Desktop is running
echo 2. Run start_system.bat to start all services
echo.
pause
