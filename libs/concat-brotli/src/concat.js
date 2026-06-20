/** @typedef {{ filename: string, data: Uint8Array }} VariantInput */

/** @typedef {{ filename: string, offset: number, length: number }} VariantSegment */

/**
 * @param {VariantInput[]} variants
 * @returns {{ data: Uint8Array, segments: VariantSegment[] }}
 */
export function concatVariants(variants) {
    let totalLength = 0;
    for (const variant of variants) {
        totalLength += variant.data.byteLength;
    }

    const data = new Uint8Array(totalLength);
    /** @type {VariantSegment[]} */
    const segments = [];
    let offset = 0;

    for (const variant of variants) {
        segments.push({
            filename: variant.filename,
            offset,
            length: variant.data.byteLength,
        });
        data.set(variant.data, offset);
        offset += variant.data.byteLength;
    }

    return { data, segments };
}

/**
 * @param {Uint8Array} bundle
 * @param {number} offset
 * @param {number} length
 * @returns {Uint8Array}
 */
export function sliceVariant(bundle, offset, length) {
    return bundle.subarray(offset, offset + length);
}

/**
 * @param {Uint8Array} bytes
 * @returns {string}
 */
export function decodeUtf8(bytes) {
    return new TextDecoder("utf-8").decode(bytes);
}
