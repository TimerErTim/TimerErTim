import { getAllServerBlogMetadata, loadTransitBlogMetadata } from "@/model/blogs";
import { readFile } from "node:fs/promises";
import RenderBlog from "./render-blog";

async function getSvgContent(path: string): Promise<string> {
    const svgContent = await readFile(path, 'utf8');
    return svgContent;
}

export async function generateStaticParams() {
    const blogs = await getAllServerBlogMetadata();
    return blogs.map(b => ({ "blog-name": b.slug }));
}

export default async function BlogPage({ params }: { params: Promise<{ "blog-name": string }> }) {
    const p = await params;
    const blogData = await loadTransitBlogMetadata(p["blog-name"]);
    const blogMetadata = (await getAllServerBlogMetadata()).find(b => b.slug === p["blog-name"])!;

    return (
        <>
            <header className="border-b border-gray-200 mb-8 pb-5">
                <h1 className="text-4xl font-bold m-0 leading-tight break-words">{blogMetadata.title}</h1>
                <div className="mt-3 text-gray-600 text-base leading-snug">
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
                {blogMetadata.description && (
                    <div className="mt-4 text-gray-500 text-lg">
                        {blogMetadata.description}
                    </div>
                )}
                {blogMetadata.keywords && blogMetadata.keywords.length > 0 && (
                    <div className="mt-5 text-sm text-gray-400">
                        Tags: {blogMetadata.keywords.join(", ")}
                    </div>
                )}
            </header>
            <article>
                <RenderBlog blogData={blogData} />
            </article>
        </>
    );
}