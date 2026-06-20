import type {
    OrderStrategyFn,
    OrderStrategyName,
    PickBestOrderResult,
    VariantInput,
} from "./types.js";

export declare const ORDER_STRATEGIES: Record<OrderStrategyName, OrderStrategyFn>;

export declare function listOrderStrategies(variants: VariantInput[]): string[];

export declare function pickBestOrder(
    variants: VariantInput[],
    compress: (data: Uint8Array) => Uint8Array,
): PickBestOrderResult;
