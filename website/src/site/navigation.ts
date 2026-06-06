import { routes } from "@/paths";

export const navigation = {
  navItems: [
    { label: "About", href: routes.about() },
    { label: "Blog", href: routes.blog() },
  ],
} as const;
