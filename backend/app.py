"""
FastAPI Backend for Cataract Detection - Dual Model Ensemble

Accepts eye images via POST /predict, runs inference using TWO TFLite models
(ResNet50 and EfficientNetB0), and returns the averaged ensemble prediction.

Usage:
    uvicorn app:app --host 0.0.0.0 --port 8080
"""

import io
import time
import numpy as np
from PIL import Image
from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="Cataract Detection API - Ensemble")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# ---------------------------------------------------------------------------
# Model loading – dual model ensemble
# ---------------------------------------------------------------------------
MODEL_1_PATH = "resnet50_cataract_99percent_float16.tflite"
MODEL_2_PATH = "densenet121_cataract.tflite"  # DenseNet121 - excellent for medical imaging

_interpreter1 = None
_interpreter2 = None


def _load_model(model_path: str):
    """Load a single TFLite model."""
    # Try tflite-runtime first (lightweight)
    try:
        import tflite_runtime.interpreter as tflite
        interpreter = tflite.Interpreter(model_path=model_path)
        interpreter.allocate_tensors()
        print(f"Loaded TFLite model from {model_path} (tflite-runtime)")
        return interpreter
    except Exception:
        pass

    # Fall back to TensorFlow's built-in TFLite interpreter
    try:
        import tensorflow as tf
        interpreter = tf.lite.Interpreter(model_path=model_path)
        interpreter.allocate_tensors()
        print(f"Loaded TFLite model from {model_path} (tensorflow)")
        return interpreter
    except Exception as e:
        print(f"Warning: Could not load model '{model_path}'. Error: {e}")
        return None


def _load_models():
    """Load both models at startup."""
    global _interpreter1, _interpreter2

    # Load Model 1 (ResNet50)
    _interpreter1 = _load_model(MODEL_1_PATH)

    # Load Model 2 (EfficientNetB0)
    _interpreter2 = _load_model(MODEL_2_PATH)

    # Verify at least one model loaded
    if _interpreter1 is None and _interpreter2 is None:
        raise RuntimeError(
            f"Could not load any model. "
            "Install tflite-runtime or tensorflow."
        )

    # Log ensemble status
    if _interpreter1 and _interpreter2:
        print("✅ Ensemble mode: Both ResNet50 and DenseNet121 loaded")
    elif _interpreter1:
        print(f"⚠️ Single model mode: Only {MODEL_1_PATH} loaded")
    else:
        print(f"⚠️ Single model mode: Only {MODEL_2_PATH} loaded")


def _run_inference(interpreter, image_bytes: bytes) -> float:
    """
    Run inference on a single model and return the raw prediction value.

    Args:
        interpreter: TFLite interpreter instance
        image_bytes: Raw image bytes

    Returns:
        float: Raw prediction value (0-1, where 1 = Normal, 0 = Cataract)
    """
    if interpreter is None:
        raise RuntimeError("Model interpreter not loaded")

    # Get model input details
    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()

    # Determine expected input shape
    input_shape = input_details[0]["shape"]
    height, width = input_shape[1], input_shape[2]

    # Preprocess image
    img = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    img = img.resize((width, height))
    img_array = np.array(img, dtype=np.float32) / 255.0
    img_array = np.expand_dims(img_array, axis=0)

    # Run inference
    interpreter.set_tensor(input_details[0]["index"], img_array)
    interpreter.invoke()
    output = interpreter.get_tensor(output_details[0]["index"])

    return float(output[0][0])


def _predict_ensemble(image_bytes: bytes) -> dict:
    """
    Run ensemble inference using both models.

    The ensemble averages predictions from both models:
    - If both models available: simple average
    - If only one model available: use that model's prediction

    Args:
        image_bytes: Raw image bytes

    Returns:
        dict with prediction, className, confidence, and model details
    """
    predictions = []
    models_used = []

    # Run inference on Model 1 (ResNet50)
    if _interpreter1 is not None:
        try:
            pred1 = _run_inference(_interpreter1, image_bytes)
            predictions.append(pred1)
            models_used.append("ResNet50")
        except Exception as e:
            print(f"Warning: Model 1 inference failed: {e}")

    # Run inference on Model 2 (DenseNet121)
    if _interpreter2 is not None:
        try:
            pred2 = _run_inference(_interpreter2, image_bytes)
            predictions.append(pred2)
            models_used.append("DenseNet121")
        except Exception as e:
            print(f"Warning: Model 2 inference failed: {e}")

    if not predictions:
        raise RuntimeError("No models available for inference")

    # Average the predictions
    avg_prediction = sum(predictions) / len(predictions)

    # Determine class (same threshold logic as original)
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
    }


# ---------------------------------------------------------------------------
# Endpoints
# ---------------------------------------------------------------------------

@app.on_event("startup")
async def startup():
    _load_models()


@app.get("/health")
async def health():
    """Health check endpoint that also reports model status."""
    models_loaded = []
    if _interpreter1 is not None:
        models_loaded.append("ResNet50")
    if _interpreter2 is not None:
        models_loaded.append("DenseNet121")

    return {
        "status": "healthy",
        "ensembleMode": len(models_loaded) == 2,
        "modelsLoaded": models_loaded
    }


@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    """
    Predict cataract using ensemble of models.

    Returns:
        JSON with:
        - prediction: averaged prediction value (0-1)
        - className: "Cataract" or "Normal"
        - confidence: confidence percentage
        - inferenceTime: time taken for inference
        - modelsUsed: list of models that were used
    """
    if file.content_type and not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="File must be an image")

    image_bytes = await file.read()
    if not image_bytes:
        raise HTTPException(status_code=400, detail="Empty file")

    start = time.time()
    result = _predict_ensemble(image_bytes)
    elapsed = time.time() - start
    result["inferenceTime"] = round(elapsed, 3)

    return result
