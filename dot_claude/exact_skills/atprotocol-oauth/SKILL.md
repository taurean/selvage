---
name: atprotocol-oauth
description: Set up AT Protocol OAuth from scratch or repair an existing implementation. Use when starting a new AT Protocol or Bluesky app, adding Bluesky login to an existing project, or debugging broken AT Proto auth. Routes between SvelteKit browser apps (@atproto/oauth-client-browser) and server-side confidential clients (raw DPoP/PAR/JWT).
allowed-tools: Bash, Read, Edit, Write, Glob, Grep
---

You are implementing AT Protocol OAuth. Your first job is to determine which implementation path applies, then read the correct reference skill and execute it.

## Step 1: Detect context

Before asking anything, silently check:
- Does `package.json` exist? Is `@sveltejs/kit` a dependency?
- Is there an existing `src/lib/auth.ts`, `src/auth.ts`, or similar?
- Are there lexicon files (`src/lexicons/*.json` or similar)?
- Is there a `static/client-metadata.json`?

## Step 2: Ask ONE routing question

Based on what you found, ask the user a single focused question:

> "Is this a **SvelteKit browser app** (public client using `@atproto/oauth-client-browser`), or a **server-side app** (confidential client with raw DPoP/PAR/JWT)?"

If the context already makes it obvious (SvelteKit detected), skip the question and proceed — just confirm your assumption in one sentence.

## Step 3A: SvelteKit browser app

Read `references/oauth-sveltekit-browser.md` in full.

Then ask ONE more question to determine the API client path:

> "Does this app define custom AT Protocol lexicons (your own record schemas), or does it only use standard Bluesky APIs?"

- **Custom lexicons** → follow Path B (generated AtpBaseClient)
- **Bluesky APIs only** → follow Path A (Agent from @atproto/api)

Then implement everything in the skill guide:
1. Install packages
2. Configure `vite.config.ts` (127.0.0.1)
3. Create `src/lib/config.ts` with dev + prod split
4. Create `static/client-metadata.json` for production
5. Create `src/lib/auth.ts` with BrowserOAuthClient singleton
6. Create `src/lib/stores/auth.ts` with session/profile stores
7. Wire `+layout.svelte` with onMount initialization
8. Show the API client usage pattern (Agent or AtpBaseClient)

## Step 3B: Server-side confidential client

Read `references/oauth.md` in full and follow it.

## Critical rules (apply to both paths)

- Never use `transition:generic` scope in browser apps — use granular `repo:` / `rpc:` scopes
- Always bind fetchHandler: `session.fetchHandler.bind(session)`
- Always use `client.revoke(did)` for logout, not just clearing state
- Never initialize BrowserOAuthClient in a SvelteKit `load()` function — use `onMount`
- Dev server must run on 127.0.0.1, not localhost
- The `redirect_uri` type cast is expected: `as \`${string}://${string}\``

## On completion

Verify the implementation builds (`npx tsc --noEmit` or `npm run build`) and walk the user through the login flow to confirm the OAuth redirect and callback work.
