import zlib from "zlib";
import { promisify } from "util";
import init, {
  decompress,
  decompress_with_dictionary,
} from "../libs/brotli-wasm/pkg/brotli_dict_wasm.js";
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const brotliCompress = promisify(zlib.brotliCompress);
const brotliDecompress = promisify(zlib.brotliDecompress);

await init(
  fs.readFileSync(
    path.join(__dirname, "../libs/brotli-wasm/pkg/brotli_dict_wasm_bg.wasm"),
  ),
);

const ref = '<svg xmlns="http://www.w3.org/2000/svg"><text>ref</text></svg>';
const variant =
  '<svg xmlns="http://www.w3.org/2000/svg"><text>ref</text><text>extra</text></svg>';
const dictBuf = Buffer.from(ref, "utf8");
const dict = new Uint8Array(dictBuf);

const variantCompressed = await brotliCompress(variant, {
  params: {
    [zlib.constants.BROTLI_PARAM_MODE]: zlib.constants.BROTLI_MODE_TEXT,
    [zlib.constants.BROTLI_PARAM_QUALITY]: 11,
  },
  dictionary: dictBuf,
});

const nodeVariant = await brotliDecompress(Buffer.from(variantCompressed), {
  dictionary: dictBuf,
});
console.log("node variant ok", nodeVariant.toString() === variant);

try {
  const wasmVariant = new TextDecoder().decode(
    decompress_with_dictionary(new Uint8Array(variantCompressed), dict),
  );
  console.log("wasm variant ok", wasmVariant === variant);
} catch (e) {
  console.error("wasm variant fail", e);
}
