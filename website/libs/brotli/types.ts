export interface BrotliDecodeOptions {
  /**
   * Custom dictionary used during decompression. Must match the dictionary used
   * when the stream was compressed. Pass `null` to use the built-in default.
   */
  customDictionary?: BufferSource | null;
}
