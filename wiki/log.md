# Knowledge Wiki — Change Log

> Append-only chronological record of all ingests and changes to the wiki corpus.

| Date | Action | Page | Note |
|------|--------|------|------|
| 2026-01-15 | Created | python/decorators.md | Written from session 1 chronicle |
| 2026-01-15 | Created | python/iterator-protocol.md | Prerequisite for decorators' closure explanation |
| 2026-01-22 | Created | python/comprehensions.md | Cross-reference from iterator-protocol |
| 2026-01-22 | Updated | python/iterator-protocol.md | Added comprehension cross-ref |
| 2026-01-22 | Updated | wiki/index.md | Rebuilt with python category |
| 2026-02-03 | Created | rag/chunking-strategies.md | Written from session 2 chronicle |
| 2026-02-03 | Created | rag/embedding-spaces.md | Prerequisite for chunking failure-mode explanation |
| 2026-02-03 | Updated | wiki/index.md | Added rag category |

## Schema

Columns are fixed. Rows append chronologically. Actions: `Created`, `Updated`, `Merged`, `Deprecated`. The Note column is one short sentence — the `why` of the change. Git history remains the authoritative change log; this file is the human-readable summary.
