#!/usr/bin/env node
import { copyFileSync, existsSync, mkdirSync, readFileSync } from "node:fs";
import { join } from "node:path";

const repoRoot = process.env.TIMERERTIM_REPO_ROOT;
const themesPath = join(repoRoot, "look-and-feel/themes.json");
const sourceFontsDir = join(repoRoot, "fonts");
const targetFontsDir = join(process.cwd(), "build/fonts");

const themes = JSON.parse(readFileSync(themesPath, "utf8"));
const { fonts } = themes;

if (!fonts) {
  console.error("themes.json is missing a fonts key");
  process.exit(1);
}

mkdirSync(targetFontsDir, { recursive: true });

for (const role of Object.keys(fonts)) {
  for (const file of fonts[role].files) {
    const source = join(sourceFontsDir, file);
    const target = join(targetFontsDir, file);
    if (!existsSync(source)) {
      console.error(`Missing font file: ${source}`);
      process.exit(1);
    }
    copyFileSync(source, target);
    console.log(`Copied ${file} → build/fonts/`);
  }
}
