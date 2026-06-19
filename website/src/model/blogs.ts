import { fsPaths } from "@/paths";
import fs from "node:fs/promises";

export type BlogVariantHeader = {
    theme: "light" | "dark",
    width_pt: number,
    compressedFilename: string,
    filename: string,
    referenceVariant: string | null,
}

export type ServerBlogMetadata = {
    slug: string,
    title: string,
    description: string,
    keywords: string[],
    author: string[],
    createdAt: Date,
    updatedAt: Date,
    variants: BlogVariantHeader[]
}

export type TransitBlogMetadata = {
    variants: BlogVariant[]
}

export type BlogVariant = {
    theme: "light" | "dark",
    width_pt: number,
    filename: string,
    compressedBase64: string,
    referenceVariant: string | null,
}

export async function loadTransitBlogMetadata(blogSlug: string): Promise<TransitBlogMetadata> {
    const buildJsonPath = fsPaths.blogBuildJson(blogSlug);
    const buildJson = await fs.readFile(buildJsonPath, "utf8");
    const build = JSON.parse(buildJson);
    return {
        variants: await Promise.all(build.variants.map(async (variant: BlogVariantHeader) => ({
            theme: variant.theme,
            width_pt: variant.width_pt,
            filename: variant.filename,
            referenceVariant: variant.referenceVariant,
            compressedBase64: await fs.readFile(
                fsPaths.blogVariantFile(blogSlug, variant.compressedFilename),
                "base64",
            ),
        }))),
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
