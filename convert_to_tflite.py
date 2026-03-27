"""
Convert DenseNet121 Keras model to TFLite format.
Run this script after training to get the TFLite model for the backend.
"""

import tensorflow as tf
import os

KERAS_MODEL_PATH = "densenet121_cataract.keras"
TFLITE_FLOAT16_PATH = "densenet121_cataract_float16.tflite"

print("=" * 60)
print("Converting DenseNet121 Keras to TFLite")
print("=" * 60)

# Check if Keras model exists
if not os.path.exists(KERAS_MODEL_PATH):
    print(f"ERROR: {KERAS_MODEL_PATH} not found!")
    exit(1)

print(f"\nInput: {KERAS_MODEL_PATH} ({os.path.getsize(KERAS_MODEL_PATH)/(1024*1024):.2f} MB)")

# Load the Keras model
print("\nLoading Keras model...")
try:
    model = tf.keras.models.load_model(KERAS_MODEL_PATH)
    print(f"Model loaded successfully!")
    print(f"Input shape: {model.input_shape}")
    print(f"Output shape: {model.output_shape}")
except Exception as e:
    print(f"ERROR loading model: {e}")
    exit(1)

# Convert to TFLite (Float16 - smaller size, good for deployment)
print(f"\nConverting to TFLite Float16...")
try:
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    converter.target_spec.supported_types = [tf.float16]
    tflite_model = converter.convert()

    with open(TFLITE_FLOAT16_PATH, 'wb') as f:
        f.write(tflite_model)

    print(f"SUCCESS! Saved: {TFLITE_FLOAT16_PATH}")
    print(f"Size: {os.path.getsize(TFLITE_FLOAT16_PATH)/(1024*1024):.2f} MB")
    print(f"Compression: {(1 - os.path.getsize(TFLITE_FLOAT16_PATH)/os.path.getsize(KERAS_MODEL_PATH))*100:.1f}%")

except Exception as e:
    print(f"ERROR converting to Float16: {e}")
    print("\nTrying standard TFLite conversion...")
    try:
        converter = tf.lite.TFLiteConverter.from_keras_model(model)
        tflite_model = converter.convert()

        with open("densenet121_cataract.tflite", 'wb') as f:
            f.write(tflite_model)

        print(f"SUCCESS! Saved: densenet121_cataract.tflite")
        print(f"Size: {os.path.getsize('densenet121_cataract.tflite')/(1024*1024):.2f} MB")
    except Exception as e2:
        print(f"ERROR: {e2}")
        exit(1)

print("\n" + "=" * 60)
print("Conversion complete!")
print("=" * 60)
print(f"\nNext steps:")
print(f"1. Copy {TFLITE_FLOAT16_PATH} to the backend folder")
print(f"2. Update backend app.py MODEL_2_PATH to use this model")
