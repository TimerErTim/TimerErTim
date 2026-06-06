import type { Metadata } from "next";
import { notFound } from "next/navigation";

import { BlogPdfDownloadButton } from "@/components/blog-pdf-download-button";
import { prose } from "@/components/primitives";
import { siteConfig } from "@/config/site";
import {
    buildBlogPageMetadata,
    buildBlogPostingJsonLd,
} from "@/lib/blog-metadata";
import {
    blogHasPdf,
    getAllServerBlogMetadata,
    getServerBlogMetadata,
    loadTransitBlogMetadata,
} from "@/model/blogs";
import RenderBlog from "./render-blog";

export async function generateStaticParams() {
    const blogs = await getAllServerBlogMetadata();
    return blogs.map(b => ({ "blog-name": b.slug }));
}

export async function generateMetadata({
    params,
}: {
    params: Promise<{ "blog-name": string }>;
}): Promise<Metadata> {
    const p = await params;
    const blogMetadata = await getServerBlogMetadata(p["blog-name"]);
    if (!blogMetadata) {
        return {};
    }

    const hasPdf = await blogHasPdf(p["blog-name"]);
    return buildBlogPageMetadata({
        blog: blogMetadata,
        siteName: siteConfig.name,
        hasPdf,
    });
}

export default async function BlogPage({ params }: { params: Promise<{ "blog-name": string }> }) {
    const p = await params;
    const blogMetadata = await getServerBlogMetadata(p["blog-name"]);
    if (!blogMetadata) {
        notFound();
    }

    const blogData = await loadTransitBlogMetadata(p["blog-name"]);
    const hasPdf = await blogHasPdf(p["blog-name"]);
    const jsonLd = buildBlogPostingJsonLd({
        blog: blogMetadata,
        siteName: siteConfig.name,
        hasPdf,
    });

    return (
        <>
            <script
                type="application/ld+json"
                dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
            />
            <header className="border-b border-border mb-8 pb-5">
                <h1 className="font-sans text-large leading-large font-bold m-0">
                    {blogMetadata.title}
                </h1>
                <div className="mt-3 text-small leading-small text-muted">
                    {blogMetadata.author && blogMetadata.author.length > 0 && (
                        <span>
                            By {blogMetadata.author.join(", ")}
                        </span>
                    )}
                    {blogMetadata.updatedAt && (
                        <span className={blogMetadata.author && blogMetadata.author.length > 0 ? "ml-4" : ""}>
                            Last updated: {blogMetadata.updatedAt.toLocaleDateString(undefined, { year: 'numeric', month: 'short', day: 'numeric' })}
                        </span>
                    )}
                </div>
                {hasPdf && (
                    <div className="mt-4">
                        <BlogPdfDownloadButton slug={p["blog-name"]} />
                    </div>
                )}
                {blogMetadata.description && (
                    <p className={`${prose()} mt-4 text-foreground`}>
                        {blogMetadata.description}
                    </p>
                )}
                {blogMetadata.keywords && blogMetadata.keywords.length > 0 && (
                    <p className="mt-5 text-tiny leading-tiny text-muted m-0">
                        Tags: {blogMetadata.keywords.join(", ")}
                    </p>
                )}
            </header>
            <article className={prose()}>
                <RenderBlog blogData={blogData} />
            </article>
        </>
    );
}
