// Configuration
const N8N_WEBHOOK_URL = 'http://localhost:5678/webhook/speech-translate';

// DOM Elements
const recordButton = document.getElementById('recordButton');
const audioUpload = document.getElementById('audioUpload');
const targetLanguageSelect = document.getElementById('targetLanguage');
const translatedTextArea = document.getElementById('translatedText');
const saveButton = document.getElementById('saveButton');
const clearButton = document.getElementById('clearButton');
const statusIndicator = document.getElementById('statusIndicator');
const fileName = document.getElementById('fileName');
const metadata = document.getElementById('metadata');
const detectedLanguageDiv = document.getElementById('detectedLanguage');
const originalTextDiv = document.getElementById('originalText');

// State
let mediaRecorder = null;
let audioChunks = [];
let isRecording = false;
let currentTranslationData = null;

// Language mapping for display
const languageNames = {
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
    'ms': 'Malay'
};

// Status message functions
function showStatus(message, type) {
    statusIndicator.textContent = message;
    statusIndicator.className = `status-indicator ${type}`;
}

function hideStatus() {
    statusIndicator.style.display = 'none';
}

// Recording functionality
recordButton.addEventListener('click', async () => {
    if (!isRecording) {
        await startRecording();
    } else {
        stopRecording();
    }
});

async function startRecording() {
    try {
        showStatus('Requesting microphone access...', 'info');
        
        const stream = await navigator.mediaDevices.getUserMedia({ 
            audio: {
                echoCancellation: true,
                noiseSuppression: true,
                autoGainControl: true
            } 
        });
        
        // Use appropriate MIME type based on browser support
        let mimeType = 'audio/webm';
        if (MediaRecorder.isTypeSupported('audio/webm;codecs=opus')) {
            mimeType = 'audio/webm;codecs=opus';
        } else if (MediaRecorder.isTypeSupported('audio/ogg;codecs=opus')) {
            mimeType = 'audio/ogg;codecs=opus';
        } else if (MediaRecorder.isTypeSupported('audio/mp4')) {
            mimeType = 'audio/mp4';
        }
        
        mediaRecorder = new MediaRecorder(stream, { mimeType });
        audioChunks = [];
        
        mediaRecorder.ondataavailable = (event) => {
            if (event.data.size > 0) {
                audioChunks.push(event.data);
            }
        };
        
        mediaRecorder.onstop = async () => {
            const audioBlob = new Blob(audioChunks, { type: mimeType });
            audioChunks = [];
            
            // Stop all tracks to release microphone
            stream.getTracks().forEach(track => track.stop());
            
            await processAudio(audioBlob);
        };
        
        mediaRecorder.start();
        isRecording = true;
        
        recordButton.classList.add('recording');
        recordButton.innerHTML = `
            <svg class="icon" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8 7a1 1 0 00-1 1v4a1 1 0 001 1h4a1 1 0 001-1V8a1 1 0 00-1-1H8z" clip-rule="evenodd"/>
            </svg>
            <span>Stop Recording</span>
        `;
        
        showStatus('Recording... Click "Stop Recording" when done', 'processing');
        
    } catch (error) {
        console.error('Error accessing microphone:', error);
        showStatus('Error: Could not access microphone. Please check permissions.', 'error');
    }
}

function stopRecording() {
    if (mediaRecorder && mediaRecorder.state !== 'inactive') {
        mediaRecorder.stop();
        isRecording = false;
        
        recordButton.classList.remove('recording');
        recordButton.innerHTML = `
            <svg class="icon" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM9.555 7.168A1 1 0 008 8v4a1 1 0 001.555.832l3-2a1 1 0 000-1.664l-3-2z" clip-rule="evenodd"/>
            </svg>
            <span>Start Recording</span>
        `;
        
        showStatus('Processing recording...', 'processing');
    }
}

// File upload functionality
audioUpload.addEventListener('change', async (event) => {
    const file = event.target.files[0];
    if (file) {
        fileName.textContent = `Selected: ${file.name}`;
        await processAudio(file);
    }
});

// Process audio (from recording or upload)
async function processAudio(audioBlob) {
    try {
        showStatus('Processing audio... This may take a moment', 'processing');
        
        // Disable buttons during processing
        recordButton.disabled = true;
        audioUpload.disabled = true;
        
        const targetLanguage = targetLanguageSelect.value;
        
        // Create FormData
        const formData = new FormData();
        formData.append('audio', audioBlob, 'audio_file');
        formData.append('target_language', targetLanguage);
        
        // Send to n8n webhook
        const response = await fetch(N8N_WEBHOOK_URL, {
            method: 'POST',
            body: formData
        });
        
        if (!response.ok) {
            throw new Error(`Server error: ${response.status} ${response.statusText}`);
        }
        
        const result = await response.json();
        
        if (result.success) {
            // Display results
            translatedTextArea.value = result.translated_text;
            currentTranslationData = result;
            
            // Show metadata
            const detectedLang = languageNames[result.detected_language] || result.detected_language;
            detectedLanguageDiv.textContent = detectedLang;
            originalTextDiv.textContent = result.transcribed_text.substring(0, 50) + 
                (result.transcribed_text.length > 50 ? '...' : '');
            metadata.style.display = 'flex';
            
            // Enable save button
            saveButton.disabled = false;
            
            showStatus(`✓ Translation complete! Detected ${detectedLang}`, 'success');
        } else {
            throw new Error(result.error || 'Translation failed');
        }
        
    } catch (error) {
        console.error('Error processing audio:', error);
        showStatus(`Error: ${error.message}. Make sure n8n and services are running.`, 'error');
    } finally {
        // Re-enable buttons
        recordButton.disabled = false;
        audioUpload.disabled = false;
    }
}

// Save functionality
saveButton.addEventListener('click', () => {
    if (!currentTranslationData) return;
    
    const targetLang = languageNames[currentTranslationData.target_language];
    const detectedLang = languageNames[currentTranslationData.detected_language];
    const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
    
    // Create file content
    const content = `Speech Translation Result
========================
Date: ${new Date().toLocaleString()}
Detected Language: ${detectedLang}
Target Language: ${targetLang}

Original Transcription:
${currentTranslationData.transcribed_text}

Translated Text (${targetLang}):
${currentTranslationData.translated_text}
`;
    
    // Create and download file
    const blob = new Blob([content], { type: 'text/plain;charset=utf-8' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `translation_${currentTranslationData.target_language}_${timestamp}.txt`;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
    
    showStatus('Translation saved successfully!', 'success');
});

// Clear functionality
clearButton.addEventListener('click', () => {
    translatedTextArea.value = '';
    fileName.textContent = '';
    audioUpload.value = '';
    metadata.style.display = 'none';
    currentTranslationData = null;
    saveButton.disabled = true;
    hideStatus();
});

// Initial state
showStatus('Ready! Select a target language and provide audio to translate.', 'info');
