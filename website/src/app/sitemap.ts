import type { MetadataRoute } from "next";

import { getAllServerBlogMetadata } from "@/model/blogs";
import { urls } from "@/paths";

export const dynamic = "force-static";

export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  const blogs = await getAllServerBlogMetadata();

  return [
    {
      url: urls.home(),
      changeFrequency: "monthly",
      priority: 1,
    },
    {
      url: urls.blog(),
      changeFrequency: "weekly",
      priority: 0.9,
    },
    {
      url: urls.about(),
      changeFrequency: "monthly",
      priority: 0.7,
    },
    ...blogs.map((blog) => ({
      url: urls.blogPost(blog.slug),
      lastModified: blog.updatedAt,
      changeFrequency: "monthly" as const,
      priority: 0.8,
    })),
  ];
}
