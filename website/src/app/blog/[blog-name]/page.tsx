import type { Metadata } from "next";
import { notFound } from "next/navigation";

import { BlogPdfDownloadButton } from "@/components/blog-pdf-download-button";
import { BlogSidebar } from "@/components/blog-sidebar";
import { PageShell } from "@/components/page-shell";
import { prose } from "@/components/primitives";
import { Tag } from "@/components/ui/tag";
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
import { site } from "@/site";
import RenderBlog from "./render-blog";
import { twMerge } from "@/lib/tw";

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
        siteName: site.name,
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
        siteName: site.name,
        hasPdf,
    });

    return (
        <>
            <script
                type="application/ld+json"
                dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
            />
            <PageShell
                sidebar={<BlogSidebar currentSlug={p["blog-name"]} />}
                sidebarLayout="match-content"
                subContent={
                    <article className={twMerge(prose(), "border-t border-border pt-10")}>
                        <RenderBlog blogData={blogData} />
                    </article>
                }
            >
                <header>
                    <h1 className="font-sans text-large leading-large font-bold m-0">
                        {blogMetadata.title}
                    </h1>
                    <div className="flex flex-row flex-wrap justify-between">

                    <div className="mt-3 mb-2 text-small leading-small text-muted grow">
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
                        <div className="mt-2">
                            <BlogPdfDownloadButton slug={p["blog-name"]} />
                        </div>
                    )}
                    </div>
                    {blogMetadata.description && (
                        <p className={`${prose()} mt-4 text-foreground`}>
                            {blogMetadata.description}
                        </p>
                    )}
                    {blogMetadata.keywords && blogMetadata.keywords.length > 0 && (
                        <div className="mt-5 flex flex-wrap gap-2">
                            {blogMetadata.keywords.map((keyword) => (
                                <Tag key={keyword}>{keyword}</Tag>
                            ))}
                        </div>
                    )}
                </header>
            </PageShell>
        </>
    );
}
