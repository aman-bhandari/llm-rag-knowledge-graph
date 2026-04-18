# Embedding Spaces

**Summary:** An embedding maps a text span to a dense vector. Retrieval is nearest-neighbour search in that vector space under a distance metric. Two chunks embed near each other when they share semantic or lexical signal the model was trained to recognise.
**Tags:** #rag #embeddings #retrieval
**Last Updated:** 2026-02-03
**Sources:** Sentence-Transformers docs, "BERT Rediscovers the Classical NLP Pipeline" (Tenney et al.), original word2vec paper

---

## Content

### The minimum useful model

An embedding model is a function `text → vector ∈ R^d`. Typical `d`: 384 (all-MiniLM), 768 (bge-base), 1536 (OpenAI ada-002), 3072 (text-embedding-3-large). Larger `d` allows more orthogonal directions and usually more discriminative similarity at the cost of storage and compute.

Two vectors are "near" when their distance under the chosen metric is small. Nearness is an approximation of semantic similarity — the model was trained on a pretext task (next sentence prediction, contrastive pairs, masked language modelling) that correlates with what humans call semantic similarity, but the correlation is not exact.

### Dense vs sparse

- **Dense** embeddings: every dimension is populated. Learned by neural models. Captures co-occurrence and paraphrase. Poor at exact keyword matches (a query for "SKU-42" may not retrieve a chunk containing "SKU-42" if no training signal linked that exact token).
- **Sparse** embeddings: most dimensions are zero. Includes classical BM25 (term-frequency based) and modern learned sparse (SPLADE). Exact-match dominant; paraphrase blind.

Dense retrieves "the overnight reconciliation job's batch size" against a query about "maximum batch size for overnight reconciliation". Sparse (BM25) retrieves only if the exact terms overlap. Production retrieval often combines both — hybrid search, scores fused.

### Distance metrics

Three common choices:

| Metric | Formula (informally) | When to use |
|--------|----------------------|-------------|
| Cosine similarity | normalise both, take dot product | Default for most embedding models; scale-invariant |
| Dot product | raw dot, no normalisation | When model outputs are pre-normalised or when magnitude is a useful signal |
| Euclidean (L2) | sqrt of sum of squared differences | Rare for text embeddings; more common in image |

Most sentence-encoder models (MiniLM, bge, etc.) output vectors intended for cosine similarity. The model card specifies the intended metric; using the wrong metric on a model trained for another degrades retrieval quality.

### The lexical-overlap failure mode

This is the most common RAG failure mode in practice, and it is subtle.

Dense embeddings are trained to cluster texts that *co-occur in training*. They are not trained to preserve exact-keyword overlap. A chunk containing the literal string `"maximum batch size"` and a chunk containing the literal string `"5000"` are not guaranteed to be near each other in embedding space unless the training corpus linked those concepts. If they were in separate sentences (or split across chunks — see [[chunking-strategies]]), retrieval can fail to surface both.

The symptom: the query embeds near the chunk containing the phrase from the query, not near the chunk containing the answer. Keyword-based sanity check passes (the retrieved chunk has the query terms); generation quality fails (the retrieved chunk has no answer).

Mitigations, roughly in increasing cost:

1. **Chunking that keeps related phrases together.** The cheapest and most common fix. See [[chunking-strategies]].
2. **Hybrid retrieval.** Combine dense with BM25. The BM25 scorer catches exact-match signal the dense model missed.
3. **Reranking.** A cross-encoder rescores top-k candidates with full query-chunk attention. Expensive per-query; high quality.
4. **Better embedding model.** Domain-tuned models (scientific, code, legal) embed domain-specific terminology with more discrimination. Typically the last resort — changing the model triggers full re-indexing.

### Dimensionality and storage

For a corpus of N chunks and embedding dimension d, the index holds N × d × 4 bytes (float32). A 10M-chunk corpus at d=1536 is 60GB uncompressed. Production systems use int8 or binary quantisation, PQ (product quantisation), or dimensionality reduction (Matryoshka embeddings support variable-d retrieval from a single model). These are storage-quality trade-offs; worth measuring before committing.

### Evaluation

Evaluate retrieval — not generation — first. Label 25-100 queries with the correct chunk (by chunk ID). Measure recall@k and MRR. If recall@5 is below 70%, the retrieval layer is the bottleneck; tuning the generator is wasted effort until retrieval clears that bar.

## Cross-references

- **Prerequisites:** none in this corpus yet; useful context would be basic linear algebra (dot product, vector norms)
- **Related:** [[chunking-strategies]] — the upstream decision whose failure mode this page's lexical-overlap section describes
- **Applications:** every RAG pipeline; semantic search; deduplication; clustering; paraphrase detection
