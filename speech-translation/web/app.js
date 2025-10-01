const N8N_WEBHOOK_URL = (window.N8N_WEBHOOK_URL || 'http://127.0.0.1:8001/proxy/n8n');

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
    const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
    const mime = MediaRecorder.isTypeSupported('audio/webm;codecs=opus') ? 'audio/webm;codecs=opus' : 'audio/webm';
    mediaRecorder = new MediaRecorder(stream, { mimeType: mime });
    chunks = [];

    mediaRecorder.ondataavailable = e => {
      if (e.data && e.data.size > 0) chunks.push(e.data);
    };

    mediaRecorder.onstop = async () => {
      const blob = new Blob(chunks, { type: 'audio/webm' });
      statusEl.textContent = 'Translating...';
      try {
        const data = await sendToN8N(blob, languageSelect.value);
        translatedText.value = data.translatedText || '';
        statusEl.textContent = `Detected: ${data.sourceLanguage} → ${data.targetLanguage}`;
      } catch (err) {
        console.error(err);
        statusEl.textContent = 'Error translating. See console.';
      } finally {
        resetRecorder();
      }
    };

    mediaRecorder.start();
    statusEl.textContent = 'Recording...';
    startBtn.disabled = true;
    stopBtn.disabled = false;
  } catch (err) {
    console.error(err);
    statusEl.textContent = 'Microphone access denied or unavailable.';
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
  translatedText.value = '';
  statusEl.textContent = 'Uploading & translating...';
  try {
    const data = await sendToN8N(file, languageSelect.value);
    translatedText.value = data.translatedText || '';
    statusEl.textContent = `Detected: ${data.sourceLanguage} → ${data.targetLanguage}`;
  } catch (err) {
    console.error(err);
    statusEl.textContent = 'Error translating. See console.';
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

