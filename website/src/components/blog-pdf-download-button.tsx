import { blogPdfFilename, routes } from "@/paths";

export function BlogPdfDownloadButton({ slug }: { slug: string }) {
    return (
        <a
            className="button button--secondary button--md rounded-full inline-flex items-center gap-2"
            href={routes.blogPostPdf(slug)}
            download={blogPdfFilename(slug)}
        >
            Download PDF
        </a>
    );
}
