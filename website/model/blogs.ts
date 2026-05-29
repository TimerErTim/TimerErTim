import { buildInfo } from "@/config/system";
import fs from "node:fs/promises";
import path from "node:path";

export type BlogVariantHeader = {
    theme: "light" | "dark",
    width_pt: number,
    compressedFilename: string,
    filename: string,
}

export type ServerBlogMetadata = {
    slug: string,
    title: string,
    description: string,
    keywords: string[],
    author: string[],
    createdAt: Date,
    updatedAt: Date,
    compressionRefVariant: string,
    variants: BlogVariantHeader[]
}

export type TransitBlogMetadata = {
    compressionRefFilename: string, // The filename of the reference variant, which has to be uncompressed with no dict
    variants: BlogVariant[]
}

export type BlogVariant = {
    theme: "light" | "dark",
    width_pt: number,
    filename: string,
    compressedBase64: string,
}

export async function loadTransitBlogMetadata(blogSlug: string): Promise<TransitBlogMetadata> {
    const buildJsonPath = path.join(buildInfo.repoRoot, "build/website/blogs", blogSlug, "build.json");
    const buildJson = await fs.readFile(buildJsonPath, "utf8");
    const build = JSON.parse(buildJson);
    return {
        compressionRefFilename: build.compressionRefVariant,
        variants: await Promise.all(build.variants.map(async (variant: BlogVariantHeader) => ({
            theme: variant.theme,
            width_pt: variant.width_pt,
            filename: variant.filename,
            compressedBase64: await fs.readFile(path.join(buildInfo.repoRoot, "build/website/blogs", blogSlug, variant.compressedFilename), "base64"),
        }))),
    }
}

export async function getAllServerBlogMetadata(): Promise<ServerBlogMetadata[]> {
    const blogs = await fs.readdir(path.join(buildInfo.repoRoot, "build/website/blogs"));
    return await Promise.all(blogs.map(async (blogSlug) => {
        const buildData = await fs.readFile(path.join(buildInfo.repoRoot, "build/website/blogs", blogSlug, "build.json"), "utf8");
        const build = JSON.parse(buildData);
        return {
            slug: build.slug,
            title: build.title,
            description: build.description,
            keywords: build.keywords,
            author: build.author,
            createdAt: new Date(build.createdAt * 1000),
            updatedAt: new Date(build.updatedAt * 1000),
            compressionRefVariant: build.compressionRefVariant,
            variants: build.variants,
        };
    }));
}