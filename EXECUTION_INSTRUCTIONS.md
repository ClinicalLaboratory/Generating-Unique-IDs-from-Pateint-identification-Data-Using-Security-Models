# Complete Execution Instructions - Speech Translation System

## 🎯 Overview

This document provides complete, step-by-step instructions for deploying and executing the Speech Translation System on your Microsoft Surface.

---

## 📦 Part 1: Prerequisites Installation

### 1.1 Install Python

1. **Download Python 3.11:**
   - Visit: https://www.python.org/downloads/
   - Click "Download Python 3.11.x"

2. **Run the installer:**
   - ✅ **CHECK:** "Add Python to PATH" (CRITICAL!)
   - ✅ **CHECK:** "Install pip"
   - Click "Install Now"
   - Wait for completion
   - Click "Close"

3. **Verify installation:**
   ```powershell
   python --version
   ```
   Expected output: `Python 3.11.x`

---

### 1.2 Install Docker Desktop

1. **Download Docker Desktop:**
   - Visit: https://www.docker.com/products/docker-desktop/
   - Click "Download for Windows"

2. **Run the installer:**
   - Accept license
   - Use WSL 2 (recommended settings)
   - Complete installation
   - **Restart your Surface**

3. **Start Docker Desktop:**
   - Launch from Start Menu
   - Wait for "Docker Desktop is running"
   - Sign in (optional) or skip

4. **Verify installation:**
   ```powershell
   docker --version
   docker ps
   ```

---

### 1.3 Install FFmpeg

**Method A: Using Chocolatey (Recommended)**

1. **Install Chocolatey package manager:**
   - Open PowerShell as **Administrator**
   - Run:
   ```powershell
   Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
   ```

2. **Install FFmpeg:**
   ```powershell
   choco install ffmpeg -y
   ```

3. **Close and reopen PowerShell**

**Method B: Manual Installation**

1. **Download FFmpeg:**
   - Visit: https://ffmpeg.org/download.html#build-windows
   - Click "Windows builds from gyan.dev"
   - Download "ffmpeg-release-essentials.zip"

2. **Extract and install:**
   - Extract to `C:\ffmpeg`
   - Add `C:\ffmpeg\bin` to system PATH:
     - Search "Environment Variables" in Start Menu
     - Click "Environment Variables"
     - Under "System variables", select "Path"
     - Click "Edit" → "New"
     - Add: `C:\ffmpeg\bin`
     - Click "OK" on all dialogs
   - **Restart PowerShell**

3. **Verify installation:**
   ```powershell
   ffmpeg -version
   ```

---

## 📁 Part 2: Project Setup

### 2.1 Organize Project Files

1. **Create project directory:**
   ```powershell
   cd C:\Users\$env:USERNAME\Documents
   mkdir SpeechTranslation
   cd SpeechTranslation
   ```

2. **Copy all project files to this folder:**
   - whisper_service.py
   - translation_service.py
   - speech_translation_workflow.json
   - index.html
   - app.js
   - requirements.txt
   - setup.bat
   - start_system.bat
   - stop_system.bat
   - test_services.py
   - All .md documentation files

3. **Verify files:**
   ```powershell
   dir
   ```
   Should show all 15+ files

---

### 2.2 Run Initial Setup

1. **Open PowerShell in project folder:**
   - Right-click folder in File Explorer
   - Select "Open in Terminal"

2. **Run setup script:**
   ```powershell
   .\setup.bat
   ```

3. **Wait for completion:**
   - Creates virtual environment (1-2 minutes)
   - Installs Python packages (8-12 minutes)
   - Downloads Whisper model (first run only)
   - Shows "Setup Complete!" when done

4. **Verify setup:**
   - Check for `venv` folder in project directory
   - Should be ~500MB in size

---

## 🚀 Part 3: First Execution

### 3.1 Start the System

1. **Ensure Docker Desktop is running:**
   - Check system tray for Docker whale icon
   - Status should be "Docker Desktop is running"

2. **Start all services:**
   ```powershell
   .\start_system.bat
   ```

3. **Observe startup sequence:**
   - Main window shows progress
   - New windows open for each service:
     - **Whisper Service** (loading AI model)
     - **Translation Service** (loading packages)
     - **Web Interface** (starting server)
   - Browser opens automatically

4. **Wait for services (30-60 seconds):**
   - First run: 60-90 seconds (downloads models)
   - Subsequent runs: 30-45 seconds

---

### 3.2 Configure n8n (FIRST TIME ONLY)

1. **n8n opens at http://localhost:5678:**
   - Create account screen appears

2. **Create local account:**
   - **Email:** anything@example.com (fake OK, stored locally)
   - **Password:** Choose any password
   - Click "Get Started"
   - Skip any activation prompts

3. **Import workflow:**
   - Click **"Workflows"** in left sidebar
   - Click **"Add Workflow"**
   - Select **"Import from File"**
   - Browse to: `C:\Users\...\SpeechTranslation\speech_translation_workflow.json`
   - Click **"Import"**

4. **Activate workflow:**
   - Workflow opens showing connected nodes
   - Click **toggle switch** at top-right corner
   - Switch turns **GREEN** = workflow is active
   - Webhook is now listening

5. **Verify activation:**
   - Green checkmark appears on nodes
   - Status shows "Active"
   - Workflow is ready to receive requests

---

### 3.3 Use the Web Interface

1. **Open web interface:**
   - Go to: http://localhost:8000
   - Should see "Speech Translation" page
   - Status: "Ready! Select a target language..."

2. **Test microphone recording:**

   **Step 1:** Select language
   - Choose target language from dropdown (e.g., "Spanish")

   **Step 2:** Start recording
   - Click "Start Recording"
   - Browser asks for microphone permission
   - Click "Allow"

   **Step 3:** Speak
   - Say in English: "Hello, how are you today?"
   - Speak clearly for 5-10 seconds

   **Step 4:** Stop recording
   - Click "Stop Recording"
   - Status: "Processing audio..."

   **Step 5:** View results
   - Wait 10-30 seconds
   - Original transcription appears
   - Detected language shown (e.g., "English")
   - Translation appears in Spanish
   - Success message shown

3. **Test file upload:**

   **Step 1:** Prepare audio file
   - Use any audio file (MP3, WAV, M4A, etc.)
   - Preferably with speech in it

   **Step 2:** Select language
   - Choose target language

   **Step 3:** Upload
   - Click "Upload Audio File"
   - Select your audio file
   - Status: "Processing audio..."

   **Step 4:** View results
   - Wait 10-60 seconds (depends on file length)
   - Results appear as with recording

4. **Save translation:**
   - Click "Save as Text File"
   - File downloads automatically
   - Named: `translation_es_2025-10-02...txt`
   - Contains original and translated text

5. **Clear and repeat:**
   - Click "Clear" to reset
   - Ready for next translation

---

## 🔍 Part 4: Verification & Testing

### 4.1 Service Health Check

**Run automated test:**
```powershell
python test_services.py
```

**Expected output:**
```
========================================
Speech Translation System Health Check
========================================

Testing Web Interface...
✓ Web Interface is running and healthy

Testing n8n Dashboard...
✓ n8n Dashboard is running and healthy

Testing Whisper Service...
✓ Whisper Service is running and healthy

Testing Translation Service...
✓ Translation Service is running and healthy

========================================
Summary
========================================
✓ All services are running correctly!

You can now use the system at:
  http://localhost:8000
```

---

### 4.2 Manual Service Verification

**Check each service individually:**

1. **Web Interface:**
   - Visit: http://localhost:8000
   - Should load page with UI

2. **n8n Dashboard:**
   - Visit: http://localhost:5678
   - Should show n8n interface

3. **Whisper API:**
   - Visit: http://localhost:9000/health
   - Should show: `{"status":"healthy","service":"whisper-local","model":"base"}`

4. **Translation API:**
   - Visit: http://localhost:9001/health
   - Should show: `{"status":"healthy","service":"translation-local"}`

---

### 4.3 End-to-End Test Scenarios

**Test 1: English → Spanish**
- Input: "The weather is beautiful today"
- Expected: "El clima es hermoso hoy"

**Test 2: English → French**
- Input: "Thank you very much"
- Expected: "Merci beaucoup"

**Test 3: English → German**
- Input: "Good morning, how can I help you?"
- Expected: "Guten Morgen, wie kann ich Ihnen helfen?"

**Test 4: Multi-sentence**
- Input: "Hello. My name is John. I am learning Spanish."
- Should translate complete text

**Test 5: Audio file**
- Upload any speech audio file
- Should transcribe and translate correctly

---

## 🛑 Part 5: Stopping the System

### 5.1 Proper Shutdown

1. **Close browser tabs** (optional)

2. **Run stop script:**
   ```powershell
   .\stop_system.bat
   ```

3. **Wait for shutdown:**
   - n8n container stops
   - Whisper service stops
   - Translation service stops
   - Web server stops
   - All terminal windows close

4. **Verify cleanup:**
   ```powershell
   docker ps
   ```
   Should show no `n8n-speech-translation` container

---

### 5.2 Manual Cleanup (if needed)

If stop script fails:

```powershell
# Stop Docker container
docker stop n8n-speech-translation
docker rm n8n-speech-translation

# Kill Python processes (if stuck)
taskkill /F /IM python.exe
```

---

## 🔄 Part 6: Daily Usage Workflow

### Morning Routine

1. **Start Docker Desktop**
   - Open from Start Menu
   - Wait for "running" status

2. **Navigate to project:**
   ```powershell
   cd C:\Users\$env:USERNAME\Documents\SpeechTranslation
   ```

3. **Start system:**
   ```powershell
   .\start_system.bat
   ```

4. **Wait 30 seconds**

5. **Open browser:**
   - Go to http://localhost:8000
   - Start translating!

### Evening Routine

1. **Stop system:**
   ```powershell
   .\stop_system.bat
   ```

2. **Close Docker Desktop** (optional)

---

## 🐛 Part 7: Troubleshooting

### Issue: Services won't start

**Diagnosis:**
```powershell
docker ps
python --version
ffmpeg -version
```

**Solutions:**
1. Restart Docker Desktop
2. Check if ports are in use
3. Run `.\stop_system.bat` then retry
4. Reboot Surface if needed

---

### Issue: Workflow not responding

**Diagnosis:**
- Check n8n at http://localhost:5678
- Verify workflow is active (green toggle)
- Check browser console (F12) for errors

**Solutions:**
1. Restart n8n:
   ```powershell
   docker restart n8n-speech-translation
   ```
2. Re-activate workflow in n8n
3. Check webhook URL in app.js

---

### Issue: Poor transcription quality

**Diagnosis:**
- Check audio quality
- Verify microphone is working
- Test with known good audio file

**Solutions:**
1. Use clearer audio
2. Reduce background noise
3. Upgrade Whisper model:
   - Edit `whisper_service.py`
   - Change `"base"` to `"medium"` or `"large"`
   - Requires more RAM

---

### Issue: Translation fails

**Diagnosis:**
- Check Translation Service window for errors
- First run downloads packages (2-3 minutes)
- Some language pairs need intermediate translation

**Solutions:**
1. Wait for package downloads (first run)
2. Check logs in Translation Service window
3. Restart translation service

---

### Issue: Microphone not working

**Solutions:**
1. Grant microphone permission in browser
2. Check Windows privacy settings:
   - Settings → Privacy → Microphone
   - Enable for browsers
3. Test microphone in other apps
4. Try different browser (Chrome/Edge)

---

## 📊 Part 8: Performance Optimization

### For Faster Processing

1. **Upgrade Whisper model (if needed):**
   - Edit `whisper_service.py` line 25
   - Options: `tiny` (fastest) to `large` (best quality)

2. **Allocate more Docker resources:**
   - Docker Desktop → Settings → Resources
   - Increase Memory to 4-8GB
   - Increase CPUs to 2-4

3. **Close background apps:**
   - Free up RAM for AI processing
   - Close unnecessary browser tabs

4. **Use AC power:**
   - Performance mode works best plugged in

---

## 🎓 Part 9: Advanced Usage

### Access from Other Devices

1. **Find Surface IP address:**
   ```powershell
   ipconfig
   ```
   Look for IPv4 Address (e.g., 192.168.1.100)

2. **On other device:**
   - Open browser
   - Go to: `http://192.168.1.100:8000`
   - Must be on same WiFi network

### Batch Processing

Process multiple files:
1. Upload first file
2. Save translation
3. Click "Clear"
4. Upload next file
5. Repeat

### Export Workflow

Backup your n8n workflow:
1. Open n8n dashboard
2. Open workflow
3. Click "..." menu
4. Select "Download"
5. Save JSON file

---

## ✅ Part 10: Success Criteria

### System is Working Correctly When:

- ✅ All 4 services start without errors
- ✅ Web interface loads instantly
- ✅ Microphone recording works smoothly
- ✅ File uploads are accepted
- ✅ Transcriptions appear within 30 seconds
- ✅ Translations are accurate
- ✅ Save functionality works
- ✅ No error messages appear
- ✅ System is stable over time
- ✅ Stop script cleanly shuts down

---

## 🎉 Conclusion

You now have complete instructions for deploying and executing the Speech Translation System!

### Quick Reference

**Start System:**
```powershell
cd C:\Users\$env:USERNAME\Documents\SpeechTranslation
.\start_system.bat
```

**Use System:**
- Open: http://localhost:8000

**Stop System:**
```powershell
.\stop_system.bat
```

**Check Health:**
```powershell
python test_services.py
```

---

## 📞 Support Resources

- **Quick Start:** See `QUICK_START.md`
- **Installation Help:** See `INSTALLATION_GUIDE.md`
- **Technical Details:** See `PROJECT_OVERVIEW.md`
- **Troubleshooting:** See `README.md`
- **Deployment Checklist:** See `DEPLOYMENT_CHECKLIST.md`

---

**System Version:** 1.0  
**Last Updated:** October 2, 2025  
**Compatible With:** Microsoft Surface (All modern models)  
**Operating System:** Windows 10/11  

**Enjoy your private, professional-grade speech translation system!** 🚀
