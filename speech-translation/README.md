# 🎤 Real-time Speech Translation System

A complete local speech translation system using Whisper AI, Argos Translate, and n8n workflows. Designed for Microsoft Surface and other modern devices with full Docker deployment support.

## ✨ Features

- **🎯 Real-time Speech Translation**: Record audio or upload files for instant translation
- **🌍 Multi-language Support**: 40+ languages supported with automatic detection
- **🔒 100% Local Processing**: No cloud services, complete privacy
- **📱 Surface-Optimized**: Touch-friendly interface optimized for Microsoft Surface devices
- **🐳 Docker Deployment**: One-command deployment with Docker Compose
- **🎨 Modern UI**: Responsive, dark-themed interface with accessibility features
- **💾 Save Translations**: Export translated text to files
- **🔄 n8n Workflow**: Extensible workflow engine for custom processing

## 🚀 Quick Start

### Prerequisites

- **Docker Desktop** installed and running
- **Microsoft Surface** or any modern computer with microphone
- **Web browser** with microphone support (Chrome, Firefox, Edge)

### 1. Clone and Start

```bash
# Clone the repository
git clone <repository-url>
cd speech-translation

# Start the entire system
./start.sh
```

### 2. Import n8n Workflow

1. Open http://localhost:5678
2. Click the menu (≡) → **Import from file**
3. Select `n8n/workflow_speech_translate.json`
4. Click **Import** and **Activate** the workflow

### 3. Use the Web Interface

1. Open http://localhost:8002
2. Select target language
3. **Record**: Click "Start Recording" and speak
4. **Upload**: Choose an audio file and click "Upload & Translate"
5. **Save**: Click "Save Translated Text" to download results

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Web Interface │────│   n8n Workflow  │────│ Whisper Service │
│   (Port 8002)   │    │   (Port 5678)   │    │   (Port 8001)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │              ┌─────────────────┐              │
         └──────────────│ Docker Network  │──────────────┘
                        └─────────────────┘
```

### Components

1. **Web Interface** (Nginx): Modern, responsive UI for recording and uploading audio
2. **n8n Workflow Engine**: Orchestrates the translation pipeline
3. **Whisper Service** (FastAPI): Handles speech recognition and translation
4. **Docker Network**: Secure internal communication between services

## 🎛️ Supported Languages

The system supports 40+ languages including:

- **European**: English, Spanish, French, German, Italian, Portuguese, Dutch, Russian
- **Asian**: Chinese, Japanese, Korean, Hindi, Thai, Vietnamese
- **Middle Eastern**: Arabic, Persian, Hebrew, Turkish
- **Others**: And many more with automatic language detection

## 🔧 Configuration

### Environment Variables

Create a `.env` file to customize settings:

```bash
# Whisper model size (tiny, base, small, medium, large)
WHISPER_MODEL=base

# Service ports
N8N_PORT=5678
WHISPER_PORT=8001
WEB_PORT=8002

# Performance settings
WHISPER_DEVICE=cpu  # or cuda for GPU
```

### Microsoft Surface Optimization

The system is specifically optimized for Microsoft Surface devices:

- **Touch-friendly UI**: 44px minimum touch targets
- **High DPI support**: Optimized for Surface's high-resolution displays
- **Audio processing**: Enhanced noise cancellation and gain control
- **Performance**: CPU-optimized Whisper models for Surface processors
- **Responsive design**: Adapts to Surface's various screen orientations

## 📊 Monitoring and Logs

### View Service Logs
```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f whisper-service
docker compose logs -f n8n
docker compose logs -f web-interface
```

### Health Checks
```bash
# Check all services
curl http://localhost:5678/healthz  # n8n
curl http://localhost:8001/healthz  # Whisper
curl http://localhost:8002          # Web interface
```

## 🛠️ Development

### Local Development Setup

```bash
# Install dependencies
bash setup.sh

# Start services individually
source .venv/bin/activate

# Start Whisper service
WHISPER_MODEL=base uvicorn scripts.transcribe_translate_service:app --host 127.0.0.1 --port 8001

# Start web server
cd web && python -m http.server 8002
```

### Custom Workflows

The n8n workflow can be extended for:
- **Custom preprocessing**: Audio enhancement, noise reduction
- **Multiple outputs**: Save to databases, send notifications
- **Batch processing**: Process multiple files automatically
- **Integration**: Connect to other services and APIs

## 🔒 Privacy and Security

- **100% Local**: All processing happens on your device
- **No Cloud Calls**: No data sent to external services
- **Secure Network**: Docker internal networking
- **No Data Persistence**: Audio files are processed in memory only
- **CORS Protection**: Proper cross-origin request handling

## 📱 Browser Compatibility

| Browser | Recording | File Upload | Compatibility |
|---------|-----------|-------------|---------------|
| Chrome  | ✅        | ✅          | Full          |
| Firefox | ✅        | ✅          | Full          |
| Edge    | ✅        | ✅          | Full          |
| Safari  | ⚠️        | ✅          | Limited*      |

*Safari has limited WebM support; MP3/WAV files work best.

## 🚨 Troubleshooting

### Common Issues

**Services won't start:**
```bash
# Check Docker is running
docker info

# Restart Docker Desktop
# Try again: ./start.sh
```

**Microphone not working:**
- Ensure browser has microphone permission
- Check Windows privacy settings (Settings → Privacy → Microphone)
- Try refreshing the page

**Translation is slow:**
- First translation downloads the Whisper model (1-2 minutes)
- Subsequent translations are much faster
- Consider using `WHISPER_MODEL=tiny` for faster processing

**n8n workflow not found:**
- Ensure you imported the workflow file
- Check the workflow is activated (toggle switch)
- Verify webhook URL in workflow settings

### Performance Optimization

**For faster processing:**
```bash
# Use smaller Whisper model
echo "WHISPER_MODEL=tiny" >> .env

# Allocate more memory to Docker
# Docker Desktop → Settings → Resources → Memory: 4GB+
```

**For better accuracy:**
```bash
# Use larger Whisper model
echo "WHISPER_MODEL=small" >> .env
# or medium/large for best quality
```

## 🛑 Stopping the System

```bash
# Stop all services
./stop.sh

# Or manually
docker compose down

# Remove all data (including downloaded models)
docker compose down -v
```

## 📋 System Requirements

### Minimum Requirements
- **RAM**: 4GB available
- **Storage**: 2GB free space
- **CPU**: Dual-core processor
- **OS**: Windows 10/11, macOS, Linux

### Recommended for Microsoft Surface
- **Surface Pro 7+** or **Surface Laptop 3+**
- **RAM**: 8GB or more
- **Storage**: 5GB free space (for larger Whisper models)
- **Network**: Internet for initial setup only

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with `./start.sh`
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License. See LICENSE file for details.

## 🙏 Acknowledgments

- **OpenAI Whisper**: Speech recognition model
- **Argos Translate**: Local translation engine
- **n8n**: Workflow automation platform
- **FastAPI**: Modern Python web framework

---

**Need help?** Open an issue or check the troubleshooting section above.