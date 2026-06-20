declare module "brotli-compress/js" {
    export function compress(data: Uint8Array, options: BrotliCompressOptions): Uint8Array;
    export function decompress(data: Uint8Array): Uint8Array;
}

export type VariantInput = {
    filename: string;
    data: Uint8Array;
};

export type VariantSegment = {
    filename: string;
    offset: number;
    length: number;
};

export type VariantSlice = {
    offset: number;
    length: number;
};

export type CompressionMetadata = {
    format: string;
    compressedFilename: string;
    lgwin: number;
    quality: number;
    uncompressedLength: number;
    compressedLength: number;
    orderStrategy: string;
};

export type BrotliCompressOptions = {
    lgwin?: number;
    quality?: number;
};

export type CompressBlogVariantsOptions = BrotliCompressOptions & {
    bundleFilename?: string;
};

export type CompressBlogVariantsResult = {
    bundleFilename: string;
    compressed: Uint8Array;
    segments: VariantSegment[];
    metadata: CompressionMetadata;
};

export type OrderStrategyFn = (variants: VariantInput[]) => VariantInput[];

export type OrderStrategyName =
    | "widthAsc_lightFirst"
    | "widthAsc_interleaved"
    | "widthDesc_interleaved"
    | "themeThenWidth";

export type PickBestOrderResult = {
    ordered: VariantInput[];
    strategy: string;
    compressed: Uint8Array;
};
