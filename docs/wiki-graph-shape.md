# Wiki-as-RAG Graph Shape

The wiki is a graph. Nodes are atomic concept pages; edges are `[[wiki-links]]` between them. Every teaching exchange that introduces a concept writes (or updates) a node. Every node links to its prerequisites, its siblings, and its applications. Over months the corpus compounds into a retrieval substrate that is both human-readable (opens in Obsidian, renders in any markdown viewer) and machine-traversable (a small Python script walks it — see `scripts/wiki_traverse.py`).

This doc specifies the shape. A retrieval layer — embedding similarity, keyword search, or plain graph BFS — can sit on top. The shape is the substrate.

---

## Why a graph, not a flat corpus

Flat corpora (one folder of markdown, no cross-references) retrieve well by embedding similarity but poorly by prerequisite chain. You ask "how do decorators work?" and the top-k pages cluster on surface-level mentions rather than on the actual learning path from closures → first-class functions → decorators → `functools.wraps`.

Graph shape lets retrieval walk prerequisites. A query for "decorators" anchors at `python/decorators`, then follows `[[closures-and-cells]]` backwards to the prerequisite, and `[[functools-wraps]]` forwards to the application. The resulting subgraph is the learning path, not a similarity cluster.

The graph does not replace embeddings. It complements them. For production RAG you would embed the nodes for similarity search AND expose the graph for prerequisite traversal; the two retrievers answer different questions.

---

## Directory shape

```
wiki/
  README.md
  index.md           # master index, pages by category
  log.md             # append-only change log
  python/
    index.md         # category index
    decorators.md
    iterator-protocol.md
    comprehensions.md
  rag/
    index.md
    chunking-strategies.md
    embedding-spaces.md
```

- **One category per directory.** Category boundary is a human judgment (topic area, difficulty tier, audience). Keep categories coarse — 5-10 categories is enough for a corpus of a few hundred nodes.
- **One concept per file.** Atomic. If a page covers two concepts, split it.
- **File name == slug.** `decorators.md` is linked as `[[decorators]]` or `[[python/decorators]]`. Use kebab-case: `iterator-protocol.md`, `chunking-strategies.md`.
- **Every category has an `index.md`** listing its pages with one-line descriptions.
- **The root `index.md`** links to category indexes and to every page.
- **`log.md`** is append-only. Every ingest (create, rewrite, merge) appends a row.

---

## Node format

Every concept page has the same shape:

```markdown
# <Concept Name>

**Summary:** <one-sentence distillation. Used by retrieval previews.>
**Tags:** #category #difficulty #… (space-separated, used by faceted search)
**Last Updated:** YYYY-MM-DD
**Sources:** <canonical docs, papers, books — comma-separated>

---

## Content

<the actual teaching content — code, diagrams, examples, analogies>

## Cross-references

- **Prerequisites:** [[prereq-1]], [[prereq-2]]
- **Related:** [[sibling-1]], [[sibling-2]]
- **Applications:** [[application-1]]
```

The Cross-references block is not decorative. It is the graph. Retrieval walks these three edge types and can weight them differently — "Prerequisites" weighted higher for "how do I learn X", "Applications" weighted higher for "where is X used".

---

## Wiki-link syntax

- `[[slug]]` — short form. Retrieval resolves to any `.md` file in the vault with that basename. Ambiguous if two categories have the same slug.
- `[[category/slug]]` — qualified form. Unambiguous. Preferred when slug appears in multiple categories.
- `[[slug|display text]]` — Obsidian's aliased-link form. The display text shows in the rendered page; the link still resolves to the slug. Retrieval should strip the alias and resolve on the slug.
- `[[slug#Section]]` — Obsidian's header-anchor form. Links to a specific `## Section` inside the target page. Retrieval should strip the `#Section` and resolve on the slug (same page, just scrolled).

All four forms are Obsidian-compatible. Retrieval code (`scripts/wiki_traverse.py`) handles all four with a single regex.

---

## Log file schema

`wiki/log.md` is append-only. Format:

```markdown
# Knowledge Wiki — Change Log

> Append-only chronological record of all ingests and changes.

| Date | Action | Page | Note |
|------|--------|------|------|
| 2026-01-15 | Created | python/decorators.md | Imported from session notes |
| 2026-01-17 | Updated | python/decorators.md | Added functools.wraps cross-ref |
```

The log is the audit trail. It answers "when was this written? what changed?" without requiring git archaeology. Git history remains the authoritative record; the log is a human-readable summary.

---

## Index files

Every `index.md` (category and root) is a table of contents. No narrative, no teaching content. Just links.

Root `index.md`:

```markdown
# Knowledge Wiki — Master Index

> Browse in Obsidian for graph view.

## Categories

- [Python](python/index.md) — N pages
- [RAG](rag/index.md) — N pages

## Pages by Category

### Python
- [[python/decorators]] — cross-cutting behavior wrap pattern
- [[python/iterator-protocol]] — iter(), next(), StopIteration

### RAG
- [[rag/chunking-strategies]] — fixed-size vs semantic chunking
- [[rag/embedding-spaces]] — dense vs sparse; distance metrics
```

Category `index.md` is the same shape but scoped to one category.

---

## Retrieval example

`scripts/wiki_traverse.py` is the minimum viable retrieval primitive:

```bash
python3 scripts/wiki_traverse.py python/decorators --depth 2
```

Output: the seed node and every node reachable within 2 hops along `[[wiki-link]]` edges, with indentation showing depth. Flag `--format json` emits the subgraph as JSON for downstream tooling.

This script has **no external dependencies**. Python 3.10+ stdlib only. The graph shape is the substrate; any retrieval technology — embeddings, LLM reranking, hybrid BM25 + dense — can read this same wiki and layer its own index on top.

---

## Obsidian compatibility

Open `wiki/` as an Obsidian vault. Everything works out of the box:

- `[[wiki-link]]` renders as clickable link.
- Graph view shows the cross-reference structure.
- Backlinks panel shows incoming links per node.
- The `.obsidian/` directory gets created on first open; `workspace.json` (per-user view state) is gitignored, but `app.json` / `graph.json` can be committed to share view preferences across contributors.

No Obsidian plugins required. The vault is a plain directory of markdown files with a convention. That is the point — the corpus outlives any specific tool.

---

## When to add a node

- **New concept introduced** in a teaching exchange → new node.
- **Existing concept re-taught from a different angle** → update the existing node; do not create a duplicate. The log row captures the update.
- **Concept that collapses two existing nodes** → write the merged node, mark the old two as deprecated (add `**Deprecated:** See [[merged-node]]` at the top). Keep the old files; do not delete — back-links may point at them from elsewhere in the corpus.

---

## Anti-patterns

- **Nodes that are just a link dump.** A node without `## Content` is filler. Delete it or absorb it into the referrer.
- **Nodes that duplicate the canonical docs verbatim.** Link to the canonical docs under `**Sources:**` and write the teaching angle in your own words. The value of the wiki is the angle, not the re-typing.
- **Cross-references that do not resolve.** A `[[broken-link]]` is a gap. Integrity-check should flag unresolved links. (`scripts/integrity-check.sh` in this repo does not currently enforce this — it is a fair extension point.)
- **Categories that balloon past ~20 pages.** Split the category. A category index with 50 entries becomes unusable.
