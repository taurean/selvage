# Deepening

How to deepen a cluster of shallow modules safely, given its dependencies.
Assumes the vocabulary in [LANGUAGE.md](LANGUAGE.md) — **module**,
**interface**, **seam**, **adapter**.

## Dependency categories

When assessing a candidate, classify its dependencies. The category determines
how the deepened module is tested across its seam.

### 1. In-process

Pure computation, in-memory state, no I/O. Always deepenable — merge the modules
and test through the new interface directly. No adapter needed.

### 2. Local-substitutable

Dependencies with local test stand-ins (PGLite for Postgres, an in-memory
filesystem, Miniflare for Workers bindings). Deepenable if the stand-in exists.
The deepened module is tested with the stand-in running in the suite. The seam
is internal; no port at the module's external interface.

### 3. Remote but owned — ports and adapters

Your own services across a network boundary. Define a **port** at the seam. The
deep module owns the logic; the transport is injected as an **adapter**. Tests
use an in-memory adapter; production uses HTTP, gRPC, or a queue.

Recommendation shape: _"Define a port at the seam, implement an HTTP adapter for
production and an in-memory adapter for testing, so the logic sits in one deep
module even though it's deployed across a network."_

### 4. True external — mock

Third-party services you don't control. The deepened module takes the external
dependency as an injected port; tests provide a mock adapter.

## Seam discipline

- **One adapter means a hypothetical seam. Two adapters means a real one.**
  Don't introduce a port unless at least two adapters are justified — typically
  production plus test. A single-adapter seam is indirection wearing a seam's
  clothes.
- **Internal seams are not external seams.** A deep module can have internal
  seams, private to its implementation and used by its own tests, as well as the
  external seam at its interface. Don't expose an internal seam through the
  interface just because a test uses it.

## Testing the deepened module

Test shape, seams, and pruning are owned by the task process's `testing.md` —
don't restate them here. Two things specific to deepening:

- **The old unit tests on the shallow modules become waste** once tests exist at
  the deepened interface. Delete them in the same commit that flags them, per
  the prune pass and [DEAD-1]. Where a shallow module's test covered a story the
  new interface tests don't, replace at the story's seam rather than keeping the
  old test.
- **The interface is the test surface.** If a surviving test has to reach past
  the new interface to assert what it needs, the deepening put the seam in the
  wrong place. That's design feedback, not a testing problem.
