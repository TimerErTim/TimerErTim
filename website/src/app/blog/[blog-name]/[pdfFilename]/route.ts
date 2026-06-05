import {
    getAllServerBlogMetadata,
    getBlogPdfFilesystemPath,
} from "@/model/blogs";
import fs from "node:fs/promises";

export const dynamic = "force-static";

export async function generateStaticParams() {
    const blogs = await getAllServerBlogMetadata();
    return blogs.map((blog) => ({
        "blog-name": blog.slug,
        pdfFilename: `${blog.slug}.pdf`,
    }));
}

export async function GET(
    _request: Request,
    { params }: { params: Promise<{ "blog-name": string; pdfFilename: string }> },
) {
    const p = await params;
    const expectedFilename = `${p["blog-name"]}.pdf`;
    if (p.pdfFilename !== expectedFilename) {
        return new Response("Not found", { status: 404 });
    }

    const pdfPath = getBlogPdfFilesystemPath(p["blog-name"]);
    const pdfBytes = await fs.readFile(pdfPath);

    return new Response(pdfBytes, {
        headers: {
            "Content-Type": "application/pdf",
        },
    });
}
