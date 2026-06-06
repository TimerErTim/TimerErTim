import type { MetadataRoute } from "next";

import { routes } from "@/paths";
import { site } from "@/site";
import { identityAssets } from "@/site/identity-assets";
import { themeColors } from "@/site/theme.generated";

export const dynamic = "force-static";

export default function manifest(): MetadataRoute.Manifest {
  return {
    name: site.name,
    short_name: site.name,
    description: site.description,
    start_url: routes.home(),
    scope: routes.home(),
    display: "browser",
    background_color: themeColors.light.base,
    theme_color: themeColors.light.base,
    icons: [
      {
        src: identityAssets.androidChrome192,
        sizes: "192x192",
        type: "image/png",
      },
      {
        src: identityAssets.androidChrome512,
        sizes: "512x512",
        type: "image/png",
      },
    ],
  };
}
