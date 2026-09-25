import { Suspense } from "react";
import { BlogSidebar } from "@/components/blog-sidebar";
import { PageShell } from "@/components/page-shell";
import {
  BlogOverview,
  BlogOverviewFallback,
  type BlogOverviewItem,
} from "@/components/blog-overview";
import { buildSitePageMetadata } from "@/lib/site-metadata";
import { getAllServerBlogMetadata } from "@/model/blogs";
import { routes } from "@/paths";
import { site } from "@/site";

export const metadata = buildSitePageMetadata({
  title: "Blog",
  description: `Essays and posts from ${site.name}.`,
  route: routes.blog(),
});

export default async function BlogPage() {
  const blogs = await getAllServerBlogMetadata();
  blogs.sort((a, b) => b.updatedAt.getTime() - a.updatedAt.getTime());

  const overviewItems: BlogOverviewItem[] = blogs.map((blog) => ({
    slug: blog.slug,
    title: blog.title,
    description: blog.description,
    keywords: blog.keywords ?? [],
    updatedAtDisplay: blog.updatedAt.toLocaleDateString(undefined, {
      year: "numeric",
      month: "short",
      day: "numeric",
    }),
  }));

  return (
    <PageShell sidebar={<BlogSidebar />} sidebarLayout="fill">
      <Suspense fallback={<BlogOverviewFallback blogs={overviewItems} />}>
        <BlogOverview blogs={overviewItems} />
      </Suspense>
    </PageShell>
  );
}
