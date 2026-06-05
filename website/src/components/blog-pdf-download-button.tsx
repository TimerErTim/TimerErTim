export function BlogPdfDownloadButton({
    slug,
    downloadPath,
}: {
    slug: string;
    downloadPath: string;
}) {
    return (
        <a
            className="button button--secondary button--md rounded-full inline-flex items-center gap-2"
            href={downloadPath}
            download={`${slug}.pdf`}
        >
            Download PDF
        </a>
    );
}
