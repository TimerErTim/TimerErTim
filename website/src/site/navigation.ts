import { routes } from "@/paths";

export const navigation = {
  navItems: [
    { label: "Home", href: routes.home() },
    { label: "Blog", href: routes.blog() },
    { label: "Docs", href: routes.docs() },
    { label: "About", href: routes.about() },
  ],
} as const;
