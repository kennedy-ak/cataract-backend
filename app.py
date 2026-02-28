"""
FastAPI backend for cataract detection.

Accepts eye images via POST /predict, runs inference using one or two TFLite
models, and returns either a single-model result or an averaged ensemble.

Usage:
    uvicorn app:app --host 0.0.0.0 --port 8080
"""

import io
import os
import time
from pathlib import Path

import numpy as np
from fastapi import FastAPI, File, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from PIL import Image

app = FastAPI(title="Cataract Detection API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

BASE_DIR = Path(__file__).resolve().parent
MODEL_PATHS = [
    ("ResNet50", BASE_DIR / "resnet50_cataract_99percent_float16.tflite"),
    ("DenseNet121", BASE_DIR / "densenet121_cataract.tflite"),
]
ALLOW_TENSORFLOW_FALLBACK = os.getenv("ALLOW_TF_LITE_FALLBACK", "").lower() in {
    "1",
    "true",
    "yes",
}

_loaded_models = []


def _create_interpreter(model_path: Path):
    errors = []

    try:
        import tflite_runtime.interpreter as tflite

        interpreter = tflite.Interpreter(model_path=str(model_path))
        interpreter.allocate_tensors()
        print(f"Loaded TFLite model from {model_path.name} (tflite-runtime)")
        return interpreter
    except Exception as exc:
        errors.append(f"tflite-runtime: {exc}")

    if ALLOW_TENSORFLOW_FALLBACK:
        try:
            import tensorflow as tf

            interpreter = tf.lite.Interpreter(model_path=str(model_path))
            interpreter.allocate_tensors()
            print(f"Loaded TFLite model from {model_path.name} (tensorflow)")
            return interpreter
        except Exception as exc:
            errors.append(f"tensorflow: {exc}")

    joined_errors = "; ".join(errors)
    tf_hint = ""
    if not ALLOW_TENSORFLOW_FALLBACK:
        tf_hint = " Set ALLOW_TF_LITE_FALLBACK=1 to permit TensorFlow as a fallback."

    raise RuntimeError(
        f"Could not load '{model_path.name}'. Install tflite-runtime.{tf_hint} "
        f"Loader errors: {joined_errors}"
    )


def _load_models():
    global _loaded_models

    loaded_models = []
    for model_name, model_path in MODEL_PATHS:
        if not model_path.exists():
            print(f"Skipping missing model: {model_path.name}")
            continue

        interpreter = _create_interpreter(model_path)
        loaded_models.append((model_name, interpreter))

    if not loaded_models:
        expected = ", ".join(path.name for _, path in MODEL_PATHS)
        raise RuntimeError(
            f"No models could be loaded. Expected at least one of: {expected}"
        )

    _loaded_models = loaded_models

    model_names = ", ".join(model_name for model_name, _ in _loaded_models)
    if len(_loaded_models) > 1:
        print(f"Ensemble mode enabled: {model_names}")
    else:
        print(f"Single-model mode enabled: {model_names}")


def _run_inference(interpreter, image_bytes: bytes) -> float:
    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()

    input_shape = input_details[0]["shape"]
    height, width = input_shape[1], input_shape[2]

    img = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    img = img.resize((width, height))
    img_array = np.array(img, dtype=np.float32) / 255.0
    img_array = np.expand_dims(img_array, axis=0)

    interpreter.set_tensor(input_details[0]["index"], img_array)
    interpreter.invoke()
    output = interpreter.get_tensor(output_details[0]["index"])

    return float(output[0][0])


def _predict(image_bytes: bytes) -> dict:
    if not _loaded_models:
        raise RuntimeError("No model interpreters loaded")

    predictions = []
    models_used = []

    for model_name, interpreter in _loaded_models:
        prediction = _run_inference(interpreter, image_bytes)
        predictions.append(prediction)
        models_used.append(model_name)

    avg_prediction = sum(predictions) / len(predictions)

    if avg_prediction < 0.7:
        class_name = "Cataract"
        confidence = (1 - avg_prediction) * 100
    else:
        class_name = "Normal"
        confidence = avg_prediction * 100

    return {
        "prediction": round(avg_prediction, 4),
        "className": class_name,
        "confidence": round(confidence, 2),
        "modelsUsed": models_used,
        "ensembleMode": len(models_used) > 1,
    }


@app.on_event("startup")
async def startup():
    _load_models()


@app.get("/health")
async def health():
    return {
        "status": "healthy",
        "modelsLoaded": [model_name for model_name, _ in _loaded_models],
        "ensembleMode": len(_loaded_models) > 1,
        "tensorflowFallbackEnabled": ALLOW_TENSORFLOW_FALLBACK,
    }


@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    if file.content_type and not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="File must be an image")

    image_bytes = await file.read()
    if not image_bytes:
        raise HTTPException(status_code=400, detail="Empty file")

    start = time.time()
    result = _predict(image_bytes)
    elapsed = time.time() - start
    result["inferenceTime"] = round(elapsed, 3)

    return result
