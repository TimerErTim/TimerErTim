import { State } from "./state";
import type { BrotliDecodeOptions } from "./types";

/**
 * Decodes Brotli-compressed data and returns the decompressed output as a
 * `Uint8Array`. Throws a {@link BrotliDecoderError} subclass when decoding fails.
 */
export function decompress(
  input: BufferSource,
  options?: BrotliDecodeOptions,
): Uint8Array {
  return State.decompress(input, options?.customDictionary);
}

export default decompress;
