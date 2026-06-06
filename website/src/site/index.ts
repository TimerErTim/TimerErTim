
import { identity } from "@/site/identity";
import { identityAssets } from "@/site/identity-assets";
import { legal } from "@/site/legal";
import { links } from "@/site/links";
import { navigation } from "@/site/navigation";

export type Site = typeof site;

export const site = {
  ...identity,
  ...navigation,
  links,
  legal,
  identity: identityAssets,
} as const;

// Backward-compatible alias during migration
export const siteConfig = site;
