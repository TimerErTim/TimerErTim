import zlib from "node:zlib";

import {
    DEFAULT_BUNDLE_FILENAME,
    DEFAULT_LGWIN,
    DEFAULT_QUALITY,
    FORMAT_VERSION,
} from "./constants.js";
import { concatVariants } from "./concat.js";
import { pickBestOrder } from "./order.js";

/**
 * @param {Uint8Array} data
 * @param {{ lgwin?: number, quality?: number }} [options]
 * @returns {Buffer}
 */
export function brotliCompressSync(data, options = {}) {
    const lgwin = options.lgwin ?? DEFAULT_LGWIN;
    const quality = options.quality ?? DEFAULT_QUALITY;
    return zlib.brotliCompressSync(data, {
        params: {
            [zlib.constants.BROTLI_PARAM_QUALITY]: quality,
            [zlib.constants.BROTLI_PARAM_LGWIN]: lgwin,
        },
    });
}

/**
 * @param {Uint8Array} data
 * @returns {Buffer}
 */
export function brotliDecompressSync(data) {
    return zlib.brotliDecompressSync(data);
}

/**
 * @param {import("./constants.js").VariantInput[]} variants
 * @param {{ lgwin?: number, quality?: number, bundleFilename?: string }} [options]
 */
export function compressBlogVariants(variants, options = {}) {
    const lgwin = options.lgwin ?? DEFAULT_LGWIN;
    const quality = options.quality ?? DEFAULT_QUALITY;
    const bundleFilename = options.bundleFilename ?? DEFAULT_BUNDLE_FILENAME;

    const { ordered, strategy, compressed } = pickBestOrder(variants, (data) =>
        brotliCompressSync(data, { lgwin, quality }),
    );

    const { data, segments } = concatVariants(ordered);
    const roundtrip = brotliDecompressSync(compressed);
    if (roundtrip.byteLength !== data.byteLength) {
        throw new Error("Brotli roundtrip length mismatch");
    }
    for (let index = 0; index < data.byteLength; index += 1) {
        if (roundtrip[index] !== data[index]) {
            throw new Error(`Brotli roundtrip byte mismatch at index ${index}`);
        }
    }

    return {
        bundleFilename,
        compressed: new Uint8Array(compressed),
        segments,
        metadata: {
            format: FORMAT_VERSION,
            compressedFilename: bundleFilename,
            lgwin,
            quality,
            uncompressedLength: data.byteLength,
            compressedLength: compressed.byteLength,
            orderStrategy: strategy,
        },
    };
}

export {
    DEFAULT_BUNDLE_FILENAME,
    DEFAULT_LGWIN,
    DEFAULT_QUALITY,
    FORMAT_VERSION,
} from "./constants.js";
export { concatVariants, decodeUtf8, sliceVariant } from "./concat.js";
