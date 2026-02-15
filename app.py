"""
FastAPI Backend for Cataract Detection

Accepts eye images via POST /predict, runs inference using a TFLite model,
and returns the prediction result.

Usage:
    uvicorn app:app --host 0.0.0.0 --port 8080
"""

import io
import time
import numpy as np
from PIL import Image
from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="Cataract Detection API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# ---------------------------------------------------------------------------
# Model loading – try TFLite first, fall back to full TensorFlow / Keras
# ---------------------------------------------------------------------------
MODEL_PATH = "resnet50_cataract_99percent_float16.tflite"
_interpreter = None
_keras_model = None


def _load_model():
    """Load the model once at startup."""
    global _interpreter, _keras_model

    # Try tflite-runtime first (lightweight)
    try:
        import tflite_runtime.interpreter as tflite
        _interpreter = tflite.Interpreter(model_path=MODEL_PATH)
        _interpreter.allocate_tensors()
        print(f"Loaded TFLite model from {MODEL_PATH} (tflite-runtime)")
        return
    except Exception:
        pass

    # Fall back to TensorFlow's built-in TFLite interpreter
    try:
        import tensorflow as tf
        _interpreter = tf.lite.Interpreter(model_path=MODEL_PATH)
        _interpreter.allocate_tensors()
        print(f"Loaded TFLite model from {MODEL_PATH} (tensorflow)")
        return
    except Exception as e:
        raise RuntimeError(
            f"Could not load model '{MODEL_PATH}'. "
            "Install tflite-runtime or tensorflow. "
            f"Error: {e}"
        )


def _predict(image_bytes: bytes) -> dict:
    """Run inference on raw image bytes and return the result dict."""
    if _interpreter is None:
        raise RuntimeError("Model not loaded")

    # Get model input details
    input_details = _interpreter.get_input_details()
    output_details = _interpreter.get_output_details()

    # Determine expected input shape (e.g. [1, 224, 224, 3])
    input_shape = input_details[0]["shape"]  # [batch, height, width, channels]
    height, width = input_shape[1], input_shape[2]

    # Preprocess image
    img = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    img = img.resize((width, height))
    img_array = np.array(img, dtype=np.float32) / 255.0
    img_array = np.expand_dims(img_array, axis=0)

    # Run inference
    _interpreter.set_tensor(input_details[0]["index"], img_array)
    _interpreter.invoke()
    output = _interpreter.get_tensor(output_details[0]["index"])

    prediction_value = float(output[0][0])

    # Determine class
    if prediction_value < 0.7:
        class_name = "Cataract"
        confidence = (1 - prediction_value) * 100
    else:
        class_name = "Normal"
        confidence = prediction_value * 100

    return {
        "prediction": prediction_value,
        "className": class_name,
        "confidence": round(confidence, 2),
    }


# ---------------------------------------------------------------------------
# Endpoints
# ---------------------------------------------------------------------------

@app.on_event("startup")
async def startup():
    _load_model()


@app.get("/health")
async def health():
    return {"status": "healthy"}


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
