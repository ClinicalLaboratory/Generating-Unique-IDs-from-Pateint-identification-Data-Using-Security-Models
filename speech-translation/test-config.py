#!/usr/bin/env python3
"""
Configuration validation script for the Speech Translation System
"""

import json
import yaml
import os
import sys
from pathlib import Path

def test_docker_compose():
    """Test Docker Compose configuration"""
    print("🐳 Testing Docker Compose configuration...")
    
    compose_file = Path("docker-compose.yml")
    if not compose_file.exists():
        print("❌ docker-compose.yml not found")
        return False
    
    try:
        with open(compose_file) as f:
            config = yaml.safe_load(f)
        
        # Check required services
        required_services = ['n8n', 'whisper-service', 'web-interface']
        services = config.get('services', {})
        
        for service in required_services:
            if service not in services:
                print(f"❌ Missing service: {service}")
                return False
            print(f"✅ Service found: {service}")
        
        # Check networks
        if 'networks' not in config:
            print("❌ No networks defined")
            return False
        
        print("✅ Docker Compose configuration valid")
        return True
        
    except Exception as e:
        print(f"❌ Docker Compose validation error: {e}")
        return False

def test_n8n_workflow():
    """Test n8n workflow configuration"""
    print("\n🔄 Testing n8n workflow...")
    
    workflow_file = Path("n8n/workflow_speech_translate.json")
    if not workflow_file.exists():
        print("❌ n8n workflow file not found")
        return False
    
    try:
        with open(workflow_file) as f:
            workflow = json.load(f)
        
        # Check required fields
        required_fields = ['name', 'nodes', 'connections']
        for field in required_fields:
            if field not in workflow:
                print(f"❌ Missing workflow field: {field}")
                return False
        
        # Check nodes
        nodes = workflow.get('nodes', [])
        required_nodes = ['Webhook', 'Call Local Whisper Service', 'Respond to Webhook']
        
        node_names = [node.get('name', '') for node in nodes]
        for required_node in required_nodes:
            if required_node not in node_names:
                print(f"❌ Missing node: {required_node}")
                return False
            print(f"✅ Node found: {required_node}")
        
        print("✅ n8n workflow configuration valid")
        return True
        
    except Exception as e:
        print(f"❌ n8n workflow validation error: {e}")
        return False

def test_web_interface():
    """Test web interface files"""
    print("\n🌐 Testing web interface...")
    
    web_files = ['web/index.html', 'web/app.js', 'web/styles.css']
    
    for file_path in web_files:
        if not Path(file_path).exists():
            print(f"❌ Missing web file: {file_path}")
            return False
        print(f"✅ Web file found: {file_path}")
    
    # Test HTML structure
    try:
        with open('web/index.html') as f:
            html_content = f.read()
        
        required_elements = ['languageSelect', 'startBtn', 'stopBtn', 'translatedText']
        for element in required_elements:
            if element not in html_content:
                print(f"❌ Missing HTML element: {element}")
                return False
        
        print("✅ Web interface structure valid")
        return True
        
    except Exception as e:
        print(f"❌ Web interface validation error: {e}")
        return False

def test_python_service():
    """Test Python service configuration"""
    print("\n🐍 Testing Python service...")
    
    service_file = Path("scripts/transcribe_translate_service.py")
    if not service_file.exists():
        print("❌ Python service file not found")
        return False
    
    requirements_file = Path("requirements.txt")
    if not requirements_file.exists():
        print("❌ requirements.txt not found")
        return False
    
    try:
        with open(requirements_file) as f:
            requirements = f.read()
        
        required_packages = ['fastapi', 'uvicorn', 'whisper', 'argostranslate']
        for package in required_packages:
            if package not in requirements:
                print(f"❌ Missing package: {package}")
                return False
            print(f"✅ Package found: {package}")
        
        print("✅ Python service configuration valid")
        return True
        
    except Exception as e:
        print(f"❌ Python service validation error: {e}")
        return False

def test_dockerfiles():
    """Test Dockerfile configurations"""
    print("\n📦 Testing Dockerfiles...")
    
    dockerfiles = ['Dockerfile.whisper', 'Dockerfile.web']
    
    for dockerfile in dockerfiles:
        if not Path(dockerfile).exists():
            print(f"❌ Missing Dockerfile: {dockerfile}")
            return False
        
        try:
            with open(dockerfile) as f:
                content = f.read()
            
            if 'FROM' not in content:
                print(f"❌ Invalid Dockerfile: {dockerfile}")
                return False
            
            print(f"✅ Dockerfile valid: {dockerfile}")
            
        except Exception as e:
            print(f"❌ Dockerfile validation error for {dockerfile}: {e}")
            return False
    
    return True

def test_scripts():
    """Test shell scripts"""
    print("\n📜 Testing shell scripts...")
    
    scripts = ['start.sh', 'stop.sh', 'init-workflow.sh']
    
    for script in scripts:
        if not Path(script).exists():
            print(f"❌ Missing script: {script}")
            return False
        
        # Check if executable
        if not os.access(script, os.X_OK):
            print(f"⚠️  Script not executable: {script}")
        else:
            print(f"✅ Script found and executable: {script}")
    
    return True

def main():
    """Run all tests"""
    print("🧪 Speech Translation System - Configuration Test")
    print("=" * 50)
    
    tests = [
        test_docker_compose,
        test_n8n_workflow,
        test_web_interface,
        test_python_service,
        test_dockerfiles,
        test_scripts
    ]
    
    results = []
    for test in tests:
        results.append(test())
    
    print("\n" + "=" * 50)
    print("📊 Test Results:")
    
    passed = sum(results)
    total = len(results)
    
    if passed == total:
        print(f"✅ All tests passed! ({passed}/{total})")
        print("\n🎉 System is ready for deployment!")
        return 0
    else:
        print(f"❌ Some tests failed ({passed}/{total})")
        print("\n🔧 Please fix the issues above before deployment.")
        return 1

if __name__ == "__main__":
    sys.exit(main())