import { SITE_ORIGIN } from "@/paths";

export const identity = {
  name: process.env.TIMERERTIM_PSEUDONYM ?? "timerertim",
  legalName: process.env.TIMERERTIM_LEGAL_NAME ?? "Tim Peko",
  description: "Online portfolio and blogs for everything technical",
  url: SITE_ORIGIN,
} as const;
