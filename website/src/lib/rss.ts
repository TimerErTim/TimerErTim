import type { ServerBlogMetadata } from "@/model/blogs";

function escapeXml(value: string): string {
  return value
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&apos;");
}

export function buildBlogRssFeed({
  siteName,
  siteDescription,
  siteUrl,
  blogs,
}: {
  siteName: string;
  siteDescription: string;
  siteUrl: string;
  blogs: ServerBlogMetadata[];
}): string {
  const feedUrl = `${siteUrl}/feed.xml`;
  const items = [...blogs]
    .sort((a, b) => b.updatedAt.getTime() - a.updatedAt.getTime())
    .map((blog) => {
      const itemUrl = `${siteUrl}/blog/${blog.slug}/`;
      const categories = blog.keywords
        .map((keyword) => `      <category>${escapeXml(keyword)}</category>`)
        .join("\n");
      const author =
        blog.author.length > 0
          ? `      <author>${escapeXml(blog.author.join(", "))}</author>\n`
          : "";

      const updated =
        blog.updatedAt.getTime() !== blog.createdAt.getTime()
          ? `      <atom:updated>${blog.updatedAt.toISOString()}</atom:updated>\n`
          : "";

      return `    <item>
      <title>${escapeXml(blog.title)}</title>
      <link>${escapeXml(itemUrl)}</link>
      <description>${escapeXml(blog.description)}</description>
      <pubDate>${blog.createdAt.toUTCString()}</pubDate>
${updated}      <guid isPermaLink="true">${escapeXml(itemUrl)}</guid>
${author}${categories}
    </item>`;
    })
    .join("\n");

  return `<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
  <channel>
    <title>${escapeXml(`${siteName} Blog`)}</title>
    <link>${escapeXml(siteUrl)}</link>
    <description>${escapeXml(siteDescription)}</description>
    <language>en</language>
    <atom:link href="${escapeXml(feedUrl)}" rel="self" type="application/rss+xml" />
${items}
  </channel>
</rss>
`;
}
