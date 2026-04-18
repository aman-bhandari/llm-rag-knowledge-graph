# Comprehensions

**Summary:** List, dict, set, and generator comprehensions are concise surfaces over the iterator protocol. List comprehensions materialise; generator expressions stream. The choice is a memory decision.
**Tags:** #python #patterns #fundamentals
**Last Updated:** 2026-01-22
**Sources:** Python language reference (Displays for lists, sets, and dictionaries), PEP 202 / PEP 274 / PEP 289

---

## Content

### The four forms

```python
[x * 2 for x in seq]          # list comprehension       → list
{x * 2 for x in seq}          # set comprehension        → set
{k: v for k, v in pairs}      # dict comprehension       → dict
(x * 2 for x in seq)          # generator expression     → generator (iterator)
```

The first three materialise the full result in memory. The fourth is lazy — it yields one element per `next()` call and never holds the whole sequence.

### Eager vs lazy — the memory decision

This is the only comprehension choice that matters at scale.

```python
total = sum([x ** 2 for x in range(10_000_000)])   # materialises 10M-element list first
total = sum( x ** 2 for x in range(10_000_000))    # streams through sum, holds one int at a time
```

Both compute the same result. The first allocates ~80MB for the intermediate list. The second allocates one int. For any pipeline whose output is consumed once by an aggregator (`sum`, `max`, `any`, `min`, `''.join(...)`), the generator expression is the right choice.

The first is not wrong if you need the intermediate list for something else — reuse, indexing, multiple passes. The pattern is: build a list when you need random access; build a generator when you need one-pass streaming.

### Nested comprehensions

```python
flat = [x for row in matrix for x in row]          # flatten
square = [[x * y for x in row] for y in col]       # 2D build
```

The reading order for nested comprehensions is left-to-right for the `for` clauses (outermost to innermost) and then the leading expression. This is the opposite of what the syntax visually suggests — the expression appears first but evaluates last.

### Conditional comprehensions

```python
evens   = [x for x in seq if x % 2 == 0]            # filter-only
ternary = [x if x > 0 else 0 for x in seq]          # transform only, no filter
both    = [x * 2 for x in seq if x > 0]             # filter then transform
```

The `if` at the end is a filter. The `x if cond else y` in the leading expression is a ternary — a transform decision per element, not a filter. They compose: filter first, then ternary transform, in that order.

### When to prefer a plain for-loop

Comprehensions are expressions, not statements. They produce a value. If the body has side effects — writes to a file, updates a counter in the outer scope, calls an API — a for-loop is the right shape. A comprehension that calls an API in its expression is a comprehension pretending to be a loop, and it reads worse than a loop would.

## Cross-references

- **Prerequisites:** [[iterator-protocol]] — a comprehension compiles down to the iterator protocol; the generator-expression form is literally a generator
- **Related:** [[decorators]] (the other major place Python's first-class-function machinery surfaces)
- **Applications:** data-shape transforms, pipeline intermediate stages, lazy streams over large corpora
