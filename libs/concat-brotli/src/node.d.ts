import type {
    BrotliCompressOptions,
    CompressBlogVariantsOptions,
    CompressBlogVariantsResult,
    VariantInput,
} from "./types.js";

export {
    DEFAULT_BUNDLE_FILENAME,
    DEFAULT_LGWIN,
    DEFAULT_QUALITY,
    FORMAT_VERSION,
} from "./constants.js";
export { concatVariants, decodeUtf8, sliceVariant } from "./concat.js";
export type { VariantInput, VariantSegment } from "./concat.js";

export declare function brotliCompressSync(
    data: Uint8Array,
    options?: BrotliCompressOptions,
): Buffer;

export declare function brotliDecompressSync(data: Uint8Array): Buffer;

export declare function compressBlogVariants(
    variants: VariantInput[],
    options?: CompressBlogVariantsOptions,
): CompressBlogVariantsResult;
