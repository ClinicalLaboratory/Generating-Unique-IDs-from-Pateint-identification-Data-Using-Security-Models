@echo off
REM Stop Script for Speech Translation System on Microsoft Surface

echo ========================================
echo Stopping Speech Translation System
echo ========================================
echo.

echo [1/4] Stopping n8n container...
docker stop n8n-speech-translation >nul 2>&1
docker rm n8n-speech-translation >nul 2>&1
echo n8n stopped
echo.

echo [2/4] Stopping Whisper service...
REM Kill Python processes running whisper_service.py
for /f "tokens=2" %%i in ('tasklist ^| findstr /i "python"') do (
    wmic process where "ProcessId=%%i and CommandLine like '%%whisper_service.py%%'" delete >nul 2>&1
)
echo Whisper service stopped
echo.

echo [3/4] Stopping Translation service...
REM Kill Python processes running translation_service.py
for /f "tokens=2" %%i in ('tasklist ^| findstr /i "python"') do (
    wmic process where "ProcessId=%%i and CommandLine like '%%translation_service.py%%'" delete >nul 2>&1
)
echo Translation service stopped
echo.

echo [4/4] Stopping web server...
REM Kill Python processes running http.server
for /f "tokens=2" %%i in ('tasklist ^| findstr /i "python"') do (
    wmic process where "ProcessId=%%i and CommandLine like '%%http.server%%'" delete >nul 2>&1
)
echo Web server stopped
echo.

echo ========================================
echo All Services Stopped!
echo ========================================
echo.
pause
