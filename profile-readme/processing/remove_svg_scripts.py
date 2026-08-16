#!/usr/bin/env python3
"""Remove <script> elements from typst-ts-cli svg_html output."""

import os
import re

TARGET_FILE = os.environ["usage_file"]

with open(TARGET_FILE, "r", encoding="utf-8") as f:
    content = f.read()

content = re.sub(
    r"<script\b[^>]*>.*?</script>",
    "",
    content,
    flags=re.DOTALL | re.IGNORECASE,
)

with open(TARGET_FILE, "w", encoding="utf-8") as f:
    f.write(content)
