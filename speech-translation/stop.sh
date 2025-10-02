#!/bin/bash
set -euo pipefail

echo "🛑 Stopping Local Speech Translation System"
echo "=========================================="

# Use docker compose or docker-compose based on availability
COMPOSE_CMD="docker compose"
if ! docker compose version >/dev/null 2>&1; then
    COMPOSE_CMD="docker-compose"
fi

echo "📦 Stopping services..."
$COMPOSE_CMD down

echo "🧹 Cleaning up..."
# Remove unused containers and networks
docker system prune -f --filter "label=com.docker.compose.project=speech-translation" >/dev/null 2>&1 || true

echo "✅ System stopped successfully!"
echo ""
echo "💡 To start again, run: ./start.sh"
echo "🗑️  To remove all data, run: $COMPOSE_CMD down -v"