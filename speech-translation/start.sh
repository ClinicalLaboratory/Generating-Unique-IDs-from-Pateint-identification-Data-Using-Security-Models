#!/bin/bash
set -euo pipefail

echo "🚀 Starting Local Speech Translation System"
echo "=========================================="

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker Desktop and try again."
    exit 1
fi

# Check if Docker Compose is available
if ! command -v docker-compose >/dev/null 2>&1 && ! docker compose version >/dev/null 2>&1; then
    echo "❌ Docker Compose is not available. Please install Docker Compose."
    exit 1
fi

# Use docker compose or docker-compose based on availability
COMPOSE_CMD="docker compose"
if ! docker compose version >/dev/null 2>&1; then
    COMPOSE_CMD="docker-compose"
fi

echo "📦 Building and starting services..."
$COMPOSE_CMD up --build -d

echo "⏳ Waiting for services to be ready..."
sleep 10

# Check service health
echo "🔍 Checking service health..."

# Check n8n
if curl -f http://localhost:5678/healthz >/dev/null 2>&1; then
    echo "✅ n8n is running at http://localhost:5678"
else
    echo "⚠️  n8n is starting up (may take a few more seconds)"
fi

# Check Whisper service
if curl -f http://localhost:8001/healthz >/dev/null 2>&1; then
    echo "✅ Whisper service is running at http://localhost:8001"
else
    echo "⚠️  Whisper service is starting up (may take a few more seconds)"
fi

# Check web interface
if curl -f http://localhost:8002 >/dev/null 2>&1; then
    echo "✅ Web interface is running at http://localhost:8002"
else
    echo "⚠️  Web interface is starting up (may take a few more seconds)"
fi

echo ""
echo "🎉 System is starting up!"
echo ""

# Automatically initialize the workflow
echo "🔄 Auto-importing n8n workflow..."
if ./init-workflow.sh; then
    echo ""
    echo "✅ System is ready to use!"
    echo ""
    echo "🚀 Quick start:"
    echo "   1. Open http://localhost:8002"
    echo "   2. Allow microphone access when prompted"
    echo "   3. Select target language and start translating!"
else
    echo ""
    echo "⚠️  Automatic workflow import failed. Manual setup required:"
    echo "   1. Open http://localhost:5678"
    echo "   2. Import workflow: n8n/workflow_speech_translate.json"
    echo "   3. Activate the workflow"
    echo "   4. Then open http://localhost:8002"
fi
echo ""
echo "📊 Monitor logs with: $COMPOSE_CMD logs -f"
echo "🛑 Stop system with: $COMPOSE_CMD down"
echo ""
echo "🔧 Troubleshooting:"
echo "   - If services are slow to start, wait 1-2 minutes"
echo "   - Check logs: $COMPOSE_CMD logs [service-name]"
echo "   - Restart: $COMPOSE_CMD restart [service-name]"