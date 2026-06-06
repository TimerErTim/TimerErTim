import type { Metadata } from "next";

import { absoluteSiteUrl, routes, urls } from "@/paths";
import { site } from "@/site";
import { identityAssets } from "@/site/identity-assets";

export const siteTitleTemplate = `%s • ${site.name}`;

export const defaultSocialImage = {
  url: identityAssets.socialPreview,
  alt: `${site.name} — ${site.description}`,
} as const;

export function buildSitePageMetadata({
  title,
  description = site.description,
  route,
}: {
  title: string;
  description?: string;
  route: string;
}): Metadata {
  const url = absoluteSiteUrl(route);

  return {
    title,
    description,
    alternates: {
      canonical: url,
    },
    openGraph: {
      type: "website",
      locale: "en",
      url,
      siteName: site.name,
      title,
      description,
      images: [defaultSocialImage],
    },
    twitter: {
      card: "summary_large_image",
      title,
      description,
      images: [defaultSocialImage.url],
    },
  };
}

export function rootSiteMetadata(): Metadata {
  return {
    metadataBase: new URL(urls.site()),
    title: {
      default: site.name,
      template: siteTitleTemplate,
    },
    description: site.description,
    icons: {
      icon: [
        { url: routes.favicon(), sizes: "any" },
        { url: routes.favicon32(), sizes: "32x32", type: "image/png" },
        { url: routes.favicon16(), sizes: "16x16", type: "image/png" },
      ],
      apple: routes.appleTouchIcon(),
    },
    manifest: routes.manifest(),
    alternates: {
      canonical: urls.home(),
      types: {
        "application/rss+xml": urls.feed(),
      },
    },
    openGraph: {
      type: "website",
      locale: "en",
      url: urls.home(),
      siteName: site.name,
      title: site.name,
      description: site.description,
      images: [defaultSocialImage],
    },
    twitter: {
      card: "summary_large_image",
      title: site.name,
      description: site.description,
      images: [defaultSocialImage.url],
    },
    robots: {
      index: true,
      follow: true,
    },
  };
}
