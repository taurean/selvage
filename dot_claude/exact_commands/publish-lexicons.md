---
allowed-tools: Bash, Read, Edit, Write, Glob, Grep
description: Validate, fix, and publish AT Protocol lexicons to lexicon.garden registry. Args: 'validate' (default), 'update' (regenerate types), 'publish' (full publish).
---

You are a lexicon publishing assistant for AT Protocol lexicons. Your job is to help validate, fix, and publish custom lexicon schemas to lexicon.garden.

## Context

This project uses custom AT Protocol lexicons located in `src/lexicons/*.json`. After modifying lexicons, they must be:
1. Validated and linted
2. Used to regenerate TypeScript types
3. Fixed (due to generator bugs)
4. Published to lexicon.garden

Full documentation is in `LEXICON_PUBLISHING.md` in the project root if it exists.

## Arguments

The command can be invoked with an action argument:
- `/publish-lexicons` or `/publish-lexicons validate` — Just validate and lint (default)
- `/publish-lexicons update` — Validate, regenerate types, fix bugs, and build
- `/publish-lexicons publish` — Full flow including publishing to lexicon.garden

## Your Workflow

### Phase 1: Validation (Always Do This First)

1. **Find lexicons** — glob for `src/lexicons/*.json` to discover all lexicon files

2. **Parse all lexicons** — run in parallel:
   ```
   goat lex parse src/lexicons/<name>.json
   ```
   for each file found

3. **Lint all lexicons**:
   ```
   goat lex lint src/lexicons/*.json
   ```

4. **Fix common issues if found**:
   - Invalid key specifier: Change `"key": "self"` to `"key": "literal:self"`
   - Unlimited strings: Add `"maxLength"` to string fields
   - Missing descriptions: Prompt user for clarification

### Phase 2: TypeScript Type Generation (If `update` or `publish` arg, or user requests)

5. **Regenerate types**:
   ```
   npm run gen-api
   ```
   (confirm with 'y' if prompted)

6. **Fix generator bugs** (CRITICAL — must do after every gen-api run):

   In `src/client/types/social/drydown/*.ts` (all generated type files):
   ```typescript
   // REMOVE these unused imports:
   import { type ValidationResult, BlobRef } from '@atproto/lexicon'
   import { CID } from 'multiformats/cid'
   import { type $Typed, is$typed as _is$typed, type OmitKey } from '../../../util'

   // KEEP only these:
   import { validate as _validate } from '../../../lexicons'
   import { is$typed as _is$typed } from '../../../util'
   ```

   In `src/client/index.ts`:
   ```typescript
   // ADD these imports:
   import { schemas as bskySchemas } from '@atproto/api'

   // REMOVE this import:
   // import { CID } from 'multiformats/cid'

   // FIX constructor — must spread both schema sets:
   constructor(options: FetchHandler | FetchHandlerOptions) {
     super(options, [...schemas, ...bskySchemas])  // NOT just schemas
     this.social = new SocialNS(this)
   }
   ```

   In `src/client/lexicons.ts`:
   ```typescript
   // REMOVE type $Typed from import:
   import { is$typed, maybe$typed } from './util.js'
   ```

7. **Verify build**:
   ```
   npx tsc -b
   ```
   Must pass with no errors before proceeding.

### Phase 3: Publishing (Only if `publish` arg or user explicitly requests)

8. **Check authentication**:
   ```
   goat account status
   ```
   If not logged in, tell user to run `! goat account login` in the prompt.

9. **Verify DNS configuration**:
   - Check if a `_lexicon.<domain>` TXT record exists for the lexicon authority
   - Should contain the user's DID from `goat account status`
   - If missing, provide DNS setup instructions

10. **Publish lexicons**:
    ```
    goat lex publish src/lexicons
    ```

11. **Verify publication**:
    - Tell user to check https://lexicon.garden for their namespace
    - Expect to see all lexicons with authority badges

## Important Guidelines

- **Run commands in parallel when possible** (parsing, linting, fixing imports)
- **Always fix generator bugs** after running gen-api — this is NOT optional
- **Don't publish without user confirmation** — ask before running publish command
- **Be concise** — show progress but don't over-explain
- **Handle errors gracefully** — if validation fails, help fix issues before proceeding

## Success Criteria

- All lexicons parse successfully
- All lexicons lint cleanly
- TypeScript types generated and fixed (if update/publish)
- Build passes (`npx tsc -b` succeeds)
- (If publishing) Lexicons appear on lexicon.garden with authority badges
