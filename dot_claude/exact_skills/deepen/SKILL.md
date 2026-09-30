---
name: deepen
description: >
  Find deepening opportunities in a codebase — refactors that turn shallow
  modules into deep ones, informed by the domain language in GLOSSARY.md and
  any recorded decisions. Use when the user wants to improve architecture,
  find refactoring opportunities, consolidate tightly-coupled modules, or make
  a codebase more testable and AI-navigable.
disable-model-invocation: true
---

# Deepen

Surface architectural friction and propose **deepening opportunities** —
refactors that turn shallow modules into deep ones. The aim is testability and
AI-navigability.

Every suggestion uses the vocabulary in [LANGUAGE.md](LANGUAGE.md) exactly —
**module**, **interface**, **implementation**, **depth**, **seam**, **adapter**,
**leverage**, **locality** — never "component," "service," "API," or
"boundary." Read it before writing anything. Dependency handling lives in
[DEEPENING.md](DEEPENING.md); read it before classifying any candidate.

This skill is _informed_ by the project's domain model. The domain language
gives names to good seams; recorded decisions mark territory the skill should
not re-litigate.

**Deepening is structural work.** Per [SLICE-2], a deepening never rides along
with a feature — it is its own slice, before or after, with its own PR. This
holds even when the deepening is obviously an improvement and the feature
touches the same files. If a candidate surfaces mid-task, it goes in the brief's
open questions, not into the current slice.

## Process

### 1. Explore

Read the project's `GLOSSARY.md` and any recorded decisions in the area first.

Then walk the codebase — dispatch the `Explore` agent when the surface is large
enough that reading it would fill this context, directly when it isn't. Don't
follow rigid heuristics; explore organically and note where you experience
friction:

- Where does understanding one concept require bouncing between many small
  modules?
- Where are modules **shallow** — interface nearly as complex as the
  implementation?
- Where have pure functions been extracted just for testability, but the real
  bugs hide in how they're called (no **locality**)?
- Where do tightly-coupled modules leak across their seams?
- Which parts are untested, or hard to test through their current interface?

Apply the **deletion test** to anything you suspect is shallow: would deleting
it concentrate complexity, or just move it? A "yes, concentrates" is the signal
you want.

### 2. Present candidates as an HTML report

Write a self-contained HTML file to the OS temp directory so nothing lands in
the repo. Resolve the temp dir from `$TMPDIR`, falling back to `/tmp` (or
`%TEMP%` on Windows), and write to
`<tmpdir>/architecture-review-<timestamp>.html` so each run gets a fresh file.
Open it — `open` on macOS, `xdg-open` on Linux, `start` on Windows — and tell
the user the absolute path.

Each candidate is a card carrying: files involved, the problem, the solution in
plain English, wins in terms of locality and leverage, a before/after diagram, a
recommendation-strength badge, and a dependency-category tag from
[DEEPENING.md](DEEPENING.md). End with a **Top recommendation** section. The
scaffold and diagram patterns are in [HTML-REPORT.md](HTML-REPORT.md).

**Use `GLOSSARY.md` vocabulary for the domain, and `LANGUAGE.md` vocabulary for
the architecture.** If `GLOSSARY.md` defines "Order," talk about "the Order
intake module" — not "the FooBarHandler," and not "the Order service."

**Decision conflicts:** if a candidate contradicts a recorded decision, surface
it only when the friction is real enough to warrant revisiting that decision.
Mark it clearly in the card. Don't list every theoretical refactor a past
decision forbids.

Do not propose interfaces yet. After the file is written, ask which candidate
they'd like to explore.

### 3. Design conversation

Once a candidate is picked, resolve its design per `/poke-holes`: find the
unknowns that would change the deepening if they resolved differently —
constraints, what sits behind the seam, which tests survive — and skip
everything that wouldn't. Stop when the load-bearing unknowns are resolved, and
say so.

Side effects happen inline as decisions crystallize:

- **Naming a deepened module after a concept not in `GLOSSARY.md`?** Add the
  term, per `domain-knowledge`
  ([GLOSSARY-FORMAT.md](../domain-knowledge/GLOSSARY-FORMAT.md)). Create the
  file lazily if it doesn't exist.
- **Sharpening a fuzzy term during the conversation?** Update `GLOSSARY.md`
  right there.
- **The deepening moves a seam or changes what's fragile?** That's a
  `/systems-map` update, proposed with the work.
- **User rejects the candidate with a load-bearing reason?** Offer to record it:
  _"Want me to record this so future architecture reviews don't re-suggest
  it?"_ Only when the reason would actually be needed by a future explorer —
  skip ephemeral reasons ("not worth it right now") and self-evident ones. Use
  the project's decision-record tooling.

When the deepened module's interface is the open question rather than the
deepening itself, run `/prototype` and take its interface branch — several
contrasting designs, compared on depth and seam placement, before committing.

### 4. Hand off to a task

A chosen deepening is a task, not something to start here. Run `/task` with the
deepening as the goal; the brief carries the candidate, the dependency category,
and the target interface.
