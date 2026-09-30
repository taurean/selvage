---
name: systems-map
description: Creates and maintains SYSTEMS_MAP.md, a project-level document that lets a reader decide which small part of a codebase is relevant to a task without reading the rest. Use when the user invokes /systems-map, or asks to create or update the systems map.
---

# Systems map

RFC 2119 applies. MUST and MUST NOT are absolute; SHOULD and SHOULD NOT are
strong defaults; MAY is genuinely optional.

The map exists so that a reader — human or agent — can decide which small part
of the project is relevant without opening anything else. Every rule below
serves that promise. An entry that doesn't let someone make that decision has
failed, however accurate it is.

This skill is the authority for `SYSTEMS_MAP.md`. `domain-knowledge` decides
*when* project knowledge gets captured and owns `CONTEXT.md` and `GLOSSARY.md`;
for this file it defers here.

## File mechanics

- `SYSTEMS_MAP.md` MUST be a single flat markdown file at the project root.
- The file MUST open with one short paragraph stating the promise and how the
  areas are divided, followed by `## Layout` and then `## Areas`.
- `## Layout` holds a commented ASCII tree of the repo — each entry gets a
  one-phrase "what this is for" comment. Go only as deep as navigation
  requires: a directory whose contents all serve one purpose is one line. Mark
  gitignored-but-expected directories. Update the tree when files or
  directories it names move, appear, or disappear — not for changes inside
  them.
- Unlike a brief, it MUST be committed. It is project documentation, not
  per-task working context.
- It MUST NOT be split into multiple files preemptively. You MAY propose a
  split once the file is hard to browse, but MUST NOT split without explicit
  human approval.

## Modes

Pick the mode from the file's existence, not from how the request was phrased.

### Create — the file does not exist

- Survey the codebase to propose an initial set of areas before writing
  anything.
- Group by this test: _do these parts change for the same reason, or different
  ones?_ Parts that change for different reasons MUST be separate areas, even
  when they share a directory.
- **Areas are concerns, not directories.** One area MAY span several paths, and
  one path MAY serve two areas. The question each area answers is "what task
  brings you here," not "what is in this folder." An area list that mirrors the
  directory tree is usually a sign the areas weren't derived, just transcribed.
- Present the proposed breakdown to the human for confirmation before writing.
  The initial structure is more expensive to correct later than any individual
  field, so it MUST NOT be finalized unilaterally.

### Update — the file exists

- You MUST NOT edit for changes that stay inside an area's already-described
  boundary. Routine work in an established area MUST NOT trigger an edit.
- You MUST propose an edit to an area entry when, and only when, at least one
  is true:
  - the area's boundary moved;
  - a seam was added, closed, or changed;
  - something previously safe became fragile, or the reverse;
  - the area was removed or merged into another — the entry MUST then be
    removed or merged, because a stale entry describing code that no longer
    exists is worse than no entry.
- You SHOULD use the current brief's seams-and-surface section as the primary
  signal rather than re-deriving from a fresh scan. Without a brief, you MAY
  use a diff against the merge-base.
- You MUST NOT re-survey the whole codebase on any invocation. Only the
  implicated areas get re-examined.
- You MUST make the smallest diff that satisfies the triggering condition, and
  MUST NOT rewrite unrelated entries.

## Seam promotion

A seam found while building one slice belongs to that slice's brief by default.

It MUST NOT be promoted into the map unless it would matter to a second,
unrelated future task — structural to the area, not incidental to the task that
found it. When that's unclear, ask the human.

## Area entry format

```
### [Area name]
For: [one sentence, domain or experience terms]
Lives at: [entry points to start reading from]
Why this shape: [only when genuinely non-obvious]
Seams: [structural extension or swap points]
Fragile: [load-bearing things that aren't declared contracts]
```

**For** — MUST be present. One sentence, in domain or experience terms. MUST
NOT be implementation-only: naming a class or a table instead of what the area
is for tells the reader nothing about whether to keep reading.

**Lives at** — MUST be present. Entry points, not an inventory. MUST NOT
enumerate every file.

**Why this shape** — MAY be omitted. If present, it MUST describe a genuinely
non-obvious reason. When the honest answer is "it's a standard form," omit it
rather than manufacture a rationale.

**Seams** — MUST be present. If no real extension or swap points exist after
actively checking, write that. Absence of the field reads as "not yet
considered."

**Fragile** — MUST be present, and it is the field this document exists for as
much as any other. Load-bearing things that aren't declared contracts:
ordering dependencies, values duplicated across several places, assumptions one
module makes about another's internals, anything that breaks quietly when
changed.

Per [CONTRACT-2], you MUST NOT write "none found" for a check you did not
perform. An honest "none found — checked X and Y" is acceptable and useful; a
reflexive "none found" is worse than an empty field, because it reads as
answered and stops the next reader from looking.

## Validation before writing

- Each entry MUST let a reader decide whether to look further without opening
  any of its files. If it doesn't, revise it before finishing.
- An entry MUST NOT duplicate an existing one in substance. Where a proposed
  entry overlaps heavily with an existing area, ask the human whether it's
  actually the same area.

## Example entry

```
### Identity and access
For: Who a user is and what they're allowed to do, in domain terms (tenant, role, capability).
Lives at: `src/identity/index.ts`, `src/identity/policy.ts`
Seams: Capability checks funnel through `policy.evaluate()` — swap the auth provider or add a capability here.
Fragile: Session token TTL is hard-coded in three places; changing it requires all three.
```
