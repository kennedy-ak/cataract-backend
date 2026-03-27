"""
Simple DenseNet121 to TFLite converter
"""
import tensorflow as tf
import os

KERAS_MODEL = "densenet121_cataract.keras"
TFLITE_OUTPUT = "densenet121_cataract.tflite"

print("Loading model...")
model = tf.keras.models.load_model(KERAS_MODEL)

print(f"Input shape: {model.input_shape}")
print(f"Output shape: {model.output_shape}")

print("\nConverting to TFLite...")
converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model = converter.convert()

print(f"Saving to {TFLITE_OUTPUT}...")
with open(TFLITE_OUTPUT, 'wb') as f:
    f.write(tflite_model)

size = os.path.getsize(TFLITE_OUTPUT)
print(f"\nSUCCESS! Saved {size/1024/1024:.2f} MB")

# Copy to backend
import shutil
backend_dest = "backend/" + TFLITE_OUTPUT
shutil.copy(TFLITE_OUTPUT, backend_dest)
print(f"Copied to {backend_dest}")
