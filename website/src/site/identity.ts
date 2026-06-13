import { SITE_ORIGIN } from "@/paths";
import configValues from "../../config/values.json";

export const identity = {
  name: configValues.TIMERERTIM_PSEUDONYM,
  legalName: configValues.TIMERERTIM_LEGAL_NAME,
  description: "Online portfolio and blogs for everything technical",
  url: SITE_ORIGIN,
} as const;
