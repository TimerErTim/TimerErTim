import { fsPaths } from "@/paths";
import fs from "node:fs/promises";

export type BlogCompressionMetadata = {
    format: string,
    compressedFilename: string,
    lgwin: number,
    quality: number,
    uncompressedLength: number,
    compressedLength: number,
    orderStrategy: string,
}

export type BlogVariantHeader = {
    theme: "light" | "dark",
    width_pt: number,
    filename: string,
    offset: number,
    length: number,
}

export type ServerBlogMetadata = {
    slug: string,
    title: string,
    description: string,
    keywords: string[],
    author: string[],
    createdAt: Date,
    updatedAt: Date,
    compression: BlogCompressionMetadata,
    variants: BlogVariantHeader[]
}

export type TransitBlogMetadata = {
    compression: BlogCompressionMetadata,
    compressedBase64: string,
    variants: BlogVariant[]
}

export type BlogVariant = {
    theme: "light" | "dark",
    width_pt: number,
    filename: string,
    offset: number,
    length: number,
}

export async function loadTransitBlogMetadata(blogSlug: string): Promise<TransitBlogMetadata> {
    const buildJsonPath = fsPaths.blogBuildJson(blogSlug);
    const buildJson = await fs.readFile(buildJsonPath, "utf8");
    const build = JSON.parse(buildJson);
    const compression = build.compression as BlogCompressionMetadata;
    return {
        compression,
        compressedBase64: await fs.readFile(
            fsPaths.blogVariantFile(blogSlug, compression.compressedFilename),
            "base64",
        ),
        variants: build.variants.map((variant: BlogVariantHeader) => ({
            theme: variant.theme,
            width_pt: variant.width_pt,
            filename: variant.filename,
            offset: variant.offset,
            length: variant.length,
        })),
    }
}

export async function blogHasPdf(blogSlug: string): Promise<boolean> {
    return fs.access(fsPaths.blogPdf(blogSlug)).then(() => true).catch(() => false);
}

function parseServerBlogMetadata(build: Record<string, unknown>): ServerBlogMetadata {
    return {
        slug: build.slug as string,
        title: build.title as string,
        description: build.description as string,
        keywords: build.keywords as string[],
        author: build.author as string[],
        createdAt: new Date((build.createdAt as number) * 1000),
        updatedAt: new Date((build.updatedAt as number) * 1000),
        compression: build.compression as BlogCompressionMetadata,
        variants: build.variants as BlogVariantHeader[],
    };
}

export async function getServerBlogMetadata(blogSlug: string): Promise<ServerBlogMetadata | null> {
    const buildJsonPath = fsPaths.blogBuildJson(blogSlug);
    if (!await fs.access(buildJsonPath).then(() => true).catch(() => false)) {
        return null;
    }
    const buildData = await fs.readFile(buildJsonPath, "utf8");
    return parseServerBlogMetadata(JSON.parse(buildData));
}

export async function getAllServerBlogMetadata(): Promise<ServerBlogMetadata[]> {
    const blogs = await fs.readdir(fsPaths.blogsRoot());
    const results = await Promise.all(blogs.map((blogSlug) => getServerBlogMetadata(blogSlug)));
    return results.filter((result): result is ServerBlogMetadata => result !== null);
}
