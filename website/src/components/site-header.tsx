import ExportedImage from "next-image-export-optimizer";

import { AppLink } from "@/components/ui";
import { routes } from "@/paths";
import { site } from "@/site";

export function SiteHeader() {
  return (
    <header className="pt-10 pb-6 text-center">
      <AppLink
        className="inline-flex flex-col items-center no-underline hover:no-underline"
        href={routes.home()}
        variant="plain"
      >
        <ExportedImage
          alt={site.name}
          className="h-10 w-auto dark:hidden"
          height={40}
          priority
          src={site.identity.bannerLight}
          width={280}
        />
        <ExportedImage
          alt={site.name}
          className="hidden h-10 w-auto dark:block"
          height={40}
          priority
          src={site.identity.bannerDark}
          width={280}
        />
      </AppLink>
      <p className="mt-2 text-small leading-small text-foreground m-0">
        {site.description}
      </p>
    </header>
  );
}
