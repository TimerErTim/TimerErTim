#!/usr/bin/env node
import { copyFileSync, existsSync, mkdirSync } from "node:fs";
import { join } from "node:path";

const repoRoot = process.env.TIMERERTIM_REPO_ROOT;
const source = join(repoRoot, "cv/out/cvs/CV_en_latest.pdf");
const publicDir = join(process.cwd(), "public");
const targetDir = join(publicDir, "cv");
const target = join(targetDir, "lebenslauf.pdf");

if (!existsSync(source)) {
  console.error(`Missing CV build output: ${source}`);
  console.error("Run //cv:build:cv first.");
  process.exit(1);
}

mkdirSync(targetDir, { recursive: true });
copyFileSync(source, target);
console.log(`Copied ${source} → public/cv/lebenslauf.pdf`);
