use brotlic_sys::{
    BrotliDecoderAttachDictionary, BrotliDecoderCreateInstance, BrotliDecoderDecompressStream,
    BrotliDecoderDestroyInstance, BrotliDecoderResult_BROTLI_DECODER_NEEDS_MORE_OUTPUT,
    BrotliDecoderResult_BROTLI_DECODER_RESULT_SUCCESS,
    BrotliSharedDictionaryType_BROTLI_SHARED_DICTIONARY_RAW,
};
use std::ptr;
use wasm_bindgen::prelude::*;

const OUTPUT_CHUNK: usize = 64 * 1024;

fn decode(input: &[u8], dictionary: Option<&[u8]>) -> Result<Vec<u8>, String> {
    let dict_storage = dictionary.map(|d| d.to_vec());

    unsafe {
        let state = BrotliDecoderCreateInstance(None, None, ptr::null_mut());
        if state.is_null() {
            return Err("Brotli decoder init failed".into());
        }

        if let Some(ref dict) = dict_storage {
            if BrotliDecoderAttachDictionary(
                state,
                BrotliSharedDictionaryType_BROTLI_SHARED_DICTIONARY_RAW,
                dict.len(),
                dict.as_ptr(),
            ) == 0
            {
                BrotliDecoderDestroyInstance(state);
                return Err("Brotli dictionary attach failed".into());
            }
        }

        let mut output = Vec::new();
        let mut output_buf = vec![0u8; OUTPUT_CHUNK];
        let mut next_in = input.as_ptr();
        let mut available_in = input.len();
        let mut total_out = 0usize;

        loop {
            let mut available_out = output_buf.len();
            let mut next_out = output_buf.as_mut_ptr();

            let result = BrotliDecoderDecompressStream(
                state,
                &mut available_in,
                &mut next_in,
                &mut available_out,
                &mut next_out,
                &mut total_out,
            );

            let produced = output_buf.len() - available_out;
            if produced > 0 {
                output.extend_from_slice(&output_buf[..produced]);
            }

            if result == BrotliDecoderResult_BROTLI_DECODER_RESULT_SUCCESS {
                break;
            }
            if result == BrotliDecoderResult_BROTLI_DECODER_NEEDS_MORE_OUTPUT {
                continue;
            }

            BrotliDecoderDestroyInstance(state);
            return Err(format!("Brotli decode failed (code {result})"));
        }

        BrotliDecoderDestroyInstance(state);
        Ok(output)
    }
}

#[wasm_bindgen]
pub fn decompress(input: &[u8]) -> Result<Vec<u8>, JsValue> {
    decode(input, None).map_err(|err| JsValue::from_str(&err))
}

#[wasm_bindgen]
pub fn decompress_with_dictionary(
    input: &[u8],
    dictionary: &[u8],
) -> Result<Vec<u8>, JsValue> {
    decode(input, Some(dictionary)).map_err(|err| JsValue::from_str(&err))
}
