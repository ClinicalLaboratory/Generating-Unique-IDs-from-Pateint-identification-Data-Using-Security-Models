#!/usr/bin/env python3
"""
Test script to check the Flask Whisper service endpoints and compatibility
"""

import requests
import json
import sys
from pathlib import Path

def test_flask_service():
    """Test the Flask Whisper service running on port 9000"""
    
    base_url = "http://127.0.0.1:9000"
    
    print("🔍 Testing Flask Whisper Service")
    print("=" * 40)
    
    # Test 1: Check if service is running
    print("1. Testing service availability...")
    try:
        response = requests.get(f"{base_url}/", timeout=5)
        print(f"   Status: {response.status_code}")
        if response.status_code == 404:
            print("   ✅ Service is running (404 is expected for root path)")
        else:
            print(f"   Response: {response.text[:200]}")
    except requests.exceptions.RequestException as e:
        print(f"   ❌ Service not reachable: {e}")
        return False
    
    # Test 2: Check common endpoints
    endpoints_to_test = [
        "/health",
        "/healthz", 
        "/transcribe",
        "/translate",
        "/whisper",
        "/api/transcribe",
        "/api/translate"
    ]
    
    print("\n2. Testing common endpoints...")
    available_endpoints = []
    
    for endpoint in endpoints_to_test:
        try:
            response = requests.get(f"{base_url}{endpoint}", timeout=5)
            if response.status_code != 404:
                available_endpoints.append(endpoint)
                print(f"   ✅ {endpoint} - Status: {response.status_code}")
                if response.headers.get('content-type', '').startswith('application/json'):
                    try:
                        data = response.json()
                        print(f"      Response: {json.dumps(data, indent=2)[:200]}")
                    except:
                        pass
            else:
                print(f"   ❌ {endpoint} - Not found")
        except requests.exceptions.RequestException:
            print(f"   ❌ {endpoint} - Error")
    
    # Test 3: Try POST requests on available endpoints
    print(f"\n3. Testing POST requests on available endpoints...")
    
    # Create a small test audio file (silence)
    test_audio_content = b'\x00' * 1024  # Simple test data
    
    for endpoint in available_endpoints:
        try:
            # Test with form data
            files = {'audio': ('test.wav', test_audio_content, 'audio/wav')}
            data = {'language': 'en', 'task': 'transcribe', 'target': 'es'}
            
            response = requests.post(f"{base_url}{endpoint}", 
                                   files=files, 
                                   data=data, 
                                   timeout=30)
            
            print(f"   📤 POST {endpoint} - Status: {response.status_code}")
            if response.status_code == 200:
                try:
                    result = response.json()
                    print(f"      ✅ Success: {json.dumps(result, indent=2)[:200]}")
                except:
                    print(f"      Response: {response.text[:200]}")
            else:
                print(f"      Response: {response.text[:200]}")
                
        except requests.exceptions.RequestException as e:
            print(f"   ❌ POST {endpoint} - Error: {e}")
    
    # Test 4: Check service info
    print(f"\n4. Service Analysis:")
    print(f"   Available endpoints: {available_endpoints}")
    
    if available_endpoints:
        print(f"\n✅ Flask service is accessible!")
        print(f"📋 Recommended n8n workflow configuration:")
        print(f"   - Use endpoint: {available_endpoints[0] if available_endpoints else '/transcribe'}")
        print(f"   - URL: {base_url}{available_endpoints[0] if available_endpoints else '/transcribe'}")
        return True
    else:
        print(f"\n⚠️  No standard endpoints found. The service might use custom paths.")
        return False

def create_compatible_workflow(endpoint="/transcribe"):
    """Create a workflow compatible with the detected Flask service"""
    
    workflow = {
        "name": "Flask Whisper Compatible",
        "nodes": [
            {
                "parameters": {
                    "path": "speech-translate",
                    "responseMode": "responseNode",
                    "options": {"binaryData": True}
                },
                "id": "webhook",
                "name": "Webhook",
                "type": "n8n-nodes-base.webhook",
                "typeVersion": 2,
                "position": [200, 300]
            },
            {
                "parameters": {
                    "method": "POST",
                    "url": f"http://127.0.0.1:9000{endpoint}",
                    "sendBody": True,
                    "contentType": "multipart-form-data",
                    "bodyParameters": {
                        "parameters": [
                            {"name": "language", "value": "={{ $json.body?.targetLang || 'en' }}"},
                            {"name": "task", "value": "transcribe"}
                        ]
                    },
                    "sendBinaryData": True,
                    "binaryPropertyName": "audio",
                    "options": {"timeout": 300000}
                },
                "id": "http",
                "name": "Flask Whisper",
                "type": "n8n-nodes-base.httpRequest",
                "typeVersion": 4,
                "position": [500, 300]
            },
            {
                "parameters": {
                    "responseBody": "={{ $json }}",
                    "options": {
                        "responseHeaders": {
                            "entries": [
                                {"name": "Content-Type", "value": "application/json"},
                                {"name": "Access-Control-Allow-Origin", "value": "*"}
                            ]
                        }
                    }
                },
                "id": "respond",
                "name": "Respond to Webhook",
                "type": "n8n-nodes-base.respondToWebhook",
                "typeVersion": 1,
                "position": [800, 300]
            }
        ],
        "connections": {
            "Webhook": {"main": [[{"node": "Flask Whisper", "type": "main", "index": 0}]]},
            "Flask Whisper": {"main": [[{"node": "Respond to Webhook", "type": "main", "index": 0}]]}
        },
        "active": True
    }
    
    # Save the workflow
    with open('/workspace/speech-translation/n8n/workflow_flask_auto.json', 'w') as f:
        json.dump(workflow, f, indent=2)
    
    print(f"\n📄 Created compatible workflow: n8n/workflow_flask_auto.json")

if __name__ == "__main__":
    if test_flask_service():
        create_compatible_workflow()
        print(f"\n🚀 Next steps:")
        print(f"1. Import the workflow: n8n/workflow_flask_auto.json")
        print(f"2. Or use the manual workflow: n8n/workflow_flask_compatible.json")
        print(f"3. Make sure your Flask service accepts the expected parameters")
    else:
        print(f"\n❌ Could not connect to Flask service on port 9000")
        print(f"   Make sure the service is running and accessible")