---
name: "reflect-notes"
description: "The complete system for how Taurean takes notes in Reflect (reflect.app) — note types, daily note structure, backlink rules, formatting, and the reference standard. Use for any task touching his notes: writing or restructuring a note; creating a reference, fragment, assertion, question, artifact, protocol or entity note; link vs plain text; recording where an idea came from; or drafting content he will paste into Reflect. Trigger on mentions of Reflect, daily notes, backlinks, assertions, references, citations, \"add this to my notes\", or any note-shaped output — even when the app is not named. Do NOT use for Mymind saves or for Obsidian (a past tool)."
---

# How Taurean takes notes

One system, one app, one owner. Notes live in Reflect: a networked note-taking
app with daily notes, `[[backlinks]]`, hashtags, note aliases, and an
outline editor where everything is a bullet. There is no field-level query
language — retrieval runs on backlinks, full-text search, and hashtags.

The purpose: a support system for where he thinks, so thoughts don't languish
forgotten and without value. It augments a Zettelkasten flow — references,
fragments, questions, assertions and artifacts feeding each other — on top of
a chronological capture layer, plus a small set of entity notes describing his
world.

Any output destined for these notes must conform to this system. When a rule
here conflicts with a general note-taking convention, this system wins.

## The tool split

- **Reflect** holds what Taurean writes: thinking, captures, entities, ideas,
  references.
- **Mymind** holds content made by others: saved articles, images, links.

Never paste external content wholesale into Reflect. Reference it (see the
reference standard) and let the content itself live in Mymind or at its
source.

**Everything he reads lives in Reflect.** He accesses notes only through the
Reflect app. Any document meant for him to review (a report, a checklist, a
set of drafts) is written as a note in the vault's `notes/` folder and linked
from today's daily note, never left as a file elsewhere. Working files that
are not notes (scripts) may live in a dot-folder Reflect does not index.

## The vault on disk

The vault is a folder of markdown files: `daily/YYYY-MM-DD.md`,
`notes/*.md`, `templates/*.md`, `assets/`. Each note file may start with
YAML frontmatter (`id`, `aliases`, `pinned`); keep it intact. The title is the
first `# ` line. Reflect often writes a non-breaking space after a field
colon (`type: #person`); treat it as a space when parsing. The vault is a git
repository: commit each logical change with a clear message so it can be
undone.

## Note shape

Every note outside the daily note has one shape: **header block, divider,
body.** The header block ends with the `type:` line; the `---` divider
follows; body content goes below it. (Older notes use `***`; both render as a
divider, but write `---`.)

What the header block holds depends on the kind. For thinking notes and
projects it is the core content — the claim, the question, the idea, the
project description. For people, cycles, trips and references it is the
structured fields. Either way the type line comes last in the header block,
because the all-notes view previews the first ~200 characters and shows
hashtags in a separate column. A hashtag at the top spends that space twice.

**Templates are the source of truth.** Every templated kind is instantiated
from its template, which lives in the vault at `templates/<kind>.md`. Read
the template before creating or converting a templated note. When anything in
this skill or the reference standard disagrees with a template, the template
wins. Current templates: agenda, amaru, article, assertion, audio, book,
concept, cycle, film, packing lists, person, project, question, text, trip,
video. Fragment, artifact and protocol have no template yet; do not invent one
(second-occurrence principle).

**Hashtags are plain `#tag` text.** Never a markdown link. Text copied from
Reflect's web app turns tags into links like
`[#person](https://reflect.app/g/.../tag/person)`; convert those back to
`#person`, and web links to notes back to `[[Title]]`.

## Tags

Most notes carry **one** type tag. Layered tags (general to specific) are used
only where the thinking flow benefits from grouping like with like: references,
and the optional form tag on artifacts.

Rule for any specific tag: **it must still mean something when met cold**, on
its own tag page, with no general tag beside it. `#film` passes; `#definition`
or `#paraphrase` would not. If a candidate second tag fails this, don't add
the layer.

## The daily note — the log

Everything enters here. No exceptions, no decisions at capture time. No type
line, no divider. Structure is three parent bullets:

```
- Log
- Tasks
- Threads
```

Log holds dated happenings and session trail. Tasks are tasks. Threads hold
undirected thinking that may develop across days.

## Entity notes — his world

Containers that describe his world rather than his thinking. They grow *by
accretion*: backlinked in passing, the incoming-backlinks panel does the work.
One tag each, no layering.

Kinds in use:

- `#person` — templated.
- `#place`
- `#project` — templated.
- `#cycle` — templated. His 2-week work cycles.
- `#trip` — templated.
- `#meeting` — **recurring meetings only.** One note for the standing meeting
  (e.g. "Team Standup"); each occurrence is a dated bullet in that day's daily
  note linking to it. Instances never get their own notes, so they never need
  titles. A bespoke meeting note exists only for a one-off that is significant
  and has an obvious name. Otherwise meeting content lives in the daily note,
  linked to the people and projects involved.
- `#protocol` — steps he follows in a given context, decided in advance so he
  doesn't have to decide in the moment (e.g. a daily journaling prompt set, or
  what to do when a flight is cancelled). Evaluated by whether it works, not
  whether it's true. An ordered sequence; branching is allowed but not
  expected.
- `#concept` — a named, defined term other notes refer to. The header holds
  the definition; the body holds a `related:` line.

Dormant: `#jira-ticket` (keep existing notes; don't create new ones unless he
works in Jira again). Not in use: `#team`, `#organization`, `#company` — don't
create new notes of these kinds; existing ones are pending his review.

Entity kinds with a template are instantiated from it — the fields are the
structure, empty values included. For a kind with no template, a name and a
type line are a complete note; add structure only as it is earned. Person-note
fields the template lacks (job title, company, known for) go in the body when
they have a value; empty ones are dropped.

**Integration labels are not entities.** Reflect and its integrations
suggest parent bullets that link to notes like `Voice note`, `Journal`,
`Links`, `Weather Report`, `Audio memos`. These are channels, not things: how
something arrived never classifies it. Write them as plain text.

## The thinking engine

Five kinds. They feed each other **in any order** — this is a web, not a
pipeline. References feed fragments, questions and assertions; assertions
open questions and questions produce assertions; an artifact can come first
(writing your way into something) with assertions extracted afterwards; and a
finished artifact can itself become a reference for later thinking.

**1. References — things.** An external thing he can point at, documented so
he can find it again. Tagged general to specific:

- `#reference`
- Media (second tag): `#video` (moving imagery and sound as one message),
  `#audio` (explicitly non-visual), `#text` (the written word)
- Form (third tag, when one applies): `#film` (short or feature; leans
  toward ~two hours), `#podcast` (audio or video), `#book` (dense text with
  its own internal organization), `#article` (article, essay, post)

Examples: `#reference #video #film`, `#reference #audio #podcast`,
`#reference #text #book`, `#reference #video` (no form fits). This supersedes
the single source-kind tag table in `references/reference-standard.md`.

The body holds his raw engagement: highlights, marginalia, course notes. A
sequential explanation (e.g. a chain of definitions that only make sense
together) stays in the body; don't shatter it into notes that can't stand
alone.

**2. Fragments — ideas taken from things.** A single idea lifted out of a
source that he wants to carry without having taken a position on it: someone
else's framework, a gotcha to recognise later, a useful distinction.

- Tagged `#fragment`, bare. No second layer (none passes the cold-read rule).
- Provenance is the line: a fragment is someone else's idea; assertions and
  questions are his own. A reference is the thing; a fragment is content from
  it.
- Split out only what **escapes its source** — an idea that would be useful in
  a context other than the one it came from. Most of a source's body won't
  qualify, and that's fine. Splitting is never forced or exhaustive.
- Rewrite in his own words. The rewriting is the comprehension check; it is
  where errors in the original notes get caught.
- Title carries the idea ("Seniority is making it accessible to others"), not
  a label ("Developer seniority").
- References back to the source with a position, same as an assertion.
- An idea from an AI conversation can be captured as a fragment with its
  origin noted, without a reference note for the conversation.

**3. Assertions — claims he produces.** One idea each, in his own words: a
position he would defend, challenge, or both. They grow *by revision*: when
understanding changes, the note is rewritten, not appended to. His own
reaction to a source skips the fragment stage and goes straight here or to a
question.

```
- The claim, stated in one bullet.
- type: #assertion

---

- references
  - [[Source]] position
```

**4. Questions — inquiries he produces.** One probing question each,
open-ended, able to branch into several lines of thought.

The title is a short, lossy form of the question. The first bullet is the
full question with the minimum context needed for it to stand on its own —
a few sentences of premise may precede the question itself. The type line
follows, then the divider. Below the divider: a `tangential questions`
parent bullet holding lower-priority questions that don't warrant their own
note, then a `references` parent bullet holding reference backlinks.

```
# Wear in software?

- We value objects that show signs of use over time. Lived-in leather feels
  softer and has its own visual appeal. Is there a parallel to this for
  software, and is that possible?
- type: #question

---

- tangential questions
  - Tangential question that doesn't warrant its own note
- references
  - [[Source]] position
  - [[Source]] position
```

The first bullet is revised when the framing sharpens. The body grows by
accretion: tangents and references are appended.

**5. Artifacts — things he composed.** Writing he made: a blog post, a
message to someone, a resume, a talk outline, a set of working principles, or
something for no one in particular.

- `#artifact` alone when the form isn't clear yet or never becomes one.
- A second tag for form is added **only once the form is clear**
  (`#artifact #post`, `#artifact #message`). He should never have to guess the
  destination at capture time; the general tag is the one he always knows.
- Artifacts can reference the assertions, fragments and references they draw
  on, and later drafts can point back to earlier ones.

## Unsettled — ask, don't invent

These are open in his design of the system. Don't create rules, types or
structure for them; ask him when a task touches them.

- Where reflections and journal entries live, and whether journals move into
  the vault.
- Resurfacing: how and when old notes come back to him. He frames this as a
  habit question (e.g. cycle cooldowns) more than an app feature.
- A process for splitting heavily annotated reference notes beyond the
  "escapes its source" test.

## Rules of flow

**The daily note is the only creation door.** New notes are born by typing
`[[New Thing]]` inside today's daily note. No entity or thinking-engine note
may exist without a link from the day it was created or worked on. When
developing an existing note, a single Log line — `Worked on [[X]]` — satisfies
the rule and builds a session trail.

**The second-occurrence principle.** A guide for when it is unclear whether
something has earned structure, not a hard rule. By default, do not build
structure, templates, or dedicated notes on first occurrence; the second
occurrence is the signal. Taurean may create structure earlier when the
need is already clear. This applies to recurring meetings, note templates,
promotion of nested layers to their own notes, and promotion of tangential
questions to their own question notes.

## The backlink gate

Linking and note creation are the same act — an unresolved backlink is the
note. So the only decision is **link vs plain text**. Run every candidate
through three tests, in order. Fail any one → plain text.

1. **Recurrence.** Will this entity plausibly appear in three or more notes
   within a year — given his actual life and work, not hypothetically?
2. **Retrieval.** Name the concrete future moment he opens this entity's
   page. "Prepping to meet Alex, want recent context" is real. "Someday I
   might want everything about Shopify" is not.
3. **Relationship.** Is there an ongoing relationship — working with,
   tracking, forming an opinion — or did it merely pass through view?

A backlink is a pre-answered future query. If the query can't be pictured,
don't place the link.

References earn their place by feeding thinking: a reference should be linked
from a fragment, question, assertion or artifact, or hold his own engagement
in its body. A reference with neither is a floating capture.

## The reference standard

How the origin of any idea gets recorded — for every source type: published
work, serialized media, games, posts, conversations, dreams, smells, data,
AI sessions, documents. The full normative text is in
`references/reference-standard.md`. **Read it before creating or editing any
source note, header block, or inline reference.** Where it conflicts with the
templates or with this skill (tags, dividers), those win. The load-bearing
points:

- A source is a note; a reference is `[[Source]] position` — backlink plus a
  short position in the source's native units. Nothing else.
- Source note names are the natural title, no type prefix. Discriminators
  only on collision: year (film), author surname (book), artist (music).
- The header block is a bulleted list at the top of a source note, ending
  with the `type` line, then a `---` divider, then the body. Field sets vary
  by source kind and follow the templates.
- **The name is the origin.** The `by` line (`director` for film) is the
  speaker or maker — never the publisher, never the person who linked it.
  Surfacers go on `found via`, or on `via` nested under `published at`, per
  the template; nest further bullets when provenance is a chain.
- Sources with no external identifier (conversations, dreams, tastings) are
  named `TypeWord + subject + (YYYY-MM-DD)` and linked from that day's daily
  note.
- One note per layer that collects references: series not episode, album not
  track. Promote an inner layer to its own note only when it collects
  repeated references (second-occurrence principle again).
- Notes created by integrations keep their titles; the canonical name is
  added as an alias.

## Formatting conventions

- **Everything is a bullet.** Reflect is an outliner. Nesting expresses
  relationship — containment, provenance chains, sub-points. Do not emit
  flat paragraphs for note content; do not use headings inside notes.
- **Never start a note with a hashtag.** The `type` line is always the last
  line of the header block, directly above the divider.
- **Dividers are `---`.**
- **Dates are ISO**: `YYYY-MM-DD`, always.
- **Units are metric**: grams, ml, km, Celsius — in every context.
- **Titles are natural**: no prefixes, no slugs, no invented naming schemes,
  and no `[[links]]` or `**bold**` inside a title (links to such notes don't
  resolve).
- **Aliases use `//` in the title.** `Canonical Title // Alias // Alias`.
  The text before the first `//` is the canonical title; each segment after
  a `//` is an alias. "Add an alias" anywhere in this system means append
  `// Alias` to the title. Do not flag `//` as a naming scheme.
- **Links are deliberate.** Sparse, gate-tested links; an over-linked graph
  is noise, and noise is the failure mode.

## Agent conduct in this system

- **Never guess metadata.** A wrong year or a publisher credited as author
  is an invisible error that outlives the session. Unknown values get the
  placeholder `(fill: description)` or stay as the template's empty field.
  A visible gap is correct; a confident guess is a defect.
- **Output note-ready bullets.** Content meant for Reflect is delivered as a
  bulleted outline he can paste, conforming to every rule above — or, when
  working on the vault directly, written as notes and linked from today's
  daily note.
- **Bracket links in generated text may not resolve.** Reflect linkifies
  `[[` at type-time. Flag that pasted links may need retyping via
  autocomplete; never claim a generated link is live.
- **Notes pasted out of Reflect lose their link brackets.** Copying strips
  `[[ ]]`, so a name in plain text may already be a live backlink. Do not
  flag plain text as unlinked or recommend linking it; ask whether it is
  linked when the answer matters.
- **Respect the gate.** Do not backlink every proper noun in generated
  content. Apply the three tests; default to plain text.
- **Don't force notes into existing types.** When something doesn't fit,
  consider whether it reveals a gap in the system before deleting, merging or
  reclassifying it. Bring it to him.
- **Do not restructure unasked.** Entity notes keep their template shape;
  assertions stay single-claim; questions stay single-question, with
  tangents and references appended below the divider; the daily note
  structure is fixed. Suggest structural changes, don't perform them.
- **Reference before content.** When producing a note derived from a source,
  the header block or inline reference comes with it — an idea without its
  origin recorded is an incomplete note in this system.