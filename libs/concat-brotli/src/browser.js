import { decodeUtf8, sliceVariant } from "./concat.js";

/**
 * @param {Uint8Array} bundle
 * @param {{ offset: number, length: number }} segment
 * @returns {string}
 */
export function extractVariantText(bundle, segment) {
    return decodeUtf8(sliceVariant(bundle, segment.offset, segment.length));
}

export { decodeUtf8, sliceVariant } from "./concat.js";
