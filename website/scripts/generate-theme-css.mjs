import { readFileSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const themesPath = join(__dirname, "../look-and-feel.json");
const outputPath = join(__dirname, "../src/styles/theme.generated.css");

const themes = JSON.parse(readFileSync(themesPath, "utf8"));

function normalizeColors(colors) {
  return {
    base: colors.base,
    foreground: colors.foreground ?? colors.text,
    accent: colors.accent,
    neutral: colors.neutral,
    surface: colors.surface,
    overlay: colors.overlay,
    border: colors.border,
    danger: colors.danger,
    warning: colors.warning,
    success: colors.success,
    info: colors.info,
  };
}

function themeVars(colors, prefix) {
  const normalized = normalizeColors(colors);
  return Object.entries(normalized)
    .map(([key, value]) => `  --theme-${key}: ${value};`)
    .join("\n");
}

const { layout } = themes;
const light = themes.light;
const dark = themes.dark;

const css = `/* Generated from look-and-feel.json — do not edit */
:root,
.light {
${themeVars(light, "light")}
}

.dark {
${themeVars(dark, "dark")}
}

@theme inline {
  --color-background: var(--theme-base);
  --color-foreground: var(--theme-foreground);
  --color-accent: var(--theme-accent);
  --color-muted: var(--theme-neutral);
  --color-surface: var(--theme-surface);
  --color-overlay: var(--theme-overlay);
  --color-border: var(--theme-border);
  --color-danger: var(--theme-danger);
  --color-warning: var(--theme-warning);
  --color-success: var(--theme-success);
  --color-info: var(--theme-info);

  --font-size-tiny: ${layout.fontSize.tiny}px;
  --font-size-small: ${layout.fontSize.small}px;
  --font-size-medium: ${layout.fontSize.medium}px;
  --font-size-large: ${layout.fontSize.large}px;

  --leading-tiny: ${layout.lineHeight.tiny}px;
  --leading-small: ${layout.lineHeight.small}px;
  --leading-medium: ${layout.lineHeight.medium}px;
  --leading-large: ${layout.lineHeight.large}px;

  --radius-sm: ${layout.radius.small}px;
  --radius-md: ${layout.radius.medium}px;
  --radius-lg: ${layout.radius.large}px;
}
`;

writeFileSync(outputPath, css);
console.log(`Wrote ${outputPath}`);
