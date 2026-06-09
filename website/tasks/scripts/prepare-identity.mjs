#!/usr/bin/env node
import { copyFileSync, existsSync, mkdirSync } from "node:fs";
import { join } from "node:path";

const repoRoot = process.env.TIMERERTIM_REPO_ROOT;
const sourceDir = join(repoRoot, "assets/identity");
const publicDir = join(process.cwd(), "public");
const targetDir = join(publicDir, "identity");

const requiredFiles = ["banner.png", "banner_dark.png"];

const optionalFiles = [
  {
    source: join(repoRoot, "assets/banners/social-preview.png"),
    target: join(targetDir, "social-preview.png"),
    fallback: join(sourceDir, "banner.png"),
  },
];

mkdirSync(targetDir, { recursive: true });

for (const file of requiredFiles) {
  const source = join(sourceDir, file);
  const target = join(targetDir, file);
  if (!existsSync(source)) {
    console.error(`Missing identity asset: ${source}`);
    process.exit(1);
  }
  copyFileSync(source, target);
  console.log(`Copied ${file} → public/identity/`);
}

for (const { source, target, fallback } of optionalFiles) {
  const sourcePath = source;
  const resolvedSource = existsSync(sourcePath)
    ? sourcePath
    : fallback && existsSync(fallback)
      ? fallback
      : null;

  if (!resolvedSource) {
    console.warn(`Skipping optional asset (not found): ${sourcePath}`);
    continue;
  }

  copyFileSync(resolvedSource, target);
  const label = resolvedSource === sourcePath ? source : `${source} (fallback)`;
  console.log(`Copied ${label} → ${target.replace(`${process.cwd()}/`, "")}`);
}
