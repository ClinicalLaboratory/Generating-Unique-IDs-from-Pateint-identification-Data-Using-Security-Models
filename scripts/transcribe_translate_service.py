import os
import io
import tempfile
import shutil
from typing import Optional, Dict, Any

from fastapi import FastAPI, UploadFile, File, Form, HTTPException
from fastapi.responses import JSONResponse, Response
from fastapi.middleware.cors import CORSMiddleware
import httpx
import uvicorn

import torch
import whisper

# Argos Translate
from argostranslate import package as argos_package
from argostranslate import translate as argos_translate


def get_env(name: str, default: Optional[str] = None) -> str:
    value = os.environ.get(name)
    return value if value is not None else (default if default is not None else "")


WHISPER_MODEL_NAME = get_env("WHISPER_MODEL", "base")
DEVICE = "cuda" if torch.cuda.is_available() else "cpu"


class LazyWhisperModel:
    _model = None

    @classmethod
    def get(cls):
        if cls._model is None:
            cls._model = whisper.load_model(WHISPER_MODEL_NAME, device=DEVICE)
        return cls._model


def normalize_lang_code(code: str) -> str:
    if not code:
        return "en"
    code = code.lower()
    # Normalize common variants
    mappings = {
        "zh-cn": "zh",
        "zh-hans": "zh",
        "zh-hant": "zh",
        "pt-br": "pt",
        "pt-pt": "pt",
        "he": "he",
        "iw": "he",
        "jw": "jv",
    }
    return mappings.get(code, code.split("-")[0])


def ensure_argos_model(from_code: str, to_code: str) -> None:
    from_code = normalize_lang_code(from_code)
    to_code = normalize_lang_code(to_code)

    # Refresh index once per process to discover models
    try:
        argos_package.update_package_index()
    except Exception:
        # If offline, proceed with whatever is installed
        pass

    installed = argos_translate.load_installed_languages()
    has_direct = False
    for lang in installed:
        if lang.code == from_code:
            for t in installed:
                if t.code == to_code:
                    try:
                        _ = lang.get_translation(t)
                        has_direct = True
                    except Exception:
                        has_direct = False
            break

    if has_direct:
        return

    # Try to install direct package
    try:
        available = argos_package.get_available_packages()
        for pkg in available:
            if pkg.from_code == from_code and pkg.to_code == to_code:
                dl_path = pkg.download()
                argos_package.install_from_path(dl_path)
                return
    except Exception:
        # Ignore failures; may be offline
        pass


def load_translator(from_code: str, to_code: str):
    from_code = normalize_lang_code(from_code)
    to_code = normalize_lang_code(to_code)
    languages = argos_translate.load_installed_languages()
    from_lang = next((l for l in languages if l.code == from_code), None)
    to_lang = next((l for l in languages if l.code == to_code), None)
    if not from_lang or not to_lang:
        return None
    try:
        return from_lang.get_translation(to_lang)
    except Exception:
        return None


def transcribe_and_translate(audio_path: str, target_lang: str) -> Dict[str, Any]:
    model = LazyWhisperModel.get()

    # Load & detect language
    audio = whisper.load_audio(audio_path)
    mel = whisper.log_mel_spectrogram(audio).to(model.device)
    _, probs = model.detect_language(mel)
    detected_lang = normalize_lang_code(max(probs, key=probs.get))

    # Full transcription
    result = model.transcribe(audio_path, language=detected_lang, task="transcribe")
    transcription = result.get("text", "").strip()

    target_lang = normalize_lang_code(target_lang)

    # Ensure translation model and translate
    ensure_argos_model(detected_lang, target_lang)
    translator = load_translator(detected_lang, target_lang)

    if translator is None and detected_lang != "en":
        # Try pivot via English
        ensure_argos_model(detected_lang, "en")
        ensure_argos_model("en", target_lang)
        translator_src_en = load_translator(detected_lang, "en")
        translator_en_tgt = load_translator("en", target_lang)
        if translator_src_en and translator_en_tgt:
            intermediate = translator_src_en.translate(transcription)
            translated = translator_en_tgt.translate(intermediate)
        else:
            translated = transcription if detected_lang == target_lang else transcription
    elif translator is None and detected_lang == "en":
        ensure_argos_model("en", target_lang)
        translator_en_tgt = load_translator("en", target_lang)
        translated = translator_en_tgt.translate(transcription) if translator_en_tgt else transcription
    else:
        translated = translator.translate(transcription) if translator else transcription

    return {
        "transcription": transcription,
        "sourceLanguage": detected_lang,
        "targetLanguage": target_lang,
        "translatedText": translated,
        "model": WHISPER_MODEL_NAME,
        "device": DEVICE,
    }


app = FastAPI(title="Local Whisper + Argos Service")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"]
)


@app.get("/healthz")
def healthz():
    # Touch the model to ensure it loads without error
    try:
        _ = LazyWhisperModel.get()
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    return {"status": "ok", "model": WHISPER_MODEL_NAME, "device": DEVICE}


@app.post("/transcribe-translate")
async def transcribe_translate(audio: UploadFile = File(...), target: str = Form("en")):
    # Persist upload to a temporary file for Whisper/ffmpeg
    suffix = ""
    if audio.filename and "." in audio.filename:
        suffix = os.path.splitext(audio.filename)[1]
    elif audio.content_type == "audio/webm":
        suffix = ".webm"
    elif audio.content_type == "audio/wav":
        suffix = ".wav"
    elif audio.content_type == "audio/mpeg":
        suffix = ".mp3"
    else:
        suffix = ".bin"

    with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as tmp:
        temp_path = tmp.name
        content = await audio.read()
        tmp.write(content)

    try:
        result = transcribe_and_translate(temp_path, target)
        return JSONResponse(result)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        try:
            os.remove(temp_path)
        except Exception:
            pass


@app.post("/proxy/n8n")
async def proxy_to_n8n(audio: UploadFile = File(...), targetLang: str = Form("en")):
    # streams to local n8n webhook to avoid browser CORS
    webhook_url = os.environ.get("N8N_WEBHOOK_URL", "http://localhost:5678/webhook-test/speech-translate")
    content = await audio.read()
    files = {
        "audio": (audio.filename or "audio.webm", content, audio.content_type or "application/octet-stream"),
        "targetLang": (None, targetLang),
    }
    async with httpx.AsyncClient(timeout=600) as client:
        resp = await client.post(webhook_url, files=files)
        # Try JSON; if not JSON, return raw content and status
        try:
            data = resp.json()
            return JSONResponse(data, status_code=resp.status_code)
        except Exception:
            return Response(content=resp.content, status_code=resp.status_code, media_type=resp.headers.get("content-type", "text/plain"))


if __name__ == "__main__":
    uvicorn.run("scripts.transcribe_translate_service:app", host="127.0.0.1", port=int(get_env("PORT", "8001")), reload=False)

