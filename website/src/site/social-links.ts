import { routes } from "@/paths";

/** Client-safe social links (also used as fallbacks in {@link ./links}). */
export const socialLinks = {
  github: "https://github.com/timerertim",
  linkedin: "https://www.linkedin.com/in/tim-peko-470a05249/",
  youtube: "https://www.youtube.com/@timerertim",
  rss: routes.feed(),
} as const;
