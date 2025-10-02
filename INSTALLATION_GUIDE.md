# Complete Installation Guide for Microsoft Surface

This guide provides detailed step-by-step instructions for setting up the Speech Translation System on your Microsoft Surface.

## 📦 Part 1: Installing Prerequisites

### 1.1 Install Python

1. **Download Python:**
   - Go to https://www.python.org/downloads/
   - Download Python 3.11 or later (recommended: Python 3.11.x)

2. **Install Python:**
   - Run the installer
   - ⚠️ **IMPORTANT:** Check "Add Python to PATH" during installation
   - Choose "Install Now"
   - Wait for installation to complete
   - Click "Close"

3. **Verify Installation:**
   ```powershell
   python --version
   ```
   Should show: `Python 3.11.x` or similar

### 1.2 Install Docker Desktop

1. **Download Docker Desktop:**
   - Go to https://www.docker.com/products/docker-desktop/
   - Click "Download for Windows"

2. **Install Docker Desktop:**
   - Run the installer
   - Accept license agreement
   - Use recommended settings (WSL 2 backend)
   - Complete installation
   - Restart your Surface if prompted

3. **Start Docker Desktop:**
   - Launch Docker Desktop from Start Menu
   - Wait for Docker engine to start (whale icon in system tray)
   - Accept any first-time setup prompts

4. **Verify Installation:**
   ```powershell
   docker --version
   docker ps
   ```

### 1.3 Install FFmpeg

**Option A: Using Chocolatey (Recommended)**

1. **Install Chocolatey:**
   - Open PowerShell as Administrator
   - Run:
     ```powershell
     Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
     ```

2. **Install FFmpeg:**
   ```powershell
   choco install ffmpeg
   ```

3. **Verify Installation:**
   ```powershell
   ffmpeg -version
   ```

**Option B: Manual Installation**

1. **Download FFmpeg:**
   - Go to https://ffmpeg.org/download.html#build-windows
   - Click "Windows builds from gyan.dev"
   - Download "ffmpeg-release-essentials.zip"

2. **Extract FFmpeg:**
   - Extract the ZIP file to `C:\ffmpeg`
   - You should have: `C:\ffmpeg\bin\ffmpeg.exe`

3. **Add to PATH:**
   - Open "Edit system environment variables" from Start Menu
   - Click "Environment Variables"
   - Under "System variables", find "Path"
   - Click "Edit" → "New"
   - Add: `C:\ffmpeg\bin`
   - Click "OK" on all dialogs
   - Restart PowerShell

4. **Verify Installation:**
   ```powershell
   ffmpeg -version
   ```

## 📥 Part 2: Download and Setup Project

### 2.1 Download Project Files

1. **Create Project Directory:**
   ```powershell
   cd C:\Users\YourUsername\Documents
   mkdir SpeechTranslation
   cd SpeechTranslation
   ```

2. **Copy all project files** to this directory:
   - `setup.bat`
   - `start_system.bat`
   - `stop_system.bat`
   - `requirements.txt`
   - `whisper_service.py`
   - `translation_service.py`
   - `speech_translation_workflow.json`
   - `index.html`
   - `app.js`
   - `README.md`

### 2.2 Run Setup

1. **Open PowerShell** in the project directory:
   - Right-click folder → "Open in Terminal"
   - Or: `cd C:\Users\YourUsername\Documents\SpeechTranslation`

2. **Run Setup Script:**
   ```powershell
   .\setup.bat
   ```

3. **Wait for Setup to Complete:**
   - Python virtual environment will be created
   - All dependencies will be installed
   - This may take 10-15 minutes
   - You'll see progress messages

4. **Setup Complete!**
   - You should see "Setup Complete!" message
   - Press any key to continue

## 🚀 Part 3: First-Time System Start

### 3.1 Start All Services

1. **Ensure Docker Desktop is Running:**
   - Look for Docker whale icon in system tray
   - It should say "Docker Desktop is running"

2. **Start the System:**
   ```powershell
   .\start_system.bat
   ```

3. **Wait for Services:**
   - Multiple command windows will open (don't close them)
   - Wait about 30-60 seconds for all services to start
   - You'll see:
     - "Whisper Service" window (loading model first time)
     - "Translation Service" window (downloading packages)
     - "Web Interface" window
   - Browser will open automatically

### 3.2 Configure n8n (First Time Only)

1. **n8n Dashboard Opens:**
   - Browser opens to http://localhost:5678
   - You'll see n8n welcome screen

2. **Create Account:**
   - Enter email (can be fake, stored locally)
   - Create password
   - Click "Get Started"

3. **Import Workflow:**
   - Click "Workflows" in left sidebar
   - Click "Add Workflow" → "Import from File"
   - Browse to your project folder
   - Select `speech_translation_workflow.json`
   - Click "Import"

4. **Activate Workflow:**
   - Workflow opens automatically
   - You'll see connected nodes
   - Click the toggle switch at top-right (should turn green)
   - Workflow is now active!

### 3.3 Test the System

1. **Open Web Interface:**
   - Go to http://localhost:8000
   - You should see "Speech Translation" page

2. **Test Recording:**
   - Select target language (e.g., "Spanish")
   - Click "Start Recording"
   - Allow microphone access when prompted
   - Speak in English: "Hello, how are you?"
   - Click "Stop Recording"
   - Wait for processing (10-30 seconds)
   - See translation appear!

3. **Test File Upload:**
   - Select target language
   - Click "Upload Audio File"
   - Select an audio file (MP3, WAV, etc.)
   - Wait for processing
   - See translation appear!

## ✅ Part 4: Verification Checklist

After setup, verify everything is working:

- [ ] Python installed and in PATH
- [ ] Docker Desktop running
- [ ] FFmpeg installed and in PATH
- [ ] Virtual environment created (`venv` folder exists)
- [ ] All dependencies installed (no errors in setup)
- [ ] n8n running at http://localhost:5678
- [ ] Whisper service running at http://localhost:9000
- [ ] Translation service running at http://localhost:9001
- [ ] Web interface accessible at http://localhost:8000
- [ ] Workflow imported and activated in n8n
- [ ] Microphone recording works
- [ ] File upload works
- [ ] Translations appear correctly

## 🔄 Part 5: Daily Usage

### Starting the System

1. **Ensure Docker Desktop is running**
2. **Open PowerShell in project folder**
3. **Run:** `.\start_system.bat`
4. **Wait 30 seconds**
5. **Open browser to:** http://localhost:8000

### Using the System

1. **Select target language** from dropdown
2. **Record or upload audio**
3. **View translation results**
4. **Save translation** to file if needed
5. **Click "Clear"** to start over

### Stopping the System

1. **Close browser**
2. **Open PowerShell in project folder**
3. **Run:** `.\stop_system.bat`
4. **Wait for services to stop**

## 🆘 Common Setup Issues

### Issue: "Python is not recognized"

**Solution:**
- Reinstall Python with "Add to PATH" checked
- Or manually add Python to PATH:
  1. Find Python location (usually `C:\Users\YourName\AppData\Local\Programs\Python\Python311`)
  2. Add to system PATH environment variable

### Issue: "Docker is not running"

**Solution:**
- Start Docker Desktop from Start Menu
- Wait for it to fully start (whale icon in tray)
- Try running start script again

### Issue: "FFmpeg is not recognized"

**Solution:**
- Verify FFmpeg is installed
- Check PATH includes FFmpeg bin folder
- Restart PowerShell after adding to PATH

### Issue: Setup fails during pip install

**Solution:**
- Ensure stable internet connection
- Try running setup again
- If specific package fails, try:
  ```powershell
  .\venv\Scripts\activate
  pip install --upgrade pip
  pip install -r requirements.txt
  ```

### Issue: Whisper takes very long to start

**Solution:**
- First run downloads AI model (~150MB)
- Be patient, it's normal
- Subsequent starts are much faster
- Check internet connection for first download

### Issue: n8n asks for activation key

**Solution:**
- n8n is free for local use
- Click "Continue without activation"
- Or create free n8n.io account (optional)

### Issue: Workflow not responding

**Solution:**
- Check workflow is activated (green toggle)
- Verify webhook URL in browser console
- Restart n8n: 
  ```powershell
  docker restart n8n-speech-translation
  ```

### Issue: Translation service fails

**Solution:**
- First run downloads translation packages
- Wait 2-3 minutes for initial download
- Check "Translation Service" window for errors
- Some language pairs may take longer

### Issue: Poor transcription quality

**Solution:**
- Use clear audio with minimal background noise
- Speak clearly and at moderate pace
- Ensure good microphone quality
- Consider upgrading to larger Whisper model

## 📞 Need More Help?

If you're still having issues:

1. Check the main README.md troubleshooting section
2. Look at service logs in the terminal windows
3. Check Docker Desktop container logs
4. Verify all prerequisites are correctly installed
5. Try stopping and restarting the system

## 🎉 Congratulations!

You now have a fully functional local speech translation system on your Microsoft Surface!

The system is:
- ✅ Completely private and secure
- ✅ Works offline (after initial setup)
- ✅ No API keys or subscriptions needed
- ✅ Professional-grade AI translation
- ✅ Easy to use web interface

**Enjoy your new speech translation system!**
