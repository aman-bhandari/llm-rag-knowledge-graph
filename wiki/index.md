# Knowledge Wiki — Master Index

> Synthetic corpus demonstrating the wiki-as-RAG graph shape. 5 concept pages, 2 categories, cross-linked.

## Categories

- [Python](python/index.md) — 3 pages
- [RAG](rag/index.md) — 2 pages

## Pages by category

### Python

- [[python/decorators]] — cross-cutting behavior via function replacement + closures
- [[python/iterator-protocol]] — iter(), next(), StopIteration, and why generators compose
- [[python/comprehensions]] — list / dict / set / generator comprehensions; eager vs lazy

### RAG

- [[rag/chunking-strategies]] — fixed-size, recursive, semantic, agentic; failure modes per strategy
- [[rag/embedding-spaces]] — dense vs sparse; distance metrics; the lexical-overlap failure mode

## How to navigate

- Click any `[[wiki-link]]` to follow the cross-reference (works in Obsidian and most markdown viewers).
- For programmatic traversal: `python3 ../scripts/wiki_traverse.py <category>/<slug>`.
- For the change history per page: see [log.md](log.md).
