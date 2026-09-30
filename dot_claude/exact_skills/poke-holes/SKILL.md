---
name: poke-holes
description: Grill an idea, plan, or request until the load-bearing unknowns are resolved — one question per message, each with a recommended answer. Use when the user asks to poke holes in something, pressure-test a plan, or think a design through before building; and from the align step of a task, the interview step of a plan, and the kickoff grill.
---

# Poke holes

Find what the plan doesn't survive, before it's built.

## The contract

**One question per message.** Not a numbered list, not "a few things." One.
Several questions arrive as a form to fill in, and a form gets answered
quickly and shallowly.

**Each question carries a recommended answer**, one line, so the reply can be
"yes" or a correction. You have read the code and the context; the human has
not, or not recently. Making them generate the answer from scratch is work you
could have done.

**Short.** The question plus its recommendation should be answerable without
scrolling back. If it needs a paragraph of setup, you haven't finished thinking
about it yet.

**Stop when the load-bearing unknowns resolve.** Not when you run out of
questions — you will not run out. Exhaustive grilling costs the human's
attention, and attention spent here is attention not available at review.

## What counts as load-bearing

A question is load-bearing if a different answer produces a different plan.

Ask about:

- **Decisions that constrain everything downstream.** Data shape, the seam the
  work runs through, what owns what.
- **What's hard to undo** ([REV-1]). Migrations, public interfaces, deletions,
  anything already depended on.
- **The boundary.** What this explicitly isn't. Vague boundaries produce scope
  creep in one direction and false stops in the other.
- **Assumptions the plan rests on that nobody has checked.** "This assumes the
  existing endpoint returns X — does it?"
- **The failure the plan is trying to prevent**, when the plan is defensive.
  Often the answer reveals the failure doesn't occur ([FALLBACK-1]).

Don't ask about:

- Anything the codebase can tell you. Go read it.
- Preferences with no downstream consequence.
- Things the human already answered, phrased differently.
- Details that only matter after a decision that hasn't been made yet.

## Order

Ask the question whose answer eliminates the most other questions. A resolved
architecture question dissolves a dozen implementation questions; the reverse
never happens.

When two questions are equally load-bearing, ask the harder-to-reverse one
first.

## Pressure-testing an answer

When the human gives an answer that seems to leave a hole, say what the hole is
and let them close it. Once. If they hold the position, take it — they may know
something about the domain that isn't in the code, and relitigating is how
grilling becomes exhausting.

The exception is [REV-1]: for irreversible steps, say plainly what won't be
undoable and confirm they've heard it. Still once.

## When called from another skill

`/task` at align, `/project-plan` at interview, `/suede-kickoff` at the grill
threads. In each case the calling skill names what has to come out of the
conversation. This file governs how you ask; that list governs what you ask
about, and you're done when it's answered — not when you've stopped being
curious.

## When invoked directly

The human has something they want stress-tested. Read whatever they're pointing
at first — the code, the plan, the draft. Then find the load-bearing unknowns
yourself rather than asking them what to ask about.

End with what you'd still be uncertain about after all the answers. That
residue is the useful output: it's what the plan is betting on.
