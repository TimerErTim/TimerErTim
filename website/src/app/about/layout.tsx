import { PageShell } from "@/components/page-shell";
import { buildSitePageMetadata } from "@/lib/site-metadata";
import { routes } from "@/paths";
import { site } from "@/site";

export const metadata = buildSitePageMetadata({
  title: "About",
  description: site.content.about.body,
  route: routes.about(),
});

export default function AboutLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return <PageShell>{children}</PageShell>;
}
