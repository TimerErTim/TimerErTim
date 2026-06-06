#!/usr/bin/env node
import { copyFileSync, existsSync, mkdirSync } from "node:fs";
import { join } from "node:path";

const repoRoot = process.env.TIMERERTIM_REPO_ROOT;
const sourceDir = join(repoRoot, "assets/favicon");
const publicDir = join(process.cwd(), "public");

/** RealFaviconGenerator-style bundle files copied to website public/. */
const faviconFiles = [
  "favicon.ico",
  "favicon-16x16.png",
  "favicon-32x32.png",
  "apple-touch-icon.png",
  "android-chrome-192x192.png",
  "android-chrome-512x512.png",
];

mkdirSync(publicDir, { recursive: true });

let copied = 0;
for (const file of faviconFiles) {
  const source = join(sourceDir, file);
  const target = join(publicDir, file);
  if (!existsSync(source)) {
    console.warn(`Skipping favicon asset (not found): ${source}`);
    continue;
  }
  copyFileSync(source, target);
  console.log(`Copied ${file} → public/${file}`);
  copied += 1;
}

if (copied === 0) {
  console.warn(
    `No favicon assets found in ${sourceDir}. Add a RealFaviconGenerator bundle or icon files there.`,
  );
}
