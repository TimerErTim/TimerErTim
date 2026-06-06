import { AppLink } from "@/components/ui";
import { routes } from "@/paths";
import { site } from "@/site";

export function SiteHeader() {
  return (
    <header className="pt-10 pb-6 text-center">
      <AppLink href={routes.home()} variant="plain">
        <h1 className="text-large leading-large font-semibold tracking-tight m-0">
          {site.name}
        </h1>
      </AppLink>
      <p className="mt-2 text-small leading-small text-foreground m-0">
        {site.description}
      </p>
    </header>
  );
}
