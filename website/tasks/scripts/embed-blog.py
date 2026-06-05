#!/usr/bin/env -S uv run --script
#MISE description="Export all website embedding files to the build directory"
# Runs inside the blog's directory
#
# /// script
# requires-python = ">=3.8"
# ///

from dataclasses import dataclass
import os
import json
from typing import List, Literal
import shutil

# The task is always executed in the blog's directory, so we can use the current directory as the blog slug
# We cannot pass {{config_root | basename}} as an argument to the task because there is a bug, where it 
# refers to the task file not the including mise config root
BLOG_SLUG = os.path.basename(os.getcwd())
REPO_ROOT = os.environ["REPO_ROOT"]
os.environ["MISE_TASK_OUTPUT"] = "quiet"

old_print = print
print = lambda *args, **kwargs: old_print(*args, **{k: v for k, v in kwargs.items() if k != 'flush'}, flush=True)

print(f"BLOG_SLUG: {BLOG_SLUG}")

def get_build_hash(timestamp: int) -> str:
    import subprocess

    # Run 'mise run build:ref-hash' with the timestamp argument
    try:
        subprocess.run(
            ["mise", "run", "build:ref-hash", str(timestamp)],
            check=True,
            stdout=None,  # link to parent stdout
            stderr=None   # link to parent stderr
        )
   
        # Load the refs.sha256sum
        sha256sum_path = os.path.join("build", "refs.sha256sum")
        try:
            with open(sha256sum_path, "r") as f:
                return f.read().strip()
        except Exception as e:
            print(f"Failed to read {sha256sum_path}: {e}")
    except subprocess.CalledProcessError as e:
        print(f"Error running 'mise run build:ref-hash': {e.stderr.decode().strip() if e.stderr else e}")
    return None

@dataclass
class BlogSvgVariant:
    theme: Literal["light", "dark"]
    page_width: int
    """
    The width of the page in points.
    """

    def to_filename(self) -> str:
        return f"main_{self.theme}_{self.page_width}pt.svg"

def export_blog_variants(variants: List[BlogSvgVariant], dst_dir_rel: str):
    import subprocess
    try:
        cmd = " ::: ".join([f"export:web-format:single --theme {variant.theme} --page-width {variant.page_width}pt" for variant in variants])
        subprocess.run(
            ["mise", "run", *cmd.split(" ")],
            check=True,
            stdout=None,  # link to parent stdout
            stderr=None   # link to parent stderr
            )
        for variant in variants:
            src_file = os.path.join("build/", variant.to_filename())
            dst_file_rel = os.path.join(dst_dir_rel, variant.to_filename())
            shutil.copy(src_file, os.path.join(REPO_ROOT, dst_file_rel))
            print(f"Copied {src_file} -> {dst_file_rel}")
    except subprocess.CalledProcessError as e:
        print(f"Error running 'mise run export:web-format:single': {e.stderr.decode().strip() if e.stderr else e}")
        return None

relative_build_json_path = os.path.join("dist/website/api/blogs", BLOG_SLUG, "build.json")
build = None
try:
    with open(os.path.join(REPO_ROOT, relative_build_json_path), "r") as f:
        build = json.load(f)
except FileNotFoundError:
    print(f"Info: {relative_build_json_path} does not exist. 'build' set to None.")
except Exception as e:
    print(f"Warning: Error reading {relative_build_json_path}: {e}. 'build' set to None.")
    
previous_reference_hash = build["contentHash"] if build is not None else None
new_reference_hash = None
if previous_reference_hash is not None:
    reference_hash_timestamp = build["updatedAt"]
    new_reference_hash = get_build_hash(reference_hash_timestamp)

# If the reference hash has changed, export the blog embedding files
if previous_reference_hash is None or previous_reference_hash != new_reference_hash:
    import time
    current_timestamp = int(time.time())
    # Calculate the new reference hash
    new_reference_hash = get_build_hash(current_timestamp)
    metadata = json.load(open("build/metadata.json"))
    created_timestamp = build["createdAt"] if build is not None else current_timestamp
    dst_dir_rel = os.path.join("build/website/blogs", BLOG_SLUG)
    dst_dir = os.path.join(REPO_ROOT, dst_dir_rel)

    variants = [
        BlogSvgVariant(theme=theme, page_width=page_width)
        for theme in ["light", "dark"]
        for page_width in range(320, 1097, 128)
    ]
    compression_ref_variant = variants[0]
    export_blog_variants(variants, dst_dir_rel)

    build_data = {
        "slug": BLOG_SLUG,
        "contentHash": new_reference_hash,
        "createdAt": created_timestamp,
        "updatedAt": current_timestamp,
        "compressionRefVariant": compression_ref_variant.to_filename(),
        "variants": [
            {
                "filename": variant.to_filename(),
                "theme": variant.theme,
                "width_pt": variant.page_width,
            }
            for variant in variants
        ],
        **metadata
    }

    with open(os.path.join(REPO_ROOT, dst_dir_rel, "build.json"), "w") as f:
        json.dump(build_data, f, indent=2)
else:  # Otherwise, copy the previous embedding files to the build directory
    import shutil
    
    src_dir_rel = os.path.join(REPO_ROOT, "dist/website/api/blogs", BLOG_SLUG)
    dst_dir = os.path.join(REPO_ROOT, "build/website/blogs", BLOG_SLUG)

    try:
        if os.path.exists(os.path.join(REPO_ROOT, dst_dir)):
            shutil.rmtree(os.path.join(REPO_ROOT, dst_dir))
        shutil.copytree(os.path.join(REPO_ROOT, src_dir_rel), os.path.join(REPO_ROOT, dst_dir))
        print(f"Copied {src_dir_rel} -> {dst_dir}")
    except Exception as e:
        print(f"Failed to copy directory from {src_dir_rel} to {dst_dir}: {e}")

