import { routes, SITE_ORIGIN } from "@/paths";

export type SiteConfig = typeof siteConfig;

export const siteConfig = {
  name: "timerertim",
  description: "Blogs about software, thinking, and building things.",
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
    linkedin: "https://www.linkedin.com/in/tim-peko-470a05249/",
    rss: routes.feed(),
  },
};
