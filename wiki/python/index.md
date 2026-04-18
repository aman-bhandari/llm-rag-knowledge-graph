# Python — Category Index

Concept pages for Python internals that recur in AI-engineering work.

## Pages

- [[decorators]] — cross-cutting behavior via function replacement and closures
- [[iterator-protocol]] — `iter()`, `next()`, `StopIteration`, and why generators compose
- [[comprehensions]] — list / dict / set / generator comprehensions; eager vs lazy evaluation

## Reading order

1. [[iterator-protocol]] first — it is the prerequisite for both others.
2. [[comprehensions]] — applies the iterator protocol to data-shape work.
3. [[decorators]] — uses closures (which build on iterator-style state retention) as the mechanism under the `@` sugar.
