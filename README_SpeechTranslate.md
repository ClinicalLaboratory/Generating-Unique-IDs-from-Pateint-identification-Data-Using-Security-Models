## Local Real-time Speech Translation (Whisper + Argos + n8n)

This project provides:
- A local FastAPI service that performs speech-to-text with Whisper and translates with Argos Translate.
- An n8n workflow that receives audio, calls the local service, and returns JSON.
- A local web page that records/upload audio, selects target language, shows and saves translated text.

### 1) Prerequisites
- Linux with `ffmpeg` installed
- Python 3.10+
- n8n running locally on `http://localhost:5678`

### 2) Install dependencies
```bash
cd /workspace
bash setup.sh
```

### 3) Start the local Whisper+Argos service
```bash
cd /workspace
source .venv/bin/activate
WHISPER_MODEL=base uvicorn scripts.transcribe_translate_service:app --host 127.0.0.1 --port 8001
```

Health check: `curl http://127.0.0.1:8001/healthz`

### 4) Import and activate the n8n workflow
Import the JSON at `n8n/workflow_speech_translate.json` into n8n (top-right menu → Import from file). It is pre-configured to be active and listen at:
```
POST http://localhost:5678/webhook-test/speech-translate
```

If you have n8n CLI access on the host, you can also import via CLI:
```bash
n8n import:workflow --input=/workspace/n8n/workflow_speech_translate.json
```

### 5) Open the local web page
Serve the `web/` directory or open `web/index.html` directly in your browser.

If you need a simple static server:
```bash
cd /workspace/web
python3 -m http.server 8002
# Then open http://localhost:8002
```

The page posts audio to the n8n webhook and shows the translated text returned from the workflow.

### Notes
- The service installs Argos Translate language packages on-demand when translating new pairs (requires internet). To preinstall, run a one-time warmup by calling `POST /transcribe-translate` with small audio for the pairs you care about.
- To change the Whisper model, set `WHISPER_MODEL` to one of: `tiny`, `base`, `small`, `medium`, `large`.

### Windows
- Use `setup_windows.ps1` to install dependencies and create the venv.
- See `README_Windows.md` for detailed Windows-specific steps, including enabling the optional `WHISPER_BACKEND=faster` and serving the local web UI.

