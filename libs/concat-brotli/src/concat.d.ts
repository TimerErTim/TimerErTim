import type { VariantInput, VariantSegment } from "./types.js";

export type { VariantInput, VariantSegment } from "./types.js";

export declare function concatVariants(
    variants: VariantInput[],
): { data: Uint8Array; segments: VariantSegment[] };

export declare function sliceVariant(
    bundle: Uint8Array,
    offset: number,
    length: number,
): Uint8Array;

export declare function decodeUtf8(bytes: Uint8Array): string;
