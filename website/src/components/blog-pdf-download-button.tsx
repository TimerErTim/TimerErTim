import { blogPdfFilename, routes } from "@/paths";
import { Button } from "@/components/ui";

export function BlogPdfDownloadButton({ slug }: { slug: string }) {
    return (
        <a
            className="contents"
            download={blogPdfFilename(slug)}
            href={routes.blogPostPdf(slug)}
        >
            <Button variant="primary" size="sm">
                Download PDF
            </Button>
       
        </a>
    );
}
