---
name: task
description: >
  The end-to-end task process for selvage: align on the goal and how much
  review it needs, prep a worktree and brief, build in vertical slices with one
  observable check per story, verify with chezmoi, review, and land.
  User-invoked at task start.
disable-model-invocation: true
---

# Task

Align → prep → build → verify → review → land.

`engineering-discipline` is in effect from the first line of code to the last.
Its stopping rules govern every interruption in this process; don't restate
them here, follow them.

## 1. Align

Reach shared understanding through a short back-and-forth, per `/poke-holes`:
one question per message, each with a one-line recommended answer. Stop as soon
as the load-bearing unknowns are resolved.

Four things come out of this step. The first two are the human's; the second
two are yours to propose and theirs to correct.

**Goal** — a narrow, falsifiable outcome, still true a week after merge. Not a
proxy like "tests pass" or "the PR merges."

**Boundary** — what this task does not claim. Over-specify. The boundary is what
[STOP-2] protects, so a vague one means either false stops or silent scope
creep.

**Reversibility** — what the work touches that is hard to undo, per [REV-1].
State it plainly, including "nothing — this is all additive and revertible" when
that's true. This is the read that governs how much care the rest of the process
takes.

**Review posture** — when the human gets pulled back in. Propose one and say
why, from three inputs: how scoped the request is, how many decisions are still
open, and how delicate the surface is.

- Low on all three → **at the PR.** They see it once, when you think it's
  merge-ready.
- High on any one → **before committing to an approach.** You'll come back with
  the plan before building it.
- Irreversible surface → **at the irreversible step**, per [REV-3], regardless
  of the other two.

The human can move it. Moving it later costs more, which is why it's proposed
now rather than discovered mid-build.

If the goal cannot land as one PR — a rewrite, or several sizeable cuts that
could merge independently — say so and suggest `/project-plan` before any prep.

## 2. Prep

1. Fetch `origin` and create the task's worktree and branch from the latest
   `origin/main`. The branch is `<type>/<slug>` per `CLAUDE.md`; put the issue
   number in the slug when the task tracks one — the branch name is the handle
   tying this work to its tracker entry. The worktree is a sibling of the main
   checkout, named after the branch with `/` replaced by `-`:

   ```bash
   git fetch origin
   git worktree add ../<type>-<slug> -b <type>/<slug> origin/main
   ```

2. Read `SYSTEMS_MAP.md`. Use it to find the relevant area. Do not scan the
   repository; that is what the map exists to prevent.
3. Write the brief ([brief.md](brief.md)).
4. Open a draft PR titled for the task, with the brief as its body.

The draft PR exists from here on, so the work is inspectable while it happens
rather than only at the end.

## 3. Build

Build the thinnest end-to-end path first, then widen slice by slice. Each slice
cuts through every layer the story touches and leaves selvage in a state that
applies cleanly ([SLICE-3]).

**Per slice:**

1. Build the slice. One concern at a time — behavior or structure, never both
   ([SLICE-1], [SLICE-2]).
2. For each user story the slice completes, write its check from the story's
   "Done when" line, before rereading the change. Shape and seam per
   [testing.md](testing.md).
3. A slice that only plumbs toward a story adds no check. One story, one check.
4. Run the checks that apply ([testing.md](testing.md), "What runs when").
5. Delete what this slice made dead ([DEAD-1]).

**When a story check fails against the real change**, reconcile against the story
before touching either side ([VERIFY-3]). If the failure suggests the story is
wrong rather than the code, that is [STOP-3] — stop and ask.

**Bugs:** reproduce first, encode the reproduction as a failing test, observe it
fail, then fix ([BUG-1] through [BUG-4]). The reproduction goes in a PR comment
when confirmed.

**Open questions** accumulate in the brief as they arise ([STOP-4]). They are
not interruptions; they surface at land.

## 4. Verify

Run the checks in `CLAUDE.md`, "Verification before completion", from the
task's worktree. Behavior gets confirmed by observing the deployed result, not
by reading the diff ([VERIFY-1], [VERIFY-2]): the target chezmoi would write,
the skill Claude Code loads, the shell that starts.

Anything that can only be observed on the Mac after `chezmoi apply` goes in the
PR description as a post-merge check for the human.

## 5. Review

1. Run `/review` against the branch. The fixed point is the merge-base with
   `origin/main`; it won't ask.
2. Resolve everything blocking. Non-blocking findings either get fixed, or get
   added to the brief's open questions with a reason for leaving them.
3. Re-run `/review` if the fixes were substantial enough to have introduced
   something new.

## 6. Land

1. If the work moved an area boundary, changed a seam, or shifted what's
   fragile, propose the `/systems-map` update so it commits with the branch.
   The brief's seam assessment is the signal. Anything load-bearing you found
   that isn't a declared contract goes in the area's `Fragile` field
   ([CONTRACT-1]).
2. Push the branch. Update the PR body if the brief diverged during the task.
3. Comment on the PR with: whether anything blocks merge, where the human should
   focus, and the open-questions queue. Lead with the verdict ([ASK-5]).
4. Delete the worktree. Return to `main` and pull.
