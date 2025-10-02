// Detect if running in Docker or locally
const N8N_WEBHOOK_URL = (window.N8N_WEBHOOK_URL || 
  (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1' 
    ? 'http://127.0.0.1:8001/proxy/n8n' 
    : `http://${window.location.hostname}:8001/proxy/n8n`));

const languages = [
  { code: 'ar', name: 'Arabic' },
  { code: 'bg', name: 'Bulgarian' },
  { code: 'bn', name: 'Bengali' },
  { code: 'cs', name: 'Czech' },
  { code: 'da', name: 'Danish' },
  { code: 'de', name: 'German' },
  { code: 'el', name: 'Greek' },
  { code: 'en', name: 'English' },
  { code: 'es', name: 'Spanish' },
  { code: 'et', name: 'Estonian' },
  { code: 'fa', name: 'Persian' },
  { code: 'fi', name: 'Finnish' },
  { code: 'fr', name: 'French' },
  { code: 'he', name: 'Hebrew' },
  { code: 'hi', name: 'Hindi' },
  { code: 'hr', name: 'Croatian' },
  { code: 'hu', name: 'Hungarian' },
  { code: 'id', name: 'Indonesian' },
  { code: 'it', name: 'Italian' },
  { code: 'ja', name: 'Japanese' },
  { code: 'jv', name: 'Javanese' },
  { code: 'ko', name: 'Korean' },
  { code: 'lt', name: 'Lithuanian' },
  { code: 'lv', name: 'Latvian' },
  { code: 'ms', name: 'Malay' },
  { code: 'nl', name: 'Dutch' },
  { code: 'no', name: 'Norwegian' },
  { code: 'pl', name: 'Polish' },
  { code: 'pt', name: 'Portuguese' },
  { code: 'ro', name: 'Romanian' },
  { code: 'ru', name: 'Russian' },
  { code: 'sk', name: 'Slovak' },
  { code: 'sl', name: 'Slovenian' },
  { code: 'sr', name: 'Serbian' },
  { code: 'sv', name: 'Swedish' },
  { code: 'th', name: 'Thai' },
  { code: 'tr', name: 'Turkish' },
  { code: 'uk', name: 'Ukrainian' },
  { code: 'ur', name: 'Urdu' },
  { code: 'vi', name: 'Vietnamese' },
  { code: 'zh', name: 'Chinese' },
];

const languageSelect = document.getElementById('languageSelect');
const startBtn = document.getElementById('startBtn');
const stopBtn = document.getElementById('stopBtn');
const statusEl = document.getElementById('status');
const fileInput = document.getElementById('fileInput');
const uploadBtn = document.getElementById('uploadBtn');
const translatedText = document.getElementById('translatedText');
const saveBtn = document.getElementById('saveBtn');

languages.forEach(l => {
  const opt = document.createElement('option');
  opt.value = l.code;
  opt.textContent = `${l.name} (${l.code})`;
  if (l.code === 'en') opt.selected = true;
  languageSelect.appendChild(opt);
});

let mediaRecorder = null;
let chunks = [];

function resetRecorder() {
  chunks = [];
  mediaRecorder = null;
}

async function sendToN8N(blob, targetLang) {
  const form = new FormData();
  form.append('audio', blob, 'recording.webm');
  form.append('targetLang', targetLang);

  const resp = await fetch(N8N_WEBHOOK_URL, {
    method: 'POST',
    body: form,
  });
  if (!resp.ok) {
    throw new Error(`Request failed: ${resp.status}`);
  }
  return await resp.json();
}

startBtn.addEventListener('click', async () => {
  translatedText.value = '';
  statusEl.textContent = 'Requesting microphone...';
  
  try {
    // Check if mediaDevices is supported
    if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
      throw new Error('MediaDevices API not supported');
    }
    
    const constraints = { 
      audio: {
        echoCancellation: true,
        noiseSuppression: true,
        autoGainControl: true,
        sampleRate: 44100
      } 
    };
    
    const stream = await navigator.mediaDevices.getUserMedia(constraints);
    
    // Try different MIME types for better compatibility
    let mimeType = 'audio/webm';
    if (MediaRecorder.isTypeSupported('audio/webm;codecs=opus')) {
      mimeType = 'audio/webm;codecs=opus';
    } else if (MediaRecorder.isTypeSupported('audio/mp4')) {
      mimeType = 'audio/mp4';
    } else if (MediaRecorder.isTypeSupported('audio/wav')) {
      mimeType = 'audio/wav';
    }
    
    mediaRecorder = new MediaRecorder(stream, { mimeType });
    chunks = [];

    mediaRecorder.ondataavailable = e => {
      if (e.data && e.data.size > 0) chunks.push(e.data);
    };

    mediaRecorder.onstop = async () => {
      // Stop all tracks to release microphone
      stream.getTracks().forEach(track => track.stop());
      
      const blob = new Blob(chunks, { type: mimeType });
      statusEl.textContent = 'Translating...';
      
      try {
        const data = await sendToN8N(blob, languageSelect.value);
        translatedText.value = data.translatedText || '';
        statusEl.textContent = `Detected: ${data.sourceLanguage} → ${data.targetLanguage}`;
      } catch (err) {
        console.error('Translation error:', err);
        statusEl.textContent = `Error: ${err.message || 'Translation failed'}`;
      } finally {
        resetRecorder();
      }
    };

    mediaRecorder.onerror = (event) => {
      console.error('MediaRecorder error:', event.error);
      statusEl.textContent = `Recording error: ${event.error.name}`;
      resetRecorder();
    };

    mediaRecorder.start(1000); // Collect data every second
    statusEl.textContent = 'Recording... (click Stop when finished)';
    startBtn.disabled = true;
    stopBtn.disabled = false;
    
  } catch (err) {
    console.error('Microphone error:', err);
    let errorMsg = 'Microphone access denied or unavailable.';
    
    if (err.name === 'NotAllowedError') {
      errorMsg = 'Microphone access denied. Please allow microphone access and try again.';
    } else if (err.name === 'NotFoundError') {
      errorMsg = 'No microphone found. Please connect a microphone and try again.';
    } else if (err.name === 'NotSupportedError') {
      errorMsg = 'Audio recording not supported in this browser.';
    }
    
    statusEl.textContent = errorMsg;
  }
});

stopBtn.addEventListener('click', () => {
  if (mediaRecorder && mediaRecorder.state !== 'inactive') {
    mediaRecorder.stop();
    startBtn.disabled = false;
    stopBtn.disabled = true;
  }
});

uploadBtn.addEventListener('click', async () => {
  const file = fileInput.files && fileInput.files[0];
  if (!file) {
    alert('Please choose an audio file first.');
    return;
  }
  
  // Validate file type
  const validTypes = ['audio/wav', 'audio/mp3', 'audio/mpeg', 'audio/webm', 'audio/ogg', 'audio/m4a', 'audio/aac'];
  if (!validTypes.includes(file.type) && !file.name.match(/\.(wav|mp3|webm|ogg|m4a|aac)$/i)) {
    alert('Please select a valid audio file (WAV, MP3, WebM, OGG, M4A, AAC).');
    return;
  }
  
  // Check file size (limit to 50MB)
  if (file.size > 50 * 1024 * 1024) {
    alert('File size too large. Please select a file smaller than 50MB.');
    return;
  }
  
  translatedText.value = '';
  statusEl.textContent = 'Uploading & translating...';
  uploadBtn.disabled = true;
  
  try {
    const data = await sendToN8N(file, languageSelect.value);
    translatedText.value = data.translatedText || '';
    statusEl.textContent = `Detected: ${data.sourceLanguage} → ${data.targetLanguage}`;
  } catch (err) {
    console.error('Upload error:', err);
    statusEl.textContent = `Error: ${err.message || 'Upload failed'}`;
  } finally {
    uploadBtn.disabled = false;
  }
});

saveBtn.addEventListener('click', () => {
  const text = translatedText.value || '';
  const blob = new Blob([text], { type: 'text/plain;charset=utf-8' });
  const a = document.createElement('a');
  a.href = URL.createObjectURL(blob);
  a.download = `translation_${languageSelect.value}.txt`;
  a.click();
  URL.revokeObjectURL(a.href);
});

