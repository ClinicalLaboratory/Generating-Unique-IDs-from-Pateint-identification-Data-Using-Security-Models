# 🖥️ Microsoft Surface Setup Guide

Complete setup instructions for deploying the Real-time Speech Translation System on Microsoft Surface devices.

## 🎯 Surface-Specific Optimizations

This system is specifically optimized for Microsoft Surface hardware:

- **Touch Interface**: Large touch targets and gesture-friendly controls
- **High DPI Support**: Crisp rendering on Surface's high-resolution displays  
- **Audio Processing**: Optimized for Surface's built-in microphones
- **Performance**: CPU-tuned for Surface processors (Intel/AMD)
- **Battery Efficiency**: Lightweight processing to preserve battery life

## 📋 Prerequisites

### Supported Surface Models
- **Surface Pro 7, 8, 9, X** (Recommended: 8GB+ RAM)
- **Surface Laptop 3, 4, 5** (Recommended: 8GB+ RAM)
- **Surface Studio 2+**
- **Surface Book 3**

### Required Software
1. **Windows 11** (recommended) or **Windows 10** (version 2004+)
2. **Docker Desktop for Windows** (latest version)
3. **Modern web browser** (Edge, Chrome, or Firefox)

## 🚀 Installation Steps

### Step 1: Install Docker Desktop

1. **Download Docker Desktop**:
   - Visit: https://www.docker.com/products/docker-desktop/
   - Download "Docker Desktop for Windows"

2. **Install Docker Desktop**:
   ```powershell
   # Run the installer as Administrator
   # Enable WSL 2 integration when prompted
   # Restart when installation completes
   ```

3. **Configure Docker for Surface**:
   - Open Docker Desktop
   - Go to **Settings** → **Resources**
   - Set **Memory**: 4GB minimum, 6GB recommended
   - Set **CPU**: 2 cores minimum, 4 cores recommended
   - Click **Apply & Restart**

### Step 2: Enable Required Windows Features

Open **PowerShell as Administrator** and run:

```powershell
# Enable WSL 2 (if not already enabled)
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# Enable Hyper-V (for Docker)
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All

# Restart required
Restart-Computer
```

### Step 3: Download and Deploy

1. **Clone the Repository**:
   ```powershell
   # Open PowerShell or Command Prompt
   cd C:\Users\%USERNAME%\Documents
   git clone <repository-url> speech-translation
   cd speech-translation
   ```

2. **Start the System**:
   ```powershell
   # Make sure Docker Desktop is running
   .\start.sh
   ```

   Or on Windows without bash:
   ```powershell
   docker compose up --build -d
   .\init-workflow.sh
   ```

### Step 4: Configure Surface Audio

1. **Microphone Settings**:
   - Open **Settings** → **Privacy & security** → **Microphone**
   - Enable "Allow apps to access your microphone"
   - Enable "Allow desktop apps to access your microphone"

2. **Audio Enhancement** (Optional):
   - Open **Settings** → **System** → **Sound**
   - Select your Surface microphone
   - Click **Device properties**
   - Enable **Audio enhancements** for better quality

## 🎮 Surface-Specific Usage

### Touch Controls

The interface is optimized for Surface touch input:

- **Large Touch Targets**: All buttons are 44px+ for easy finger tapping
- **Gesture Support**: Swipe and tap gestures work naturally
- **Zoom Friendly**: Interface scales properly with Windows zoom settings

### Surface Pen Integration

While not required, the Surface Pen can be used to:
- Navigate the interface precisely
- Select text in the translation output
- Interact with dropdown menus

### Tablet Mode

The system works seamlessly in Surface tablet mode:
- **Auto-rotation**: Interface adapts to portrait/landscape
- **Touch Keyboard**: Windows on-screen keyboard works with text inputs
- **Full-screen**: Browser can be used in full-screen mode

## ⚡ Performance Optimization

### For Surface Pro (Intel)
```bash
# Create .env file for optimal settings
echo "WHISPER_MODEL=base" > .env
echo "WHISPER_DEVICE=cpu" >> .env
echo "TORCH_NUM_THREADS=4" >> .env
```

### For Surface Laptop (AMD)
```bash
# Optimized for AMD processors
echo "WHISPER_MODEL=base" > .env
echo "WHISPER_DEVICE=cpu" >> .env
echo "OMP_NUM_THREADS=4" >> .env
```

### For High-Performance Surfaces
```bash
# Use larger model for better accuracy
echo "WHISPER_MODEL=small" > .env
echo "WHISPER_DEVICE=cpu" >> .env
```

## 🔋 Battery Optimization

To maximize battery life on Surface devices:

1. **Use Smaller Models**:
   ```bash
   echo "WHISPER_MODEL=tiny" > .env
   ```

2. **Windows Power Settings**:
   - Set power mode to "Battery saver" or "Balanced"
   - Reduce screen brightness
   - Close unnecessary applications

3. **Docker Resource Limits**:
   ```yaml
   # Add to docker-compose.yml services
   deploy:
     resources:
       limits:
         cpus: '2.0'
         memory: 2G
   ```

## 🌐 Network Configuration

### Windows Firewall

Docker Desktop usually handles firewall rules, but if you have issues:

```powershell
# Allow Docker through Windows Firewall
New-NetFirewallRule -DisplayName "Docker Desktop" -Direction Inbound -Protocol TCP -LocalPort 5678,8001,8002 -Action Allow
```

### Corporate Networks

If on a corporate Surface with network restrictions:

1. **Proxy Configuration**:
   ```bash
   # Configure Docker proxy in Docker Desktop settings
   # HTTP Proxy: your-proxy:port
   # HTTPS Proxy: your-proxy:port
   ```

2. **DNS Issues**:
   ```powershell
   # Flush DNS cache
   ipconfig /flushdns
   ```

## 🛠️ Troubleshooting Surface Issues

### Common Surface Problems

**Docker won't start:**
```powershell
# Check Hyper-V is enabled
Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All

# Restart Docker Desktop
Stop-Process -Name "Docker Desktop" -Force
Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"
```

**Microphone not detected:**
```powershell
# Check audio devices
Get-AudioDevice -List

# Reset audio service
Restart-Service -Name "AudioSrv" -Force
```

**Performance issues:**
- Close Microsoft Teams, Skype, or other audio apps
- Disable Windows Game Mode
- Check Windows Update for Surface firmware updates

**Touch interface problems:**
- Calibrate touch screen in Windows Settings
- Update Surface drivers via Windows Update
- Restart Windows Explorer: `taskkill /f /im explorer.exe && start explorer.exe`

### Surface-Specific Logs

Check Surface hardware status:
```powershell
# Surface diagnostic info
Get-WmiObject -Class Win32_Battery
Get-WmiObject -Class Win32_Processor
dxdiag /t surface_info.txt
```

## 🔄 Updates and Maintenance

### Keeping System Updated

```powershell
# Update Docker images
docker compose pull
docker compose up --build -d

# Update Windows and Surface firmware
# Windows Update → Check for updates
# Install Surface and Windows updates
```

### Backup Configuration

```powershell
# Backup your settings
copy .env .env.backup
copy docker-compose.yml docker-compose.yml.backup
```

## 📞 Surface Support

### Microsoft Surface Support
- **Surface Support**: https://support.microsoft.com/surface
- **Surface Community**: https://answers.microsoft.com/surface
- **Surface Diagnostic Toolkit**: Available in Microsoft Store

### System Requirements Check
```powershell
# Check if your Surface meets requirements
systeminfo | findstr /C:"Total Physical Memory"
systeminfo | findstr /C:"Processor"
wmic diskdrive get size,model
```

## 🎉 Success Indicators

Your Surface setup is working correctly when:

- ✅ Docker Desktop shows all containers running (green)
- ✅ Web interface loads at http://localhost:8002
- ✅ Microphone permission granted in browser
- ✅ Touch controls respond smoothly
- ✅ Audio recording works without echo/feedback
- ✅ Translation completes in under 30 seconds

---

**Surface-specific issues?** Check the troubleshooting section or open an issue with your Surface model details.