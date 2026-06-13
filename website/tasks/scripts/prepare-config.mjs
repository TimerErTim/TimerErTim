#!/usr/bin/env node
import { copyFileSync, existsSync, mkdirSync } from "node:fs";
import { join } from "node:path";

const repoRoot = process.env.TIMERERTIM_REPO_ROOT;
const source = join(repoRoot, "config/values.json");
const targetDir = join(process.cwd(), "config");
const target = join(targetDir, "values.json");

if (!existsSync(source)) {
  console.error(`Missing config values: ${source}`);
  process.exit(1);
}

mkdirSync(targetDir, { recursive: true });
copyFileSync(source, target);
console.log(`Copied values.json → config/values.json`);
