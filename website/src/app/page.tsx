import { site } from "@/site";
import { title, subtitle } from "@/components/primitives";
import { PageShell } from "@/components/page-shell";
import { AppLink, Button, Card } from "@/components/ui";
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

        <Card className="mt-12 max-w-xl" padding="md">
          <p className="text-small leading-small text-foreground m-0">
            Blog entries are rendered using <AppLink external href="https://typst.app/">Typst</AppLink> and embedded in the website as svg. For more information, see the <AppLink href={routes.blogPost("2026-blog-with-typst")}>the blogpost</AppLink>.
          </p>
        </Card>
      </section>
    </PageShell>
  );
}
