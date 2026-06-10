"use client";

import { useState } from "react";
import { usePathname } from "next/navigation";

import { BlogSearch } from "@/components/blog-search";
import { routes } from "@/paths";
import { site } from "@/site";
import { AppLink, Divider } from "@/components/ui";
import {
  GithubIcon,
  LinkedInIcon,
  RssIcon,
  YoutubeIcon,
} from "@/components/icons";
import type { BlogSearchEntry } from "@/lib/blog-search";

function isActive(pathname: string, href: string) {
  if (href === routes.home()) {
    return pathname === "/";
  }
  return pathname === href || pathname.startsWith(`${href}`);
}

type SiteNavProps = {
  searchEntries: BlogSearchEntry[];
};

export function SiteNav({ searchEntries }: SiteNavProps) {
  const pathname = usePathname();
  const [isMenuOpen, setIsMenuOpen] = useState(false);

  return (
    <nav className="mb-8">
      <Divider />
      <div className="flex items-center justify-between gap-4 py-3">
        <ul className="hidden sm:flex items-center gap-5 m-0 p-0 list-none">
          {site.navItems.map((item) => (
            <li key={item.href}>
              <AppLink
                active={isActive(pathname, item.href)}
                href={item.href}
                variant="nav"
              >
                {item.label}
              </AppLink>
            </li>
          ))}
        </ul>

        <div className="hidden sm:flex items-center gap-3 ml-auto">
          <div className="w-44">
            <BlogSearch entries={searchEntries} />
          </div>
          <AppLink
            aria-label="RSS feed"
            href={site.links.rss}
            variant="muted"
          >
            <RssIcon />
          </AppLink>
          <AppLink
            aria-label="GitHub"
            external
            href={site.links.github}
            variant="muted"
          >
            <GithubIcon />
          </AppLink>
          <AppLink
            aria-label="LinkedIn"
            external
            href={site.links.linkedin}
            variant="muted"
          >
            <LinkedInIcon />
          </AppLink>
          <AppLink
            aria-label="YouTube"
            external
            href={site.links.youtube}
            variant="muted"
          >
            <YoutubeIcon />
          </AppLink>
        </div>

        <button
          aria-expanded={isMenuOpen}
          aria-label="Toggle menu"
          className="sm:hidden p-2 text-foreground hover:text-accent transition-colors"
          onClick={() => setIsMenuOpen(!isMenuOpen)}
          type="button"
        >
          <svg
            className="h-5 w-5"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            {isMenuOpen ? (
              <path
                d="M6 18L18 6M6 6l12 12"
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={1.5}
              />
            ) : (
              <path
                d="M4 6h16M4 12h16M4 18h16"
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={1.5}
              />
            )}
          </svg>
        </button>
      </div>
      <Divider />

      {isMenuOpen && (
        <div className="sm:hidden py-4 space-y-4">
          <ul className="flex flex-col gap-2 m-0 p-0 list-none">
            {site.navItems.map((item) => (
              <li key={item.href}>
                <AppLink
                  active={isActive(pathname, item.href)}
                  className="block py-1.5"
                  href={item.href}
                  variant="nav"
                >
                  {item.label}
                </AppLink>
              </li>
            ))}
          </ul>
          <BlogSearch entries={searchEntries} />
          <div className="flex items-center gap-4">
            <AppLink href={site.links.rss} variant="muted">
              RSS
            </AppLink>
            <AppLink external href={site.links.github} variant="muted">
              GitHub
            </AppLink>
            <AppLink external href={site.links.linkedin} variant="muted">
              LinkedIn
            </AppLink>
            <AppLink external href={site.links.youtube} variant="muted">
              YouTube
            </AppLink>
          </div>
        </div>
      )}
    </nav>
  );
}
