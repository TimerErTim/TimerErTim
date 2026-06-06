#!/usr/bin/env node
import { readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";

const repoRoot = process.env.TIMERERTIM_REPO_ROOT;
const themesPath = join(repoRoot, "look-and-feel/themes.json");
const cssOutputPath = join(process.cwd(), "src/app/theme.generated.css");
const tsOutputPath = join(process.cwd(), "src/site/theme.generated.ts");

const themes = JSON.parse(readFileSync(themesPath, "utf8"));

function normalizeColors(colors) {
  return {
    base: colors.base,
    foreground: colors.foreground,
    accent: colors.accent,
    neutral: colors.neutral,
    surface: colors.surface,
    overlay: colors.overlay,
    border: colors.border,
    danger: colors.danger,
    warning: colors.warning,
    success: colors.success,
    info: colors.info,
    muted: colors.muted,
  };
}

function themeVars(colors) {
  const normalized = normalizeColors(colors);
  return Object.entries(normalized)
    .map(([key, value]) => `  --theme-${key}: ${value};`)
    .join("\n");
}

const { layout } = themes;

const themeColorTokens = [
  "background",
  "foreground",
  "accent",
  "muted",
  "surface",
  "overlay",
  "border",
  "danger",
  "warning",
  "success",
  "info",
];

const themeFontSizes = Object.keys(layout.fontSize);

const css = `/* Generated from look-and-feel/themes.json — do not edit */
:root,
.light {
${themeVars(themes.light)}
}

.dark {
${themeVars(themes.dark)}
}

@theme inline {
  --color-background: var(--theme-base);
  --color-foreground: var(--theme-foreground);
  --color-accent: var(--theme-accent);
  --color-muted: var(--theme-muted);
  --color-surface: var(--theme-surface);
  --color-overlay: var(--theme-overlay);
  --color-border: var(--theme-border);
  --color-danger: var(--theme-danger);
  --color-warning: var(--theme-warning);
  --color-success: var(--theme-success);
  --color-info: var(--theme-info);

  --text-tiny: ${layout.fontSize.tiny}px;
  --text-tiny--line-height: ${layout.lineHeight.tiny}px;
  --text-small: ${layout.fontSize.small}px;
  --text-small--line-height: ${layout.lineHeight.small}px;
  --text-medium: ${layout.fontSize.medium}px;
  --text-medium--line-height: ${layout.lineHeight.medium}px;
  --text-large: ${layout.fontSize.large}px;
  --text-large--line-height: ${layout.lineHeight.large}px;

  --leading-tiny: ${layout.lineHeight.tiny}px;
  --leading-small: ${layout.lineHeight.small}px;
  --leading-medium: ${layout.lineHeight.medium}px;
  --leading-large: ${layout.lineHeight.large}px;

  --radius-sm: ${layout.radius.small}px;
  --radius-md: ${layout.radius.medium}px;
  --radius-lg: ${layout.radius.large}px;
}
`;

const light = normalizeColors(themes.light);
const dark = normalizeColors(themes.dark);

const ts = `/* Generated from look-and-feel/themes.json — do not edit */

export const themeColors = {
  light: ${JSON.stringify(light)},
  dark: ${JSON.stringify(dark)},
} as const;

export const themeSemanticColors = ${JSON.stringify(themeColorTokens)} as const;

export const themeFontSizes = ${JSON.stringify(themeFontSizes)} as const;
`;

writeFileSync(cssOutputPath, css);
writeFileSync(tsOutputPath, ts);
console.log(`Wrote ${cssOutputPath}`);
console.log(`Wrote ${tsOutputPath}`);
