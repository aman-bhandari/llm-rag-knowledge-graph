# Decorators

**Summary:** A decorator replaces a function with a new function that has the original captured in its closure. The `@` is sugar; the mechanism is replacement plus a closure.
**Tags:** #python #patterns #intermediate
**Last Updated:** 2026-01-22
**Sources:** Python language reference (Function definitions), PEP 318

---

## Content

### The mechanism, stated precisely

A decorator is a callable that takes a function and returns a callable. The decorated name in the module namespace is rebound to the return value. This is replacement, not wrapping.

```python
def log_calls(func):
    def wrapper(*args, **kwargs):
        print(f"calling {func.__name__}")
        return func(*args, **kwargs)
    return wrapper

@log_calls
def add(a, b):
    return a + b
```

The `@log_calls` line above is equivalent to:

```python
def add(a, b):
    return a + b
add = log_calls(add)
```

After that last line executes, the name `add` in the module namespace does not point at the original `add` anymore. It points at `wrapper`. The original function is still alive — it is captured in `wrapper`'s closure via the local name `func` — but it is only reachable *through* `wrapper`, never directly.

### Why `functools.wraps` is not optional

Because the decorator replaced the function, introspection against the decorated name sees the wrapper's metadata, not the original's. `add.__name__` returns `"wrapper"`. `add.__doc__` is the wrapper's docstring (likely `None`). Debuggers show the wrapper in stack traces. Framework code that dispatches on `__name__` routes to the wrong handler.

`functools.wraps` copies the replaced function's identity attributes onto the replacement:

```python
import functools

def log_calls(func):
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        print(f"calling {func.__name__}")
        return func(*args, **kwargs)
    return wrapper
```

This is not stylistic. Any decorator that does not carry `functools.wraps` silently breaks every tool that reads function metadata.

### The closure is the load-bearing part

The reason `wrapper` can still call `func` after `add` has been rebound to `wrapper` is that `func` was captured into `wrapper`'s closure at decoration time. Closures are implemented in CPython as a tuple of cell objects attached to the inner function. That tuple is live for the lifetime of the inner function. The original `add` is reachable through the cell; through the module namespace, it is not.

This is why the "wrapping a gift" analogy — paper around an unchanged object — fails. The original is moved out of the namespace into a cell. The decorator box is not around the original; it has *taken the original's place*, and carries the original internally.

### When to use a decorator

When the same cross-cutting behavior (timing, retry, logging, caching, authentication) applies to many functions with identical argument shapes, a decorator removes the repetition without touching the decorated function's body. When the behavior is specific to one function, inline the behavior; a decorator is overhead.

### When not to use a decorator

- When the behavior needs the caller's argument *by name* rather than `*args, **kwargs`. Decorators work argument-agnostically; anything that needs typed introspection is better as an explicit helper.
- When the decorator changes the return type in a non-obvious way. Callers of a decorated function should not be surprised by what they get back. If the behavior changes the signature, the decorated function should also change its own signature visibly.

## Cross-references

- **Prerequisites:** [[iterator-protocol]] (closures and cells appear in both contexts — iterator state is a closure pattern, and decorators lean on the same cell mechanism for captured state)
- **Related:** [[comprehensions]] (the other major place lazy evaluation and first-class-function patterns show up in Python)
- **Applications:** framework glue, instrumentation, caching layers, retry wrappers
