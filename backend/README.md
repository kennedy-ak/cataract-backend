# Cataract Detection - FastAPI Backend

FastAPI backend that accepts eye images and returns cataract predictions using a TFLite model.

## Setup

1. Install Python 3.9+

2. Install dependencies:
```bash
pip install -r requirements.txt
```

3. Place the model file in this directory:
```
backend/
├── app.py
├── requirements.txt
└── resnet50_cataract_99percent_float16.tflite  ← copy this here
```

4. Run the server:
```bash
uvicorn app:app --host 0.0.0.0 --port 8080
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
{"status": "healthy"}
```

## VPS Deployment

```bash
git clone https://github.com/YOUR_USER/YOUR_REPO.git
cd YOUR_REPO
pip install -r requirements.txt
# copy model file here
uvicorn app:app --host 0.0.0.0 --port 8080
```

For production, run behind a reverse proxy (nginx) with:
```bash
uvicorn app:app --host 127.0.0.1 --port 8080 --workers 2
```
