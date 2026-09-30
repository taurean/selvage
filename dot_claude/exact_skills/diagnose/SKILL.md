---
name: diagnose
description: Disciplined diagnosis for hard bugs and performance regressions. Build a fast deterministic feedback loop first — that is the skill — then reproduce, minimise, hypothesise, instrument, fix, regression-test. Use when the user says "diagnose this" or "debug this", reports a bug, says something is broken, throwing, or failing, or describes a performance regression.
allowed-tools: Bash(${CLAUDE_SKILL_DIR}/scripts/*)
---

# Diagnose

A discipline for hard bugs. Skip phases only when explicitly justified.

`engineering-discipline` [BUG-1] through [BUG-4] are the floor — reproduce
first, test before fix, fix the cause not the symptom, verify every affected
path. This skill is what you do when the floor isn't enough because the bug
won't reproduce cleanly, or the cause won't surface from reading.

When exploring, read `GLOSSARY.md` for the domain model of the relevant modules,
`CONTEXT.md` for constraints that would look like bugs but aren't, and any
recorded decisions in the area.

## Phase 1 — Build a feedback loop

**This is the skill.** Everything else is mechanical. With a fast,
deterministic, agent-runnable pass/fail signal for the bug, you will find the
cause — bisection, hypothesis-testing, and instrumentation all just consume that
signal. Without one, no amount of staring at code will save you.

Spend disproportionate effort here. Be aggressive, be creative, refuse to give
up.

### Ways to construct one, in roughly this order

1. **Failing test** at whatever seam reaches the bug — unit, integration, e2e.
2. **Curl or HTTP script** against a running dev server.
3. **CLI invocation** with a fixture input, diffing stdout against a known-good
   snapshot.
4. **Headless browser script** (Playwright) — drives the UI, asserts on DOM,
   console, or network.
5. **Replay a captured trace.** Save a real request, payload, or event log to
   disk; replay it through the code path in isolation.
6. **Throwaway harness.** A minimal subset of the system — one service, mocked
   deps — that exercises the bug path with a single function call.
7. **Property or fuzz loop.** For "sometimes wrong output", run 1000 random
   inputs and look for the failure mode.
8. **Bisection harness.** If the bug appeared between two known states, automate
   "boot at state X, check, repeat" so `git bisect run` can drive it.
9. **Differential loop.** Same input through two versions or two configs, diff
   the outputs.
10. **Human-in-the-loop script.** Last resort. If a human must click, drive them
    with `${CLAUDE_SKILL_DIR}/scripts/hitl-loop.template.sh` so the loop stays
    structured and the captured output feeds back to you.

Build the right feedback loop and the bug is 90% fixed.

### Iterate on the loop itself

Treat the loop as a product. Once you have _a_ loop, ask:

- Can I make it faster? Cache setup, skip unrelated init, narrow the scope.
- Can I make the signal sharper? Assert on the specific symptom, not "didn't
  crash".
- Can I make it more deterministic? Pin time, seed the RNG, isolate the
  filesystem, freeze the network.

A 30-second flaky loop is barely better than no loop. A 2-second deterministic
loop is a debugging superpower.

### Non-deterministic bugs

The goal isn't a clean repro but a **higher reproduction rate**. Loop the
trigger 100 times, parallelise, add stress, narrow timing windows, inject
sleeps. A 50% flake is debuggable; 1% is not. Keep raising the rate until it is.

### When you genuinely cannot build a loop

Stop and say so. List what you tried, then ask for one of: access to an
environment that reproduces it, a captured artifact (HAR file, log dump, core
dump, screen recording with timestamps), or permission to add temporary
production instrumentation. Adding production instrumentation is [REV-3]
territory — it ships; get explicit approval.

Do **not** proceed to hypothesise without a loop.

## Phase 2 — Reproduce

Run the loop. Watch the bug appear.

Confirm:

- [ ] The loop produces the failure mode the **user** described, not a different
      failure that happens to be nearby. Wrong bug, wrong fix.
- [ ] It reproduces across multiple runs, or at a high enough rate to debug
      against.
- [ ] You captured the exact symptom — error message, wrong output, timing — so
      later phases can verify the fix addresses it.

Then **minimise**: strip inputs, config, and participating code until removing
anything more makes the bug vanish. Everything that survives is signal;
everything you removed is one less place the cause can hide.

If the bug doesn't reproduce at all, that's [BUG-1] — say so and stop rather
than fixing what you assume it was.

## Phase 3 — Hypothesise

Generate **3 to 5 ranked hypotheses** before testing any of them. Generating one
at a time anchors you on the first plausible idea.

Each must be **falsifiable** — state the prediction it makes:

> "If X is the cause, then changing Y will make the bug disappear" / "changing Z
> will make it worse."

If you can't state the prediction, the hypothesis is a vibe. Discard or sharpen
it.

**Show the ranked list to the user before testing.** They often re-rank it
instantly ("we just deployed a change to #3") or know what's already been ruled
out. Cheap checkpoint, big saving. Keep it to the list and your ranking, per
[ASK-4] — they should be able to answer without rereading. Don't block: proceed
with your ranking if they're away.

## Phase 4 — Instrument

Each probe maps to a specific prediction from Phase 3. **Change one variable at
a time.**

Tool preference:

1. **Debugger or REPL inspection** where the environment supports it. One
   breakpoint beats ten logs.
2. **Targeted logs** at the boundaries that distinguish hypotheses.
3. Never "log everything and grep".

**Tag every debug log** with a unique prefix — `[DEBUG-a4f2]`. Cleanup becomes a
single grep. Untagged logs survive; tagged logs die.

**Performance branch.** For regressions, logs are usually the wrong instrument.
Establish a baseline measurement — timing harness, `performance.now()`, a
profiler, a query plan — then bisect. Measure first, fix second.

## Phase 5 — Fix and regression test

[BUG-2] requires the regression test to exist and be observed failing before the
fix. This phase is about where it goes.

A **correct seam** is one where the test exercises the real bug pattern as it
occurs at the call site. A seam that's too shallow — a single-caller test when
the bug needs multiple callers, a unit test that can't replicate the chain that
triggered it — gives false confidence, which is worse than no test.

**If no correct seam exists, that is the finding.** The architecture is
preventing the bug from being locked down. Surface it explicitly rather than
writing the shallow test and moving on, and carry it into Phase 6.

With a correct seam:

1. Turn the minimised repro into a failing test there.
2. Watch it fail.
3. Apply the fix.
4. Watch it pass.
5. Re-run the Phase 1 loop against the original, un-minimised scenario.

## Phase 6 — Cleanup and post-mortem

Required before declaring done:

- [ ] The original repro no longer reproduces — re-run the Phase 1 loop.
- [ ] Regression test passes, or the absent seam is documented.
- [ ] All `[DEBUG-...]` instrumentation removed. Grep the prefix.
- [ ] Throwaway harnesses deleted ([DEAD-1]).
- [ ] The hypothesis that turned out correct is stated in the commit or PR, so
      the next debugger learns.

**Then ask: what would have prevented this bug?**

- **A non-obvious constraint nobody knew about** → it belongs in `CONTEXT.md`,
  per `domain-knowledge`. Use the Symptom/Fix pattern; the next person arrives
  holding the same error.
- **Something load-bearing that isn't a declared contract** → the area's
  `Fragile` field, per [CONTRACT-1].
- **Architecture — no good test seam, tangled callers, hidden coupling** →
  recommend `/deepen` with the specifics. Make this recommendation **after** the
  fix is in, not before; you know more now than when you started.
