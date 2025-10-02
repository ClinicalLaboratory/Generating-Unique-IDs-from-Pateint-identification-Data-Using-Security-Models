#!/usr/bin/env python3
"""
Service Health Check Script
Tests if all services are running and responding correctly
"""

import requests
import sys
import time

def test_service(name, url, timeout=5):
    """Test if a service is responding"""
    try:
        response = requests.get(url, timeout=timeout)
        if response.status_code == 200:
            print(f"✓ {name} is running and healthy")
            return True
        else:
            print(f"✗ {name} returned status code {response.status_code}")
            return False
    except requests.exceptions.ConnectionError:
        print(f"✗ {name} is not responding (connection refused)")
        return False
    except requests.exceptions.Timeout:
        print(f"✗ {name} timed out")
        return False
    except Exception as e:
        print(f"✗ {name} error: {e}")
        return False

def main():
    print("=" * 50)
    print("Speech Translation System Health Check")
    print("=" * 50)
    print()
    
    services = [
        ("Web Interface", "http://localhost:8000"),
        ("n8n Dashboard", "http://localhost:5678"),
        ("Whisper Service", "http://localhost:9000/health"),
        ("Translation Service", "http://localhost:9001/health"),
    ]
    
    results = []
    for name, url in services:
        print(f"Testing {name}...")
        result = test_service(name, url)
        results.append(result)
        time.sleep(0.5)
        print()
    
    print("=" * 50)
    print("Summary")
    print("=" * 50)
    
    all_healthy = all(results)
    
    if all_healthy:
        print("✓ All services are running correctly!")
        print()
        print("You can now use the system at:")
        print("  http://localhost:8000")
        return 0
    else:
        print("✗ Some services are not running")
        print()
        print("Please ensure:")
        print("  1. Docker Desktop is running")
        print("  2. You have run: .\\start_system.bat")
        print("  3. All services have finished starting (wait 30-60 seconds)")
        return 1

if __name__ == "__main__":
    sys.exit(main())
