"use client";

import { useSearchParams } from "next/navigation";
import { Tag } from "@/components/ui";
import { routes } from "@/paths";

export type BlogTagCount = {
  tag: string;
  count: number;
};

export function BlogSidebarTagListFallback({ tags }: { tags: BlogTagCount[] }) {
  return (
    <ul className="m-0 p-0 list-none flex flex-wrap gap-1.5 pb-4">
      {tags.map(({ tag, count }) => (
        <li key={tag}>
          <Tag href={routes.blog(tag)}>
            <span>{tag}</span>
            <span className="opacity-80 text-[10px] font-normal">({count})</span>
          </Tag>
        </li>
      ))}
    </ul>
  );
}

export function BlogSidebarTagList({ tags }: { tags: BlogTagCount[] }) {
  const searchParams = useSearchParams();
  const currentTag = searchParams.get("tag");

  return (
    <ul className="m-0 p-0 list-none flex flex-wrap gap-1.5 pb-4">
      {tags.map(({ tag, count }) => {
        const isActive = currentTag?.toLowerCase() === tag.toLowerCase();
        return (
          <li key={tag}>
            <Tag
              href={isActive ? routes.blog() : routes.blog(tag)}
              active={isActive}
            >
              <span>{tag}</span>
              <span className="opacity-80 text-[10px] font-normal">({count})</span>
            </Tag>
          </li>
        );
      })}
    </ul>
  );
}
