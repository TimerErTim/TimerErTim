import type { MetadataRoute } from "next";

import { routes, urls } from "@/paths";

export const dynamic = "force-static";

export default function robots(): MetadataRoute.Robots {
  return {
    rules: {
      userAgent: "*",
      allow: "/",
    },
    sitemap: `${urls.site()}${routes.sitemap()}`,
  };
}
