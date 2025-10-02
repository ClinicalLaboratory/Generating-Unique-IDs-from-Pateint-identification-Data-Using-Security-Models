# 🔧 Troubleshooting Guide

## n8n Workflow Issues

### "Bad request - please check your parameters" Error

This error typically occurs when the n8n HTTP Request node is not properly configured. Here are the solutions:

#### Solution 1: Use the Fixed Workflow

Replace the original workflow with the fixed version:

1. **Delete the existing workflow** in n8n
2. **Import the fixed workflow**:
   ```bash
   # Use the fixed workflow file
   cp n8n/workflow_speech_translate_fixed.json n8n/workflow_speech_translate.json
   ```
3. **Re-import in n8n**:
   - Open http://localhost:5678
   - Go to Workflows → Import from file
   - Select `n8n/workflow_speech_translate.json`
   - Activate the workflow

#### Solution 2: Manual Configuration

If you prefer to fix the existing workflow manually:

1. **Open the workflow** in n8n
2. **Click on the "Whisper Transcribe" node**
3. **Configure the HTTP Request node**:
   - **URL**: `http://whisper-service:8001/transcribe-translate`
   - **Method**: `POST`
   - **Send Body**: `Yes`
   - **Body Content Type**: `Multipart Form Data`
   - **Body Parameters**:
     - Name: `target`
     - Value: `{{ $json.body?.targetLang || $json.query?.targetLang || 'en' }}`
   - **Send Binary Data**: `Yes`
   - **Binary Property**: `audio`
   - **Timeout**: `300000` (5 minutes)

#### Solution 3: Use Simple Workflow

For a more robust solution, use the simple workflow:

```bash
# Copy the simple workflow
cp n8n/workflow_simple.json n8n/workflow_speech_translate.json

# Restart the system
./stop.sh
./start.sh
```

### Common n8n Issues

#### 1. Service Connection Issues

**Problem**: n8n can't connect to whisper-service

**Solution**:
```bash
# Check if services are running
docker compose ps

# Check service logs
docker compose logs whisper-service
docker compose logs n8n

# Restart services
docker compose restart whisper-service
docker compose restart n8n
```

#### 2. Webhook URL Issues

**Problem**: Webhook not receiving requests

**Check the webhook URL**:
- In n8n: Should be `http://localhost:5678/webhook/speech-translate`
- In web app: Should point to `http://localhost:8001/proxy/n8n`

**Fix**:
1. Check the webhook path in n8n workflow
2. Verify the web app is using the correct proxy URL

#### 3. Binary Data Issues

**Problem**: Audio data not being passed correctly

**Debug steps**:
1. **Test the Whisper service directly**:
   ```bash
   # Test with a sample audio file
   curl -X POST http://localhost:8001/debug \
     -F "audio=@sample.wav" \
     -F "target=es"
   ```

2. **Check n8n execution logs**:
   - Open n8n → Executions
   - Click on failed execution
   - Check each node's input/output

#### 4. Parameter Extraction Issues

**Problem**: Target language not being extracted

**Solution**: Use the Code node approach (workflow_simple.json):
```javascript
// Extract target language from request
const targetLang = $input.first().json.body?.targetLang || 
                  $input.first().json.query?.targetLang || 
                  $input.first().json.targetLang || 'en';

// Get the audio binary data
const audioBinary = $input.first().binary?.audio;

if (!audioBinary) {
  throw new Error('No audio data found in request');
}

// Return the data for the next node
return {
  json: { targetLang },
  binary: { audio: audioBinary }
};
```

## Web Interface Issues

### 1. Microphone Not Working

**Check browser permissions**:
- Chrome: Settings → Privacy and security → Site settings → Microphone
- Firefox: about:preferences#privacy → Permissions → Microphone
- Edge: Settings → Site permissions → Microphone

**On Microsoft Surface**:
- Windows Settings → Privacy → Microphone → Allow apps to access microphone

### 2. File Upload Issues

**Supported formats**: WAV, MP3, WebM, OGG, M4A, AAC
**Max file size**: 50MB

**Common issues**:
- File too large → Compress or use shorter audio
- Unsupported format → Convert to supported format
- Empty file → Check file integrity

### 3. CORS Issues

**Problem**: Cross-origin request blocked

**Solution**:
- Use the proxy endpoint: `http://localhost:8001/proxy/n8n`
- Or add CORS headers to n8n (not recommended for production)

## Docker Issues

### 1. Services Won't Start

```bash
# Check Docker is running
docker info

# Check system resources
docker system df

# Clean up if needed
docker system prune -f

# Restart Docker Desktop
# Then try: ./start.sh
```

### 2. Port Conflicts

**Problem**: Port already in use

**Solution**:
```bash
# Check what's using the ports
netstat -tulpn | grep :5678
netstat -tulpn | grep :8001
netstat -tulpn | grep :8002

# Kill conflicting processes or change ports in docker-compose.yml
```

### 3. Memory Issues

**Problem**: Out of memory errors

**Solution**:
```bash
# Increase Docker memory limit
# Docker Desktop → Settings → Resources → Memory: 6GB+

# Or use smaller Whisper model
echo "WHISPER_MODEL=tiny" > .env
docker compose up --build -d
```

## Performance Issues

### 1. Slow Translation

**First translation is slow (normal)**:
- Whisper model download: 1-2 minutes
- Subsequent translations: 5-30 seconds

**Optimization**:
```bash
# Use smaller model for speed
echo "WHISPER_MODEL=tiny" > .env

# Use larger model for accuracy
echo "WHISPER_MODEL=small" > .env

# Restart after changes
docker compose up --build -d
```

### 2. High CPU Usage

**On Microsoft Surface**:
```bash
# Limit CPU usage
echo "TORCH_NUM_THREADS=2" >> .env
echo "OMP_NUM_THREADS=2" >> .env

# Restart services
docker compose restart whisper-service
```

## Debugging Steps

### 1. Test Each Component

```bash
# 1. Test Whisper service
curl http://localhost:8001/healthz

# 2. Test n8n
curl http://localhost:5678/healthz

# 3. Test web interface
curl http://localhost:8002

# 4. Test workflow (with audio file)
curl -X POST http://localhost:5678/webhook/speech-translate \
  -F "audio=@test.wav" \
  -F "targetLang=es"
```

### 2. Check Logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs whisper-service
docker compose logs n8n
docker compose logs web-interface

# Follow logs in real-time
docker compose logs -f whisper-service
```

### 3. Validate Configuration

```bash
# Run configuration tests
python3 test-config.py

# Check Docker Compose syntax
docker compose config
```

## Getting Help

### 1. Collect Debug Information

Before asking for help, collect:

```bash
# System info
docker --version
docker compose --version
uname -a

# Service status
docker compose ps

# Recent logs
docker compose logs --tail=50 whisper-service > whisper.log
docker compose logs --tail=50 n8n > n8n.log

# Configuration test
python3 test-config.py > config-test.log
```

### 2. Test with Sample Data

```bash
# Create a test audio file (5 seconds of silence)
ffmpeg -f lavfi -i anullsrc=duration=5 -ar 16000 test.wav

# Test the service directly
curl -X POST http://localhost:8001/transcribe-translate \
  -F "audio=@test.wav" \
  -F "target=es"
```

### 3. Reset Everything

If all else fails:

```bash
# Stop and remove everything
./stop.sh
docker compose down -v

# Clean Docker system
docker system prune -a -f

# Restart fresh
./start.sh
```

---

**Still having issues?** Open a GitHub issue with:
- Error messages
- Log files
- System information
- Steps to reproduce