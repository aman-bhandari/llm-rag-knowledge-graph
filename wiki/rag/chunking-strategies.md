# Chunking Strategies

**Summary:** The chunker is the only RAG decision that cannot be fixed downstream. A bad chunk boundary is a partial object in the index; no downstream layer can recover information that got split across it.
**Tags:** #rag #retrieval #upstream
**Last Updated:** 2026-02-03
**Sources:** LangChain text-splitter docs, LlamaIndex node parsers

---

## Content

### Four strategies, roughly ordered by sophistication

1. **Fixed-size.** Split on token (or character) count. Constant chunk size, no overlap by default. Simplest to implement. Fails when the boundary lands inside a self-contained unit (a table row, a code block, a numbered list item).
2. **Recursive / character-based.** Try splitting on `\n\n`, fall back to `\n`, fall back to sentence boundary, fall back to character boundary. Respects paragraph and line breaks; still agnostic to meaning.
3. **Semantic.** Embed sentences and split where embedding similarity between adjacent sentences drops below a threshold. Respects topic boundaries; costly to compute; threshold tuning is corpus-specific.
4. **Agentic / structure-aware.** An LLM (or a parser for structured formats) decides chunk boundaries based on document structure — heading hierarchy, table boundaries, code-block fences, list items. Most expensive; least corpus-agnostic; highest-quality for documents with clear structure.

No strategy is universally correct. The right choice depends on what a *self-contained unit* looks like in the source corpus.

### Failure modes per strategy

| Strategy | Failure mode | Typical symptom |
|----------|--------------|-----------------|
| Fixed-size | Splits mid-unit | Retrieval returns the chunk containing the query terms; the chunk containing the answer has no overlap and ranks far below |
| Recursive | Respects whitespace, not meaning | Table rows kept together only if the table is separated by blank lines from surrounding text |
| Semantic | Threshold-sensitive | Over-merges at low threshold (chunks drift across topics); over-splits at high threshold (definition separated from example) |
| Agentic | LLM mis-parses structure | Markdown with irregular heading levels; code with unmatched fences |

The fixed-size failure mode is the most common in practice because it is the default in most tutorials. The pattern: a table, a numbered list, or a definition-example pair gets split; the query matches one half; the other half never ranks.

### Overlap is a separate decision

Any strategy can add overlap — N tokens (or sentences) of the previous chunk prepended to the current chunk. Overlap mitigates the boundary-split failure mode by ensuring any phrase spanning a boundary appears in at least one chunk in full.

Overlap costs index size and introduces redundancy in retrieval (two chunks return the same passage; reranker or dedup handles it). Typical overlap values: 10-20% of chunk size. Zero overlap is the wrong default but remains the default in most quickstart code.

### The upstream-downstream argument

A bad embedding model can be swapped. A bad reranker can be tuned. A bad generator can be re-prompted. A bad chunk boundary splits the information across two records in the index, and no downstream layer has access to the original document to reassemble them. The chunker's decisions are load-bearing for every downstream layer; the downstream layers cannot repair what the chunker destroyed.

This is why chunking is worth disproportionate attention compared to the many other RAG knobs. Getting it right makes every downstream evaluation more interpretable. Getting it wrong produces failure modes that look like retrieval bugs and waste hours of reranker debugging.

### Practical defaults for new corpora

- Start with **recursive** splitting (respects paragraph structure, zero cost) with **10-20% overlap** between adjacent chunks.
- Evaluate by manually labelling 25-50 queries and checking whether the correct chunk is in the top-5 retrieved.
- If structured data dominates (tables, code, hierarchical docs), layer in **structure-aware** boundaries for those subsets — one table per chunk, one code block per chunk — while keeping recursive for prose.
- Only reach for **semantic** chunking when evaluation shows adjacent-chunk boundaries falling mid-argument and the overlap budget is insufficient to cover it.

## Cross-references

- **Prerequisites:** [[embedding-spaces]] — understanding why a split chunk does not retrieve the query requires understanding what an embedding represents
- **Related:** none in this corpus yet; candidates include retrieval metrics (NDCG, MRR), reranker patterns, evaluation harness design
- **Applications:** every RAG pipeline; production retrieval over large corpora; agentic RAG (where the agent decides which chunk to query next)
