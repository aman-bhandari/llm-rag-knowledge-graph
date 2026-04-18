# Chronicle Editorial Format

A chronicle is a long-form narrative account of a learning session. Not a transcript. Not a diary. A refined story extracted from raw material, written in third person, honest about what broke and what clicked.

This doc is the format spec. Every chronicle in `chronicle/examples/` conforms to it. A publisher (MDX pipeline, static-site generator, or just a markdown viewer) can render these files directly.

---

## When to write one

- One chronicle per meaningful session. Not per hour, not per commit — per session-as-an-arc.
- The raw material (the transcript, the IDE tabs, the scratch notes) stays private. Only the refined story publishes.
- If a session had no arc — the learner just executed a rote exercise — skip the chronicle. A chronicle without an arc becomes filler, and filler dilutes the corpus.

---

## Directory shape

```
chronicle/
  _template/
    README.md         # this contract, linked to
  examples/
    YYYY-MM-DD-session-N.md
```

Filename pattern: `YYYY-MM-DD-session-N.md`

- `YYYY-MM-DD` is the calendar date of the session being chronicled (not the date the chronicle was written).
- `N` is the chronicle sequence number. It is independent of any internal "lab session" counter. The lab may run 40 sessions and chronicle 12; chronicles are gated on arc-worthiness, not on session count.

---

## Frontmatter contract (YAML, required)

Every chronicle opens with a YAML frontmatter block enclosed by `---` fences.

### Required fields

| Field | Type | Notes |
|-------|------|-------|
| `date` | ISO 8601 date | Session date, not write date |
| `session` | integer | Chronicle sequence number (not lab session number) |
| `topic` | string | Short human topic. May reference a curriculum unit but must stand alone |
| `title` | string | Short. No colons. No subtitles |
| `summary` | string | 1-3 sentences. Used by list views and meta descriptions |
| `status` | enum | `complete`, `draft`, or `wip`. Publishers render only `complete` |
| `prev` | string | Path to previous chronicle or `(none -- this is the beginning)` |
| `next` | string | Path to next chronicle or `(none -- next session upcoming)` |

### Optional fields

| Field | Type | Notes |
|-------|------|-------|
| `bullets` | list of strings | 3-6 bullets for list views |
| `loop-beats` | object | Quality-gate audit surface, below |
| `wiki-nodes` | list of strings | Paths to supporting wiki concepts, e.g. `python/decorators` |

### `loop-beats` structure

When the session taught a concept through a learning loop (analogy → mechanism → return), capture the two beats a reader cannot fabricate:

```yaml
loop-beats:
  analogy-failure: >
    The sentence or moment where the opening analogy broke and forced
    the mental model to upgrade. Required when the session had an
    analogy-failure moment.
  return-line-verbal: >
    The verbatim sentence the learner said at the close, when a verbal
    return happened.
  return-behavioral: >
    One sentence describing a behavioral return — the learner correctly
    predicted a downstream consequence without restating the analogy.
```

At least one of `return-line-verbal` or `return-behavioral` should be present when a loop closed. Both may be present.

---

## Body structure

After the frontmatter, the body has four required beats. The prose style is up to the author; the beats are not.

### 1. The Opening

Set the scene. What session is this? What had the learner already done? What question was on the table today? This is where the reader latches onto the arc.

Not: "Session 5 covered decorators."
Yes: "She came in with a decorator that worked and did not know why. The test she had written passed, but the wrapper was silently swallowing the function's original name. For a minute she could not tell whether that was a bug."

### 2. The Work

What was attempted. What the learner tried. The concrete code / exercise / problem. It is fine to quote small code snippets inline. It is not fine to paste an entire file.

### 3. The Break

Where it stopped working, or where the learner got confused. The longer this section, the more honest the chronicle. Do not edit out the 30 minutes of wrong turns — those are the value. A chronicle whose learner never struggled reads like a sales pitch, not a record.

### 4. The Click (or the Deferral)

How it resolved. If it resolved: the exact sentence or moment where it snapped into place. If it did not resolve: the deferral — what the learner will try next session and why. A chronicle is allowed to end on a deferred question. A fake resolution is worse than an honest open loop.

---

## Voice and conventions

- **Third person, past tense.** "She wrote the test" not "I write the test". Distance makes the writing publishable.
- **Honest about the timeline.** If it took 40 minutes, say 40 minutes. If the learner retried the same mistake three times, say three times. Softening the timeline is the fastest way to make a chronicle feel fake.
- **No hype vocabulary.** The CI audit (`.github/workflows/ci.yml` → "Hype-word audit") runs a grep over every markdown file and fails the build on any hit. Replace hype words with specific operational language: what number, what threshold, what observable behavior. "3x faster than the previous implementation, measured on the benchmark in `tests/perf`" beats any adjective.
- **No named individuals unless they consented.** Use anonymised first names or role labels ("the learner", "the coach").
- **No real client names, domains, or ticket IDs.** If the session touched real client work, substitute a generic placeholder.

---

## Wiki-node back-links

When a chronicle teaches or applies a concept that has a wiki page, list it under `wiki-nodes` in the frontmatter. The publisher may render this as a sidebar "Concepts used in this session". The back-link is one-directional from the chronicle; the wiki page does not need to know about the chronicle (the graph is only bidirectional for peer-to-peer wiki links).

Path format: `category/concept-slug` — no leading slash, no `.md` suffix. Example: `python/decorators`.

---

## Quality gates (before `status: complete`)

Before flipping `status` from `draft` to `complete`:

1. **The Click gate.** Does the body actually contain a click moment or an honest deferral? If the chronicle ends flatly ("and then the session ended"), it is not done.
2. **The Fresh-Eye gate.** Read it cold the next day. Any sentence that reads as diary or aspirational — rewrite or delete.
3. **The Hype gate.** Grep for the no-hype words. Zero hits.
4. **The Identifier gate.** Grep for real individual names, real company names, real client domains. Zero hits.
5. **The Frontmatter gate.** All required fields present, `prev` and `next` resolve (or are explicitly `(none ...)`).

Once all five pass, change `status: draft` to `status: complete` and link the previous chronicle's `next` field to this file.

---

## Migration and historical compatibility

The frontmatter contract is append-only. Never remove a required field without a migration plan. If a field is added later, existing chronicles render without it — the publisher must tolerate missing optional fields and must not treat an absent optional field as invalid.

Retroactive edits to published chronicles are a last resort. The corpus is append-only; the reasoning trail is the value. If a chronicle's claim is wrong, write the correction into the next chronicle rather than silently amending the old one.
