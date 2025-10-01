#!/usr/bin/env bash
set -euo pipefail

PYTHON_BIN=${PYTHON_BIN:-python3}
PIP_BIN=${PIP_BIN:-pip3}

echo "[+] Installing system dependencies (ffmpeg)"
if command -v apt-get >/dev/null 2>&1; then
  sudo apt-get update -y
  sudo apt-get install -y ffmpeg
elif command -v dnf >/dev/null 2>&1; then
  sudo dnf install -y ffmpeg
elif command -v pacman >/dev/null 2>&1; then
  sudo pacman -Sy --noconfirm ffmpeg
else
  echo "[!] Please install ffmpeg manually for your distro."
fi

echo "[+] Creating virtual environment at .venv"
${PYTHON_BIN} -m venv .venv
source .venv/bin/activate

echo "[+] Upgrading pip/setuptools/wheel"
pip install --upgrade pip setuptools wheel

echo "[+] Installing Python dependencies"
pip install -r requirements.txt || true

echo "[+] Ensuring CPU PyTorch is installed (fallback)"
pip install --index-url https://download.pytorch.org/whl/cpu torch torchvision torchaudio

echo "[+] Installation complete. To start the service:"
echo "    source .venv/bin/activate && WHISPER_MODEL=base uvicorn scripts.transcribe_translate_service:app --host 127.0.0.1 --port 8001"

