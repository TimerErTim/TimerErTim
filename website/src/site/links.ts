import { routes } from "@/paths";

export const links = {
  github: "https://github.com/timerertim",
  linkedin: "https://www.linkedin.com/in/tim-peko-470a05249/",
  rss: routes.feed(),
  sourceCode: process.env.TIMERERTIM_SOURCE_CODE_URL ?? "https://github.com/timerertim",
  copyrightNotice:
    process.env.TIMERERTIM_COPYRIGHT_NOTICE_URL ??
    `${process.env.TIMERERTIM_SOURCE_CODE_URL ?? "https://github.com/timerertim"}/blob/main/COPYRIGHT.md`,
} as const;
