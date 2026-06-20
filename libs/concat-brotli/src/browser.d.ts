export { decodeUtf8, sliceVariant } from "./concat.js";
export type { VariantInput, VariantSegment } from "./concat.js";

export declare function extractVariantText(
    bundle: Uint8Array,
    segment: import("./types.js").VariantSlice,
): string;
