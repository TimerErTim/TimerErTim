#!/usr/bin/env -S uv run --script
#MISE description="Extract the first <svg> element and inline decode base64 <img> nodes"
#MISE dir="{{cwd}}"
#USAGE arg "<file>" help="The target file to process"

import re
import os
import base64

# Define your target file path
TARGET_FILE = os.environ["usage_file"]

with open(TARGET_FILE, "r", encoding="utf-8") as f:
    content = f.read()

# =====================================================================
# PART 1: Trim everything outside the root <svg> wrapper
# =====================================================================
start_idx = content.find("<svg")
end_idx = content.rfind("</svg>")

if start_idx != -1 and end_idx != -1:
    content = content[start_idx : end_idx + 6]  # Extracted from <svg to </svg>

# =====================================================================
# PART 2: Recursively inline decode base64 <img> nodes
# =====================================================================
# Matches both <image> and <img> tags that contain a base64 encoded SVG in either href or src
img_pattern = re.compile(
    r'<(?:image|img)[^>]*?(?:xlink:href|src)=["\']data:image/svg\+xml;base64,([^"\']*?)["\'][^>]*?>'
)

def decode_and_inline(text):
    def replacer(match):
        # Grab whichever capture group matched the raw base64 payload
        b64_str = match.group(1) or match.group(2)
        try:
            return base64.b64decode(b64_str.strip()).decode("utf-8")
        except Exception:
            return match.group(0)  # If decoding fails, keep the original tag intact

    processed_text, count = img_pattern.subn(replacer, text)
    
    # Loop recursively if any replacements occurred to catch deeply nested instances
    return decode_and_inline(processed_text) if count > 0 else processed_text

final_output = decode_and_inline(content)

with open(TARGET_FILE, "w", encoding="utf-8") as f:
    f.write(final_output)