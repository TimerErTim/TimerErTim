"use client";

import Link from "next/link";
import { useSearchParams } from "next/navigation";
import { useMemo } from "react";
import { title } from "@/components/primitives";
import { Card, Tag, buttonStyles } from "@/components/ui";
import { routes } from "@/paths";

export type BlogOverviewItem = {
  slug: string;
  title: string;
  description: string;
  keywords: string[];
  updatedAtDisplay: string;
};

export function BlogOverview({ blogs }: { blogs: BlogOverviewItem[] }) {
  const searchParams = useSearchParams();
  const activeTags = searchParams ? searchParams.getAll("tag").filter(Boolean) : [];

  const filteredBlogs = useMemo(() => {
    if (activeTags.length === 0) {
      return blogs;
    }
    const lowerTags = activeTags.map((t) => t.toLowerCase());
    return blogs.filter((blog) => {
      const blogKeywords = (blog.keywords ?? []).map((k) => k.toLowerCase());
      return lowerTags.every((t) => blogKeywords.includes(t));
    });
  }, [blogs, activeTags]);

  const lowerActiveTagSet = useMemo(
    () => new Set(activeTags.map((t) => t.toLowerCase())),
    [activeTags],
  );

  return (
    <div className="flex flex-1 flex-col">
      <div className="flex flex-col gap-2">
        <div className="flex items-baseline gap-2">
          <h1 className={title()}>Blog</h1>
          <span className="text-large leading-large tracking-tight">
            ({filteredBlogs.length})
          </span>
        </div>

        {activeTags.length > 0 && (
          <div className="flex flex-wrap items-center gap-2 text-tiny text-muted">
            {activeTags.map((tag) => {
              const remainingTags = activeTags.filter(
                (t) => t.toLowerCase() !== tag.toLowerCase(),
              );
              return (
                <Tag
                  key={tag}
                  active
                  href={routes.blog(remainingTags)}
                >
                  {tag}
                  <span aria-hidden className="font-bold ml-1">
                    ×
                  </span>
                </Tag>
              );
            })}
            <Link
              href={routes.blog()}
              className="text-muted hover:text-accent no-underline hover:underline font-medium"
            >
              Clear
            </Link>
          </div>
        )}
      </div>

      <div className="mt-8">
        {filteredBlogs.length > 0 ? (
          <div className="flex flex-col gap-4">
            {filteredBlogs.map((blog) => (
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
                      {blog.keywords.map((keyword) => {
                        const isHighlighted = lowerActiveTagSet.has(
                          keyword.toLowerCase(),
                        );
                        return (
                          <Tag key={keyword} active={isHighlighted}>
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
              </Link>
            ))}
          </div>
        ) : (
          <div className="flex flex-col items-center justify-center rounded-md border-md border-dashed border-shadow py-12 text-center">
            <p className="text-medium font-bold text-foreground m-0">
              No blog posts found
            </p>
            <p className="text-small text-muted mt-1 mb-4">
              There are no posts matching the selected tags.
            </p>
            <Link
              href={routes.blog()}
              className={buttonStyles({ variant: "primary", size: "sm" })}
            >
              Show all posts
            </Link>
          </div>
        )}
      </div>
    </div>
  );
}
