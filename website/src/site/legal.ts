export const legal = {
  license: process.env.TIMERERTIM_LICENSE ?? "CC BY-NC 4.0",
  licenseUrl:
    process.env.TIMERERTIM_LICENSE_CANONICAL_URL ??
    "https://creativecommons.org/licenses/by-nc/4.0/",
} as const;
