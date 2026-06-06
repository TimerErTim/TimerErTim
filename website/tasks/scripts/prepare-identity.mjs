#!/usr/bin/env node
import { copyFileSync, existsSync, mkdirSync } from "node:fs";
import { join } from "node:path";

const repoRoot = process.env.TIMERERTIM_REPO_ROOT;
const sourceDir = join(repoRoot, "assets/identity");
const targetDir = join(process.cwd(), "public/identity");

const files = ["banner.png", "banner_dark.png"];

mkdirSync(targetDir, { recursive: true });

for (const file of files) {
  const source = join(sourceDir, file);
  const target = join(targetDir, file);
  if (!existsSync(source)) {
    console.error(`Missing identity asset: ${source}`);
    process.exit(1);
  }
  copyFileSync(source, target);
  console.log(`Copied ${file} → public/identity/`);
}
