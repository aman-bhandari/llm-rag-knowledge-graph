# llm-rag-knowledge-graph

Chronicle editorial format + wiki-as-RAG graph shape for LLM-powered research labs. 5 synthetic cross-linked concept pages, 2 sample chronicles, a zero-dependency Python retrieval example.

## What this is

A template for the written output of a learning-lab or research-lab workflow, with two coupled pieces:

1. **Chronicle editorial format.** A long-form narrative format for documenting a learning or research session. Specifies a frontmatter contract (required + optional fields, including the `loop-beats` audit surface for concept-teaching sessions), a body shape (Opening → Work → Break → Click), and five pre-publish quality gates. Two sample chronicles ship in `chronicle/examples/` as conforming references.
2. **Wiki-as-RAG graph shape.** A convention for an atomic-concept wiki where each page is a single concept and pages cross-link by `[[wiki-link]]` references. The graph is Obsidian-compatible (open the `wiki/` directory as a vault) and walkable by a small Python script (`scripts/wiki_traverse.py`) using the standard library only — no embeddings layer, no vector DB, no external dependencies. Five synthetic concept pages ship across two categories (`python/`, `rag/`).

The two pieces are coupled: chronicles reference wiki concepts via a `wiki-nodes` frontmatter field, so a publisher can render "Concepts used in this session" as a sidebar, and a retrieval layer can walk from a chronicle into the concept graph that supports it.

## Tech stack

- Plain markdown (chronicle corpus, wiki corpus, documentation)
- Python 3.10+ stdlib (retrieval example `wiki_traverse.py`; zero external dependencies)
- Bash + GitHub Actions CI for integrity gate enforcement
- Obsidian-compatible link syntax (no Obsidian plugins required)

## Architecture

```
llm-rag-knowledge-graph/
├── README.md
├── LICENSE
├── .gitignore
├── docs/
│   ├── chronicle-editorial-format.md    # Format spec for chronicle entries
│   ├── wiki-graph-shape.md              # Format spec for wiki corpus
│   └── claim-evidence.md                # Gate 0: every claim evidenced
├── chronicle/
│   ├── _template/
│   │   └── README.md                    # Copy-ready frontmatter skeleton
│   └── examples/
│       ├── 2026-01-15-session-01.md     # Synthetic sample: decorators
│       └── 2026-02-03-session-02.md     # Synthetic sample: RAG chunking
├── wiki/
│   ├── README.md
│   ├── index.md                         # Master index
│   ├── log.md                           # Append-only change log
│   ├── python/
│   │   ├── index.md
│   │   ├── decorators.md
│   │   ├── iterator-protocol.md
│   │   └── comprehensions.md
│   └── rag/
│       ├── index.md
│       ├── chunking-strategies.md
│       └── embedding-spaces.md
├── scripts/
│   ├── wiki_traverse.py                 # Retrieval example (BFS over [[wiki-link]] edges)
│   └── integrity-check.sh               # Gates 0, 4, 5 + artifact-specific
└── .github/workflows/ci.yml             # Runs integrity check + hype-word audit
```

## Setup

No install step required.

```bash
git clone https://github.com/aman-bhandari/llm-rag-knowledge-graph.git
cd llm-rag-knowledge-graph
```

Python 3.10 or newer is required for the retrieval example. All other files are plain markdown.

## Usage

### Walk the wiki graph from a seed concept

```bash
python3 scripts/wiki_traverse.py python/decorators --depth 2
```

Emits the seed node plus every node reachable within 2 hops along `[[wiki-link]]` edges, with indentation showing depth. Use `--format json` for machine-readable output:

```bash
python3 scripts/wiki_traverse.py rag/chunking-strategies --depth 1 --format json
```

### Open the wiki as an Obsidian vault

Point Obsidian at the `wiki/` directory. Graph view shows the cross-reference structure immediately; no plugins required. The four wiki-link forms (`[[slug]]`, `[[category/slug]]`, `[[slug|alias]]`, `[[slug#anchor]]`) all render as clickable links.

### Adopt the chronicle format

Copy `chronicle/_template/README.md` as the starting point for a new chronicle. Fill the frontmatter (the required fields — 8 of them — are enforced by the integrity check). Write the body in the four beats documented in `docs/chronicle-editorial-format.md`. When the five quality gates pass, flip `status: draft` to `status: complete` and link the previous chronicle's `next:` field.

## Integrity check

```bash
bash scripts/integrity-check.sh
```

Runs:

- **Gate 0** — every claim in `docs/claim-evidence.md` marked verified (✅)
- **Gate 4** — zero private identifiers (internal project names, client domains, real individuals)
- **Gate 5** — no secrets (API keys, tokens, passwords) outside `.env.example`
- **Artifact-specific** — 5 wiki concept pages, 2 wiki categories each with `index.md`, ≥2 sample chronicles, every required chronicle frontmatter field present, every `[[wiki-link]]` resolves, `scripts/wiki_traverse.py` runs green for both text and JSON output

CI runs the same gates on every push via `.github/workflows/ci.yml`.

## Honest extract statement

This artifact was extracted from a private research lab's publishing scaffolding. The extract keeps:

- The chronicle frontmatter contract (adapted generically; no project-specific naming)
- The wiki directory shape, node format, link convention, log schema
- A zero-dependency retrieval example demonstrating graph traversal

The extract excludes everything personal: real session logs, real concept pages, the lab's actual curriculum, project-specific role vocabulary, and any named individuals. The two sample chronicles and five wiki nodes that ship here are synthetic — written to conform to the format, not copied from the source corpus.

## Related artifacts

- `claude-code-mcp-qa-automation` — end-to-end QA automation built on Claude Code + MCP patterns
- `claude-code-agent-skills-framework` — research scaffold for AI-engineering coaching with Claude Code
- `nextjs-16-mdx-research-publisher` — static publisher for research labs (can render this repo's chronicle corpus)
- `claude-multi-agent-protocol` — HANDOVER + SYNC inter-repo protocol

## License

MIT © 2026 Aman Bhandari. See `LICENSE`.
