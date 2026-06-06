import path from "node:path";
import type { Route } from "next";

import { buildInfo } from "@/site/system";

export const SITE_ORIGIN = process.env.TIMERERTIM_SITE_ORIGIN!

/** Matches {@link ../next.config.mjs} `trailingSlash` setting. */
const TRAILING_SLASH = true;

function asRoute(pathname: string): Route {
    return pathname as Route;
}

function routePath(...segments: string[]): string {
    const normalized = "/" + segments.filter(Boolean).join("/");
    if (normalized === "/") {
        return "/";
    }
    return TRAILING_SLASH ? `${normalized}/` : normalized;
}

function siteOrigin(): string {
    return SITE_ORIGIN.replace(/\/$/, "");
}

function absoluteUrl(route: string): string {
    return `${siteOrigin()}${route.startsWith("/") ? route : `/${route}`}`;
}

const blogsRoot = () => path.join(buildInfo.repoRoot, "build/website/blogs");

/** Relative site routes for Next.js navigation and links. */
export const routes = {
    home: () => asRoute("/"),
    docs: () => asRoute(routePath("docs")),
    blog: () => asRoute(routePath("blog")),
    about: () => asRoute(routePath("about")),
    feed: () => asRoute("/feed.xml"),
    favicon: () => asRoute("/favicon.ico"),
    blogPost: (slug: string) => asRoute(routePath("blog", slug)),
    blogPostPdf: (slug: string) => asRoute(`/blog/${slug}/${blogPdfFilename(slug)}`),
} as const;

/** Absolute URLs for SEO, RSS, Open Graph, and other external references. */
export const urls = {
    site: siteOrigin,
    home: () => absoluteUrl(routes.home()),
    docs: () => absoluteUrl(routes.docs()),
    blog: () => absoluteUrl(routes.blog()),
    about: () => absoluteUrl(routes.about()),
    feed: () => absoluteUrl(routes.feed()),
    blogPost: (slug: string) => absoluteUrl(routes.blogPost(slug)),
    blogPostPdf: (slug: string) => absoluteUrl(routes.blogPostPdf(slug)),
} as const;

export function blogPdfFilename(slug: string): string {
    return `${slug}.pdf`;
}

export function isBlogPostPdfFilename(slug: string, filename: string): boolean {
    return filename === blogPdfFilename(slug);
}

/** Filesystem paths for statically embedded blog build artifacts. */
export const fsPaths = {
    blogsRoot,
    blogDir: (slug: string) => path.join(blogsRoot(), slug),
    blogBuildJson: (slug: string) => path.join(blogsRoot(), slug, "build.json"),
    blogPdf: (slug: string) => path.join(blogsRoot(), slug, blogPdfFilename(slug)),
    blogVariantFile: (slug: string, filename: string) =>
        path.join(blogsRoot(), slug, filename),
} as const;
