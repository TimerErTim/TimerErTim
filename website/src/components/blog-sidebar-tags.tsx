"use client";

import { useSearchParams } from "next/navigation";
import { Suspense, useLayoutEffect, useRef, useState } from "react";
import { Tag } from "@/components/ui";
import { routes } from "@/paths";

export type BlogTagCount = {
  tag: string;
  count: number;
};

type BlogSidebarTagListViewProps = {
  tags: BlogTagCount[];
  activeTags?: string[];
  enableExpand?: boolean;
};

export function BlogSidebarTagListView({
  tags,
  activeTags = [],
  enableExpand = true,
}: BlogSidebarTagListViewProps) {
  const [isExpanded, setIsExpanded] = useState(false);
  const [hasOverflow, setHasOverflow] = useState(false);
  const containerRef = useRef<HTMLUListElement>(null);

  const lowerActiveTags = activeTags.map((t) => t.toLowerCase());

  useLayoutEffect(() => {
    if (!enableExpand) return;
    const el = containerRef.current;
    if (!el) return;

    const checkOverflow = () => {
      // 2 rows take ~54px; check if content extends past 2 rows
      setHasOverflow(el.scrollHeight > 56);
    };

    checkOverflow();
    window.addEventListener("resize", checkOverflow);
    return () => window.removeEventListener("resize", checkOverflow);
  }, [tags, enableExpand]);

  return (
    <div className="flex flex-col gap-1.5 md:gap-2 pb-3 md:pb-4">
      <ul
        ref={containerRef}
        className={`m-0 p-0 list-none flex flex-wrap gap-x-1.5 gap-y-1 md:gap-y-1.5 transition-all duration-200 ${
          enableExpand && !isExpanded
            ? "max-h-[56px] overflow-hidden"
            : "max-h-none"
        }`}
      >
        {tags.map(({ tag, count }) => {
          const isActive = lowerActiveTags.includes(tag.toLowerCase());
          const nextTags = isActive
            ? activeTags.filter((t) => t.toLowerCase() !== tag.toLowerCase())
            : [...activeTags, tag];

          return (
            <li key={tag}>
              <Tag href={routes.blog(nextTags)} active={isActive}>
                <span>{tag}</span>
                <span className="opacity-80 text-[10px] font-normal">({count})</span>
              </Tag>
            </li>
          );
        })}
      </ul>

      {enableExpand && hasOverflow && (
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

function BlogSidebarTagListWithSearchParams({ tags }: { tags: BlogTagCount[] }) {
  const searchParams = useSearchParams();
  const activeTags = searchParams ? searchParams.getAll("tag").filter(Boolean) : [];

  return <BlogSidebarTagListView tags={tags} activeTags={activeTags} />;
}

export function BlogSidebarTagListFallback({ tags }: { tags: BlogTagCount[] }) {
  return <BlogSidebarTagListView tags={tags} activeTags={[]} enableExpand={false} />;
}

export function BlogSidebarTagList({ tags }: { tags: BlogTagCount[] }) {
  return (
    <Suspense fallback={<BlogSidebarTagListFallback tags={tags} />}>
      <BlogSidebarTagListWithSearchParams tags={tags} />
    </Suspense>
  );
}
