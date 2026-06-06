import { title } from "@/components/primitives";
import { BlogSidebar } from "@/components/blog-sidebar";
import { PageShell } from "@/components/page-shell";
import { Card, AppLink } from "@/components/ui";
import { getAllServerBlogMetadata } from "@/model/blogs";
import { routes } from "@/paths";

export default async function BlogPage() {
  const blogs = await getAllServerBlogMetadata();

  return (
    <PageShell sidebar={<BlogSidebar />}>
    <div>
      <h1 className={title()}>Blog</h1>
      <div className="mt-8 flex flex-col gap-4">
        {blogs.map((blog) => (
          <Card key={blog.slug} hoverable>
            <AppLink
              className="no-underline hover:no-underline"
              href={routes.blogPost(blog.slug)}
              variant="plain"
            >
              <h2 className="text-medium leading-medium font-bold text-foreground m-0">
                {blog.title}
              </h2>
            </AppLink>
            {blog.description && (
              <p className="mt-2 text-small leading-small text-foreground m-0">
                {blog.description}
              </p>
            )}
            <p className="mt-3 text-tiny leading-tiny text-muted m-0">
              Last updated:{" "}
              {blog.updatedAt.toLocaleDateString(undefined, {
                year: "numeric",
                month: "short",
                day: "numeric",
              })}
            </p>
          </Card>
        ))}
      </div>
    </div>
    </PageShell>
  );
}
