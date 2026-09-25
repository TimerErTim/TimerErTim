"use client";

import Link from "next/link";
import { useSearchParams } from "next/navigation";
import { useMemo } from "react";
import { Card, Tag } from "@/components/ui";
import { routes } from "@/paths";

export type BlogOverviewItem = {
  slug: string;
  title: string;
  description: string;
  keywords: string[];
  updatedAtDisplay: string;
};

export function BlogOverviewList({
  blogs,
  activeTag,
}: {
  blogs: BlogOverviewItem[];
  activeTag?: string | null;
}) {
  return (
    <div className="flex flex-col gap-4">
      {blogs.map((blog) => (
        <div key={blog.slug} className="group relative">
          <Card hoverable className="relative transition-all">
            <h2 className="text-medium leading-medium font-bold text-foreground m-0">
              <Link
                href={routes.blogPost(blog.slug)}
                className="text-foreground no-underline hover:text-accent after:absolute after:inset-0 after:z-0"
              >
                {blog.title}
              </Link>
            </h2>
            {blog.description && (
              <p className="mt-2 text-small leading-small text-foreground m-0 font-medium">
                {blog.description}
              </p>
            )}
            {blog.keywords && blog.keywords.length > 0 && (
              <div className="relative z-10 mt-2 flex flex-wrap gap-2">
                {blog.keywords.map((keyword) => {
                  const isCurrentTag =
                    Boolean(activeTag) &&
                    keyword.toLowerCase() === activeTag?.toLowerCase();
                  return (
                    <Tag
                      key={keyword}
                      href={isCurrentTag ? routes.blog() : routes.blog(keyword)}
                      active={isCurrentTag}
                    >
                      {keyword}
                    </Tag>
                  );
                })}
              </div>
            )}
            <p className="mt-3 text-tiny leading-tiny text-muted m-0">
              Last updated: {blog.updatedAtDisplay}
            </p>
          </Card>
        </div>
      ))}
    </div>
  );
}

export function BlogOverviewFallback({ blogs }: { blogs: BlogOverviewItem[] }) {
  return <BlogOverviewList blogs={blogs} />;
}

export function BlogOverview({ blogs }: { blogs: BlogOverviewItem[] }) {
  const searchParams = useSearchParams();
  const activeTag = searchParams.get("tag");
  const searchQuery = searchParams.get("search") || searchParams.get("q");

  const filteredBlogs = useMemo(() => {
    let result = blogs;

    if (activeTag) {
      const lowerTag = activeTag.toLowerCase();
      result = result.filter((blog) =>
        blog.keywords?.some((k) => k.toLowerCase() === lowerTag),
      );
    }

    if (searchQuery) {
      const lowerSearch = searchQuery.toLowerCase().trim();
      result = result.filter((blog) => {
        const matchesTitle = blog.title.toLowerCase().includes(lowerSearch);
        const matchesDesc = blog.description?.toLowerCase().includes(lowerSearch);
        const matchesKeyword = blog.keywords?.some((k) =>
          k.toLowerCase().includes(lowerSearch),
        );
        return matchesTitle || matchesDesc || matchesKeyword;
      });
    }

    return result;
  }, [blogs, activeTag, searchQuery]);

  const hasFilter = Boolean(activeTag || searchQuery);

  return (
    <div className="flex flex-col gap-6">
      {hasFilter && (
        <div className="flex flex-wrap items-center justify-between gap-3 rounded-md bg-overlay/40 px-3.5 py-2.5 text-small">
          <div className="flex flex-wrap items-center gap-2">
            <span className="text-muted font-medium">Filtered by:</span>
            {activeTag && (
              <span className="inline-flex items-center gap-1.5">
                <Tag active href={routes.blog()}>
                  {activeTag}
                  <span aria-hidden className="font-bold ml-0.5">
                    ×
                  </span>
                </Tag>
              </span>
            )}
            {searchQuery && (
              <span className="font-semibold text-foreground">
                &ldquo;{searchQuery}&rdquo;
              </span>
            )}
            <span className="text-tiny text-muted">
              ({filteredBlogs.length} {filteredBlogs.length === 1 ? "post" : "posts"})
            </span>
          </div>
          <Link
            href={routes.blog()}
            className="text-tiny font-bold text-muted hover:text-accent no-underline underline-offset-2 hover:underline"
          >
            Clear all
          </Link>
        </div>
      )}

      {filteredBlogs.length > 0 ? (
        <BlogOverviewList blogs={filteredBlogs} activeTag={activeTag} />
      ) : (
        <div className="flex flex-col items-center justify-center rounded-md border-md border-dashed border-shadow py-12 text-center">
          <p className="text-medium font-bold text-foreground m-0">
            No blog posts found
          </p>
          <p className="text-small text-muted mt-1 mb-4">
            {activeTag
              ? `There are no posts tagged with "${activeTag}".`
              : `No posts matched "${searchQuery}".`}
          </p>
          <Link
            href={routes.blog()}
            className="text-small font-bold text-accent hover:underline"
          >
            Show all posts
          </Link>
        </div>
      )}
    </div>
  );
}
