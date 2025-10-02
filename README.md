# Speech Translation System - Complete Setup Guide

A fully local, privacy-focused real-time speech translation system powered by OpenAI Whisper, running on Microsoft Surface through Docker Desktop.

## 🎯 Features

- **100% Local & Private** - No cloud services, all processing happens on your device
- **Real-time Audio Recording** - Record directly from your microphone
- **File Upload Support** - Upload pre-recorded audio files
- **Automatic Language Detection** - Whisper automatically detects the source language
- **Multi-language Translation** - Translate to 20+ languages
- **Beautiful Web Interface** - Modern, responsive UI
- **Save Translations** - Export translated text to files
- **Microsoft Surface Optimized** - Fully compatible with Surface hardware

## 📋 Prerequisites

Before starting, ensure you have:

1. **Windows 10/11** (for Microsoft Surface)
2. **Python 3.8 or later** - [Download here](https://www.python.org/downloads/)
3. **Docker Desktop** - [Download here](https://www.docker.com/products/docker-desktop/)
4. **FFmpeg** - [Download here](https://ffmpeg.org/download.html)
   - Or install via Chocolatey: `choco install ffmpeg`
5. **At least 4GB free RAM** (8GB recommended for better performance)
6. **At least 5GB free disk space**

## 🚀 Quick Start

### Step 1: Initial Setup

1. **Clone or download this repository** to your Microsoft Surface

2. **Open PowerShell as Administrator** in the project directory

3. **Run the setup script:**
   ```powershell
   .\setup.bat
   ```

   This will:
   - Check all prerequisites
   - Create a Python virtual environment
   - Install all required dependencies (Whisper, Flask, translation libraries)
   - Download Whisper AI model (first run only)

   **Note:** The first setup may take 10-15 minutes depending on your internet connection.

### Step 2: Start the System

1. **Make sure Docker Desktop is running**

2. **Run the start script:**
   ```powershell
   .\start_system.bat
   ```

   This will start:
   - n8n workflow automation (port 5678)
   - Whisper transcription service (port 9000)
   - Translation service (port 9001)
   - Web interface (port 8000)

3. **Wait for all services to start** (about 30 seconds)

### Step 3: Configure n8n Workflow (First Time Only)

1. **Open n8n dashboard** at http://localhost:5678

2. **Create an account** (stored locally, no internet required)

3. **Import the workflow:**
   - Click on "Workflows" → "Import from File"
   - Select `speech_translation_workflow.json` from the project folder
   - Click "Import"

4. **Activate the workflow:**
   - Open the imported "Speech Translation Workflow"
   - Click the toggle to activate it (it should turn green)
   - The webhook will be available at: http://localhost:5678/webhook/speech-translate

### Step 4: Use the System

1. **Open the web interface** at http://localhost:8000

2. **Select your target language** from the dropdown

3. **Provide audio** in one of two ways:
   - **Record:** Click "Start Recording", speak, then click "Stop Recording"
   - **Upload:** Click "Upload Audio File" and select an audio file

4. **View results:**
   - Original transcribed text will appear with detected language
   - Translated text will be shown in the text area

5. **Save translation:**
   - Click "Save as Text File" to download the translation
   - The file includes both original and translated text

## 🔧 Supported Audio Formats

- WAV
- MP3
- MP4
- M4A
- OGG
- WebM
- FLAC

## 🌍 Supported Languages

The system supports translation to/from these languages:

- English (en)
- Spanish (es)
- French (fr)
- German (de)
- Italian (it)
- Portuguese (pt)
- Dutch (nl)
- Russian (ru)
- Chinese (zh)
- Japanese (ja)
- Korean (ko)
- Arabic (ar)
- Hindi (hi)
- Turkish (tr)
- Polish (pl)
- Ukrainian (uk)
- Vietnamese (vi)
- Thai (th)
- Indonesian (id)
- Malay (ms)

## 🛠️ Troubleshooting

### Services Not Starting

**Problem:** Services fail to start

**Solutions:**
1. Ensure Docker Desktop is running
2. Check if ports 5678, 8000, 9000, 9001 are not in use
3. Restart Docker Desktop
4. Run `.\stop_system.bat` then `.\start_system.bat`

### Whisper Model Loading Issues

**Problem:** "Loading Whisper model..." takes too long

**Solutions:**
1. First run downloads the model (1-2 minutes)
2. Ensure stable internet connection for first download
3. Check available disk space (need ~1GB for base model)
4. Model is cached after first download

### Microphone Not Working

**Problem:** Browser can't access microphone

**Solutions:**
1. Grant microphone permissions in browser settings
2. Check Windows privacy settings for microphone access
3. Try a different browser (Chrome/Edge recommended)
4. Ensure no other application is using the microphone

### Translation Not Working

**Problem:** Transcription works but translation fails

**Solutions:**
1. Wait for translation packages to download (first run only)
2. Check translation service logs in the terminal window
3. Some language pairs may not have direct translation:
   - System will automatically translate through English as intermediate
4. Restart translation service if needed

### n8n Workflow Not Responding

**Problem:** Web interface shows connection error

**Solutions:**
1. Verify n8n is running at http://localhost:5678
2. Check that workflow is activated (green toggle)
3. Verify webhook URL is correct
4. Check Docker Desktop container logs
5. Restart n8n container:
   ```powershell
   docker restart n8n-speech-translation
   ```

### Audio Quality Issues

**Problem:** Poor transcription accuracy

**Solutions:**
1. Use clear audio with minimal background noise
2. Ensure proper microphone positioning
3. Upgrade to larger Whisper model for better accuracy:
   - Edit `whisper_service.py`
   - Change `model = whisper.load_model("base")` to `"medium"` or `"large"`
   - Note: Larger models require more RAM and processing time

### Docker Issues on Surface

**Problem:** Docker performance issues

**Solutions:**
1. Allocate more resources to Docker Desktop:
   - Open Docker Desktop → Settings → Resources
   - Increase Memory to at least 4GB
   - Increase CPUs to at least 2
2. Enable WSL2 backend for better performance
3. Close unnecessary applications to free up resources

## 📊 System Architecture

```
┌─────────────────┐
│  Web Interface  │ (localhost:8000)
│   (Browser)     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   n8n Workflow  │ (localhost:5678)
│   (Docker)      │
└────┬───────┬────┘
     │       │
     ▼       ▼
┌─────────┐ ┌──────────────┐
│ Whisper │ │ Translation  │
│ Service │ │   Service    │
│  :9000  │ │    :9001     │
└─────────┘ └──────────────┘
```

## 🔄 Workflow Process

1. **Audio Input** → User records or uploads audio via web interface
2. **Webhook Trigger** → n8n receives audio and target language
3. **Transcription** → Whisper transcribes audio and detects source language
4. **Translation** → If needed, text is translated to target language
5. **Response** → Translated text returned to web interface
6. **Display** → Results shown with metadata and save option

## ⚙️ Configuration

### Change Whisper Model

Edit `whisper_service.py` line 25:

```python
# Options: tiny, base, small, medium, large
model = whisper.load_model("base")
```

**Model Comparison:**

| Model  | Size | Speed | Accuracy | RAM Required |
|--------|------|-------|----------|--------------|
| tiny   | 75MB | Fast  | Good     | 1GB          |
| base   | 150MB| Fast  | Better   | 2GB          |
| small  | 500MB| Medium| Great    | 4GB          |
| medium | 1.5GB| Slow  | Excellent| 8GB          |
| large  | 3GB  | Very Slow | Best | 16GB        |

### Change Webhook URL

If you need to change the n8n webhook URL:

1. Edit `app.js` line 2:
   ```javascript
   const N8N_WEBHOOK_URL = 'http://localhost:5678/webhook/speech-translate';
   ```

2. Update the webhook path in n8n workflow if needed

### Add More Languages

To add more translation language pairs:

Edit `translation_service.py` in the `priority_translations` list (line 35)

## 🛑 Stopping the System

To stop all services:

```powershell
.\stop_system.bat
```

This will cleanly shut down:
- n8n container
- Whisper service
- Translation service
- Web server

## 🔐 Security & Privacy

- **100% Local Processing** - No data leaves your device
- **No Cloud Services** - All AI processing happens locally
- **No API Keys Required** - Completely self-contained
- **Private by Default** - No telemetry or tracking
- **Data Control** - All audio and text stays on your Surface

## 📈 Performance Tips

1. **Close Background Apps** - Free up RAM for better performance
2. **Use Wired Internet** - For faster initial setup downloads
3. **Plug In Power** - Use AC adapter for best performance
4. **Keep Docker Updated** - Latest Docker Desktop has better performance
5. **Clear Old Containers** - Periodically clean up Docker to free space
6. **Use Smaller Model** - If speed is priority, use "tiny" or "base" model
7. **Record Shorter Clips** - Process 30-60 second clips for faster results

## 🐛 Debug Mode

To run services in debug mode for troubleshooting:

1. Open separate terminals for each service
2. Activate virtual environment:
   ```powershell
   .\venv\Scripts\activate
   ```
3. Run services individually:
   ```powershell
   python whisper_service.py
   python translation_service.py
   ```

Check console output for detailed error messages.

## 📝 Logs

Service logs are available in:
- **Whisper Service:** Check terminal window or `whisper_service.log`
- **Translation Service:** Check terminal window or `translation_service.log`
- **n8n:** View in Docker Desktop logs
- **Web Server:** Check terminal window

## 🆘 Getting Help

If you encounter issues:

1. Check this README troubleshooting section
2. Verify all prerequisites are installed
3. Check service logs for error messages
4. Ensure Docker Desktop has enough resources
5. Try stopping and restarting the system

## 📜 License

This project uses open-source components:
- OpenAI Whisper (MIT License)
- n8n (Sustainable Use License)
- Argos Translate (MIT License)
- Flask (BSD License)

## 🎉 System Ready!

Your local speech translation system is now fully configured and ready to use!

**Quick Access URLs:**
- 🌐 Web Interface: http://localhost:8000
- ⚙️ n8n Dashboard: http://localhost:5678
- 🎤 Whisper API: http://localhost:9000/health
- 🌍 Translation API: http://localhost:9001/health

Enjoy private, local speech translation on your Microsoft Surface!
