import { PageShell } from "@/components/page-shell";

export default function PricingLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return <PageShell>{children}</PageShell>;
}
