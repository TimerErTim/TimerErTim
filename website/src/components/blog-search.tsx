"use client";

import Fuse from "fuse.js";
import { useCallback, useMemo, useRef, useState } from "react";
import { useRouter } from "next/navigation";

import { SearchIcon } from "@/components/icons";
import { Input } from "@/components/ui";
import type { BlogSearchEntry } from "@/lib/blog-search";
import { routes } from "@/paths";

type BlogSearchProps = {
  entries: BlogSearchEntry[];
};

export function BlogSearch({ entries }: BlogSearchProps) {
  const router = useRouter();
  const [query, setQuery] = useState("");
  const [isOpen, setIsOpen] = useState(false);
  const [activeIndex, setActiveIndex] = useState(0);
  const containerRef = useRef<HTMLDivElement>(null);

  const fuse = useMemo(
    () =>
      new Fuse(entries, {
        keys: ["title", "description", "keywords", "author", "slug"],
        threshold: 0.4,
        ignoreLocation: true,
      }),
    [entries],
  );

  const results = useMemo(() => {
    const trimmed = query.trim();
    if (!trimmed) {
      return [];
    }
    return fuse.search(trimmed, { limit: 8 }).map((result) => result.item);
  }, [fuse, query]);

  const navigateTo = useCallback(
    (slug: string) => {
      router.push(routes.blogPost(slug));
      setQuery("");
      setIsOpen(false);
      setActiveIndex(0);
    },
    [router],
  );

  const handleKeyDown = (event: React.KeyboardEvent<HTMLInputElement>) => {
    if (!isOpen || results.length === 0) {
      if (event.key === "Escape") {
        setQuery("");
        setIsOpen(false);
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
        navigateTo(selected.slug);
      }
    } else if (event.key === "Escape") {
      setIsOpen(false);
      setQuery("");
    }
  };

  return (
    <div className="relative" ref={containerRef}>
      <Input
        aria-autocomplete="list"
        aria-controls={isOpen && results.length > 0 ? "blog-search-results" : undefined}
        aria-expanded={isOpen && results.length > 0}
        aria-label="Search blog posts"
        onBlur={() => {
          window.setTimeout(() => setIsOpen(false), 150);
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
        placeholder="Search…"
        role="combobox"
        startContent={<SearchIcon className="text-base" />}
        size="sm"
        type="search"
        value={query}
      />

      {isOpen && results.length > 0 && (
        <ul
          className="absolute right-0 z-50 mt-1 w-72 max-h-80 overflow-y-auto border border-border bg-overlay shadow-sm list-none m-0 p-1"
          id="blog-search-results"
          role="listbox"
        >
          {results.map((result, index) => (
            <li key={result.slug} role="option" aria-selected={index === activeIndex}>
              <button
                className={`block w-full text-left px-2.5 py-2 text-small leading-small no-underline border-0 cursor-pointer ${
                  index === activeIndex
                    ? "bg-surface text-foreground"
                    : "bg-transparent text-foreground hover:bg-surface"
                }`}
                onMouseDown={(event) => {
                  event.preventDefault();
                  navigateTo(result.slug);
                }}
                onMouseEnter={() => setActiveIndex(index)}
                type="button"
              >
                <span className="block font-medium">{result.title}</span>
                {result.description && (
                  <span className="block text-tiny leading-tiny text-muted mt-0.5 line-clamp-2">
                    {result.description}
                  </span>
                )}
              </button>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
