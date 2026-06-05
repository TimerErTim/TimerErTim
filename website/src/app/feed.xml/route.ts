import { siteConfig } from "@/config/site";
import { buildBlogRssFeed } from "@/lib/rss";
import { getAllServerBlogMetadata } from "@/model/blogs";

export const dynamic = "force-static";

export async function GET() {
  const blogs = await getAllServerBlogMetadata();
  const feed = buildBlogRssFeed({
    siteName: siteConfig.name,
    siteDescription: siteConfig.description,
    siteUrl: siteConfig.url,
    blogs,
  });

  return new Response(feed, {
    headers: {
      "Content-Type": "application/rss+xml; charset=utf-8",
    },
  });
}
