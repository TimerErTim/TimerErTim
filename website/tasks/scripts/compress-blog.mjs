#!/usr/bin/env node
import { readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";

import { compressBlogVariants } from "../../../libs/concat-brotli/src/node.js";

const buildJsonPath = join(process.cwd(), "build.json");
const buildData = JSON.parse(readFileSync(buildJsonPath, "utf8"));

/** @type {import("../../../libs/concat-brotli/src/concat.js").VariantInput[]} */
const variantInputs = buildData.variants.map((variant) => ({
    filename: variant.filename,
    data: new Uint8Array(readFileSync(join(process.cwd(), variant.filename))),
}));

console.log(`Concatenating and compressing ${variantInputs.length} variants...`);

const result = compressBlogVariants(variantInputs);

writeFileSync(join(process.cwd(), result.bundleFilename), result.compressed);

const segmentByFilename = new Map(
    result.segments.map((segment) => [segment.filename, segment]),
);

const updatedVariants = buildData.variants.map((variant) => {
    const segment = segmentByFilename.get(variant.filename);
    if (!segment) {
        throw new Error(`Missing segment for ${variant.filename}`);
    }
    return {
        filename: variant.filename,
        theme: variant.theme,
        width_pt: variant.width_pt,
        offset: segment.offset,
        length: segment.length,
    };
});

const updatedBuildData = {
    slug: buildData.slug,
    contentHash: buildData.contentHash,
    title: buildData.title,
    description: buildData.description,
    keywords: buildData.keywords,
    author: buildData.author,
    createdAt: buildData.createdAt,
    updatedAt: buildData.updatedAt,
    compression: result.metadata,
    variants: updatedVariants,
};

writeFileSync(buildJsonPath, `${JSON.stringify(updatedBuildData, null, 2)}\n`);

console.log(
    `Wrote ${result.bundleFilename}: ${result.metadata.compressedLength} bytes `
    + `(uncompressed ${result.metadata.uncompressedLength} bytes, `
    + `strategy ${result.metadata.orderStrategy}, `
    + `lgwin ${result.metadata.lgwin})`,
);

for (const variant of updatedVariants) {
    console.log(`  ${variant.filename}: offset=${variant.offset} length=${variant.length}`);
}

console.log("Updated build.json with compression metadata and variant offsets.");
