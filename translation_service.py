#!/usr/bin/env python3
"""
Local Translation Service
Provides translation between languages using local models
Uses argostranslate for offline translation
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import logging
import argostranslate.package
import argostranslate.translate

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)

# Download and install translation packages on first run
def install_translation_packages():
    """Install available translation packages"""
    try:
        logger.info("Updating translation package index...")
        argostranslate.package.update_package_index()
        available_packages = argostranslate.package.get_available_packages()
        
        # Install commonly used translation packages
        # This is a subset - you can install more as needed
        priority_translations = [
            ('en', 'es'), ('es', 'en'),
            ('en', 'fr'), ('fr', 'en'),
            ('en', 'de'), ('de', 'en'),
            ('en', 'it'), ('it', 'en'),
            ('en', 'pt'), ('pt', 'en'),
            ('en', 'ru'), ('ru', 'en'),
            ('en', 'zh'), ('zh', 'en'),
            ('en', 'ja'), ('ja', 'en'),
            ('en', 'ko'), ('ko', 'en'),
            ('en', 'ar'), ('ar', 'en'),
            ('en', 'hi'), ('hi', 'en'),
        ]
        
        for from_code, to_code in priority_translations:
            package_to_install = next(
                (
                    pkg for pkg in available_packages
                    if pkg.from_code == from_code and pkg.to_code == to_code
                ),
                None
            )
            
            if package_to_install:
                try:
                    logger.info(f"Installing translation package: {from_code} -> {to_code}")
                    argostranslate.package.install_from_path(package_to_install.download())
                except Exception as e:
                    logger.warning(f"Could not install {from_code}->{to_code}: {e}")
        
        logger.info("Translation packages installation complete!")
    except Exception as e:
        logger.error(f"Error installing translation packages: {e}")

# Initialize translation packages
logger.info("Initializing translation service...")
install_translation_packages()
logger.info("Translation service ready!")

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'service': 'translation-local'
    })

@app.route('/translate', methods=['POST'])
def translate():
    """
    Translate text from source language to target language
    """
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({'error': 'No JSON data provided'}), 400
        
        text = data.get('text', '')
        source_lang = data.get('source_language', 'en')
        target_lang = data.get('target_language', 'en')
        
        if not text:
            return jsonify({'error': 'No text provided'}), 400
        
        logger.info(f"Translating from {source_lang} to {target_lang}")
        logger.info(f"Text: {text[:100]}...")
        
        # If source and target are the same, return original text
        if source_lang == target_lang:
            return jsonify({
                'success': True,
                'translated_text': text,
                'source_language': source_lang,
                'target_language': target_lang
            }), 200
        
        # Get installed translation
        installed_languages = argostranslate.translate.get_installed_languages()
        
        # Find source and target language objects
        source_language = next(
            (lang for lang in installed_languages if lang.code == source_lang),
            None
        )
        target_language = next(
            (lang for lang in installed_languages if lang.code == target_lang),
            None
        )
        
        if not source_language or not target_language:
            # Try translating through English as intermediate language
            if source_lang != 'en' and target_lang != 'en':
                logger.info(f"Direct translation not available, using English as intermediate")
                
                # Translate source -> English
                source_to_en = next(
                    (lang for lang in installed_languages if lang.code == source_lang),
                    None
                )
                english_lang = next(
                    (lang for lang in installed_languages if lang.code == 'en'),
                    None
                )
                
                if source_to_en and english_lang:
                    translation_en = source_to_en.get_translation(english_lang)
                    if translation_en:
                        intermediate_text = translation_en.translate(text)
                        
                        # Translate English -> target
                        en_to_target = english_lang.get_translation(target_language) if target_language else None
                        if en_to_target:
                            final_translation = en_to_target.translate(intermediate_text)
                            return jsonify({
                                'success': True,
                                'translated_text': final_translation,
                                'source_language': source_lang,
                                'target_language': target_lang,
                                'via_intermediate': True
                            }), 200
            
            return jsonify({
                'error': f'Translation from {source_lang} to {target_lang} not available',
                'suggestion': 'Install the required translation package'
            }), 400
        
        # Get translation object
        translation = source_language.get_translation(target_language)
        
        if not translation:
            return jsonify({
                'error': f'No translation available from {source_lang} to {target_lang}'
            }), 400
        
        # Perform translation
        translated_text = translation.translate(text)
        
        logger.info(f"Translated text: {translated_text[:100]}...")
        
        return jsonify({
            'success': True,
            'translated_text': translated_text,
            'source_language': source_lang,
            'target_language': target_lang
        }), 200
        
    except Exception as e:
        logger.error(f"Error translating text: {str(e)}", exc_info=True)
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/languages', methods=['GET'])
def get_languages():
    """
    Return list of installed translation languages
    """
    try:
        installed_languages = argostranslate.translate.get_installed_languages()
        languages = {lang.code: lang.name for lang in installed_languages}
        return jsonify(languages)
    except Exception as e:
        logger.error(f"Error getting languages: {e}")
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    logger.info("Starting translation service on http://0.0.0.0:9001")
    app.run(host='0.0.0.0', port=9001, debug=False)
