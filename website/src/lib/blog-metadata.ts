import type { Metadata } from "next";

import type { ServerBlogMetadata } from "@/model/blogs";
import { getBlogPdfDownloadPath } from "@/model/blogs";

function blogPageUrl(siteUrl: string, slug: string): string {
  return `${siteUrl}/blog/${slug}/`;
}

export function buildBlogPageMetadata({
  blog,
  siteName,
  siteUrl,
  hasPdf,
}: {
  blog: ServerBlogMetadata;
  siteName: string;
  siteUrl: string;
  hasPdf: boolean;
}): Metadata {
  const pageUrl = blogPageUrl(siteUrl, blog.slug);
  const pdfUrl = `${siteUrl}${getBlogPdfDownloadPath(blog.slug)}`;

  return {
    title: blog.title,
    description: blog.description,
    keywords: blog.keywords,
    authors: blog.author.map((name) => ({ name })),
    alternates: {
      canonical: pageUrl,
      ...(hasPdf
        ? {
            types: {
              "application/pdf": pdfUrl,
            },
          }
        : {}),
    },
    openGraph: {
      type: "article",
      locale: "en",
      url: pageUrl,
      siteName,
      title: blog.title,
      description: blog.description,
      publishedTime: blog.createdAt.toISOString(),
      modifiedTime: blog.updatedAt.toISOString(),
      authors: blog.author,
      tags: blog.keywords,
    },
    twitter: {
      card: "summary",
      title: blog.title,
      description: blog.description,
    },
    other: {
      "article:published_time": blog.createdAt.toISOString(),
      "article:modified_time": blog.updatedAt.toISOString(),
      ...(blog.author.length > 0
        ? { "article:author": blog.author.join(", ") }
        : {}),
    },
  };
}

export function buildBlogPostingJsonLd({
  blog,
  siteName,
  siteUrl,
  hasPdf,
}: {
  blog: ServerBlogMetadata;
  siteName: string;
  siteUrl: string;
  hasPdf: boolean;
}): Record<string, unknown> {
  const pageUrl = blogPageUrl(siteUrl, blog.slug);

  return {
    "@context": "https://schema.org",
    "@type": "BlogPosting",
    headline: blog.title,
    description: blog.description,
    url: pageUrl,
    mainEntityOfPage: {
      "@type": "WebPage",
      "@id": pageUrl,
    },
    datePublished: blog.createdAt.toISOString(),
    dateModified: blog.updatedAt.toISOString(),
    keywords: blog.keywords.join(", "),
    author: blog.author.map((name) => ({
      "@type": "Person",
      name,
    })),
    publisher: {
      "@type": "Organization",
      name: siteName,
      url: siteUrl,
    },
    ...(hasPdf
      ? {
          encoding: {
            "@type": "MediaObject",
            contentUrl: `${siteUrl}${getBlogPdfDownloadPath(blog.slug)}`,
            encodingFormat: "application/pdf",
          },
        }
      : {}),
  };
}
