import {
  getAllServerBlogMetadata,
  type ServerBlogMetadata,
} from "@/model/blogs";

export type BlogSearchEntry = Pick<
  ServerBlogMetadata,
  "slug" | "title" | "description" | "keywords" | "author"
>;

export async function getBlogSearchEntries(): Promise<BlogSearchEntry[]> {
  const blogs = await getAllServerBlogMetadata();
  return blogs.map(({ slug, title, description, keywords, author }) => ({
    slug,
    title,
    description,
    keywords,
    author,
  }));
}
