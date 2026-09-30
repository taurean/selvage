# Reference Standard for Source Notes

This standard tells you how to record where an idea came from. It applies to notes in Reflect. It has four parts: names, header blocks, positions, and inline references.

## Terms

- **Source note** — a note that identifies one source.
- **Reference** — a backlink to a source note, with an optional position after it.
- **Position** — short text that points to one location in a source.
- **Origin** — the person or work that made the content first.
- **Stub** — a source note that contains only a header block.
- **Header block** — the bullets at the top of a source note.

## Names for source notes

The name of a source note is the natural title of the source. Do not add a type prefix to the name. The type goes in the header block.

Examples: `Dune`, `Blade Runner`, `The Rest Is History`, `Elden Ring`.

### When two sources have the same name

Do not add a discriminator before a collision occurs. When a second source has the same title, do these steps:

1. Add a discriminator to the name of the new note.
2. Add the same class of discriminator to the name of the old note.
3. Add the bare title to each note as an alias.

Use the most stable discriminator for the medium:

- Film: the year. `Solaris (1972)`.
- Book: the surname of the author. `Solaris (Lem)`.
- Music: the name of the artist. `Low (Bowie)`.

### Which layer of a nested source gets the note

Make one note for the layer that will collect references. Layers below it are positions. Layers above it go in the header block.

- The series gets the note. The episode is a position.
- The album gets the note. The track is a position.
- The game gets the note. The quest is a position.
- The article gets the note. The periodical goes in the header block.

### Promotion

When one inner layer collects repeated references, promote it. Do these steps:

1. Make a new source note for the inner layer.
2. Add a `container` line to its header block. Link the parent note there.
3. Point new references at the new note.

Do not move old references. The parent note still holds them.

### Sources with no external identifier

Some sources exist only in memory. Examples: a conversation, a dream, a smell. Name these notes with a type word, a subject, and an ISO date.

- `Conversation with Alex (2026-07-14)`
- `Dream (2026-03-02)`
- `Tasting — Naysayer, Kenya Gatina (2026-05-11)`

Also link the note from the daily note for that date. The daily note is the second path back to the source.

## The header block

The header block is a bulleted list at the top of the source note. Write the most specific identification first. Write the `type` line last. The first 200 characters of the note show in the all-notes view. The type hashtag shows in the hashtag column. A hashtag at the top would use that space twice.

Order of lines:

```
- by: Denis Villeneuve
- year: 2021
- container: [[parent source]]
- edition: (translation, cut, remaster, or printing)
- via: [[person or post that surfaced the source]]
- locator: (URL or ISBN)
- type: #film
```

Rules for the header block:

- The `type` line is mandatory. All other lines are optional.
- Include a line only when it identifies the source or when it mattered.
- A name and a `type` line make a complete stub. A stub is a conforming note.
- Write nested facts as nested bullets.

### The name is the origin

The name of the source note always points to the origin. The person or post that surfaced the source goes on the `via` line. When the chain has more than one link, nest the bullets:

```
- via: [[blog post that quoted it]]
  - via: [[magazine interview]]
```

This rule prevents silent errors of attribution. The publisher is not the speaker. The person who linked a thing is not the person who said it.

## Types

Use one hashtag from this list on the `type` line.

| Type | Scope |
|---|---|
| #book | Books, scripture, long published text |
| #article | Articles, essays, blog posts, newsletter issues |
| #paper | Academic papers |
| #film | Films |
| #show | Television, web series |
| #podcast | Podcasts |
| #comic | Comics |
| #music | Albums, tracks, songs |
| #video | Online video, recorded talks, livestreams |
| #game | Video games, board games, tabletop sessions |
| #software | Applications, interfaces, tools |
| #post | Social posts, threads, comments, reviews, forum threads |
| #image | Photographs, artwork, diagrams, visual works |
| #object | Physical items, packaging, garments, tools, signage |
| #sensory | Fragrance, coffee, wine, food, sound of a space |
| #conversation | Conversations, meetings, chats, direct messages, overheard remarks |
| #event | Talks attended, tours, travel, a place at a time |
| #internal | Own thoughts, dreams, realizations, decisions |
| #ai | AI conversations, agent runs, generated artifacts, prompts |
| #data | Dashboards, metrics, health readings, logs, transactions |
| #document | Emails, contracts, forms, records, filings, legislation |

Rules for types:

- Use one type for each source note.
- If two types apply, use the type of the thing that gave the idea. A coffee at a tour is #sensory. The tour is #event.
- If no type applies, use the nearest type. Do not make a new type in the moment.
- To add a type, first add it to this list. Then use it.

## Positions

A position points to one location in a source. Write the most stable coordinate that lets you find the location again. Use the native units of the source.

| Source | Position form | Example |
|---|---|---|
| Text | Page of the edition in the header block | `p. 214` |
| Film, video, music | Timestamp | `1:12:40` |
| Show | Season, episode, timestamp | `S02E05 1:12:40` |
| Podcast | Episode, timestamp | `ep. 214 0:41:00` |
| Comic | Issue, page | `#38 p. 12` |
| Game | Named place or state in the words of the game | `Raya Lucaria, Comet Azur item text` |
| Post, chat | Date, and time if the day is dense | `2026-06-12` |
| Sensory | Stage, in natural language | `~3h into drydown` |
| Internal, live | Usually none | — |

Rules for positions:

- Page numbers belong to one edition. If the edition mattered, record it in the header block.
- Do not make coordinates that are independent of the edition. They cost too much time to write.
- Positions do not need one shared format across media. A position never leaves the reference that contains it.

## Inline references

Write a reference as the backlink, then the position, with a space between them. Use no other markers.

> the reveal in [[Dune (2021)]] 1:41:20 does the same withheld move as...

Rules for inline references:

- Always select the source note from autocomplete. If autocomplete shows no note, make a stub.
- Do not type a source name as plain text. Plain text drifts. Links do not.

## Notes from integrations

Some integrations make notes with their own conventions. Do these steps:

1. Do not rename the note.
2. Add your canonical name as an alias.
3. If the note collects references, add a header block above the imported content.

## Test for success

Open a reference from four years ago. You must know what the source is from the name alone. You must get back to the source, or to its record, in one step.
