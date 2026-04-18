# Chronicle Template — Frontmatter Contract Reference

This directory exists so a new chronicle can start from a known-good shape. Copy the block below, rename to `YYYY-MM-DD-session-N.md` under `chronicle/examples/` (or your project's equivalent directory), and fill in the beats.

For the full editorial contract — required/optional fields, body beats, voice conventions, quality gates — see [`../../docs/chronicle-editorial-format.md`](../../docs/chronicle-editorial-format.md).

---

## Starter block

```markdown
---
date: YYYY-MM-DD
session: N
topic: <short human topic>
title: <short title, no colon>
summary: >
  <one to three sentences describing the session arc>
bullets:
  - <bullet 1>
  - <bullet 2>
  - <bullet 3>
status: draft
prev: <relative path to previous chronicle, or "(none -- this is the beginning)">
next: (none -- next session upcoming)
loop-beats:
  analogy-failure: >
    <the sentence or moment where the opening analogy broke>
  return-line-verbal: >
    <the verbatim sentence the learner said at the close>
wiki-nodes:
  - category/slug-1
  - category/slug-2
---

# Session N: <title>

*<Month DD, YYYY. One-sentence hook.>*

---

## The Opening

<set the scene — what session is this, what question was on the table>

---

## The Work

<what was attempted; concrete code/exercise/problem>

---

## The Break

<where it stopped working; honest about the timeline>

---

## The Click

<how it resolved — the exact moment it snapped into place>

---

## Closing

<one paragraph connecting the click back to the opening scene>
```

---

## Promote to `complete`

Once the body is written and the five quality gates in `chronicle-editorial-format.md` pass, change `status: draft` to `status: complete` and update the previous chronicle's `next:` field to point at this file.
