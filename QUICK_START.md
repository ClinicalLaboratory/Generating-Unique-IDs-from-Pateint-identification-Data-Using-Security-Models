# Quick Start Guide - Speech Translation System

## 🚀 Get Started in 3 Steps

### Prerequisites Check ✓
Before starting, make sure you have:
- [ ] Windows 10/11 (Microsoft Surface)
- [ ] Python 3.8+ installed
- [ ] Docker Desktop installed and running
- [ ] FFmpeg installed
- [ ] At least 4GB free RAM

**Don't have these?** → See `INSTALLATION_GUIDE.md`

---

## Step 1: Setup (One Time Only)

Open PowerShell in the project folder and run:

```powershell
.\setup.bat
```

⏱️ Takes about 10-15 minutes on first run

---

## Step 2: Start the System

```powershell
.\start_system.bat
```

⏱️ Wait 30-60 seconds for all services to start

Your browser will automatically open!

---

## Step 3: Import n8n Workflow (First Time Only)

1. Browser opens n8n at http://localhost:5678
2. Create a local account (email/password)
3. Click **Workflows** → **Import from File**
4. Select `speech_translation_workflow.json`
5. Click the **toggle switch** to activate (turns green)

✅ Done! The workflow is now running.

---

## 🎤 Use the System

The web interface opens automatically at http://localhost:8000

### Record Audio:
1. Select target language (e.g., "Spanish")
2. Click "Start Recording"
3. Speak into your microphone
4. Click "Stop Recording"
5. Wait for translation (10-30 seconds)

### Upload Audio File:
1. Select target language
2. Click "Upload Audio File"
3. Choose an audio file (MP3, WAV, etc.)
4. Wait for translation

### Save Translation:
- Click "Save as Text File"
- File downloads with original and translated text

---

## 🛑 Stop the System

```powershell
.\stop_system.bat
```

---

## 🔗 Service URLs

Once started, access:

| Service | URL |
|---------|-----|
| **Web Interface** | http://localhost:8000 |
| **n8n Dashboard** | http://localhost:5678 |
| Whisper API | http://localhost:9000 |
| Translation API | http://localhost:9001 |

---

## ⚠️ Common Issues

### "Python is not recognized"
→ Install Python with "Add to PATH" option

### "Docker is not running"
→ Start Docker Desktop from Start Menu

### Services won't start
→ Make sure Docker Desktop is fully started (check system tray icon)

### Microphone not working
→ Grant browser microphone permissions when prompted

### Translation is slow
→ First run downloads models, subsequent runs are faster

---

## 🆘 Need Help?

- **Setup Problems:** See `INSTALLATION_GUIDE.md`
- **Usage Help:** See `README.md`
- **Technical Details:** See `PROJECT_OVERVIEW.md`

---

## ✅ Daily Workflow

After initial setup, your daily workflow is:

1. **Start Docker Desktop**
2. **Run:** `.\start_system.bat`
3. **Use at:** http://localhost:8000
4. **Stop:** `.\stop_system.bat`

That's it! 🎉

---

## 🎓 What This System Does

- ✅ **Transcribes** audio to text using Whisper AI
- ✅ **Detects** the source language automatically
- ✅ **Translates** to your selected target language
- ✅ **Works offline** after initial setup
- ✅ **100% private** - no cloud services
- ✅ **Professional quality** - same AI as ChatGPT voice

---

## 🎯 Supported Features

- 🎤 **Live microphone recording**
- 📁 **Audio file upload** (MP3, WAV, M4A, OGG, WebM, FLAC)
- 🌍 **20+ languages** supported
- 📝 **Save translations** to text files
- 🔒 **Completely private** - no data leaves your Surface
- ⚡ **Fast processing** - 10-30 seconds typical
- 💻 **Beautiful UI** - modern, responsive design

---

## 📱 Access from Other Devices (Optional)

Want to use from phone/tablet on same WiFi?

1. Find your Surface's IP address:
   ```powershell
   ipconfig
   ```
   Look for "IPv4 Address" (e.g., 192.168.1.100)

2. On other device, open browser to:
   ```
   http://192.168.1.100:8000
   ```

⚠️ **Note:** Both devices must be on same WiFi network

---

## 🎉 You're All Set!

Enjoy your private, professional-grade speech translation system!

**Questions?** Check the detailed documentation files included in the project.
