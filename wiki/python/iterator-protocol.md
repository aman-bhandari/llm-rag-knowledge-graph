# Iterator Protocol

**Summary:** An iterator is any object with `__iter__` returning self and `__next__` advancing state. Generators are iterators built from a function body with `yield`. Comprehensions and for-loops depend on this protocol.
**Tags:** #python #fundamentals #data
**Last Updated:** 2026-01-22
**Sources:** Python language reference (Iterator types), PEP 234

---

## Content

### The protocol, stated precisely

An iterator is any object that implements two methods:

- `__iter__(self) -> Iterator` — returns an iterator (typically `self`)
- `__next__(self) -> T` — returns the next value, or raises `StopIteration` when exhausted

A `for x in seq:` loop is sugar for:

```python
it = iter(seq)
while True:
    try:
        x = next(it)
    except StopIteration:
        break
    # body
```

Everything iterable in Python goes through this same pair of methods. Lists, tuples, dicts, files, generator expressions, comprehensions — all conform.

### Iterables vs iterators

- An **iterable** has `__iter__` that returns a *new* iterator each time. Lists are iterables.
- An **iterator** has `__iter__` that returns self, and holds its position. It is consumed on iteration — once exhausted, it stays exhausted.

```python
lst = [1, 2, 3]            # iterable, not iterator
it = iter(lst)             # iterator over lst
next(it)                   # 1
next(it)                   # 2
list(it)                   # [3]  — drained
list(it)                   # []   — already drained
```

This distinction is load-bearing for anything that iterates a stream twice. A generator is an iterator, not an iterable. Reusing it requires recreating it.

### Generators

A function containing `yield` returns a generator on call. The function body does not execute on call; it executes lazily across `next()` invocations, suspending at each `yield`.

```python
def counting_up():
    n = 0
    while True:
        yield n
        n += 1

c = counting_up()
next(c)  # 0
next(c)  # 1
next(c)  # 2
```

The generator object is an iterator with its own frame kept alive across suspensions. State between yields lives in local variables; those locals are captured in the suspended frame, analogously to how closures capture names.

### StopIteration as control flow

`StopIteration` is the only exception that is part of normal protocol, not an error condition. The for-loop catches it silently. Code that calls `next()` directly must handle it or provide a default: `next(it, sentinel)`.

Since PEP 479 (Python 3.7+), raising `StopIteration` inside a generator body is an error — it surfaces as a `RuntimeError` instead. To end a generator, `return` from the function body; the interpreter converts the return into a clean `StopIteration`.

### Why this matters for AI-engineering work

Any pipeline that streams data (document ingestion, token streams, batched training) is an iterator chain. `map`, `filter`, `zip`, comprehensions, generator expressions are all protocol conformers. Understanding that chain is memory: each intermediate stage is a generator that advances one element at a time, never materialising the whole pipeline — which is why streaming a 50GB file through a 4-stage transform does not OOM.

## Cross-references

- **Prerequisites:** none (this is a foundation page)
- **Related:** [[comprehensions]] (comprehensions are a more convenient surface for the same protocol)
- **Applications:** [[decorators]] (closure cells and generator frames use the same state-retention mechanism), streaming data pipelines, lazy evaluation over large corpora
