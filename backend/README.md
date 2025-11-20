# Cataract Detection - Training Data Collection Backend

Flask backend API for collecting training data from the mobile app to improve model accuracy.

## Features

- Receive images and prediction metadata from mobile app
- Store images and metadata for model retraining
- Statistics endpoint to monitor data collection
- CORS enabled for mobile app communication
- File size and type validation

## Installation

### Local Development

1. Install Python 3.8+

2. Install dependencies:
```bash
pip install -r requirements.txt
```

3. Run the development server:
```bash
python app.py
```

The server will start on `http://localhost:8080`

## API Endpoints

### POST /api/training-data

Receive training data from mobile app.

**Request:**
- Content-Type: `multipart/form-data`
- Fields:
  - `image`: Image file (PNG, JPG, JPEG, BMP)
  - `metadata`: JSON string containing:
    ```json
    {
      "prediction": 0.85,
      "predictedClass": 1,
      "className": "Cataract",
      "confidence": 85.0,
      "inferenceTime": 0.123,
      "timestamp": "2025-01-17T10:30:00Z",
      "deviceInfo": {
        "platform": "android",
        "version": "13"
      }
    }
    ```

**Response:**
```json
{
  "success": true,
  "submissionId": "uuid-here",
  "message": "Training data received successfully"
}
```

### GET /api/stats

Get statistics about collected data.

**Response:**
```json
{
  "totalSubmissions": 150,
  "totalImages": 150,
  "classCounts": {
    "Cataract": 75,
    "Normal": 75
  },
  "timestamp": "2025-01-17T10:30:00Z"
}
```

### GET /health

Health check endpoint.

**Response:**
```json
{
  "status": "healthy",
  "timestamp": "2025-01-17T10:30:00Z"
}
```

## Deployment

### Option 1: Google Cloud Run

1. Create `Dockerfile`:
```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

CMD exec gunicorn --bind :$PORT --workers 4 --threads 2 --timeout 0 app:app
```

2. Deploy:
```bash
gcloud run deploy cataract-backend \
  --source . \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated
```

### Option 2: Heroku

1. Create `Procfile`:
```
web: gunicorn app:app
```

2. Deploy:
```bash
heroku create cataract-backend
git push heroku main
```

### Option 3: AWS EC2 / DigitalOcean

Run with gunicorn:
```bash
gunicorn -w 4 -b 0.0.0.0:8080 app:app
```

## Update Mobile App

After deploying, update the backend URL in `lib/services/background_sync_service.dart`:

```dart
static const String _baseUrl = 'https://your-deployed-url.com';
```

## Data Storage

Collected data is stored in:
- `training_data/images/` - Image files
- `training_data/metadata/` - JSON metadata files

Each submission gets a unique UUID for both image and metadata files.

## Security Considerations

For production:
1. Add authentication (API keys, JWT tokens)
2. Add rate limiting
3. Enable HTTPS only
4. Implement data validation and sanitization
5. Add logging and monitoring
6. Configure CORS to allow only your mobile app

## Monitoring

View real-time stats:
```bash
curl https://your-backend-url.com/api/stats
```

## License

Private - For internal use only
