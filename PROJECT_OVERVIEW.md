# Speech Translation System - Project Overview

## 📁 Project Structure

```
SpeechTranslation/
├── 📄 README.md                          # Main documentation
├── 📄 INSTALLATION_GUIDE.md              # Detailed setup instructions
├── 📄 PROJECT_OVERVIEW.md                # This file
├── 📄 requirements.txt                   # Python dependencies
├── 📄 .gitignore                         # Git ignore rules
│
├── 🔧 Setup Scripts
│   ├── setup.bat                         # Windows setup script
│   ├── setup.sh                          # Linux/Mac setup script
│   ├── start_system.bat                  # Windows start script
│   ├── start_system.sh                   # Linux/Mac start script
│   ├── stop_system.bat                   # Windows stop script
│   └── stop_system.sh                    # Linux/Mac stop script
│
├── 🐍 Backend Services
│   ├── whisper_service.py                # Whisper transcription API
│   ├── translation_service.py            # Translation API
│   └── test_services.py                  # Health check script
│
├── 🌐 Frontend
│   ├── index.html                        # Web interface
│   └── app.js                            # Frontend JavaScript
│
├── ⚙️ n8n Workflow
│   └── speech_translation_workflow.json  # n8n workflow definition
│
└── 📁 Generated (after setup)
    ├── venv/                             # Python virtual environment
    ├── *.log                             # Service logs
    └── .n8n/                             # n8n data (in user home)
```

## 🏗️ System Components

### 1. Web Interface (Port 8000)
- **Files:** `index.html`, `app.js`
- **Purpose:** User-facing interface for recording/uploading audio
- **Features:**
  - Microphone recording with MediaRecorder API
  - File upload support
  - Language selection
  - Real-time status updates
  - Translation display
  - Save to file functionality

### 2. n8n Workflow Engine (Port 5678)
- **File:** `speech_translation_workflow.json`
- **Purpose:** Orchestrates the translation pipeline
- **Docker Image:** `n8nio/n8n`
- **Workflow Nodes:**
  1. **Webhook** - Receives audio from web interface
  2. **Extract Data** - Processes incoming request
  3. **Whisper Transcribe** - Sends to Whisper service
  4. **Process Transcription** - Handles Whisper response
  5. **Translation Needed?** - Checks if translation required
  6. **Translate Text** - Calls translation service
  7. **Format Translation** - Formats translated response
  8. **No Translation Needed** - Handles same-language case
  9. **Merge Results** - Combines branches
  10. **Respond to Webhook** - Returns result to web interface

### 3. Whisper Service (Port 9000)
- **File:** `whisper_service.py`
- **Purpose:** Audio transcription and language detection
- **Model:** OpenAI Whisper (base model by default)
- **Endpoints:**
  - `GET /health` - Health check
  - `POST /transcribe` - Transcribe audio
  - `GET /languages` - List supported languages
- **Features:**
  - Automatic language detection
  - High-quality transcription
  - Handles multiple audio formats
  - Temporary file management
  - No intermediate file storage in workflow

### 4. Translation Service (Port 9001)
- **File:** `translation_service.py`
- **Purpose:** Text translation between languages
- **Engine:** Argos Translate
- **Endpoints:**
  - `GET /health` - Health check
  - `POST /translate` - Translate text
  - `GET /languages` - List installed languages
- **Features:**
  - Offline translation
  - Multiple language pairs
  - Automatic intermediate translation (via English)
  - No cloud dependencies

## 🔄 Data Flow

```
┌─────────────────────────────────────────────────────────────┐
│ 1. User Interface (Browser)                                 │
│    - User records audio OR uploads file                     │
│    - Selects target language                                │
└───────────────────────┬─────────────────────────────────────┘
                        │ Audio + Target Language
                        ▼
┌─────────────────────────────────────────────────────────────┐
│ 2. n8n Webhook (Docker)                                     │
│    - Receives audio file (binary data)                      │
│    - Extracts target language parameter                     │
└───────────────────────┬─────────────────────────────────────┘
                        │ Binary Audio Data
                        ▼
┌─────────────────────────────────────────────────────────────┐
│ 3. Whisper Service (Python)                                 │
│    - Receives audio via HTTP                                │
│    - Processes in-memory (no file storage)                  │
│    - Transcribes to text                                    │
│    - Detects source language                                │
└───────────────────────┬─────────────────────────────────────┘
                        │ Transcribed Text + Detected Language
                        ▼
┌─────────────────────────────────────────────────────────────┐
│ 4. n8n Processing                                           │
│    - Checks if translation needed                           │
│    - (source language ≠ target language)                    │
└───────────────────────┬─────────────────────────────────────┘
                        │ If translation needed
                        ▼
┌─────────────────────────────────────────────────────────────┐
│ 5. Translation Service (Python)                             │
│    - Translates text to target language                     │
│    - Uses offline models                                    │
│    - Falls back to English intermediate if needed           │
└───────────────────────┬─────────────────────────────────────┘
                        │ Translated Text
                        ▼
┌─────────────────────────────────────────────────────────────┐
│ 6. n8n Response                                             │
│    - Formats response JSON                                  │
│    - Returns to webhook                                     │
└───────────────────────┬─────────────────────────────────────┘
                        │ JSON Response
                        ▼
┌─────────────────────────────────────────────────────────────┐
│ 7. User Interface                                           │
│    - Displays original transcription                        │
│    - Shows translated text                                  │
│    - Displays detected language                             │
│    - Enables save functionality                             │
└─────────────────────────────────────────────────────────────┘
```

## 🔐 Security & Privacy

### No Data Leaves Your Device
- **100% Local Processing:** All AI models run locally
- **No Cloud APIs:** No external service calls
- **No Internet Required:** After initial setup, works offline
- **No Telemetry:** No usage data collected or sent

### Data Handling
- **Audio Files:** Processed in memory, immediately deleted
- **Transcriptions:** Only stored in browser until cleared
- **Translations:** Only saved if user explicitly downloads
- **n8n Data:** Stored locally in `~/.n8n` directory

### Network Communication
- **Localhost Only:** All services communicate via localhost
- **No External Connections:** After setup, no internet needed
- **CORS Enabled:** Only for local development
- **No Authentication:** Suitable for local single-user use

## ⚡ Performance Characteristics

### Whisper Model Comparison

| Model  | Load Time | Process Time (30s audio) | Accuracy | RAM  |
|--------|-----------|--------------------------|----------|------|
| tiny   | 5s        | 3-5s                     | 85%      | 1GB  |
| base   | 8s        | 5-10s                    | 90%      | 2GB  |
| small  | 15s       | 10-20s                   | 93%      | 4GB  |
| medium | 30s       | 30-60s                   | 96%      | 8GB  |
| large  | 60s       | 60-120s                  | 98%      | 16GB |

*Note: Times are approximate and vary by hardware*

### Translation Speed
- **Direct Translation:** 1-2 seconds
- **Via English Intermediate:** 2-4 seconds
- **First Use:** 30-60 seconds (downloads model)

### Supported Hardware
- **Minimum:** 4GB RAM, 2 CPU cores, 5GB storage
- **Recommended:** 8GB RAM, 4 CPU cores, 10GB storage
- **Microsoft Surface:** All modern Surface devices supported
  - Surface Pro 7+
  - Surface Laptop 3+
  - Surface Book 3+
  - Surface Go 2+

## 🛠️ Customization Options

### Change Whisper Model
Edit `whisper_service.py` line 25:
```python
model = whisper.load_model("base")  # Change to: tiny, small, medium, large
```

### Add More Languages
Edit `translation_service.py` priority_translations list to add more language pairs.

### Adjust n8n Resources
Edit `start_system.bat/sh` Docker run command to add memory limits:
```bash
docker run -d --memory="4g" --cpus="2" ...
```

### Change Ports
- **Web Interface:** Edit `start_system.bat/sh` line with `http.server 8000`
- **n8n:** Edit Docker run command `-p 5678:5678`
- **Whisper:** Edit `whisper_service.py` line with `port=9000`
- **Translation:** Edit `translation_service.py` line with `port=9001`

### Customize Web Interface
- **Styling:** Edit `index.html` `<style>` section
- **Languages:** Edit `app.js` languageNames object
- **Webhook URL:** Edit `app.js` N8N_WEBHOOK_URL constant

## 📊 Technology Stack

### Frontend
- **HTML5** - Structure
- **CSS3** - Styling with gradients and animations
- **JavaScript (ES6+)** - Logic and API calls
- **MediaRecorder API** - Audio recording
- **Fetch API** - HTTP requests

### Backend Services
- **Python 3.8+** - Service implementation
- **Flask** - Web framework
- **Flask-CORS** - Cross-origin requests

### AI/ML
- **OpenAI Whisper** - Speech recognition
- **Argos Translate** - Neural machine translation
- **PyTorch** - ML framework for Whisper

### Orchestration
- **n8n** - Workflow automation
- **Docker** - Containerization
- **Docker Desktop** - Windows container runtime

### Audio Processing
- **FFmpeg** - Audio format conversion
- **ffmpeg-python** - Python FFmpeg bindings

## 🧪 Testing

### Manual Testing
1. Run `.\start_system.bat`
2. Wait for all services to start
3. Open http://localhost:8000
4. Test recording
5. Test file upload
6. Test different languages
7. Test save functionality

### Automated Health Check
```powershell
python test_services.py
```

This checks:
- All services are running
- All endpoints respond
- HTTP status codes are correct

### Service-Specific Testing

**Test Whisper Service:**
```powershell
curl http://localhost:9000/health
```

**Test Translation Service:**
```powershell
curl http://localhost:9001/health
```

**Test n8n:**
```powershell
curl http://localhost:5678
```

## 🔧 Maintenance

### Update Dependencies
```powershell
.\venv\Scripts\activate
pip install --upgrade -r requirements.txt
```

### Update n8n
```powershell
docker pull n8nio/n8n
.\stop_system.bat
.\start_system.bat
```

### Clear Logs
```powershell
del *.log
```

### Reset System
```powershell
.\stop_system.bat
docker rm n8n-speech-translation
rmdir /s venv
.\setup.bat
```

## 📈 Future Enhancements (Optional)

Potential improvements you could make:
1. **Real-time streaming** - Process audio as it's being recorded
2. **Multiple speakers** - Detect and separate different speakers
3. **Subtitle generation** - Output SRT/VTT files
4. **Video support** - Extract audio from video files
5. **Translation history** - Store past translations in local database
6. **Custom vocabulary** - Add domain-specific terms
7. **Batch processing** - Process multiple files at once
8. **Mobile app** - Create React Native or PWA version
9. **Better error handling** - More detailed error messages
10. **Performance monitoring** - Track processing times

## 📚 Additional Resources

### Documentation Links
- [OpenAI Whisper GitHub](https://github.com/openai/whisper)
- [n8n Documentation](https://docs.n8n.io/)
- [Argos Translate](https://github.com/argosopentech/argos-translate)
- [Flask Documentation](https://flask.palletsprojects.com/)
- [Docker Documentation](https://docs.docker.com/)

### Troubleshooting
- See `README.md` for common issues
- See `INSTALLATION_GUIDE.md` for setup problems
- Check service logs in terminal windows
- View Docker logs in Docker Desktop

## 💡 Tips & Best Practices

1. **Keep Docker Running:** Services need Docker to be active
2. **Close Unused Apps:** Free up RAM for better performance
3. **Use AC Power:** For best performance on Surface
4. **Clear Audio:** Better input = better transcription
5. **Shorter Clips:** Process 30-60 second clips for speed
6. **Regular Updates:** Keep Python and Docker updated
7. **Backup Workflows:** Export n8n workflows regularly
8. **Monitor Resources:** Check Task Manager if slow
9. **Test After Updates:** Verify system after any changes
10. **Read Logs:** Check logs when troubleshooting

## 🎓 Learning Resources

Want to understand the code better?

- **Python Flask:** Learn REST API development
- **JavaScript Async/Await:** Understand async operations
- **Docker Basics:** Learn containerization
- **n8n Workflows:** Explore workflow automation
- **Machine Learning:** Study Whisper and translation models

## ✅ System Health Indicators

### Everything is Working When:
- ✅ All 4 services show "running" in terminals
- ✅ Web interface loads without errors
- ✅ Recording button responds immediately
- ✅ File upload shows selected filename
- ✅ Processing takes reasonable time (10-60s)
- ✅ Translations appear in text area
- ✅ Save button becomes enabled
- ✅ No error messages in status indicator

### Something is Wrong When:
- ❌ Services fail to start
- ❌ Web interface shows connection error
- ❌ Recording doesn't work
- ❌ Processing takes > 2 minutes
- ❌ Translations don't appear
- ❌ Error messages in status
- ❌ Console shows 404 or 500 errors

## 🎉 Conclusion

This is a professional-grade, locally-hosted speech translation system that:
- Works completely offline (after setup)
- Respects your privacy (no cloud services)
- Uses state-of-the-art AI models
- Runs on Microsoft Surface hardware
- Provides a beautiful user interface
- Is easy to use and maintain

Enjoy your private speech translation system!
