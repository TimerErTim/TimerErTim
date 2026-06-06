import { aboutContent } from "@/site/content/about";
import { identity } from "@/site/identity";
import { legal } from "@/site/legal";
import { links } from "@/site/links";
import { navigation } from "@/site/navigation";

export type Site = typeof site;

export const site = {
  ...identity,
  ...navigation,
  links,
  legal,
  content: {
    about: aboutContent,
  },
} as const;

// Backward-compatible alias during migration
export const siteConfig = site;
