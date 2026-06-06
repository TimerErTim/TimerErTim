import { AppLink } from "@/components/ui";
import { site } from "@/site";

export function SideFooter() {
  return (
    <footer className="border-t border-border py-6 text-center text-tiny leading-tiny text-muted">
      <p className="m-0">
        © {new Date().getFullYear()} {site.legalName}
      </p>
      <p className="mt-2 m-0 flex flex-wrap items-center justify-center gap-x-3 gap-y-1">
        <AppLink external href={site.legal.licenseUrl} variant="muted">
          {site.legal.license}
        </AppLink>
        <span aria-hidden>·</span>
        <AppLink external href={site.links.sourceCode} variant="muted">
          Source
        </AppLink>
        <span aria-hidden>·</span>
        <AppLink external href={site.links.copyrightNotice} variant="muted">
          Attributions
        </AppLink>
      </p>
    </footer>
  );
}
