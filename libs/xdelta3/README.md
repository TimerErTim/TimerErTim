# xdelta3 (Python)

Python bindings for [xdelta3](https://docs.rs/xdelta3/latest/xdelta3/) — VCDIFF binary deltas via PyO3 and [maturin](https://www.maturin.rs/).

## Install

```bash
cd libs/xdelta3
maturin develop --release
# or: uv pip install -e .
```

Requires a Rust toolchain and Python ≥ 3.10.

## Usage

```python
import xdelta3

source = b"Hello, world!"
target = b"Hello, world! Hello, world!"

patch = xdelta3.encode(target, source)
restored = xdelta3.decode(patch, source)
assert restored == target
```

Argument order matches the Rust API: **new data first**, then **original**.

## Development

```bash
mise run build    # release wheel / extension
mise run test     # pytest
```
