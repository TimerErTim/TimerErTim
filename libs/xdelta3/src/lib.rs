//! PyO3 bindings for [xdelta3](https://docs.rs/xdelta3/latest/xdelta3/) (VCDIFF).

use pyo3::exceptions::PyValueError;
use pyo3::prelude::*;
use ::xdelta3 as xdelta3_rs;

/// Build a VCDIFF patch from `source` (original) to `target` (new data).
///
/// Returns patch bytes suitable for [`decode`].
#[pyfunction]
#[pyo3(signature = (reference, target))]
fn encode(reference: &[u8], target: &[u8]) -> PyResult<Vec<u8>> {
    xdelta3_rs::encode(target, reference)
        .ok_or_else(|| PyValueError::new_err("xdelta3 encode failed"))
}

/// Apply a VCDIFF patch to `source` and return the reconstructed data.
#[pyfunction]
#[pyo3(signature = (reference, patch))]
fn decode(reference: &[u8], patch: &[u8]) -> PyResult<Vec<u8>> {
    xdelta3_rs::decode(patch, reference)
        .ok_or_else(|| PyValueError::new_err("xdelta3 decode failed"))
}

/// Python module implemented in Rust.
#[pymodule]
fn xdelta3(m: &Bound<'_, PyModule>) -> PyResult<()> {
    m.add_function(wrap_pyfunction!(encode, m)?)?;
    m.add_function(wrap_pyfunction!(decode, m)?)?;
    Ok(())
}
