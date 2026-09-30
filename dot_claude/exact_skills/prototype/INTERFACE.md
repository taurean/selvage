# Interface prototype

Produce several **radically different** designs for a module's interface before
committing to one. Based on Design It Twice (Ousterhout): the first idea is
unlikely to be the best.

Uses the vocabulary in
[../deepen/LANGUAGE.md](../deepen/LANGUAGE.md) — **module**, **interface**,
**seam**, **adapter**, **leverage**, **depth**. Read it first.

**This branch produces designs, not runnable code.** That stretches "throwaway
work that answers a question" further than the other two branches, and it's
worth knowing why it belongs here anyway: the pattern is identical to
[UI.md](UI.md) — several contrasting options, judged side by side, then one
picked or hybridized. The artifact differs; the method doesn't. If a design
needs to be *felt* rather than read, that's a signal to switch to
[LOGIC.md](LOGIC.md) and build the reducer.

## When this is the right shape

- A `/deepen` candidate has been chosen and the deepened module's interface is
  undecided.
- A new module is about to be written and its shape is the expensive decision.
- Two people, or two parts of a conversation, disagree about what a module
  should expose.

## Process

### 1. Frame the problem space

Before designing, write a user-facing explanation:

- The constraints any new interface must satisfy.
- The dependencies it relies on, and which category they fall into
  ([../deepen/DEEPENING.md](../deepen/DEEPENING.md)).
- A rough illustrative code sketch to make the constraints concrete — not a
  proposal, just something to argue with.

Show this, then proceed immediately to step 2. The user reads and thinks while
the designs are produced.

### 2. Produce contrasting designs

Write a technical brief first: file paths, coupling details, dependency
category, what sits behind the seam, plus the `LANGUAGE.md` and `GLOSSARY.md`
vocabulary so every design names things consistently.

Then produce three or more designs, each under a different constraint:

- **Design 1 — minimise the interface.** One to three entry points, maximum
  leverage per entry point.
- **Design 2 — maximise flexibility.** Support many use cases and extension.
- **Design 3 — optimise for the most common caller.** Make the default case
  trivial.
- **Design 4, if applicable — ports and adapters** for cross-seam dependencies.

Dispatch these in parallel, one Task per design, each carrying the brief plus
its single constraint. Separate contexts are what keep the designs genuinely
different; producing them in sequence in one context makes each a variation on
the last.

Each design specifies:

1. **Interface** — types, methods, params, plus invariants, ordering, error
   modes. Everything a caller must know, per `LANGUAGE.md`.
2. **Usage example** showing how callers use it.
3. **What the implementation hides** behind the seam.
4. **Dependency strategy and adapters.**
5. **Trade-offs** — where leverage is high, where it's thin.

### 3. Present and compare

Present the designs sequentially so each can be absorbed, then compare them in
prose. Contrast by **depth** (leverage at the interface), **locality** (where
change concentrates), and **seam placement**.

Then give your own recommendation: which is strongest and why. If elements from
different designs combine well, propose the hybrid. Be opinionated — a menu is
not a recommendation.

### 4. Capture and hand off

The chosen interface is the answer. It belongs in the brief or the plan issue's
Decisions section, with the reasoning — the rejected designs are worth a line
each, because "we considered a wider interface and chose not to" is exactly what
stops a later slice from reversing it by accident.

Then run `/task`.

## Anti-patterns

- **Designs that differ in naming rather than shape.** If all three have the
  same entry points with different words, you produced one design three times.
- **Designing the implementation.** The interface is everything a caller must
  know. What's behind it is a separate decision and mostly a later one.
- **A menu with no recommendation.** The comparison is the work; declining to
  conclude hands it back.
- **Introducing a seam for one adapter.** Per `LANGUAGE.md`, one adapter is a
  hypothetical seam. If no design has two, the seam isn't real yet.
