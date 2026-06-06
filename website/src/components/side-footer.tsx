import { siteConfig } from "@/config/site";

export function SideFooter() {
  return (
    <footer className="border-t border-border py-6 text-center text-tiny leading-tiny text-muted">
      <span>© {new Date().getFullYear()} {siteConfig.name}</span>
    </footer>
  );
}