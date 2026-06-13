import { readFileSync } from "node:fs";
import { join } from "node:path";

import { buildInfo } from "@/site/system";

export type ConfigValues = {
  TIMERERTIM_SITE_DOMAIN: string;
  TIMERERTIM_SITE_ORIGIN: string;
  TIMERERTIM_LICENSE: string;
  TIMERERTIM_LICENSE_CANONICAL_URL: string;
  TIMERERTIM_LEGAL_NAME: string;
  TIMERERTIM_PSEUDONYM: string;
  TIMERERTIM_SOURCE_CODE_URL: string;
  TIMERERTIM_COPYRIGHT_NOTICE_PATH: string;
  TIMERERTIM_COPYRIGHT_NOTICE_URL: string;
  TIMERERTIM_GITHUB_URL: string;
  TIMERERTIM_LINKEDIN_URL: string;
  TIMERERTIM_YOUTUBE_URL: string;
  TIMERERTIM_EMAIL: string;
  TIMERERTIM_PHONE: string;
};

const valuesPath = join(buildInfo.repoRoot, "config/values.json");

export const configValues: ConfigValues = JSON.parse(
  readFileSync(valuesPath, "utf8"),
);
