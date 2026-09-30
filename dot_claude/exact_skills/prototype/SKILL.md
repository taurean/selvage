---
name: prototype
description: Build a throwaway prototype to flesh out a design before committing to it. Routes between three branches — a runnable terminal app for state and business-logic questions, several radically different UI variations toggleable from one route, or contrasting interface designs for a module. Use when the user wants to prototype, sanity-check a data model or state machine, mock up a UI, design a module interface, explore options, or says "prototype this", "let me play with it", "try a few designs".
---

# Prototype

A prototype is **throwaway work that answers a question**. The question decides
the shape.

Prototyping happens *before* a task, not inside one. Per [SLICE-4], prototype
code never rides along in a feature slice — the answer feeds the brief, and the
prototype is deleted. When a prototype produces a snippet that encodes a
decision more precisely than prose can (a state machine, a reducer, a schema, a
type shape), that snippet belongs in the brief or the plan issue's Decisions
section, trimmed to the decision-rich part.

## Pick a branch

Identify which question is being answered — from the prompt, the surrounding
code, or by asking if the user is around:

- **"Does this logic or state model feel right?"** → [LOGIC.md](LOGIC.md). A
  tiny interactive terminal app that pushes the state machine through cases that
  are hard to reason about on paper.
- **"What should this look like?"** → [UI.md](UI.md). Several radically
  different UI variations on a single route, switchable via a URL search param
  and a floating bottom bar.
- **"What should this module's interface be?"** → [INTERFACE.md](INTERFACE.md).
  Several contrasting interface designs, each under a different constraint,
  compared on depth and seam placement.

The branches produce very different artifacts — getting this wrong wastes the
whole prototype. If the question is genuinely ambiguous and the user isn't
reachable, default to whichever branch matches the surrounding work (a backend
module → logic; a page or component → UI; a deepening candidate → interface) and
state the assumption at the top.

## Rules for all three

1. **Throwaway from day one, and clearly marked.** Locate prototype code close
   to where it will actually be used so context is obvious — but name it so a
   casual reader sees it's a prototype, not production. Obey the project's
   existing routing and directory conventions; don't invent a new top-level
   structure.
2. **One command to run.** Whatever the project's task runner supports. The user
   must be able to start it without thinking.
3. **No persistence by default.** State lives in memory. Persistence is the
   thing a prototype *checks*, not something it depends on. If the question does
   involve a database, hit a scratch DB or a local file named "PROTOTYPE — wipe
   me".
4. **Skip the polish.** No tests, no error handling beyond what makes it
   runnable, no abstractions. Learn something fast, then delete it.
5. **Surface the state.** After every action (logic), on every variant switch
   (UI), or in every design's usage example (interface), show the full relevant
   state so the user can see what changed.
6. **Delete or absorb when done.** Fold the validated decision into the real
   work — as a task, not as an edit to the prototype — and delete the rest.

## When done

The **answer** is the only thing worth keeping. Capture it somewhere durable —
commit message, decision record, issue, or a `NOTES.md` next to the prototype —
along with the question it was answering. If the user is around, that capture is
a quick conversation; if not, leave the placeholder so it can be filled in
before the prototype is deleted.

Then run `/task` with the validated decision in hand. The prototype answered the
question; building on the answer is separate work under the normal rules.
