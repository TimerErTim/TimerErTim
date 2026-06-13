import { configValues } from "@/site/config";
import { socialLinks } from "@/site/social-links";

export const links = {
  github: configValues.TIMERERTIM_GITHUB_URL,
  linkedin: configValues.TIMERERTIM_LINKEDIN_URL,
  youtube: configValues.TIMERERTIM_YOUTUBE_URL,
  rss: socialLinks.rss,
  sourceCode: configValues.TIMERERTIM_SOURCE_CODE_URL,
  copyrightNotice:
    configValues.TIMERERTIM_COPYRIGHT_NOTICE_URL ??
    `${configValues.TIMERERTIM_SOURCE_CODE_URL}/blob/main/COPYRIGHT.md`,
} as const;
