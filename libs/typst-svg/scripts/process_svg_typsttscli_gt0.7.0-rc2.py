#!/usr/bin/env python3
"""Post-process typst-ts-cli svg_html output (typst-ts-cli > 0.7.0-rc2).

Extract the root <svg> and recursively inline base64 SVG embeds marked with
alt="!typst-embed-command".
"""

import base64
import os
import re

TARGET_FILE = os.environ["usage_file"]

with open(TARGET_FILE, "r", encoding="utf-8") as f:
    content = f.read()

start_idx = content.find("<svg")
end_idx = content.rfind("</svg>")

if start_idx != -1 and end_idx != -1:
    content = content[start_idx : end_idx + 6]

img_pattern = re.compile(
    r'<(?:image|img)[^>]*?(?:xlink:href|src)=["\']data:image/svg\+xml;base64,([^"\']*?)["\'][^>]*?alt=["\']!typst-embed-command["\'][^>]*?>'
)


def decode_and_inline(text):
    def replacer(match):
        b64_str = match.group(1) or match.group(2)
        try:
            return base64.b64decode(b64_str.strip()).decode("utf-8")
        except Exception:
            return match.group(0)

    processed_text, count = img_pattern.subn(replacer, text)
    return decode_and_inline(processed_text) if count > 0 else processed_text


final_output = decode_and_inline(content)

with open(TARGET_FILE, "w", encoding="utf-8") as f:
    f.write(final_output)
