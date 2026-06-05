import { getAllServerBlogMetadata } from "@/model/blogs";
import { routes } from "@/paths";
import { AppLink } from "@/components/ui";

export async function BlogSidebar({ currentSlug }: { currentSlug?: string }) {
  const blogs = await getAllServerBlogMetadata();
  const recent = blogs
    .filter((b) => b.slug !== currentSlug)
    .slice(0, 12);

  if (recent.length === 0) {
    return null;
  }

  return (
    <div className="bg-surface border border-border p-4">
      <h2 className="text-small leading-small font-semibold text-foreground m-0 mb-4">
        Recent essays
      </h2>
      <ul className="m-0 p-0 list-none space-y-2.5">
        {recent.map((blog) => (
          <li key={blog.slug} className="flex gap-2 text-small leading-small">
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
