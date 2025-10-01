Param(
    [string]$PythonExe = "py",
    [string]$VenvPath = ".venv"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "[+] Checking ffmpeg availability"
if (-not (Get-Command ffmpeg -ErrorAction SilentlyContinue)) {
    Write-Host "[!] ffmpeg not found. Attempting to install via winget or choco..."
    $ffmpegInstalled = $false
    try {
        if (Get-Command winget -ErrorAction SilentlyContinue) {
            winget install --id Gyan.FFmpeg --source winget --accept-package-agreements --accept-source-agreements
            $ffmpegInstalled = $true
        }
    } catch { }
    if (-not $ffmpegInstalled) {
        try {
            if (Get-Command choco -ErrorAction SilentlyContinue) {
                choco install ffmpeg -y
                $ffmpegInstalled = $true
            }
        } catch { }
    }
    if (-not $ffmpegInstalled) {
        Write-Warning "Could not auto-install ffmpeg. Please install from https://ffmpeg.org/download.html and add to PATH."
    }
}

Write-Host "[+] Creating virtual environment at $VenvPath"
& $PythonExe -m venv $VenvPath

Write-Host "[+] Activating virtual environment"
. "$VenvPath\Scripts\Activate.ps1"

Write-Host "[+] Upgrading pip/setuptools/wheel"
python -m pip install --upgrade pip setuptools wheel

Write-Host "[+] Installing Python dependencies"
pip install -r requirements.txt

Write-Host "[+] Ensuring CPU PyTorch is installed (fallback)"
pip install --index-url https://download.pytorch.org/whl/cpu torch torchvision torchaudio

Write-Host "[✓] Setup complete. To start the service:"
Write-Host "    . $VenvPath\Scripts\Activate.ps1"
Write-Host "    uvicorn scripts.transcribe_translate_service:app --host 127.0.0.1 --port 8001"
Write-Host "    # Optional: serve the web UI"
Write-Host "    cd web; python -m http.server 8002"

