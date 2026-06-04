#!/usr/bin/env -S uv run --script
#MISE description="Compress the website embedding files using brotli and vcdiff"
# Runs inside the website embedding directory
#
# /// script
# requires-python = ">=3.8"
# dependencies = [
#     "xdelta3",
#     "brotli==1.2.0"
# ]
#
# [tool.uv.sources]
# xdelta3 = { path = "../../../libs/xdelta3" }  # Path from this file's directory
# ///

import os
import json
import brotli
import xdelta3
from pathlib import Path

REPO_ROOT = os.environ["REPO_ROOT"]

# We are supposed to run in the blog build embedding directory
# E.g. build/website/blogs/{slug}
curdir = Path(os.getcwd())

with open("build.json", "r", encoding="utf-8") as f:
    build_data = json.load(f)

compression_ref_variant_filename = build_data["compressionRefVariant"]

with open(compression_ref_variant_filename, "rb") as f:
    compression_ref = f.read()

print(f"Reference variant for vcdiff: {compression_ref_variant_filename}")

def vcdiff_encode(reference_bytes: bytes, target_bytes: bytes) -> bytes:
    # Returns the binary VCDIFF patch (RFC 3284)
    return xdelta3.encode(reference_bytes, target_bytes)

def vcdiff_decode(reference_bytes: bytes, delta_bytes: bytes) -> bytes:
    # Returns the post-patch result
    return xdelta3.decode(reference_bytes, delta_bytes)

def brotli_compress(data_bytes):
    return brotli.compress(data_bytes, quality=11)

def brotli_decompress(data_bytes):
    return brotli.decompress(data_bytes)

updated_variants = []
for variant in build_data["variants"]:
    filename = variant["filename"]
    with open(filename, "rb") as f:
        file_bytes = f.read()

    if filename == compression_ref_variant_filename:
        # Reference variant: just compress the plain SVG.
        compressed_bytes = brotli_compress(file_bytes)
        compressed_filename = filename + ".br"
        with open(compressed_filename, "wb") as out:
            out.write(compressed_bytes)
        # Verification
        roundtripped = brotli_decompress(compressed_bytes)
        assert roundtripped == file_bytes, f"Verification failed for {filename} (reference brotli)"
        print(f"Compressed reference {filename}: {len(compressed_bytes)} bytes.")
        updated_variants.append({
            **variant,
            "compressedFilename": compressed_filename,
            # NOTE: For the reference, no vcdiff output necessary
        })
    else:
        # Not the reference: vcdiff against reference, then brotli the diff
        vcdiff_delta = vcdiff_encode(compression_ref, file_bytes)
        compressed_bytes = brotli_compress(vcdiff_delta)
        compressed_filename = filename + ".br"
        with open(compressed_filename, "wb") as out:
            out.write(compressed_bytes)
        # Verification
        # Decompress, then vcdiff apply
        decompressed_vcdiff = brotli_decompress(compressed_bytes)
        restored = vcdiff_decode(compression_ref, decompressed_vcdiff)
        assert restored == file_bytes, f"Verification failed for {filename} (vcdiff roundtrip)"
        print(f"Delta-compressed {filename} ({len(file_bytes)} -> {len(vcdiff_delta)} -> {len(compressed_bytes)} bytes)")
        updated_variants.append({
            **variant,
            "compressedFilename": compressed_filename,
            # Save type = 'vcdiff' to signal decompression method, if needed in metadata
            "compressionType": "vcdiff",
        })

# Write new build data with .compressedFilename fields
updated_build_data = {
    **build_data,
    "variants": updated_variants
}
with open("build.json", "w", encoding="utf-8") as f:
    json.dump(updated_build_data, f, indent=2)
print("Updated build.json written with compressedFilename fields.")