import { AppLink, Card, Divider } from "@/components/ui";
import { BlogSidebarTagList } from "@/components/blog-sidebar-tags";
import { getAllServerBlogMetadata } from "@/model/blogs";
import { routes } from "@/paths";

export async function BlogSidebar({
  currentSlug,
  showTags = !currentSlug,
}: {
  currentSlug?: string;
  showTags?: boolean;
}) {
  const blogs = await getAllServerBlogMetadata();
  const recent = blogs
    .filter((b) => b.slug !== currentSlug)
    .sort((a, b) => b.updatedAt.getTime() - a.updatedAt.getTime())
    .slice(0, 12);

  const tagCounts = new Map<string, number>();
  for (const blog of blogs) {
    for (const tag of blog.keywords ?? []) {
      tagCounts.set(tag, (tagCounts.get(tag) ?? 0) + 1);
    }
  }
  const allTags = Array.from(tagCounts.entries())
    .map(([tag, count]) => ({ tag, count }))
    .sort((a, b) => b.count - a.count || a.tag.localeCompare(b.tag));

  return (
    <Card className="flex h-fit max-h-full flex-col pb-0">
      <h2 className="shrink-0 text-small leading-small font-bold text-foreground m-0 mb-4">
        Recent blogs
      </h2>
      <ul className="min-h-0 flex-1 overflow-hidden m-0 p-0 list-none -space-y-1.5">
        {recent.map((blog) => (
          <li key={blog.slug} className="flex gap-2 text-small leading-small pb-4">
            <span aria-hidden className="text-accent font-bold select-none">
              ·
            </span>
            <AppLink
              className="text-foreground no-underline hover:text-accent hover:underline decoration-shadow decoration-2 underline-offset-[3px]"
              href={routes.blogPost(blog.slug)}
              variant="plain"
            >
              {blog.title}
            </AppLink>
          </li>
        ))}
      </ul>

      {showTags && allTags.length > 0 && (
        <>
          <Divider className="my-2 md:my-4" />
          <h2 className="shrink-0 text-small leading-small font-bold text-foreground m-0 mb-2 md:mb-3">
            Tags
          </h2>
          <BlogSidebarTagList tags={allTags} />
        </>
      )}
    </Card>
  );
}
