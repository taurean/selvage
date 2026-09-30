---
name: domain-knowledge
description: >
  Maintain a project's durable knowledge docs: CONTEXT.md (gotchas and edges
  unique to the project) and GLOSSARY.md (canonical domain terms), and route
  SYSTEMS_MAP.md work to the systems-map skill. Use when work surfaces a
  non-obvious constraint, a term is used vaguely or inconsistently, the
  project's structure shifts, or the user asks to document gotchas, define
  terms, or map the project.
---

# Domain knowledge

Capture project knowledge the moment it surfaces, in the doc it belongs to.
Read the format file for the doc you're about to touch:

- A non-obvious constraint, caveat, or decision — something a competent
  newcomer would get wrong and can't derive from the code →
  [CONTEXT-FORMAT.md](CONTEXT-FORMAT.md)
- A domain term — newly defined, disputed, or drifting →
  [GLOSSARY-FORMAT.md](GLOSSARY-FORMAT.md)
- The shape of the project — what lives where, extension points, what's
  fragile → **invoke `/systems-map`**. That skill owns `SYSTEMS_MAP.md`
  entirely: its format, its update triggers, and its rules about when *not* to
  edit. Don't write to that file from here.

## Behavior

- When a project ships its own rules for one of these docs, those rules win —
  the formats here are defaults for projects without their own.
- Update inline, as knowledge lands. Don't batch doc updates for the end of a
  session.
- When something blocks precise capture — a term used two ways, a constraint
  you can only half-state — ask one short question with a recommended answer,
  then record the resolution and move on. Never turn capture into an interview;
  `/poke-holes` exists for deliberate stress-testing.
- When the user or the code contradicts an existing entry, surface it and
  update whichever is wrong. The docs are only worth keeping if they win
  arguments.
- Create files lazily: the first real entry creates the doc. Never scaffold an
  empty doc or a placeholder section.
- Decision records are not one of these docs. Projects that record decisions
  bring their own tooling — deciduous, ADRs under `docs/adr/`, or nothing.
