import { siteConfig } from "@/config/site";
import { routes } from "@/paths";
import { AppLink } from "@/components/ui";

export function SiteHeader() {
  return (
    <header className="pt-10 pb-6 text-center">
      <AppLink href={routes.home()} variant="plain">
        <h1 className="text-large leading-large font-semibold tracking-tight m-0">
          {siteConfig.name}
        </h1>
      </AppLink>
      <p className="mt-2 text-small leading-small text-muted m-0">
        {siteConfig.description}
      </p>
    </header>
  );
}
