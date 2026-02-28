# Cataract Detection - FastAPI Backend

FastAPI backend that accepts eye images and returns cataract predictions using one or two TFLite models.

## Setup

1. Install Python 3.9+

2. Install dependencies:
```bash
pip install -r requirements.txt
```

This backend is configured to use `tflite-runtime` by default and does not
import TensorFlow unless you explicitly set `ALLOW_TF_LITE_FALLBACK=1`.

3. Place the model files in the project root:
```
resnet50_cataract_99percent_float16.tflite
densenet121_cataract.tflite
```

4. Run the server from the project root:
```bash
uvicorn backend.app:app --host 0.0.0.0 --port 8080
```

## API Endpoints

### POST /predict

Send an eye image, get a cataract prediction.

```bash
curl -X POST http://localhost:8080/predict \
  -F "file=@eye_image.jpg"
```

**Response:**
```json
{
  "prediction": 0.15,
  "className": "Cataract",
  "confidence": 85.0,
  "inferenceTime": 0.234
}
```

### GET /health

```json
{"status": "healthy", "ensembleMode": true}
```

## VPS Deployment

```bash
git clone https://github.com/YOUR_USER/YOUR_REPO.git
cd YOUR_REPO
pip install -r requirements.txt
# copy model files to the project root
uvicorn backend.app:app --host 0.0.0.0 --port 8080
```

For production, run behind a reverse proxy (nginx) with:
```bash
uvicorn backend.app:app --host 127.0.0.1 --port 8080 --workers 2
```
