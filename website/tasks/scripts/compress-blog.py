#!/usr/bin/env -S uv run --script
#MISE description="Compress the website embedding files using brotli and vcdiff"
# Runs inside the website embedding directory
#
# /// script
# requires-python = ">=3.8"
# dependencies = [
#     "xdelta3",
#     "brotli==1.2.0"
# ]
#
# [tool.uv.sources]
# xdelta3 = { path = "../../../libs/xdelta3" }  # Path from this file's directory
# ///

import json
import math
import brotli
import xdelta3

# We are supposed to run in the blog build embedding directory
# E.g. build/website/blogs/{slug}

with open("build.json", "r", encoding="utf-8") as f:
    build_data = json.load(f)


def vcdiff_encode(reference_bytes: bytes, target_bytes: bytes) -> bytes:
    return xdelta3.encode(reference_bytes, target_bytes)


def vcdiff_decode(reference_bytes: bytes, delta_bytes: bytes) -> bytes:
    return xdelta3.decode(reference_bytes, delta_bytes)


def brotli_compress(data_bytes: bytes) -> bytes:
    return brotli.compress(data_bytes, quality=11)


def brotli_decompress(data_bytes: bytes) -> bytes:
    return brotli.decompress(data_bytes)


def min_cost_branching(vertices, weight):
    """Edmonds minimum-cost branching. Returns incoming[v]=u for chosen edge u->v."""
    vertices = list(vertices)
    inf = math.inf

    def cheapest_incoming(active, costs):
        return {v: min(active, key=lambda u: costs[u][v]) for v in active}

    def find_cycle(incoming, active):
        active_set = set(active)
        for start in active:
            path = []
            index = {}
            node = start
            while node in active_set:
                if incoming[node] == node:
                    break
                if node in index:
                    return path[index[node]:]
                index[node] = len(path)
                path.append(node)
                node = incoming[node]
        return None

    def solve(active, costs):
        incoming = cheapest_incoming(active, costs)
        cycle = find_cycle(incoming, active)
        if cycle is None:
            return incoming

        cycle_set = set(cycle)
        contracted = cycle[0]
        active2 = [v for v in active if v not in cycle_set] + [contracted]

        costs2 = {u: {} for u in active2}
        for u in active2:
            for v in active2:
                if u == v:
                    costs2[u][v] = costs[u][v]
                elif v == contracted:
                    costs2[u][v] = min(
                        costs[u][w] - costs[incoming[w]][w] for w in cycle
                    )
                elif u == contracted:
                    costs2[u][v] = inf
                else:
                    costs2[u][v] = costs[u][v]

        incoming2 = solve(active2, costs2)

        entry = min(
            cycle,
            key=lambda w: costs[incoming2[contracted]][w] - costs[incoming[w]][w],
        )
        incoming[entry] = incoming2[contracted]
        for v in active2:
            if v != contracted:
                incoming[v] = incoming2[v]
        return incoming

    return solve(vertices, weight)


def reference_from_incoming(incoming, filenames):
    return {
        v: None if incoming[v] == v else incoming[v]
        for v in filenames
    }


def is_acyclic(reference_for, filenames):
    for start in filenames:
        seen = set()
        node = start
        while reference_for[node] is not None:
            if reference_for[node] in seen:
                return False
            seen.add(node)
            node = reference_for[node]
    return True


def topology_cost(incoming, weight, filenames):
    return sum(weight[incoming[v]][v] for v in filenames)


def best_star_topology(filenames, weight):
    best_incoming = None
    best_cost = math.inf
    for root in filenames:
        incoming = {v: (root if v != root else v) for v in filenames}
        cost = topology_cost(incoming, weight, filenames)
        if cost < best_cost:
            best_cost = cost
            best_incoming = incoming
    return best_incoming, best_cost


def best_rooted_arborescence(filenames, weight):
    best_incoming = None
    best_cost = math.inf
    for root in filenames:
        modified = {u: dict(weight[u]) for u in filenames}
        for u in filenames:
            if u != root:
                modified[u][root] = math.inf
        incoming = min_cost_branching(filenames, modified)
        incoming[root] = root
        reference_for = reference_from_incoming(incoming, filenames)
        if not is_acyclic(reference_for, filenames):
            continue
        cost = topology_cost(incoming, weight, filenames)
        if cost < best_cost:
            best_cost = cost
            best_incoming = incoming
    return best_incoming, best_cost


def optimize_topology(filenames, weight):
    candidates = []
    labels = []

    unrestricted = min_cost_branching(filenames, weight)
    reference_for = reference_from_incoming(unrestricted, filenames)
    if is_acyclic(reference_for, filenames):
        candidates.append(unrestricted)
        labels.append("unrestricted Edmonds")
    else:
        print("Warning: unrestricted Edmonds produced a cycle; skipping that result")

    rooted, _ = best_rooted_arborescence(filenames, weight)
    if rooted is not None:
        candidates.append(rooted)
        labels.append("rooted arborescence")

    star, _ = best_star_topology(filenames, weight)
    candidates.append(star)
    labels.append("star topology")

    best_index = min(
        range(len(candidates)),
        key=lambda index: topology_cost(candidates[index], weight, filenames),
    )
    print(f"Selected {labels[best_index]}")
    return candidates[best_index]


def chain_depth(reference_for, filename):
    depth = 0
    seen = {filename}
    ref = reference_for[filename]
    while ref is not None:
        depth += 1
        if ref in seen:
            raise ValueError(f"Cycle detected at {ref}")
        seen.add(ref)
        ref = reference_for[ref]
    return depth


variants = build_data["variants"]
filenames = [variant["filename"] for variant in variants]
raw_bytes = {}
for variant in variants:
    filename = variant["filename"]
    with open(filename, "rb") as f:
        raw_bytes[filename] = f.read()

print(f"Computing compression graph for {len(filenames)} variants...")

weight = {u: {} for u in filenames}
for u in filenames:
    for v in filenames:
        if u == v:
            weight[u][v] = len(brotli_compress(raw_bytes[v]))
        else:
            delta = vcdiff_encode(raw_bytes[u], raw_bytes[v])
            weight[u][v] = len(brotli_compress(delta))

incoming = optimize_topology(filenames, weight)
reference_for = reference_from_incoming(incoming, filenames)

total_bytes = sum(weight[incoming[v]][v] for v in filenames)
_, star_bytes = best_star_topology(filenames, weight)
root_count = sum(1 for v in filenames if reference_for[v] is None)
max_depth = max(chain_depth(reference_for, v) for v in filenames)

print(
    f"Optimal branching: {total_bytes} bytes total "
    f"(star baseline: {star_bytes} bytes), "
    f"{root_count} root(s), max chain depth {max_depth}"
)

updated_variants = []
for variant in variants:
    filename = variant["filename"]
    reference_variant = reference_for[filename]
    file_bytes = raw_bytes[filename]

    if reference_variant is None:
        payload = brotli_compress(file_bytes)
        restored = brotli_decompress(payload)
        assert restored == file_bytes, f"Verification failed for {filename} (brotli)"
    else:
        reference_bytes = raw_bytes[reference_variant]
        delta = vcdiff_encode(reference_bytes, file_bytes)
        payload = brotli_compress(delta)
        restored = vcdiff_decode(
            reference_bytes,
            brotli_decompress(payload),
        )
        assert restored == file_bytes, f"Verification failed for {filename} (vcdiff)"

    compressed_filename = filename + ".br"
    with open(compressed_filename, "wb") as out:
        out.write(payload)

    ref_label = reference_variant or "(raw)"
    print(f"  {filename}: {len(payload)} bytes via {ref_label}")
    updated_variants.append({
        **variant,
        "compressedFilename": compressed_filename,
        "referenceVariant": reference_variant,
    })

updated_build_data = {
    key: value
    for key, value in build_data.items()
    if key not in ("compressionRefVariant",)
}
updated_build_data["variants"] = updated_variants

with open("build.json", "w", encoding="utf-8") as f:
    json.dump(updated_build_data, f, indent=2)
print("Updated build.json with referenceVariant and compressedFilename fields.")
