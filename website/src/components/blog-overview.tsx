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
}: {
  blogs: BlogOverviewItem[];
}) {
  return (
    <div className="flex flex-col gap-4">
      {blogs.map((blog) => (
        <Link
          key={blog.slug}
          href={routes.blogPost(blog.slug)}
          className="contents"
        >
          <Card hoverable>
            <h2 className="text-medium leading-medium font-bold text-foreground m-0">
              {blog.title}
            </h2>
            {blog.description && (
              <p className="mt-2 text-small leading-small text-foreground m-0 font-medium">
                {blog.description}
              </p>
            )}
            {blog.keywords && blog.keywords.length > 0 && (
              <div className="mt-2 flex flex-wrap gap-2">
                {blog.keywords.map((keyword) => (
                  <Tag key={keyword}>{keyword}</Tag>
                ))}
              </div>
            )}
            <p className="mt-3 text-tiny leading-tiny text-muted m-0">
              Last updated: {blog.updatedAtDisplay}
            </p>
          </Card>
        </Link>
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

  const filteredBlogs = useMemo(() => {
    if (!activeTag) {
      return blogs;
    }
    const lowerTag = activeTag.toLowerCase();
    return blogs.filter((blog) =>
      blog.keywords?.some((k) => k.toLowerCase() === lowerTag),
    );
  }, [blogs, activeTag]);

  return (
    <div className="flex flex-col gap-4">
      {activeTag && (
        <div className="flex items-center gap-2 text-tiny text-muted">
          <span>Tagged with</span>
          <Tag active href={routes.blog()}>
            {activeTag}
            <span aria-hidden className="font-bold ml-1">
              ×
            </span>
          </Tag>
          <span>
            ({filteredBlogs.length} {filteredBlogs.length === 1 ? "post" : "posts"})
          </span>
          <span>·</span>
          <Link
            href={routes.blog()}
            className="text-muted hover:text-accent no-underline hover:underline font-medium"
          >
            Clear
          </Link>
        </div>
      )}

      {filteredBlogs.length > 0 ? (
        <BlogOverviewList blogs={filteredBlogs} />
      ) : (
        <div className="flex flex-col items-center justify-center rounded-md border-md border-dashed border-shadow py-12 text-center">
          <p className="text-medium font-bold text-foreground m-0">
            No blog posts found
          </p>
          <p className="text-small text-muted mt-1 mb-4">
            There are no posts tagged with &ldquo;{activeTag}&rdquo;.
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
