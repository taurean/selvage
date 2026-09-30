---
name: engineering-discipline
description: Standing engineering rules that apply to every change in every project — fallback discipline, reversibility, slice hygiene, failure-message quality, dead-code removal, implicit contracts, and when to stop and ask. Load when writing, changing, or reviewing code.
user-invocable: false
---

# Engineering discipline

RFC 2119 applies. MUST and MUST NOT are absolute. SHOULD and SHOULD NOT are
strong defaults — departing from one requires a stated reason, in the PR or in
the conversation. MAY is genuinely optional.

Each rule has an ID. Cite it when reporting a violation: `[FALLBACK-1]`, not
"this seems defensive."

---

## Fallbacks and error handling

A fallback converts a loud failure into a quiet wrong answer. That trade is
sometimes correct and usually not. The signal you suppress is the signal you
needed.

**[FALLBACK-1]** A fallback, default, catch, retry, or guard clause MUST have a
triggering condition you can name — a specific circumstance that actually occurs
in this system. If you cannot name it, the branch is masking a defect. Remove
the branch and let the failure surface.

**[FALLBACK-2]** When you can name the condition, the handler MUST be the
correct behavior *for that condition*, not a generic continuation. `?? []` is
correct when empty is a real state; it is a defect when the data should always
be present.

**[FALLBACK-3]** A `catch` that logs and continues MUST NOT be written unless
continuing is the correct response to that specific error. Rethrow, or handle
it, or let it propagate.

**[FALLBACK-4]** A retry MUST NOT wrap a deterministic operation. Retrying a
deterministic bug produces the same failure N times and hides how it started.

**[FALLBACK-5]** A branch handling a state the type system says cannot occur
MUST NOT be added. If the state can occur, the types are wrong — fix the types.

**[FALLBACK-6]** A fallback path that no user story describes is either a
missing story or code that shouldn't exist. The story list is the test list, so
an untested defensive branch is by definition unaccounted for. Name the story or
delete the branch.

**Failing loudly is the default.** An error that stops the process is cheaper
than a wrong result that doesn't.

---

## Reversibility

Bad decisions made by an agent have lagging detection. They surface several
slices later, after other work has built on them. This is the highest-cost
failure mode in agent-assisted development, and the only defence is assessing
reversibility *before* the change, not after.

**[REV-1]** At task alignment, you MUST identify what the work touches that is
hard to undo. Hard to undo includes: schema migrations, data deletion or
transformation, public API signatures, published package versions, anything
another system already depends on, and anything with a deploy that can't be
rolled back cleanly.

**[REV-2]** Process weight MUST scale with reversibility, not with task type. A
schema migration and a copy change do not get the same care because they are
both "features."

**[REV-3]** An irreversible action MUST NOT be taken without explicit human
approval, even when it is plainly the right call and even when the human
approved the surrounding task. See [STOP-1].

**[REV-4]** Where an irreversible change can be staged into a reversible
sequence — expand then contract, add then backfill then remove — you SHOULD do
so, and say why if you don't.

---

## Slice hygiene

A slice is a thin vertical path through every layer, complete on its own. The
boundary means something only if it holds.

**[SLICE-1]** A change to observable behavior and a change to structure MUST NOT
share a commit. Refactor then change, or change then refactor. The diff shows
one at a time.

**[SLICE-2]** A slice that delivers behavior MUST NOT restructure adjacent code.
Restructuring is its own slice, before or after. This holds even when the
restructure is obviously an improvement and obviously safe — the reviewer's
ability to see what changed is the thing being protected.

**[SLICE-3]** Each slice MUST leave the application in a shippable state.

**[SLICE-4]** Opportunistic improvements found mid-slice MUST NOT be folded in.
Record them as open questions or as a follow-up; the exception is dead code the
slice itself creates — see [DEAD-1].

---

## Bugs

**[BUG-1]** A bug fix MUST begin with a reproduction. If the bug does not
reproduce, stop and report that, rather than fixing what you assume it was.

**[BUG-2]** The reproduction MUST be encoded as a failing test *before* the fix
is written, and that test MUST be observed failing. A test written after a
passing fix proves the fix exists; a test written before proves the bug did.

**[BUG-3]** The fix MUST address the cause, not the symptom. If the symptom is
easier to suppress than the cause is to fix, that is a [FALLBACK-1] violation
wearing a different hat.

**[BUG-4]** Where a bug had multiple affected paths, each MUST be verified
against the reproduction, one at a time.

---

## Failure messages

A failure message is read by whoever hits it next — a human at 6pm, or an agent
with no context. It is part of the deliverable.

**[MSG-1]** An assertion or error message MUST identify what was expected, what
happened, and enough context to locate the cause. `expected true, got false`
satisfies none of these.

**[MSG-2]** A test name MUST describe the behavior under test, not the
mechanism. The name is the story, not the call it makes.

**[MSG-3]** An error thrown by your own code SHOULD name the operation and the
input that failed, without leaking secrets or dumping whole objects.

---

## Dead code

**[DEAD-1]** Code that this change makes unreachable, unused, or obsolete MUST
be deleted in the same PR. This includes now-unused exports, branches made
unreachable, configuration for removed features, and tests for deleted
behavior.

**[DEAD-2]** Code MUST NOT be commented out. Version control holds the history.

**[DEAD-3]** A deprecation left in place MUST have a stated reason and a named
consumer still depending on it. "Someone might need it" is not a consumer.

---

## Implicit contracts

The expensive knowledge in a codebase is what's load-bearing without being
declared.

**[CONTRACT-1]** When you discover something load-bearing that isn't a declared
contract — an ordering dependency, a value hard-coded in several places, an
assumption one module makes about another's internals — you MUST record it. In
`SYSTEMS_MAP.md` under the area's `Fragile` field when it is structural to the
area; in the brief when it is incidental to this task.

**[CONTRACT-2]** You MUST NOT record "none found" for a fragility check you did
not actually perform. An honest "none found after checking X and Y" is
acceptable; a reflexive one is worse than an empty field, because it reads as
answered.

**[CONTRACT-3]** Where an implicit contract can cheaply be made explicit — a
type, an assertion, a named constant — you SHOULD do so, in its own slice per
[SLICE-2].

---

## Stopping and asking

Interrupting the human has a cost, and the cost is not the interruption — it is
approval fatigue. A human interrupted badly enough starts approving everything,
at which point every gate in this process is theater. Both halves of this
section exist to protect against that: the first bounds *when* you stop, the
second bounds *what it costs* when you do.

### When to stop

**[STOP-1]** You MUST stop and ask before any irreversible action, per
[REV-3].

**[STOP-2]** You MUST stop and ask when the work requires moving the brief's
boundary — touching a seam the brief didn't name, or something it marked out of
scope.

**[STOP-3]** You MUST stop and ask when a test fails in a way that suggests the
*story* is wrong rather than the code. Continuing here produces a passing test
around a misunderstanding, which is the exact failure the isolated test writer
exists to prevent.

**[STOP-4]** Everything else MUST be queued, not asked. Record it under
`Open questions` in the brief as it arises; surface the queue as a PR comment at
share. The rule is closed: anything not covered by STOP-1 through STOP-3
queues.

### How to ask

**[ASK-1]** A stop MUST lead with the risk and why progress halted. Not
background, not what you did so far — the reason you're in the human's attention
right now.

**[ASK-2]** A stop MUST offer a recommended default, so the reply can be one
word.

**[ASK-3]** A stop MUST contain one question. A queue of questions delivered at
once is a queue, and belongs under [STOP-4].

**[ASK-4]** A stop MUST be short enough to answer without rereading. You do the
reading; the human does the deciding. If answering requires the human to
reconstruct the situation from a long paste, the question isn't ready to ask.

**[ASK-5]** Findings reported at the end — review output, the open-questions
queue — MUST lead with whether anything blocks merge. Detail goes underneath,
for the human who wants it.

---

## Verification

**[VERIFY-1]** "The tests pass" MUST NOT be reported as verification of
behavior. Tests you wrote against code you wrote share a common ancestor;
passing proves consistency, not correctness.

**[VERIFY-2]** A change to observable behavior MUST be verified by observing
the application do the thing — running it, driving it, seeing the result. Type
checks and green suites are necessary and not sufficient.

**[VERIFY-3]** When a story's test fails against the real implementation, you
MUST reconcile against the story before changing either the test or the code.
The failure is information about which one is wrong.

---

## What this file is not

This file holds rules that hold everywhere. Project conventions — naming,
formatting, framework idiom, directory layout — live in the project's
`CLAUDE.md`. Test shape, seams, and what runs when live in the task process's
`testing.md`. When those conflict with this file, this file is the weaker claim:
a project can have a reason. Say so out loud rather than silently departing.
