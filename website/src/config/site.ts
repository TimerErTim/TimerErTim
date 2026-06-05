import { routes, SITE_ORIGIN } from "@/paths";

export type SiteConfig = typeof siteConfig;

export const siteConfig = {
  name: "timerertim",
  description: "Essays about software, thinking, and building things.",
  url: SITE_ORIGIN,
  navItems: [
    {
      label: "Home",
      href: routes.home(),
    },
    {
      label: "Blog",
      href: routes.blog(),
    },
    {
      label: "Docs",
      href: routes.docs(),
    },
    {
      label: "About",
      href: routes.about(),
    },
  ],
  links: {
    github: "https://github.com/timerertim",
    rss: routes.feed(),
  },
};
