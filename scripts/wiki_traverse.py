#!/usr/bin/env python3
"""
wiki_traverse.py — walk a wiki-link graph from a seed concept and return
the connected subgraph.

This is the minimum viable primitive behind wiki-as-RAG: retrieval by
graph traversal over [[wiki-link]] references, rather than by embedding
similarity. It demonstrates the graph shape without requiring a vector
database. Teams that want embedding-based retrieval layer it on top;
the graph shape is the substrate.

Usage:
    python3 scripts/wiki_traverse.py python/decorators
    python3 scripts/wiki_traverse.py rag/chunking-strategies --depth 2
    python3 scripts/wiki_traverse.py python/iterator-protocol --format json

The seed argument is a path relative to `wiki/` without the .md suffix.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Iterable

WIKI_DIR = Path(__file__).resolve().parent.parent / "wiki"
WIKI_LINK_RE = re.compile(r"\[\[([^\]|#]+)(?:\|[^\]]*)?(?:#[^\]]*)?\]\]")


def resolve_link(link_target: str, from_node: Path) -> Path | None:
    """Resolve a [[link_target]] to an actual file on disk.

    Obsidian-style links are usually just the file name without .md; they
    resolve against any .md file in the vault with that name. For an
    artifact scaffold, we accept two forms:
      - bare name (searches anywhere in WIKI_DIR)
      - category/name (resolves relative to WIKI_DIR)
    """
    target = link_target.strip()
    if "/" in target:
        candidate = WIKI_DIR / f"{target}.md"
        return candidate if candidate.is_file() else None
    matches = list(WIKI_DIR.rglob(f"{target}.md"))
    if not matches:
        return None
    if len(matches) == 1:
        return matches[0]
    same_dir = from_node.parent / f"{target}.md"
    if same_dir.is_file():
        return same_dir
    return matches[0]


def extract_links(node: Path) -> list[str]:
    text = node.read_text(encoding="utf-8")
    return [m.group(1) for m in WIKI_LINK_RE.finditer(text)]


def first_heading(node: Path) -> str:
    for line in node.read_text(encoding="utf-8").splitlines():
        if line.startswith("# "):
            return line[2:].strip()
    return node.stem


def traverse(seed: Path, max_depth: int) -> dict:
    visited: dict[str, dict] = {}
    frontier: list[tuple[Path, int]] = [(seed, 0)]
    while frontier:
        node, depth = frontier.pop(0)
        rel = str(node.relative_to(WIKI_DIR)).removesuffix(".md")
        if rel in visited:
            continue
        links = extract_links(node)
        visited[rel] = {
            "title": first_heading(node),
            "depth": depth,
            "outbound_links": links,
        }
        if depth >= max_depth:
            continue
        for link in links:
            resolved = resolve_link(link, node)
            if resolved is not None:
                frontier.append((resolved, depth + 1))
    return visited


def render_text(subgraph: dict, seed_rel: str) -> Iterable[str]:
    yield f"Seed: {seed_rel}"
    yield f"Nodes visited: {len(subgraph)}"
    yield ""
    for rel, info in subgraph.items():
        indent = "  " * info["depth"]
        yield f'{indent}[{rel}] "{info["title"]}"'
        for link in info["outbound_links"]:
            yield f'{indent}  -> [[{link}]]'


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("seed", help="seed concept path, e.g. 'python/decorators'")
    parser.add_argument("--depth", type=int, default=2, help="max traversal hops (default: 2)")
    parser.add_argument("--format", choices=["text", "json"], default="text")
    args = parser.parse_args()

    seed_path = WIKI_DIR / f"{args.seed}.md"
    if not seed_path.is_file():
        print(f"seed not found: {seed_path}", file=sys.stderr)
        return 2

    subgraph = traverse(seed_path, max_depth=args.depth)

    if args.format == "json":
        print(json.dumps(subgraph, indent=2))
    else:
        for line in render_text(subgraph, args.seed):
            print(line)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
