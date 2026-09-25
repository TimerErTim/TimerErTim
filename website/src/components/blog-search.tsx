"use client";

import Fuse from "fuse.js";
import { useCallback, useMemo, useRef, useState } from "react";
import { useRouter } from "next/navigation";

import { SearchIcon } from "@/components/icons";
import { Input, Card, Tag } from "@/components/ui";
import type { BlogSearchEntry } from "@/lib/blog-search";
import { routes } from "@/paths";

type BlogSearchProps = {
  entries: BlogSearchEntry[];
};

type TagMatch = {
  type: "tag";
  tag: string;
  count: number;
};

type PostMatch = {
  type: "post";
  item: BlogSearchEntry;
  matchedKeywords: string[];
};

type SearchResult = TagMatch | PostMatch;

export function BlogSearch({ entries }: BlogSearchProps) {
  const router = useRouter();
  const [query, setQuery] = useState("");
  const [isOpen, setIsOpen] = useState(false);
  const [activeIndex, setActiveIndex] = useState(0);
  const containerRef = useRef<HTMLDivElement>(null);

  const tagCounts = useMemo(() => {
    const counts = new Map<string, number>();
    for (const entry of entries) {
      for (const kw of entry.keywords ?? []) {
        counts.set(kw, (counts.get(kw) ?? 0) + 1);
      }
    }
    return Array.from(counts.entries()).map(([tag, count]) => ({
      tag,
      count,
    }));
  }, [entries]);

  const tagFuse = useMemo(
    () =>
      new Fuse(tagCounts, {
        keys: ["tag"],
        threshold: 0.35,
        ignoreLocation: true,
      }),
    [tagCounts],
  );

  const postFuse = useMemo(
    () =>
      new Fuse(entries, {
        keys: [
          { name: "keywords", weight: 2.5 },
          { name: "title", weight: 2 },
          { name: "description", weight: 0.8 },
          { name: "slug", weight: 0.5 },
          { name: "author", weight: 0.3 },
        ],
        threshold: 0.4,
        ignoreLocation: true,
      }),
    [entries],
  );

  const results: SearchResult[] = useMemo(() => {
    const trimmed = query.trim();
    if (!trimmed) {
      return [];
    }

    const clean = trimmed.replace(/^(#|tag:)\s*/i, "");
    const isTagSearch = /^(#|tag:)/i.test(trimmed);

    const matchingTags: TagMatch[] = tagFuse
      .search(clean, { limit: 3 })
      .map((r) => ({
        type: "tag" as const,
        tag: r.item.tag,
        count: r.item.count,
      }));

    const matchingPosts: PostMatch[] = postFuse
      .search(clean, { limit: 6 })
      .map((r) => {
        const lowerClean = clean.toLowerCase();
        const matchedKeywords = (r.item.keywords ?? []).filter((kw) =>
          kw.toLowerCase().includes(lowerClean),
        );
        return {
          type: "post" as const,
          item: r.item,
          matchedKeywords,
        };
      });

    if (isTagSearch) {
      return [...matchingTags, ...matchingPosts];
    }

    // If query matches a tag closely, show that tag on top
    const exactTag = tagCounts.find(
      (t) => t.tag.toLowerCase() === clean.toLowerCase(),
    );
    if (exactTag && !matchingTags.some((t) => t.tag === exactTag.tag)) {
      matchingTags.unshift({
        type: "tag",
        tag: exactTag.tag,
        count: exactTag.count,
      });
    }

    return [...matchingTags, ...matchingPosts];
  }, [postFuse, tagFuse, tagCounts, query]);

  const navigateToSlug = useCallback(
    (slug: string) => {
      router.push(routes.blogPost(slug));
      setQuery("");
      setIsOpen(false);
      setActiveIndex(0);
    },
    [router],
  );

  const navigateToTag = useCallback(
    (tag: string) => {
      router.push(routes.blog(tag));
      setQuery("");
      setIsOpen(false);
      setActiveIndex(0);
    },
    [router],
  );

  const navigateToSearch = useCallback(
    (search: string) => {
      const clean = search.trim().replace(/^(#|tag:)\s*/i, "");
      const exactTag = tagCounts.find(
        (t) => t.tag.toLowerCase() === clean.toLowerCase(),
      );
      if (exactTag) {
        router.push(routes.blog(exactTag.tag));
      } else {
        // Tag search by prefix or closest match
        const matchingTag = tagCounts.find((t) =>
          t.tag.toLowerCase().includes(clean.toLowerCase()),
        );
        if (matchingTag) {
          router.push(routes.blog(matchingTag.tag));
        } else {
          router.push(routes.blog());
        }
      }
      setQuery("");
      setIsOpen(false);
      setActiveIndex(0);
    },
    [router, tagCounts],
  );

  const handleKeyDown = (event: React.KeyboardEvent<HTMLInputElement>) => {
    if (event.key === "Escape") {
      setIsOpen(false);
      setQuery("");
      return;
    }

    if (!isOpen || results.length === 0) {
      if (event.key === "Enter" && query.trim()) {
        event.preventDefault();
        navigateToSearch(query);
      }
      return;
    }

    if (event.key === "ArrowDown") {
      event.preventDefault();
      setActiveIndex((index) => (index + 1) % results.length);
    } else if (event.key === "ArrowUp") {
      event.preventDefault();
      setActiveIndex((index) => (index - 1 + results.length) % results.length);
    } else if (event.key === "Enter") {
      event.preventDefault();
      const selected = results[activeIndex];
      if (selected) {
        if (selected.type === "tag") {
          navigateToTag(selected.tag);
        } else {
          navigateToSlug(selected.item.slug);
        }
      } else {
        navigateToSearch(query);
      }
    }
  };

  return (
    <div className="relative" ref={containerRef}>
      <Input
        aria-autocomplete="list"
        aria-controls={isOpen && results.length > 0 ? "blog-search-results" : undefined}
        aria-expanded={isOpen && results.length > 0}
        aria-label="Search blog posts and tags"
        onBlur={() => {
          window.setTimeout(() => setIsOpen(false), 200);
        }}
        onChange={(event) => {
          setQuery(event.target.value);
          setIsOpen(true);
          setActiveIndex(0);
        }}
        onFocus={() => {
          if (query.trim()) {
            setIsOpen(true);
          }
        }}
        onKeyDown={handleKeyDown}
        placeholder="Search posts & tags…"
        role="combobox"
        startContent={<SearchIcon className="text-base" size={20} />}
        size="sm"
        type="search"
        value={query}
      />

      {isOpen && results.length > 0 && (
        <Card
          className="absolute right-0 z-50 mt-2 w-80 max-h-96 overflow-y-auto p-1"
          padding="none"
        >
          <ul
            className="list-none m-0 p-0"
            id="blog-search-results"
            role="listbox"
          >
            {results.map((result, index) => {
              const isSelected = index === activeIndex;

              if (result.type === "tag") {
                return (
                  <li
                    key={`tag-${result.tag}`}
                    role="option"
                    aria-selected={isSelected}
                  >
                    <button
                      className={`flex items-center justify-between w-full text-left px-2.5 py-2 text-small leading-small no-underline border-0 cursor-pointer rounded-sm font-semibold transition-colors ${
                        isSelected
                          ? "bg-overlay/50 text-foreground"
                          : "bg-transparent text-foreground hover:bg-overlay/50"
                      }`}
                      onMouseDown={(event) => {
                        event.preventDefault();
                        navigateToTag(result.tag);
                      }}
                      onMouseEnter={() => setActiveIndex(index)}
                      type="button"
                    >
                      <div className="flex items-center gap-2">
                        <span className="text-[10px] text-muted uppercase tracking-wider font-bold">
                          Tag
                        </span>
                        <Tag active={false}>#{result.tag}</Tag>
                      </div>
                      <span className="text-tiny text-muted font-normal">
                        {result.count} {result.count === 1 ? "post" : "posts"}
                      </span>
                    </button>
                  </li>
                );
              }

              const { item, matchedKeywords } = result;
              return (
                <li
                  key={`post-${item.slug}`}
                  role="option"
                  aria-selected={isSelected}
                >
                  <button
                    className={`block w-full text-left px-2.5 py-2 text-small leading-small no-underline border-0 cursor-pointer rounded-sm font-semibold transition-colors ${
                      isSelected
                        ? "bg-overlay/50 text-foreground"
                        : "bg-transparent text-foreground hover:bg-overlay/50"
                    }`}
                    onMouseDown={(event) => {
                      event.preventDefault();
                      navigateToSlug(item.slug);
                    }}
                    onMouseEnter={() => setActiveIndex(index)}
                    type="button"
                  >
                    <span className="block font-bold">{item.title}</span>
                    {item.description && (
                      <span className="block text-tiny leading-tiny text-muted mt-0.5 line-clamp-2 font-normal">
                        {item.description}
                      </span>
                    )}
                    {item.keywords && item.keywords.length > 0 && (
                      <div className="flex flex-wrap gap-1 mt-1.5">
                        {item.keywords.slice(0, 4).map((kw) => {
                          const isMatch = matchedKeywords.includes(kw);
                          return (
                            <Tag
                              key={kw}
                              active={isMatch}
                              className="text-[10px] px-1.5 py-0"
                            >
                              {kw}
                            </Tag>
                          );
                        })}
                        {item.keywords.length > 4 && (
                          <span className="text-[10px] text-muted self-center">
                            +{item.keywords.length - 4}
                          </span>
                        )}
                      </div>
                    )}
                  </button>
                </li>
              );
            })}
          </ul>
        </Card>
      )}
    </div>
  );
}
