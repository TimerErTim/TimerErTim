import { getBlogs } from "@/model/blogs";
import { notFound } from "next/navigation";
import TypstDocument from "@/components/typst-document";
import { readFile } from "node:fs/promises";

async function getArtifactData(path: string): Promise<string> {
    let data: Uint8Array;
    try {
        data = await readFile(path);
    } catch (e) {
        throw new Error(`Failed to read artifact data from ${path}`);
    }
    return btoa(String.fromCharCode(...data));
}

async function getPdfData(path: string): Promise<string> {
    let data: Uint8Array;
    try {
        data = await readFile(path);
    } catch (e) {
        throw new Error(`Failed to read PDF data from ${path}`);
    }
    // For PDFs, use base64 data URL
    return `data:application/pdf;base64,${Buffer.from(data).toString("base64")}`;
}

async function getSvgContent(path: string): Promise<string> {
    const svgContent = await readFile(path, 'utf8');
    return svgContent;
}

export async function generateStaticParams() {
    const blogs = await getBlogs();
    return blogs.map(b => ({ "blog-name": b.slug }));
}

export default async function BlogPage({ params }: { params: Promise<{ "blog-name": string }> }) {
    const p = await params;
    const blogs = await getBlogs();
    const blog = blogs.find(b => b.slug === p["blog-name"]);

    if (!blog) {
        notFound();
    }

    let artifactData = await getArtifactData(blog.vectorFormatLocalPath);

    // Assume PDF path is available as blog.pdfLocalPath
    let pdfDataUrl: string | undefined = undefined;
    pdfDataUrl = await getPdfData(blog.vectorFormatLocalPath.replace(".multi.sir.in", ".pdf"));

    let svgContent = await getSvgContent(blog.vectorFormatLocalPath.replace(".multi.sir.in", ".artifact.html.svg.html"));

    return (
        <div className="w-full h-full flex flex-col">
            <h1>{blog.title}</h1>
            <div
            suppressHydrationWarning
            dangerouslySetInnerHTML={{ __html: svgContent }} 
            />
        </div>
    );
}