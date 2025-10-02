# 🔧 Flask Whisper Service Integration

## Problem Identified

You have a **Flask-based Whisper service** running on **port 9000**, but our n8n workflows are configured for a **FastAPI service** on **port 8001**. This mismatch causes the "bad request" errors.

## 🚀 Solutions

### Solution 1: Update n8n Workflow for Flask Service (Recommended)

#### Step 1: Import Flask-Compatible Workflow

1. **Stop current system**:
   ```bash
   ./stop.sh
   ```

2. **Import the Flask-compatible workflow**:
   - Open http://localhost:5678
   - Delete any existing workflows
   - Import: `n8n/workflow_flask_compatible.json`
   - **Activate** the workflow

#### Step 2: Update Web Interface

Update the web interface to point to your Flask service:

```javascript
// In web/app.js, change the URL to:
const N8N_WEBHOOK_URL = 'http://127.0.0.1:9000/transcribe'; // Direct to Flask
// OR keep using n8n proxy:
const N8N_WEBHOOK_URL = 'http://localhost:5678/webhook/speech-translate';
```

### Solution 2: Configure n8n for Your Flask Service

#### Manual n8n Configuration

1. **Open your n8n workflow**
2. **Edit the HTTP Request node**:
   - **URL**: `http://127.0.0.1:9000/transcribe` (or your Flask endpoint)
   - **Method**: `POST`
   - **Body Type**: `Multipart Form Data`
   - **Parameters**:
     - `audio`: (binary file)
     - `language`: `{{ $json.body?.targetLang || 'en' }}`
     - `task`: `transcribe` (or `translate`)

#### Common Flask Whisper Endpoints

Your Flask service likely uses one of these endpoints:
- `/transcribe` - For speech-to-text
- `/translate` - For translation
- `/whisper` - General endpoint
- `/api/transcribe` - API version

### Solution 3: Dual Service Setup

Run both services simultaneously:

#### Option A: Keep Your Flask Service + Add FastAPI
```bash
# Your Flask service (keep running on port 9000)
# Start our FastAPI service on port 8001
cd /workspace/speech-translation
source .venv/bin/activate
uvicorn scripts.transcribe_translate_service:app --host 127.0.0.1 --port 8001
```

#### Option B: Update Our Service Port
```bash
# Change our service to port 9001 to avoid conflict
echo "PORT=9001" >> .env
docker compose up --build -d
```

## 🔧 Flask Service Configuration

### Typical Flask Whisper Service Structure

Your Flask service probably expects:

```python
# POST /transcribe
{
    "audio": <binary_file>,
    "language": "en",  # source language (optional)
    "task": "transcribe"  # or "translate"
}
```

### Response Format
```json
{
    "text": "transcribed text",
    "language": "detected_language",
    "segments": [...],
    "task": "transcribe"
}
```

## 📋 Step-by-Step Fix

### For Your Current Setup:

1. **Identify your Flask endpoints**:
   ```bash
   # Test common endpoints
   curl http://127.0.0.1:9000/transcribe
   curl http://127.0.0.1:9000/health
   curl http://127.0.0.1:9000/api/transcribe
   ```

2. **Create a test audio file**:
   ```bash
   # Create 5-second silence for testing
   ffmpeg -f lavfi -i anullsrc=duration=5 -ar 16000 test.wav
   ```

3. **Test your Flask service**:
   ```bash
   curl -X POST http://127.0.0.1:9000/transcribe \
     -F "audio=@test.wav" \
     -F "language=en" \
     -F "task=transcribe"
   ```

4. **Update n8n workflow** based on the working endpoint and parameters.

## 🛠️ Ready-Made Workflows

I've created several workflow versions for you:

### 1. Flask Compatible Workflow
**File**: `n8n/workflow_flask_compatible.json`
- ✅ Works with Flask services
- ✅ Handles different response formats
- ✅ Includes data processing
- ✅ Error handling

### 2. Simple Flask Workflow  
**File**: `n8n/workflow_flask_simple.json` (create this):

```json
{
  "name": "Simple Flask Whisper",
  "nodes": [
    {
      "parameters": {
        "path": "speech-translate",
        "responseMode": "responseNode",
        "options": {"binaryData": true}
      },
      "name": "Webhook",
      "type": "n8n-nodes-base.webhook",
      "position": [200, 300]
    },
    {
      "parameters": {
        "method": "POST",
        "url": "http://127.0.0.1:9000/transcribe",
        "sendBody": true,
        "contentType": "multipart-form-data",
        "bodyParameters": {
          "parameters": [
            {"name": "language", "value": "en"},
            {"name": "task", "value": "transcribe"}
          ]
        },
        "sendBinaryData": true,
        "binaryPropertyName": "audio"
      },
      "name": "Flask Whisper",
      "type": "n8n-nodes-base.httpRequest",
      "position": [500, 300]
    },
    {
      "parameters": {
        "responseBody": "={{ $json }}",
        "options": {
          "responseHeaders": {
            "entries": [
              {"name": "Access-Control-Allow-Origin", "value": "*"}
            ]
          }
        }
      },
      "name": "Respond to Webhook",
      "type": "n8n-nodes-base.respondToWebhook",
      "position": [800, 300]
    }
  ],
  "connections": {
    "Webhook": {"main": [[{"node": "Flask Whisper", "type": "main", "index": 0}]]},
    "Flask Whisper": {"main": [[{"node": "Respond to Webhook", "type": "main", "index": 0}]]}
  }
}
```

## 🔍 Debugging Your Flask Service

### Check Service Status
```bash
# Check if service is running
curl http://127.0.0.1:9000/
curl http://127.0.0.1:9000/health

# Check available endpoints
curl -X OPTIONS http://127.0.0.1:9000/
```

### Test with Sample Audio
```bash
# Create test audio
echo "Hello world" | espeak --stdout > test.wav

# Test transcription
curl -X POST http://127.0.0.1:9000/transcribe \
  -F "audio=@test.wav" \
  -F "language=en"
```

### Common Flask Service Parameters
- `audio` - The audio file (required)
- `language` - Source language code (optional, auto-detect if not provided)
- `task` - Either "transcribe" or "translate"
- `target_language` - For translation tasks
- `model` - Whisper model size (tiny, base, small, etc.)

## 🎯 Expected Results

After fixing the configuration:
- ✅ n8n workflow connects to Flask service successfully
- ✅ Audio files are processed without "bad request" errors
- ✅ Transcription/translation results are returned
- ✅ Web interface displays results correctly

## 📞 Quick Fix Commands

### If you know your Flask endpoint:
```bash
# Replace /transcribe with your actual endpoint
sed -i 's|whisper-service:8001/transcribe-translate|127.0.0.1:9000/transcribe|g' n8n/workflow_speech_translate.json

# Restart n8n and reimport
docker compose restart n8n
./init-workflow.sh
```

### If you want to use our FastAPI service instead:
```bash
# Stop your Flask service
# Start our complete system
./start.sh
```

The key is ensuring the **n8n workflow URL matches your actual Whisper service** endpoint and port! 🎯