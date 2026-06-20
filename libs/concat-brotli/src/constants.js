/** @typedef {{ filename: string, data: Uint8Array }} VariantInput */

/** @typedef {{ filename: string, offset: number, length: number }} VariantSegment */

export const FORMAT_VERSION = "concat-brotli-v1";
export const DEFAULT_BUNDLE_FILENAME = "variants.br";
export const DEFAULT_LGWIN = 24;
export const DEFAULT_QUALITY = 11;
