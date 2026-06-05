import { BlogSidebar } from "@/components/blog-sidebar";
import { PageShell } from "@/components/page-shell";

export default async function BlogPostLayout({
  children,
  params,
}: {
  children: React.ReactNode;
  params: Promise<{ "blog-name": string }>;
}) {
  const { "blog-name": slug } = await params;

  return (
    <PageShell sidebar={<BlogSidebar currentSlug={slug} />}>
      {children}
    </PageShell>
  );
}
