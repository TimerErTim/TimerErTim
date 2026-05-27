import { buildInfo } from "@/config/system";
import fs from "node:fs/promises";
import path from "node:path";

export type BlogMetadata = {
    slug: string,
    title: string,
    createdAt: Date,
    updatedAt: Date,
    pdfDownloadUrl: string,
    vectorFormatLocalPath: string
}

export async function getBlogs(): Promise<BlogMetadata[]> {
    const blogs = await fs.readdir(path.join(buildInfo.repoRoot, "out/blogs"));
    return blogs.map((blog) => {
        return {
            slug: blog,
            title: blog,
            createdAt: new Date(),
            updatedAt: new Date(),
            pdfDownloadUrl: path.join("/out/blogs/", blog, "/main.pdf"),
            vectorFormatLocalPath: path.join(buildInfo.repoRoot, "/out/blogs/", blog, "/main.multi.sir.in"),
        }
    });
}