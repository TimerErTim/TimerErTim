import { routes } from "@/paths";
import configValues from "../../config/values.json";

export const links = {
  github: "https://github.com/timerertim",
  linkedin: "https://www.linkedin.com/in/tim-peko-470a05249/",
  youtube: "https://www.youtube.com/@timerertim",
  rss: routes.feed(),
  sourceCode: configValues.TIMERERTIM_SOURCE_CODE_URL,
  copyrightNotice:
    configValues.TIMERERTIM_COPYRIGHT_NOTICE_URL ??
    `${configValues.TIMERERTIM_SOURCE_CODE_URL}/blob/main/COPYRIGHT.md`,
} as const;
