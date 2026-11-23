---
allowed-tools: Bash, Read, Edit, Write, Glob, Grep
description: "Validate, regenerate types for, and publish AT Protocol lexicons to the lexicon.garden registry. Args: 'validate' (default), 'update' (regenerate types), 'publish' (full publish)."
argument-hint: "validate | update | publish"
---

Validate, regenerate types for, and publish this project's AT Protocol lexicons.

Action requested: "$ARGUMENTS". Blank means `validate`.

- `validate` — parse and lint only.
- `update` — validate, regenerate types, build.
- `publish` — update, then publish to lexicon.garden.

## Before anything

1. **Find the lexicons.** Look for lexicon JSON (files with `"lexicon": 1`)
   under `lexicons/` or `src/lexicons/`; otherwise search the repo. If more
   than one candidate directory exists, ask which one.
2. **Read the project's own docs.** If the project documents its lexicon
   workflow (`LEXICON_PUBLISHING.md`, a README section, `package.json`
   scripts), that wins over anything below.

## Phase 1 — Validate (always)

1. Parse each lexicon file, in parallel: `goat lex parse <file>`.
2. Lint them together: `goat lex lint <dir>/*.json` (or the recursive set if
   the lexicons are nested).
3. Fix the common lint failures:
   - Record key `"key": "self"` → `"key": "literal:self"`.
   - Unbounded string fields → add `maxLength`.
   - Missing `description` → ask the user what it should say; never invent one.
4. Re-run parse and lint until clean.

## Phase 2 — Regenerate types (`update` or `publish`)

1. Run the project's codegen script — find it in `package.json` scripts or the
   project docs. If none exists, ask; don't guess at a generator invocation.
2. **Never hand-edit the generated output.** If it doesn't build, the fix
   belongs in the project's post-generation script (or in the codegen config),
   not in the generated files. If no such script exists, stop and tell the user
   what broke and where, so they can add one.
3. Build or typecheck with the project's own command. It must pass before
   publishing.

## Phase 3 — Publish (`publish` only)

1. Check auth: `goat account status`. If not logged in, tell the user to run
   `! goat account login`.
2. Check the DNS authority record: a `_lexicon.<authority domain>` TXT record
   must exist and contain the DID from `goat account status`. The authority
   domain is the NSID's authority reversed (`com.example.foo` →
   `example.com`). If it's missing, give the user the record to add and stop.
3. **Confirm with the user before publishing.** Publishing is outward-facing.
4. `goat lex publish <dir>`.
5. Tell the user to check lexicon.garden for their namespace; each lexicon
   should show an authority badge.

## Done means

- Every lexicon parses and lints clean.
- For `update`/`publish`: types regenerated with no hand edits, and the build
  passes.
- For `publish`: the user confirmed, and the lexicons are live.
