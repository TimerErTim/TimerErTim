import { getAllServerBlogMetadata } from "@/model/blogs";
import { routes } from "@/paths";
import { AppLink } from "@/components/ui";

export async function BlogSidebar({ currentSlug }: { currentSlug?: string }) {
  const blogs = await getAllServerBlogMetadata();
  const recent = blogs
    .filter((b) => b.slug !== currentSlug)
    .sort((a, b) => b.updatedAt.getTime() - a.updatedAt.getTime())
    .slice(0, 12);

  return (
    <div className="flex h-fit max-h-full flex-col overflow-hidden bg-surface border border-border p-4 pb-0">
      <h2 className="shrink-0 text-small leading-small font-semibold text-foreground m-0 mb-4">
        Recent blogs
      </h2>
      <ul className="min-h-0 flex-1 overflow-hidden m-0 p-0 list-none -space-y-1.5">
        {recent.map((blog) => (
          <li key={blog.slug} className="flex gap-2 text-small leading-small pb-4">
            <span aria-hidden className="text-muted select-none">
              ·
            </span>
            <AppLink
              className="text-foreground no-underline hover:text-accent hover:underline"
              href={routes.blogPost(blog.slug)}
              variant="plain"
            >
              {blog.title}
            </AppLink>
          </li>
        ))}
      </ul>
    </div>
  );
}
