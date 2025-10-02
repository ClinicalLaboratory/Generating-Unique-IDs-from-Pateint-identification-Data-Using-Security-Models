@echo off
REM Start Script for Speech Translation System on Microsoft Surface

echo ========================================
echo Starting Speech Translation System
echo ========================================
echo.

REM Check if virtual environment exists
if not exist "venv\Scripts\activate.bat" (
    echo ERROR: Virtual environment not found
    echo Please run setup.bat first
    pause
    exit /b 1
)

REM Check if Docker is running
docker ps >nul 2>&1
if errorlevel 1 (
    echo ERROR: Docker is not running
    echo Please start Docker Desktop and try again
    pause
    exit /b 1
)

echo [1/4] Starting n8n in Docker...
echo.

REM Stop any existing n8n container
docker stop n8n-speech-translation >nul 2>&1
docker rm n8n-speech-translation >nul 2>&1

REM Start n8n container
docker run -d ^
  --name n8n-speech-translation ^
  -p 5678:5678 ^
  -v "%USERPROFILE%\.n8n:/home/node/.n8n" ^
  --add-host=host.docker.internal:host-gateway ^
  n8nio/n8n

if errorlevel 1 (
    echo ERROR: Failed to start n8n container
    pause
    exit /b 1
)

echo n8n started successfully on http://localhost:5678
echo.

REM Wait for n8n to be ready
echo Waiting for n8n to be ready...
timeout /t 10 /nobreak >nul

echo [2/4] Starting Whisper service...
echo.

REM Activate virtual environment and start Whisper service in new window
start "Whisper Service" cmd /k "call venv\Scripts\activate.bat && python whisper_service.py"

echo Whisper service starting on http://localhost:9000
echo.

REM Wait a bit for Whisper to load
timeout /t 5 /nobreak >nul

echo [3/4] Starting Translation service...
echo.

REM Start Translation service in new window
start "Translation Service" cmd /k "call venv\Scripts\activate.bat && python translation_service.py"

echo Translation service starting on http://localhost:9001
echo.

REM Wait for services to be ready
timeout /t 5 /nobreak >nul

echo [4/4] Starting web interface...
echo.

REM Start simple HTTP server for web interface
start "Web Interface" cmd /k "python -m http.server 8000"

echo Web interface starting on http://localhost:8000
echo.

timeout /t 3 /nobreak >nul

echo ========================================
echo All Services Started!
echo ========================================
echo.
echo Service URLs:
echo   - Web Interface:  http://localhost:8000
echo   - n8n Dashboard:  http://localhost:5678
echo   - Whisper API:    http://localhost:9000
echo   - Translation API: http://localhost:9001
echo.
echo IMPORTANT: On first run, you need to:
echo 1. Go to http://localhost:5678 and set up n8n
echo 2. Import the workflow from speech_translation_workflow.json
echo.
echo Opening web interface in browser...
timeout /t 2 /nobreak >nul
start http://localhost:8000

echo.
echo Press any key to open n8n dashboard...
pause >nul
start http://localhost:5678

echo.
echo System is running! Keep this window open.
echo To stop the system, run stop_system.bat
echo.
pause
