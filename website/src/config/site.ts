import { routes, SITE_ORIGIN } from "@/paths";

export type SiteConfig = typeof siteConfig;

export const siteConfig = {
  name: "Next.js + HeroUI",
  description: "Make beautiful websites regardless of your design experience.",
  url: SITE_ORIGIN,
  navItems: [
    {
      label: "Home",
      href: routes.home(),
    },
    {
      label: "Docs",
      href: routes.docs(),
    },
    {
      label: "Pricing",
      href: routes.pricing(),
    },
    {
      label: "Blog",
      href: routes.blog(),
    },
    {
      label: "About",
      href: routes.about(),
    },
  ],
  navMenuItems: [
    {
      label: "Profile",
      href: routes.profile(),
    },
    {
      label: "Dashboard",
      href: routes.dashboard(),
    },
    {
      label: "Projects",
      href: routes.projects(),
    },
    {
      label: "Team",
      href: routes.team(),
    },
    {
      label: "Calendar",
      href: routes.calendar(),
    },
    {
      label: "Settings",
      href: routes.settings(),
    },
    {
      label: "Help & Feedback",
      href: routes.helpFeedback(),
    },
    {
      label: "Logout",
      href: routes.logout(),
    },
  ],
  links: {
    github: "https://github.com/heroui-inc/heroui",
    twitter: "https://twitter.com/hero_ui",
    docs: "https://heroui.com",
    discord: "https://discord.gg/9b6yyZKmH4",
    sponsor: "https://patreon.com/jrgarciadev",
  },
};
