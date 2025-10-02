#!/bin/bash
set -euo pipefail

echo "🔧 Fixing n8n Integration for Flask Whisper Service"
echo "=================================================="

# Check if Flask service is running
echo "🔍 Checking Flask service on port 9000..."
if curl -s --connect-timeout 5 http://127.0.0.1:9000/ >/dev/null 2>&1; then
    echo "✅ Flask service detected on port 9000"
    FLASK_RUNNING=true
else
    echo "⚠️  Flask service not detected on port 9000"
    FLASK_RUNNING=false
fi

# Check if n8n is running
echo "🔍 Checking n8n service..."
if curl -s --connect-timeout 5 http://localhost:5678/healthz >/dev/null 2>&1; then
    echo "✅ n8n service is running"
    N8N_RUNNING=true
else
    echo "⚠️  n8n service not running"
    N8N_RUNNING=false
fi

echo ""
echo "🛠️  Available Solutions:"
echo ""

if [ "$FLASK_RUNNING" = true ] && [ "$N8N_RUNNING" = true ]; then
    echo "✅ Both services detected - Configuring n8n for Flask integration"
    
    # Try to import Flask-compatible workflow
    echo "📥 Importing Flask-compatible workflow..."
    
    response=$(curl -s -X POST \
        -H "Content-Type: application/json" \
        -d @"n8n/workflow_flask_simple.json" \
        http://localhost:5678/rest/workflows/import 2>/dev/null || echo "failed")
    
    if echo "$response" | grep -q '"id"'; then
        workflow_id=$(echo "$response" | grep -o '"id":"[^"]*"' | cut -d'"' -f4)
        echo "✅ Flask workflow imported! ID: $workflow_id"
        
        # Activate the workflow
        activate_response=$(curl -s -X POST \
            -H "Content-Type: application/json" \
            -d '{"active": true}' \
            "http://localhost:5678/rest/workflows/$workflow_id/activate" 2>/dev/null || echo "failed")
        
        if echo "$activate_response" | grep -q '"active":true'; then
            echo "✅ Workflow activated successfully!"
            echo ""
            echo "🎉 Integration complete!"
            echo "📱 Test at: http://localhost:8002"
            echo "⚙️  n8n: http://localhost:5678"
        else
            echo "⚠️  Workflow imported but activation failed"
        fi
    else
        echo "❌ Failed to import workflow automatically"
        echo ""
        echo "📋 Manual steps:"
        echo "1. Open http://localhost:5678"
        echo "2. Delete existing workflows"
        echo "3. Import: n8n/workflow_flask_simple.json"
        echo "4. Activate the workflow"
    fi

elif [ "$FLASK_RUNNING" = true ] && [ "$N8N_RUNNING" = false ]; then
    echo "🚀 Flask detected, starting n8n..."
    
    # Start only n8n service
    docker compose up -d n8n
    
    echo "⏳ Waiting for n8n to start..."
    sleep 10
    
    # Try to import workflow
    echo "📥 Importing Flask workflow..."
    response=$(curl -s -X POST \
        -H "Content-Type: application/json" \
        -d @"n8n/workflow_flask_simple.json" \
        http://localhost:5678/rest/workflows/import 2>/dev/null || echo "failed")
    
    if echo "$response" | grep -q '"id"'; then
        echo "✅ Flask workflow imported and ready!"
    else
        echo "⚠️  Import the workflow manually: n8n/workflow_flask_simple.json"
    fi

elif [ "$FLASK_RUNNING" = false ] && [ "$N8N_RUNNING" = true ]; then
    echo "🔄 n8n detected, but no Flask service"
    echo ""
    echo "Options:"
    echo "1. Start your Flask Whisper service on port 9000"
    echo "2. Or use our complete system: ./start.sh"

else
    echo "🚀 No services detected - Starting complete system..."
    ./start.sh
fi

echo ""
echo "🔧 Configuration Summary:"
echo "========================"
echo "Flask Service: http://127.0.0.1:9000"
echo "n8n Workflow: http://localhost:5678"
echo "Web Interface: http://localhost:8002"
echo ""
echo "📋 Workflow Configuration:"
echo "- Endpoint: http://127.0.0.1:9000/transcribe"
echo "- Method: POST"
echo "- Parameters: audio (file), language, task"
echo ""
echo "🔍 Test your Flask service:"
echo "curl -X POST http://127.0.0.1:9000/transcribe \\"
echo "  -F \"audio=@test.wav\" \\"
echo "  -F \"language=en\" \\"
echo "  -F \"task=transcribe\""