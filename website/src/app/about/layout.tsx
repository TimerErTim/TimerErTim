import { PageShell } from "@/components/page-shell";
import { aboutDescription } from "@/site/content/about";
import { buildSitePageMetadata } from "@/lib/site-metadata";
import { routes } from "@/paths";

export const metadata = buildSitePageMetadata({
  title: "About",
  description: aboutDescription,
  route: routes.about(),
});

export default function AboutLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return <PageShell>{children}</PageShell>;
}
