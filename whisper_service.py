#!/usr/bin/env python3
"""
Whisper Local Service
Provides a REST API for audio transcription and translation using OpenAI Whisper
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import whisper
import tempfile
import os
import logging
from werkzeug.utils import secure_filename

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# Load Whisper model (using 'base' for balance between speed and accuracy)
# Options: tiny, base, small, medium, large
logger.info("Loading Whisper model...")
model = whisper.load_model("base")
logger.info("Whisper model loaded successfully!")

ALLOWED_EXTENSIONS = {'wav', 'mp3', 'mp4', 'm4a', 'ogg', 'webm', 'flac'}

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'service': 'whisper-local',
        'model': 'base'
    })

@app.route('/transcribe', methods=['POST'])
def transcribe():
    """
    Transcribe audio file and optionally translate to English or specified language
    """
    try:
        # Check if audio file is present
        if 'audio' not in request.files:
            return jsonify({'error': 'No audio file provided'}), 400
        
        audio_file = request.files['audio']
        
        if audio_file.filename == '':
            return jsonify({'error': 'Empty filename'}), 400
        
        # Get target language from request
        target_language = request.form.get('target_language', 'en')
        task = request.form.get('task', 'transcribe')  # transcribe or translate
        
        # Create temporary file to store audio
        with tempfile.NamedTemporaryFile(delete=False, suffix='.audio') as temp_audio:
            audio_file.save(temp_audio.name)
            temp_audio_path = temp_audio.name
        
        try:
            logger.info(f"Processing audio file: {audio_file.filename}")
            logger.info(f"Task: {task}, Target Language: {target_language}")
            
            # Transcribe audio using Whisper
            # Whisper will automatically detect the source language
            result = model.transcribe(
                temp_audio_path,
                task=task,  # 'transcribe' or 'translate' (translate means translate to English)
                verbose=False
            )
            
            # Extract information
            detected_language = result.get('language', 'unknown')
            transcribed_text = result.get('text', '').strip()
            
            logger.info(f"Detected language: {detected_language}")
            logger.info(f"Transcribed text: {transcribed_text[:100]}...")
            
            response = {
                'success': True,
                'detected_language': detected_language,
                'transcribed_text': transcribed_text,
                'target_language': target_language,
                'segments': result.get('segments', [])
            }
            
            return jsonify(response), 200
            
        finally:
            # Clean up temporary file
            if os.path.exists(temp_audio_path):
                os.unlink(temp_audio_path)
                logger.info("Temporary audio file deleted")
    
    except Exception as e:
        logger.error(f"Error processing audio: {str(e)}", exc_info=True)
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/languages', methods=['GET'])
def get_languages():
    """
    Return list of supported languages
    """
    languages = {
        'en': 'English',
        'es': 'Spanish',
        'fr': 'French',
        'de': 'German',
        'it': 'Italian',
        'pt': 'Portuguese',
        'nl': 'Dutch',
        'ru': 'Russian',
        'zh': 'Chinese',
        'ja': 'Japanese',
        'ko': 'Korean',
        'ar': 'Arabic',
        'hi': 'Hindi',
        'tr': 'Turkish',
        'pl': 'Polish',
        'uk': 'Ukrainian',
        'vi': 'Vietnamese',
        'th': 'Thai',
        'id': 'Indonesian',
        'ms': 'Malay',
        'fa': 'Persian',
        'el': 'Greek',
        'he': 'Hebrew',
        'sv': 'Swedish',
        'no': 'Norwegian',
        'da': 'Danish',
        'fi': 'Finnish',
        'cs': 'Czech',
        'ro': 'Romanian',
        'hu': 'Hungarian',
        'sk': 'Slovak'
    }
    return jsonify(languages)

if __name__ == '__main__':
    # Run on port 9000
    logger.info("Starting Whisper service on http://0.0.0.0:9000")
    app.run(host='0.0.0.0', port=9000, debug=False)
