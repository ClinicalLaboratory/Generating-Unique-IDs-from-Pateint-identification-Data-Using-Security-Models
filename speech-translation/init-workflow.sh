#!/bin/bash
set -euo pipefail

echo "🔄 Initializing n8n workflow..."

# Wait for n8n to be ready
echo "⏳ Waiting for n8n to start..."
timeout=60
counter=0

while ! curl -f http://localhost:5678/healthz >/dev/null 2>&1; do
    if [ $counter -ge $timeout ]; then
        echo "❌ Timeout waiting for n8n to start"
        exit 1
    fi
    sleep 2
    counter=$((counter + 2))
    echo "   Waiting... (${counter}s/${timeout}s)"
done

echo "✅ n8n is ready!"

# Import workflow using n8n API
echo "📥 Importing workflow..."

WORKFLOW_FILE="/workspace/speech-translation/n8n/workflow_speech_translate.json"

# Use the fixed workflow if the original fails
WORKFLOW_FILE_FIXED="/workspace/speech-translation/n8n/workflow_speech_translate_fixed.json"
WORKFLOW_FILE_SIMPLE="/workspace/speech-translation/n8n/workflow_simple.json"
WORKFLOW_FILE_FLASK="/workspace/speech-translation/n8n/workflow_flask_simple.json"

# Check if Flask service is running on port 9000
FLASK_DETECTED=false
if curl -s --connect-timeout 3 http://127.0.0.1:9000/ >/dev/null 2>&1; then
    echo "🔍 Flask Whisper service detected on port 9000"
    FLASK_DETECTED=true
fi

if [ ! -f "$WORKFLOW_FILE" ]; then
    echo "❌ Workflow file not found: $WORKFLOW_FILE"
    exit 1
fi

import_workflow() {
    local workflow_file="$1"
    local workflow_name="$2"
    
    echo "📥 Trying to import $workflow_name..."
    
    response=$(curl -s -X POST \
        -H "Content-Type: application/json" \
        -d @"$workflow_file" \
        http://localhost:5678/rest/workflows/import)

    if echo "$response" | grep -q '"id"'; then
        workflow_id=$(echo "$response" | grep -o '"id":"[^"]*"' | cut -d'"' -f4)
        echo "✅ $workflow_name imported successfully! ID: $workflow_id"
        
        # Activate the workflow
        echo "🔄 Activating workflow..."
        activate_response=$(curl -s -X POST \
            -H "Content-Type: application/json" \
            -d '{"active": true}' \
            "http://localhost:5678/rest/workflows/$workflow_id/activate")
        
        if echo "$activate_response" | grep -q '"active":true'; then
            echo "✅ Workflow activated successfully!"
            echo ""
            echo "🎉 Setup complete!"
            echo "📱 Open http://localhost:8002 to use the speech translator"
            echo "⚙️  n8n interface: http://localhost:5678"
            return 0
        else
            echo "⚠️  Workflow imported but activation failed."
            return 1
        fi
    else
        echo "❌ Failed to import $workflow_name. Response: $response"
        return 1
    fi
}

# Try to import workflows in order of preference
if [ "$FLASK_DETECTED" = true ]; then
    echo "🔧 Using Flask-compatible workflow for detected service"
    if import_workflow "$WORKFLOW_FILE_FLASK" "Flask-compatible workflow"; then
        echo "✅ Flask integration complete!"
        exit 0
    fi
fi

# Try standard workflows
if import_workflow "$WORKFLOW_FILE" "main workflow"; then
    exit 0
elif import_workflow "$WORKFLOW_FILE_FIXED" "fixed workflow"; then
    echo "✅ Used fixed workflow version"
    exit 0
elif import_workflow "$WORKFLOW_FILE_SIMPLE" "simple workflow"; then
    echo "✅ Used simple workflow version"
    exit 0
else
    echo ""
    echo "❌ All automatic imports failed. Manual setup required:"
    echo "1. Open http://localhost:5678"
    echo "2. Click menu (≡) → Import from file"
    echo "3. Try importing in this order:"
    if [ "$FLASK_DETECTED" = true ]; then
        echo "   - n8n/workflow_flask_simple.json (for your Flask service)"
    fi
    echo "   - n8n/workflow_speech_translate_fixed.json (recommended)"
    echo "   - n8n/workflow_simple.json (most compatible)"
    echo "   - n8n/workflow_speech_translate.json (original)"
    echo "4. Activate the imported workflow"
    echo "5. Then open http://localhost:8002"
    exit 1
fi