import { site } from "@/site";
import { title, subtitle } from "@/components/primitives";
import { PageShell } from "@/components/page-shell";
import { AppLink, Button } from "@/components/ui";
import { routes } from "@/paths";

export default function Home() {
  return (
    <PageShell>
      <section className="py-4">
        <h2 className={title({ size: "lg" })}>Welcome</h2>
        <p className={`${subtitle()} mt-4 max-w-xl`}>
          {site.description}
        </p>

        <div className="mt-8 flex flex-wrap gap-3">
          <AppLink href={routes.blog()} variant="plain">
            <Button variant="primary">Read the blog</Button>
          </AppLink>
          <AppLink href={routes.about()} variant="plain">
            <Button variant="secondary">About</Button>
          </AppLink>
        </div>

        <div className="mt-12 border border-border bg-surface p-5 max-w-xl">
          <p className="text-small leading-small text-muted m-0">
            Essays are rendered from Typst, with light and dark variants that
            adapt to your system theme.
          </p>
        </div>
      </section>
    </PageShell>
  );
}
