#!/usr/bin/env node
import { existsSync, readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";

const repoRoot = process.env.TIMERERTIM_REPO_ROOT;
const themesPath = join(repoRoot, "look-and-feel/themes.json");
const fontsDir = join(repoRoot, "fonts");
const outputPath = join(process.cwd(), "src/site/fonts.generated.ts");

const themes = JSON.parse(readFileSync(themesPath, "utf8"));
const { fonts } = themes;

if (!fonts) {
  console.error("themes.json is missing a fonts key — rebuild look-and-feel:build:json");
  process.exit(1);
}

function assertFontFiles(role, files) {
  for (const file of files) {
    const fullPath = join(fontsDir, file);
    if (!existsSync(fullPath)) {
      console.error(`Missing font file for ${role}: ${fullPath}`);
      process.exit(1);
    }
  }
}

function buildSrcEntries(role) {
  const { files, weights } = fonts[role];
  assertFontFiles(role, files);
  return files.map((file, index) => {
    const weight = weights[index] ?? weights[weights.length - 1] ?? 400;
    const relPath = `../../build/fonts/${file}`;
    return `    { path: "${relPath}", weight: "${weight}" }`;
  });
}

function buildFontExport(varName, role, cssVar) {
  const srcEntries = buildSrcEntries(role).join(",\n");
  return `export const ${varName} = localFont({
  src: [
${srcEntries},
  ],
  variable: "${cssVar}",
  display: "swap",
});`;
}

const ts = `/* Generated from look-and-feel/themes.json — do not edit */
import localFont from "next/font/local";

${buildFontExport("fontSans", "sans", "--font-family-sans")}

${buildFontExport("fontMono", "mono", "--font-family-mono")}
`;

writeFileSync(outputPath, ts);
console.log(`Wrote ${outputPath}`);
