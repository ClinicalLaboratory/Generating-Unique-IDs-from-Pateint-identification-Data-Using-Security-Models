## Windows Setup: Local Real-time Speech Translation

This guide runs the same system on Windows using a Python venv.

### 1) Prerequisites
- Windows 10/11
- Python 3.10+ installed (add to PATH)
- ffmpeg installed and in PATH (winget/choco or download from `https://ffmpeg.org`)
- n8n running locally at `http://localhost:5678`

### 2) Install dependencies
Open PowerShell in the repo root and run:
```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
./setup_windows.ps1
```

### 3) Start the Whisper+Argos service
```powershell
. .\.venv\Scripts\Activate.ps1
# Default: OpenAI Whisper backend
uvicorn scripts.transcribe_translate_service:app --host 127.0.0.1 --port 8001

# Optional: faster-whisper backend (CPU-friendly)
$env:WHISPER_BACKEND = "faster"
uvicorn scripts.transcribe_translate_service:app --host 127.0.0.1 --port 8001
```

Health check:
```powershell
curl http://127.0.0.1:8001/healthz
```

### 4) Import and activate the n8n workflow
Import `n8n/workflow_speech_translate.json` in the n8n UI. It listens at:
```
POST http://localhost:5678/webhook-test/speech-translate
```

### 5) Open the web UI
```powershell
cd web
python -m http.server 8002
```

Then open `http://localhost:8002` in your browser.

### Notes
- First-time translation for a new language pair may download Argos packages.
- To change the Whisper model: set `WHISPER_MODEL` to `tiny`, `base`, `small`, `medium`, or `large`.

