import { writeFile, copyFile } from "node:fs/promises";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const targetCssPath = join(
  dirname(fileURLToPath(import.meta.url)),
  "../node_modules/@myriaddreamin/typst.react/dist/typst.css",
);

const srcWasmPath = join(
  dirname(fileURLToPath(import.meta.url)),
  "../node_modules/@myriaddreamin/typst-ts-renderer/pkg/typst_ts_renderer_bg.wasm",
);

const targetWasmPath = join(
  dirname(fileURLToPath(import.meta.url)),
  "../public/_typst_ts_renderer_bg.wasm",
);

const TYPST_CSS_SRC_URL =
  "https://raw.githubusercontent.com/Myriad-Dreamin/typst.ts/refs/tags/v0.7.0-rc2/packages/typst.react/src/lib/typst.css";

async function installCss() {
  const css = await fetch(TYPST_CSS_SRC_URL);

  if (!css.ok) {
    throw new Error(`Failed to fetch typst.css: ${css.status} ${css.statusText}`);
  }

  const cssText = await css.text();
  await writeFile(targetCssPath, cssText);
}

async function publishWasm() {
  // Copy the wasm file from srcWasmPath to targetWasmPath
  await copyFile(srcWasmPath, targetWasmPath);
}

async function main() {
  // Not needed because we are using the wasm file directly
  await installCss(); 
  await publishWasm();
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
