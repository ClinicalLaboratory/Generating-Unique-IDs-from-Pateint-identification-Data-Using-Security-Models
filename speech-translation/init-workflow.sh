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

if [ ! -f "$WORKFLOW_FILE" ]; then
    echo "❌ Workflow file not found: $WORKFLOW_FILE"
    exit 1
fi

# Import the workflow
response=$(curl -s -X POST \
    -H "Content-Type: application/json" \
    -d @"$WORKFLOW_FILE" \
    http://localhost:5678/rest/workflows/import)

if echo "$response" | grep -q '"id"'; then
    workflow_id=$(echo "$response" | grep -o '"id":"[^"]*"' | cut -d'"' -f4)
    echo "✅ Workflow imported successfully! ID: $workflow_id"
    
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
    else
        echo "⚠️  Workflow imported but activation failed. Please activate manually in n8n."
    fi
else
    echo "❌ Failed to import workflow. Response: $response"
    echo ""
    echo "📋 Manual import instructions:"
    echo "1. Open http://localhost:5678"
    echo "2. Click menu (≡) → Import from file"
    echo "3. Select: n8n/workflow_speech_translate.json"
    echo "4. Click Import and Activate"
fi