"""
Convert densenet121_cataract.tflite (which uses Flex ops like FlexPad)
into a new TFLite model that only uses built-in TFLite ops.

Steps:
1. Parse the .tflite flatbuffer directly to extract weight tensors
   (bypasses interpreter entirely, so Flex ops don't matter)
2. Rebuild a DenseNet121 model in Keras with the same structure
3. Map weights from the TFLite file into the Keras model
4. Re-convert to TFLite using TFLITE_BUILTINS only (no Flex ops)

Usage:
    pip install tensorflow flatbuffers
    python convert_densenet.py
"""

import numpy as np
import tensorflow as tf

INPUT_TFLITE = "densenet121_cataract.tflite"
OUTPUT_TFLITE = "densenet121_cataract_converted.tflite"

# TFLite tensor type enum -> numpy dtype
TFLITE_DTYPE = {
    0: np.float32,
    1: np.float16,
    2: np.int32,
    3: np.uint8,
    4: np.int64,
    6: np.bool_,
    7: np.int16,
    8: np.complex64,
    9: np.int8,
}


def extract_weights_from_flatbuffer(tflite_path):
    """
    Parse the .tflite flatbuffer directly using TF's built-in schema.
    No interpreter needed, so Flex ops are irrelevant.
    """
    from tensorflow.lite.python import schema_py_generated as schema

    with open(tflite_path, "rb") as f:
        buf = bytearray(f.read())

    model = schema.Model.GetRootAs(buf, 0)
    subgraph = model.Subgraphs(0)

    # Get input shape
    input_tensor = subgraph.Tensors(subgraph.Inputs(0))
    input_shape = tuple(input_tensor.ShapeAsNumpy()[1:])  # skip batch dim

    # Extract weight tensors (buffers with actual data)
    weights = []
    for i in range(subgraph.TensorsLength()):
        tensor = subgraph.Tensors(i)
        buffer_idx = tensor.Buffer()
        buffer_data = model.Buffers(buffer_idx)

        if buffer_data is None or buffer_data.DataLength() == 0:
            continue

        name = tensor.Name()
        if name is not None:
            name = name.decode("utf-8")
        else:
            name = f"tensor_{i}"

        dtype = TFLITE_DTYPE.get(tensor.Type(), np.float32)
        shape = tuple(tensor.ShapeAsNumpy())
        raw = buffer_data.DataAsNumpy()
        arr = np.frombuffer(raw, dtype=dtype).reshape(shape).copy()

        weights.append((name, arr))

    return weights, input_shape


def build_densenet121_model(input_shape):
    """Build a DenseNet121 with a binary classification head."""
    base = tf.keras.applications.DenseNet121(
        include_top=False,
        weights=None,
        input_shape=input_shape,
        pooling="avg",
    )
    x = base.output
    x = tf.keras.layers.Dense(1, activation="sigmoid")(x)
    return tf.keras.Model(inputs=base.input, outputs=x)


def main():
    # Step 1: Extract weights from flatbuffer
    print(f"Parsing {INPUT_TFLITE} flatbuffer (no interpreter needed)...")
    tflite_weights, input_shape = extract_weights_from_flatbuffer(INPUT_TFLITE)
    print(f"  Input shape: {input_shape}")
    print(f"  Extracted {len(tflite_weights)} weight tensors")

    # Group by shape for matching
    shape_to_weights = {}
    for name, arr in tflite_weights:
        key = arr.shape
        if key not in shape_to_weights:
            shape_to_weights[key] = []
        shape_to_weights[key].append((name, arr))

    # Step 2: Build Keras model
    print(f"\nBuilding DenseNet121 Keras model with input {input_shape}...")
    model = build_densenet121_model(input_shape)

    # Step 3: Map weights
    matched = 0
    unmatched = 0
    for layer in model.layers:
        keras_weights = layer.get_weights()
        if not keras_weights:
            continue

        new_weights = []
        all_found = True
        for kw in keras_weights:
            key = kw.shape
            if key in shape_to_weights and shape_to_weights[key]:
                _, tw = shape_to_weights[key].pop(0)
                new_weights.append(tw.astype(kw.dtype))
            else:
                all_found = False
                break

        if all_found and len(new_weights) == len(keras_weights):
            layer.set_weights(new_weights)
            matched += 1
        else:
            unmatched += 1

    remaining = sum(len(v) for v in shape_to_weights.values())
    print(f"  Matched: {matched} layers")
    print(f"  Unmatched: {unmatched} layers")
    print(f"  Unused TFLite tensors: {remaining}")

    if unmatched > 0:
        print("  WARNING: Some layers unmatched — converted model may differ.")

    # Step 4: Convert to TFLite (builtin ops only)
    print("\nConverting to TFLite (TFLITE_BUILTINS only, no Flex ops)...")
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    converter.target_spec.supported_ops = [tf.lite.OpsSet.TFLITE_BUILTINS]
    tflite_model = converter.convert()

    with open(OUTPUT_TFLITE, "wb") as f:
        f.write(tflite_model)

    size_mb = len(tflite_model) / (1024 * 1024)
    print(f"  Saved: {OUTPUT_TFLITE} ({size_mb:.1f} MB)")

    # Step 5: Verify
    print("\nVerifying converted model loads without Flex delegate...")
    test_interp = tf.lite.Interpreter(model_path=OUTPUT_TFLITE)
    test_interp.allocate_tensors()
    print("  PASSED — no Flex ops needed!")

    # Quick sanity check
    dummy = np.random.rand(1, *input_shape).astype(np.float32)
    test_interp.set_tensor(test_interp.get_input_details()[0]["index"], dummy)
    test_interp.invoke()
    out = test_interp.get_tensor(test_interp.get_output_details()[0]["index"])
    print(f"  Test inference: {out[0][0]:.4f}")

    print(f"\nDone! Deploy {OUTPUT_TFLITE} to your VPS.")


if __name__ == "__main__":
    main()
