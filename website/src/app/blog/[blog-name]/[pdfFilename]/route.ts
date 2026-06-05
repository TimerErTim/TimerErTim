import { getAllServerBlogMetadata } from "@/model/blogs";
import {
    blogPdfFilename,
    fsPaths,
    isBlogPostPdfFilename,
} from "@/paths";
import fs from "node:fs/promises";

export const dynamic = "force-static";

export async function generateStaticParams() {
    const blogs = await getAllServerBlogMetadata();
    return blogs.map((blog) => ({
        "blog-name": blog.slug,
        pdfFilename: blogPdfFilename(blog.slug),
    }));
}

export async function GET(
    _request: Request,
    { params }: { params: Promise<{ "blog-name": string; pdfFilename: string }> },
) {
    const p = await params;
    if (!isBlogPostPdfFilename(p["blog-name"], p.pdfFilename)) {
        return new Response("Not found", { status: 404 });
    }

    const pdfBytes = await fs.readFile(fsPaths.blogPdf(p["blog-name"]));

    return new Response(pdfBytes, {
        headers: {
            "Content-Type": "application/pdf",
        },
    });
}
