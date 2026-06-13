import path from "node:path";
import type { Route } from "next";

import { buildInfo } from "@/site/system";
import configValues from "../../config/values.json";

/** Injected by mise from `config/values.json` during dev and build. */
export const SITE_ORIGIN = configValues.TIMERERTIM_SITE_ORIGIN;

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

export function absoluteSiteUrl(route: string): string {
    return `${siteOrigin()}${route.startsWith("/") ? route : `/${route}`}`;
}

const blogsRoot = () => path.join(buildInfo.repoRoot, "build/website/blogs");

/** Relative site routes for Next.js navigation and links. */
export const routes = {
    home: () => asRoute("/"),
    blog: () => asRoute(routePath("blog")),
    about: () => asRoute(routePath("about")),
    feed: () => asRoute("/feed.xml"),
    sitemap: () => asRoute("/sitemap.xml"),
    manifest: () => asRoute("/manifest.webmanifest"),
    favicon: () => asRoute("/favicon.ico"),
    favicon16: () => asRoute("/favicon-16x16.png"),
    favicon32: () => asRoute("/favicon-32x32.png"),
    appleTouchIcon: () => asRoute("/apple-touch-icon.png"),
    androidChrome192: () => asRoute("/android-chrome-192x192.png"),
    androidChrome512: () => asRoute("/android-chrome-512x512.png"),
    blogPost: (slug: string) => asRoute(routePath("blog", slug)),
    blogPostPdf: (slug: string) => asRoute(`/blog/${slug}/${blogPdfFilename(slug)}`),
    cvPdf: () => asRoute("/cv/tim-peko-cv.pdf"),
} as const;

/** Absolute URLs for SEO, RSS, Open Graph, and other external references. */
export const urls = {
    site: siteOrigin,
    home: () => absoluteSiteUrl(routes.home()),
    blog: () => absoluteSiteUrl(routes.blog()),
    about: () => absoluteSiteUrl(routes.about()),
    feed: () => absoluteSiteUrl(routes.feed()),
    blogPost: (slug: string) => absoluteSiteUrl(routes.blogPost(slug)),
    blogPostPdf: (slug: string) => absoluteSiteUrl(routes.blogPostPdf(slug)),
    cvPdf: () => absoluteSiteUrl(routes.cvPdf()),
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
