"""
Flask Backend for Cataract Detection Training Data Collection

This backend receives images and prediction metadata from the mobile app
for model training and improvement.

Installation:
    pip install flask flask-cors pillow

Usage:
    python app.py

Deployment:
    - For production, use gunicorn or similar WSGI server
    - Deploy to Google Cloud Run, AWS, Heroku, etc.
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
from werkzeug.utils import secure_filename
import os
import json
from datetime import datetime
import uuid

app = Flask(__name__)
CORS(app)  # Enable CORS for mobile app

# Configuration
UPLOAD_FOLDER = 'training_data/images'
METADATA_FOLDER = 'training_data/metadata'
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'bmp'}
MAX_FILE_SIZE = 10 * 1024 * 1024  # 10MB

# Create directories if they don't exist
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
os.makedirs(METADATA_FOLDER, exist_ok=True)

app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
app.config['MAX_CONTENT_LENGTH'] = MAX_FILE_SIZE


def allowed_file(filename):
    """Check if file extension is allowed"""
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS


@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.utcnow().isoformat()
    }), 200


@app.route('/api/training-data', methods=['POST'])
def upload_training_data():
    """
    Receive training data from mobile app

    Expected data:
    - image: Image file (multipart/form-data)
    - metadata: JSON string containing prediction data

    Returns:
    - 201: Success
    - 400: Bad request (missing data, invalid format)
    - 413: File too large
    - 500: Server error
    """
    try:
        # Check if image file is present
        if 'image' not in request.files:
            return jsonify({'error': 'No image file provided'}), 400

        image_file = request.files['image']

        # Check if filename is empty
        if image_file.filename == '':
            return jsonify({'error': 'Empty filename'}), 400

        # Validate file type
        if not allowed_file(image_file.filename):
            return jsonify({
                'error': f'Invalid file type. Allowed: {", ".join(ALLOWED_EXTENSIONS)}'
            }), 400

        # Check if metadata is present
        if 'metadata' not in request.form:
            return jsonify({'error': 'No metadata provided'}), 400

        # Parse metadata
        try:
            metadata = json.loads(request.form['metadata'])
        except json.JSONDecodeError:
            return jsonify({'error': 'Invalid JSON metadata'}), 400

        # Validate required metadata fields
        required_fields = ['prediction', 'predictedClass', 'className', 'confidence', 'timestamp']
        missing_fields = [field for field in required_fields if field not in metadata]
        if missing_fields:
            return jsonify({
                'error': f'Missing required metadata fields: {", ".join(missing_fields)}'
            }), 400

        # Generate unique ID for this submission
        submission_id = str(uuid.uuid4())
        timestamp = datetime.utcnow().isoformat()

        # Save image with unique filename
        file_extension = image_file.filename.rsplit('.', 1)[1].lower()
        image_filename = f'{submission_id}.{file_extension}'
        image_path = os.path.join(app.config['UPLOAD_FOLDER'], image_filename)
        image_file.save(image_path)

        # Prepare complete metadata
        complete_metadata = {
            'submissionId': submission_id,
            'receivedAt': timestamp,
            'imagePath': image_path,
            'imageFilename': image_filename,
            'prediction': metadata['prediction'],
            'predictedClass': metadata['predictedClass'],
            'className': metadata['className'],
            'confidence': metadata['confidence'],
            'inferenceTime': metadata.get('inferenceTime'),
            'capturedAt': metadata['timestamp'],
            'deviceInfo': metadata.get('deviceInfo', {}),
        }

        # Save metadata as JSON
        metadata_filename = f'{submission_id}.json'
        metadata_path = os.path.join(METADATA_FOLDER, metadata_filename)
        with open(metadata_path, 'w') as f:
            json.dump(complete_metadata, f, indent=2)

        # Log the submission
        print(f'[{timestamp}] Received training data:')
        print(f'  - ID: {submission_id}')
        print(f'  - Class: {metadata["className"]}')
        print(f'  - Confidence: {metadata["confidence"]:.2f}%')
        print(f'  - Image saved: {image_filename}')

        return jsonify({
            'success': True,
            'submissionId': submission_id,
            'message': 'Training data received successfully'
        }), 201

    except Exception as e:
        print(f'Error processing upload: {str(e)}')
        return jsonify({
            'error': 'Internal server error',
            'message': str(e)
        }), 500


@app.route('/api/stats', methods=['GET'])
def get_stats():
    """Get statistics about collected data"""
    try:
        # Count images
        image_count = len([f for f in os.listdir(UPLOAD_FOLDER) if os.path.isfile(os.path.join(UPLOAD_FOLDER, f))])

        # Count metadata files
        metadata_files = [f for f in os.listdir(METADATA_FOLDER) if f.endswith('.json')]

        # Analyze classes
        class_counts = {'Cataract': 0, 'Normal': 0}
        for metadata_file in metadata_files:
            with open(os.path.join(METADATA_FOLDER, metadata_file), 'r') as f:
                data = json.load(f)
                class_name = data.get('className', 'Unknown')
                if class_name in class_counts:
                    class_counts[class_name] += 1

        return jsonify({
            'totalSubmissions': len(metadata_files),
            'totalImages': image_count,
            'classCounts': class_counts,
            'timestamp': datetime.utcnow().isoformat()
        }), 200

    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.errorhandler(413)
def request_entity_too_large(error):
    """Handle file too large error"""
    return jsonify({
        'error': 'File too large',
        'message': f'Maximum file size is {MAX_FILE_SIZE // (1024 * 1024)}MB'
    }), 413


if __name__ == '__main__':
    print('=' * 60)
    print('Cataract Detection Training Data Collection Backend')
    print('=' * 60)
    print(f'Upload folder: {os.path.abspath(UPLOAD_FOLDER)}')
    print(f'Metadata folder: {os.path.abspath(METADATA_FOLDER)}')
    print('Endpoints:')
    print('  - POST /api/training-data : Receive training data')
    print('  - GET  /api/stats         : Get collection statistics')
    print('  - GET  /health            : Health check')
    print('=' * 60)
    print('\nStarting server...\n')

    # Run development server
    # For production, use: gunicorn -w 4 -b 0.0.0.0:8080 app:app
    app.run(host='0.0.0.0', port=8080, debug=True)
