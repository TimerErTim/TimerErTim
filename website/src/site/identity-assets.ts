import bannerLight from "../../../assets/identity/banner.png";
import bannerDark from "../../../assets/identity/banner_dark.png";

export const identityAssets = {
  bannerLight: bannerLight,
  bannerDark: bannerDark,
  /** Used for Open Graph / Twitter / WhatsApp link previews. Drop `assets/identity/social-preview.png` (1200×630 recommended). */
  socialPreview: "/identity/social-preview.png",
  /** Source bundle: `assets/favicon/` (copied to public/ by prepare:favicon). */
  favicon: "/favicon.ico",
  favicon16: "/favicon-16x16.png",
  favicon32: "/favicon-32x32.png",
  appleTouchIcon: "/apple-touch-icon.png",
  androidChrome192: "/android-chrome-192x192.png",
  androidChrome512: "/android-chrome-512x512.png",
} as const;
