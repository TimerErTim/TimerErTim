/** @typedef {import("./concat.js").VariantInput} VariantInput */

import { concatVariants } from "./concat.js";
/** @type {Record<string, (variants: VariantInput[]) => VariantInput[]>} */
export const ORDER_STRATEGIES = {
    widthAsc_lightFirst(a) {
        return [...a].sort((left, right) => {
            const widthDelta = parseWidth(left.filename) - parseWidth(right.filename);
            if (widthDelta !== 0) {
                return widthDelta;
            }
            return left.filename.localeCompare(right.filename);
        });
    },
    widthAsc_interleaved(a) {
        return [...a].sort((left, right) => {
            const widthDelta = parseWidth(left.filename) - parseWidth(right.filename);
            if (widthDelta !== 0) {
                return widthDelta;
            }
            const themeDelta = parseThemeRank(left.filename) - parseThemeRank(right.filename);
            if (themeDelta !== 0) {
                return themeDelta;
            }
            return left.filename.localeCompare(right.filename);
        });
    },
    widthDesc_interleaved(a) {
        return [...a].sort((left, right) => {
            const widthDelta = parseWidth(right.filename) - parseWidth(left.filename);
            if (widthDelta !== 0) {
                return widthDelta;
            }
            const themeDelta = parseThemeRank(left.filename) - parseThemeRank(right.filename);
            if (themeDelta !== 0) {
                return themeDelta;
            }
            return left.filename.localeCompare(right.filename);
        });
    },
    themeThenWidth(a) {
        return [...a].sort((left, right) => {
            const themeDelta = parseThemeRank(left.filename) - parseThemeRank(right.filename);
            if (themeDelta !== 0) {
                return themeDelta;
            }
            return parseWidth(left.filename) - parseWidth(right.filename);
        });
    },
};

/**
 * @param {VariantInput[]} variants
 * @returns {string[]}
 */
export function listOrderStrategies(variants) {
    return Object.keys(ORDER_STRATEGIES);
}

/**
 * @param {VariantInput[]} variants
 * @param {(data: Uint8Array) => Uint8Array} compress
 * @returns {{ ordered: VariantInput[], strategy: string, compressed: Uint8Array }}
 */
export function pickBestOrder(variants, compress) {
    let bestStrategy = "widthAsc_interleaved";
    let bestCompressed = /** @type {Uint8Array | null} */ (null);
    let bestOrdered = variants;

    for (const [strategy, orderFn] of Object.entries(ORDER_STRATEGIES)) {
        const ordered = orderFn(variants);
        const { data } = concatVariants(ordered);
        const compressed = compress(data);
        if (bestCompressed === null || compressed.byteLength < bestCompressed.byteLength) {
            bestStrategy = strategy;
            bestCompressed = compressed;
            bestOrdered = ordered;
        }
    }

    if (bestCompressed === null) {
        throw new Error("No variants provided for compression");
    }

    return {
        ordered: bestOrdered,
        strategy: bestStrategy,
        compressed: bestCompressed,
    };
}

/**
 * @param {string} filename
 */
function parseWidth(filename) {
    const match = filename.match(/_(\d+)pt\.svg$/);
    return match ? Number(match[1]) : 0;
}

/**
 * @param {string} filename
 */
function parseThemeRank(filename) {
    if (filename.includes("_light_")) {
        return 0;
    }
    if (filename.includes("_dark_")) {
        return 1;
    }
    return 2;
}
