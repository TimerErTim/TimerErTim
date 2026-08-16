#!/usr/bin/env python3
"""Post-process typst-ts-cli svg_html output (typst-ts-cli > 0.7.0-rc2).

Extract the root <svg> and recursively inline base64 SVG embeds marked with
alt="!typst-embed-command". Inlined SVG roots inherit width/height from the
outer typst <image> dimensions.
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
    r'<(?:image|img)\b[^>]*?(?:xlink:href|src)=["\']data:image/svg\+xml;base64,([^"\']*?)["\'][^>]*?alt=["\']!typst-embed-command["\'][^>]*?>',
    re.IGNORECASE,
)

svg_open_pattern = re.compile(r"<svg\b[^>]*>", re.IGNORECASE)


def extract_dimension(tag, name):
    match = re.search(
        rf"\b{name}\s*=\s*['\"]([^'\"]+)['\"]",
        tag,
        re.IGNORECASE,
    )
    return match.group(1) if match else None


def apply_svg_dimensions(svg_text, width, height):
    if width is None or height is None:
        return svg_text

    def replace_svg_open(match):
        tag = match.group(0)
        tag = re.sub(r"\s+width\s*=\s*['\"][^'\"]*['\"]", "", tag, flags=re.IGNORECASE)
        tag = re.sub(r"\s+height\s*=\s*['\"][^'\"]*['\"]", "", tag, flags=re.IGNORECASE)

        if tag.endswith("/>"):
            return tag[:-2] + f' width="{width}" height="{height}"/>'

        return tag[:-1] + f' width="{width}" height="{height}">'

    return svg_open_pattern.sub(replace_svg_open, svg_text, count=1)


def decode_and_inline(text):
    def replacer(match):
        full_tag = match.group(0)
        b64_str = match.group(1)
        width = extract_dimension(full_tag, "width")
        height = extract_dimension(full_tag, "height")

        try:
            decoded = base64.b64decode(b64_str.strip()).decode("utf-8")
        except Exception:
            return full_tag

        return apply_svg_dimensions(decoded, width, height)

    processed_text, count = img_pattern.subn(replacer, text)
    return decode_and_inline(processed_text) if count > 0 else processed_text


final_output = decode_and_inline(content)

with open(TARGET_FILE, "w", encoding="utf-8") as f:
    f.write(final_output)
