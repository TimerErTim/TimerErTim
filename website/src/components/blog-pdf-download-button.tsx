import { blogPdfFilename, routes } from "@/paths";
import { Button } from "@/components/ui";

export function BlogPdfDownloadButton({ slug }: { slug: string }) {
    return (
        <a
            className="inline-flex"
            download={blogPdfFilename(slug)}
            href={routes.blogPostPdf(slug)}
        >
            <Button variant="secondary" size="sm">
                Download
            </Button>
        </a>
    );
}
