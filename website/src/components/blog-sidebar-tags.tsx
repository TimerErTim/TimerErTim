"use client";

import { useSearchParams } from "next/navigation";
import { useLayoutEffect, useMemo, useRef, useState } from "react";
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
  const currentTags = searchParams ? searchParams.getAll("tag").filter(Boolean) : [];
  const [isExpanded, setIsExpanded] = useState(false);
  const [hasOverflow, setHasOverflow] = useState(false);
  const containerRef = useRef<HTMLUListElement>(null);

  useLayoutEffect(() => {
    const el = containerRef.current;
    if (!el) return;

    const checkOverflow = () => {
      // 2 rows take ~54px; check if content extends past 2 rows
      setHasOverflow(el.scrollHeight > 56);
    };

    checkOverflow();
    window.addEventListener("resize", checkOverflow);
    return () => window.removeEventListener("resize", checkOverflow);
  }, [tags]);

  return (
    <div className="flex flex-col gap-2 pb-4">
      <ul
        ref={containerRef}
        className={`m-0 p-0 list-none flex flex-wrap gap-1.5 transition-all duration-200 ${
          isExpanded
            ? "max-h-none"
            : "max-h-[56px] overflow-hidden"
        }`}
      >
        {tags.map(({ tag, count }) => {
          const isActive = currentTags.some(
            (t) => t.toLowerCase() === tag.toLowerCase(),
          );
          const nextTags = isActive
            ? currentTags.filter((t) => t.toLowerCase() !== tag.toLowerCase())
            : [...currentTags, tag];

          return (
            <li key={tag}>
              <Tag
                href={routes.blog(nextTags)}
                active={isActive}
              >
                <span>{tag}</span>
                <span className="opacity-80 text-[10px] font-normal">({count})</span>
              </Tag>
            </li>
          );
        })}
      </ul>

      {hasOverflow && (
        <button
          type="button"
          onClick={() => setIsExpanded((prev) => !prev)}
          className="self-start text-tiny leading-tiny font-medium text-muted hover:text-foreground hover:underline border-0 bg-transparent p-0 cursor-pointer transition-colors"
        >
          {isExpanded ? "Show fewer tags ↑" : "Show all tags ↓"}
        </button>
      )}
    </div>
  );
}
