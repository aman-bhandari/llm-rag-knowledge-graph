# Claim-Evidence Mapping

Every claim this repo makes — in its GitHub description, its README, and any resume line pointing at it — must map to a file or command that evidences the claim.

**Rule:** every row must be verified (✅) before push. An unverified row (☐) fails the integrity check and blocks CI.

## Claims

| Claim | Evidence (file / command) | Verified |
|-------|---------------------------|----------|
| "chronicle editorial format" | `docs/chronicle-editorial-format.md` present, documents frontmatter contract, body beats (Opening / Work / Break / Click), voice conventions, 5 quality gates | ✅ |
| "chronicle template" | `chronicle/_template/README.md` present; provides copy-ready frontmatter + body skeleton; references editorial format doc | ✅ |
| "2 sample chronicles" | `find chronicle/examples -type f -name '*.md' \| wc -l` returns 2; files: `2026-01-15-session-01.md`, `2026-02-03-session-02.md` | ✅ |
| "sample chronicles conform to editorial format" | Both files carry all 8 required frontmatter fields (`date`, `session`, `topic`, `title`, `summary`, `status`, `prev`, `next`); enforced by `scripts/integrity-check.sh` | ✅ |
| "wiki-as-RAG graph shape" | `docs/wiki-graph-shape.md` present; specifies directory layout, node format, wiki-link syntax (4 forms), index convention, log schema, Obsidian compatibility | ✅ |
| "5 synthetic cross-linked wiki concept pages" | `find wiki -type f -name '*.md' ! -name 'index.md' ! -name 'log.md' ! -name 'README.md' \| wc -l` returns 5: `python/decorators`, `python/iterator-protocol`, `python/comprehensions`, `rag/chunking-strategies`, `rag/embedding-spaces` | ✅ |
| "2 categories (python, rag)" | `find wiki -mindepth 1 -maxdepth 1 -type d \| wc -l` returns 2; each has `index.md` | ✅ |
| "every [[wiki-link]] resolves" | `scripts/integrity-check.sh` walks every link in wiki + chronicle and fails on unresolved references; currently green | ✅ |
| "Obsidian-compatible" | Directory is a plain vault of markdown files; `[[slug]]`, `[[category/slug]]`, `[[slug\|alias]]`, `[[slug#anchor]]` all parseable by `scripts/wiki_traverse.py` and by Obsidian's native parser (single shared link convention) | ✅ |
| "runnable retrieval example" | `python3 scripts/wiki_traverse.py python/decorators --depth 2` runs green (enforced in integrity-check); Python 3.10+ stdlib only, zero dependencies | ✅ |
| "retrieval example emits JSON" | `python3 scripts/wiki_traverse.py rag/chunking-strategies --depth 1 --format json` produces valid JSON (enforced in integrity-check) | ✅ |
| "append-only change log" | `wiki/log.md` present with documented schema (Date / Action / Page / Note); 8 rows demonstrating the shape | ✅ |

## How this file is enforced

`scripts/integrity-check.sh` (run locally) and `.github/workflows/ci.yml` (run on every push) both fail if any row in this file carries `☐` instead of `✅`. This applies Gate 0 of the bulletproof publishing contract.

## Adding a new claim

When you write a new README claim — or a resume line starts pointing at this repo with a new number:

1. Add a row here with the claim text (verbatim) and the evidencing command or file path.
2. Mark as `☐` until verified.
3. Run `bash scripts/integrity-check.sh`. It fails while any row carries `☐`.
4. Verify the evidence, flip to `✅`, re-run.
5. Push only after all rows are `✅`.
