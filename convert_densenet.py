"""
Convert DenseNet121 Keras model to TFLite
Run this script to convert your trained model to TFLite format
"""

import tensorflow as tf
import os
import sys

KERAS_MODEL = "densenet121_cataract.keras"
TFLITE_OUTPUT = "densenet121_cataract.tflite"

def main():
    print("=" * 60)
    print("DenseNet121 to TFLite Converter")
    print("=" * 60)

    # Check if Keras model exists
    if not os.path.exists(KERAS_MODEL):
        print(f"\nERROR: {KERAS_MODEL} not found!")
        print(f"Current directory: {os.getcwd()}")
        sys.exit(1)

    print(f"\n1. Loading {KERAS_MODEL}...")
    try:
        model = tf.keras.models.load_model(KERAS_MODEL)
        print(f"   ✓ Model loaded")
        print(f"   Input shape: {model.input_shape}")
        print(f"   Output shape: {model.output_shape}")
    except Exception as e:
        print(f"   ERROR loading model: {e}")
        sys.exit(1)

    print(f"\n2. Converting to TFLite...")
    try:
        converter = tf.lite.TFLiteConverter.from_keras_model(model)
        tflite_model = converter.convert()
        print(f"   ✓ Conversion complete")
    except Exception as e:
        print(f"   ERROR converting: {e}")
        sys.exit(1)

    print(f"\n3. Saving to {TFLITE_OUTPUT}...")
    try:
        with open(TFLITE_OUTPUT, 'wb') as f:
            f.write(tflite_model)
        size_mb = os.path.getsize(TFLITE_OUTPUT) / (1024*1024)
        print(f"   ✓ Saved: {TFLITE_OUTPUT}")
        print(f"   Size: {size_mb:.2f} MB")
    except Exception as e:
        print(f"   ERROR saving: {e}")
        sys.exit(1)

    # Also copy to backend folder
    backend_path = "backend/" + TFLITE_OUTPUT
    print(f"\n4. Copying to backend...")
    try:
        os.makedirs("backend", exist_ok=True)
        with open(backend_path, 'wb') as f:
            f.write(tflite_model)
        print(f"   ✓ Copied to {backend_path}")
    except Exception as e:
        print(f"   WARNING: Could not copy to backend: {e}")

    print("\n" + "=" * 60)
    print("✅ CONVERSION COMPLETE!")
    print("=" * 60)
    print(f"\nFiles created:")
    print(f"  - {TFLITE_OUTPUT}")
    print(f"  - {backend_path}")
    print(f"\nYour backend will now use ResNet50 + DenseNet121 ensemble!")

if __name__ == "__main__":
    main()
