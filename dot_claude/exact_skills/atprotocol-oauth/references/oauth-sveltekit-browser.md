# AT Protocol OAuth: SvelteKit

Implementation guide for AT Protocol OAuth in SvelteKit apps deployed to Cloudflare Pages (or any edge runtime). Uses `@atproto/oauth-client-browser` for the OAuth flow and server-side HMAC session cookies for auth state. Supports any number of users across any ATProto PDS.

---

## Architecture

```
Browser                              Server
──────────────────────────────       ─────────────────────────────
@atproto/oauth-client-browser        HMAC-SHA256 signed cookie
  - handles authorize redirect         - stores only the DID
  - stores OAuth state in IndexedDB    - created after OAuth completes
  - exchanges code for session         - no ATProto tokens server-side
  - oauth_state lives here ONLY
```

**Key implication:** No server-side table for OAuth state. No `ATPROTO_CLIENT_ID` env var. The only required env var is `SESSION_SECRET`.

---

## Install

```bash
pnpm add @atproto/oauth-client-browser
```

No other ATProto packages needed. The browser client handles DPoP, PKCE, and PAR internally.

---

## Step 1: Vite config — bind to 127.0.0.1

This is required before anything else. The ATProto loopback OAuth flow redirects to `http://127.0.0.1:PORT/auth/callback` — if Vite only listens on `localhost`, the callback 404s.

```ts
// vite.config.ts
import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vite';

export default defineConfig({
  plugins: [sveltekit()],
  server: {
    host: '127.0.0.1',
  },
});
```

Always open `http://127.0.0.1:5173` in dev — not `http://localhost:5173`.

---

## Step 2: Client metadata route

Serve the metadata from a dynamic server route instead of a static file. It derives `client_id` from `url.origin`, so the same route works in dev (`http://127.0.0.1:5173`) and production (`https://yourdomain.com`) without any env var.

```ts
// src/routes/oauth-client-metadata.json/+server.ts
import type { RequestHandler } from './$types';
import { json } from '@sveltejs/kit';

export const GET: RequestHandler = ({ url }) => {
  const origin = url.origin;
  return json(
    {
      client_id: `${origin}/oauth-client-metadata.json`,
      client_name: 'Your App',
      client_uri: origin,
      application_type: 'web',
      redirect_uris: [`${origin}/auth/callback`],
      scope: 'atproto',
      grant_types: ['authorization_code', 'refresh_token'],
      response_types: ['code'],
      token_endpoint_auth_method: 'none',
      dpop_bound_access_tokens: true,
    },
    {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Cache-Control': 'no-store',
      },
    }
  );
};
```

Adjust `scope` if needed — see scope guidance below.

---

## Step 3: OAuth client factory

Detects protocol at runtime and builds the correct client_id format for each environment.

```ts
// src/lib/auth/client.ts
import { BrowserOAuthClient } from '@atproto/oauth-client-browser';

/**
 * Call only from onMount — uses window, IndexedDB, and sessionStorage.
 * Never call from load() functions or server code.
 */
export async function createOAuthClient(): Promise<BrowserOAuthClient> {
  const { protocol, hostname, port } = window.location;

  if (protocol === 'http:') {
    // Loopback client_id: the PDS applies the loopback exemption — no metadata
    // fetch, application_type treated as 'native', loopback redirect URI allowed.
    // BrowserOAuthClient.load() calls atprotoLoopbackClientMetadata() for http: URLs.
    const portStr = port ? `:${port}` : '';
    const redirectUri = `http://127.0.0.1${portStr}/auth/callback`;
    const clientId = `http://localhost?redirect_uri=${encodeURIComponent(redirectUri)}`;
    return BrowserOAuthClient.load({
      clientId,
      handleResolver: 'https://api.bsky.app',
    });
  }

  // Production: standard discoverable client. BrowserOAuthClient.load() fetches
  // metadata from the URL and validates it.
  return BrowserOAuthClient.load({
    clientId: `${protocol}//${hostname}${port ? `:${port}` : ''}/oauth-client-metadata.json`,
    handleResolver: 'https://api.bsky.app',
    fetch: window.fetch.bind(window), // Safari: prevents "Illegal invocation"
  });
}
```

**Why `BrowserOAuthClient.load()` and not `new BrowserOAuthClient({ clientMetadata })`:**
The constructor validates `clientMetadata` inline and rejects any `client_id` that isn't HTTPS or uses an IP/localhost hostname. `load()` with an `http:` URL bypasses metadata validation entirely by using the standard loopback metadata format instead.

---

## Step 4: Session cookie module

Stores only the DID — no ATProto tokens ever touch the server.

```ts
// src/lib/server/session.ts
const COOKIE_NAME = 'session';
const COOKIE_MAX_AGE = 60 * 60 * 24 * 30; // 30 days

async function importKey(secret: string): Promise<CryptoKey> {
  const enc = new TextEncoder();
  return crypto.subtle.importKey(
    'raw', enc.encode(secret),
    { name: 'HMAC', hash: 'SHA-256' },
    false, ['sign', 'verify']
  );
}

function b64url(buf: ArrayBuffer): string {
  return btoa(String.fromCharCode(...new Uint8Array(buf)))
    .replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
}

function fromB64url(str: string): Uint8Array {
  return Uint8Array.from(atob(str.replace(/-/g, '+').replace(/_/g, '/')), c => c.charCodeAt(0));
}

export async function createSession(
  cookies: import('@sveltejs/kit').Cookies,
  did: string,
  platform: App.Platform
): Promise<void> {
  const key = await importKey(platform.env.SESSION_SECRET);
  const payload = b64url(new TextEncoder().encode(did));
  const sig = b64url(await crypto.subtle.sign('HMAC', key, new TextEncoder().encode(payload)));
  cookies.set(COOKIE_NAME, `${payload}.${sig}`, {
    path: '/',
    httpOnly: true,
    secure: true,
    sameSite: 'lax',
    maxAge: COOKIE_MAX_AGE,
  });
}

export async function getSession(
  cookies: import('@sveltejs/kit').Cookies,
  platform: App.Platform
): Promise<{ did: string } | null> {
  const value = cookies.get(COOKIE_NAME);
  if (!value) return null;
  const dot = value.lastIndexOf('.');
  if (dot === -1) return null;
  const [payload, sig] = [value.slice(0, dot), value.slice(dot + 1)];
  try {
    const key = await importKey(platform.env.SESSION_SECRET);
    const valid = await crypto.subtle.verify(
      'HMAC', key,
      fromB64url(sig), new TextEncoder().encode(payload)
    );
    if (!valid) return null;
    return { did: new TextDecoder().decode(fromB64url(payload)) };
  } catch {
    return null;
  }
}

export function destroySession(cookies: import('@sveltejs/kit').Cookies): void {
  cookies.delete(COOKIE_NAME, { path: '/' });
}
```

---

## Step 5: Using the authenticated DID

The DID is the stable, permanent identifier for an ATProto user. Handles (e.g. `you.bsky.social`) can change — DIDs never do. Always use the DID as the primary key when storing user data.

```ts
// In any +page.server.ts or +server.ts:
export const load: PageServerLoad = async ({ locals, platform }) => {
  const { did } = locals.user!; // guaranteed by auth guard
  const db = getDb(platform!);
  const items = await db.select().from(myTable).where(eq(myTable.userId, did));
  return { items };
};
```

`locals.user.did` on the server and `session.sub` in the browser (OAuthSession) are the same value.

---

## Step 6: Types

```ts
// src/app.d.ts
declare global {
  namespace App {
    interface Locals {
      user: { did: string } | null;
    }
    interface Platform {
      env: {
        DB: D1Database;        // optional — remove if not using D1
        SESSION_SECRET: string; // min 32 chars
      };
      context: { waitUntil(promise: Promise<unknown>): void };
      caches: CacheStorage & { default: Cache };
    }
  }
}
export {};
```

---

## Step 7: Server hook

```ts
// src/hooks.server.ts
import type { Handle } from '@sveltejs/kit';
import { getSession } from '$lib/server/session';

export const handle: Handle = async ({ event, resolve }) => {
  event.locals.user = await getSession(event.cookies, event.platform!);
  return resolve(event);
};
```

---

## Step 8: Auth guard

```ts
// src/routes/+layout.server.ts
import type { LayoutServerLoad } from './$types';
import { redirect } from '@sveltejs/kit';

export const load: LayoutServerLoad = ({ locals, url }) => {
  const publicPaths = ['/login', '/auth/callback'];
  if (!locals.user && !publicPaths.some(p => url.pathname.startsWith(p))) {
    redirect(302, '/login');
  }
  return { user: locals.user };
};
```

---

## Step 9: Login page

```ts
// src/routes/login/+page.server.ts
import type { PageServerLoad } from './$types';
import { redirect } from '@sveltejs/kit';

export const load: PageServerLoad = ({ locals }) => {
  if (locals.user) redirect(302, '/');
};
```

```svelte
<!-- src/routes/login/+page.svelte -->
<script lang="ts">
  import { createOAuthClient } from '$lib/auth/client';

  let handle = $state('');

  async function signIn() {
    if (!handle.trim()) return;
    const client = await createOAuthClient();
    await client.signIn(handle.trim(), { scope: 'atproto' });
  }
</script>

<form onsubmit={(e) => { e.preventDefault(); signIn(); }}>
  <input
    type="text"
    bind:value={handle}
    placeholder="you.bsky.social"
    autocomplete="username"
  />
  <button type="submit">Sign in with ATProto</button>
</form>
```

`signIn()` accepts a handle (`you.bsky.social`), a DID (`did:plc:...`), or a PDS URL. The client resolves it to the correct authorization server automatically — users from any PDS are supported.

---

## Step 10: Callback page

```svelte
<!-- src/routes/auth/callback/+page.svelte -->
<script lang="ts">
  import { onMount } from 'svelte';
  import { enhance } from '$app/forms';
  import { createOAuthClient } from '$lib/auth/client';

  let formEl: HTMLFormElement;
  let didInput: HTMLInputElement;
  let errorMessage = $state<string | null>(null);

  onMount(async () => {
    try {
      const client = await createOAuthClient();
      // readCallbackParams() reads from both ?query and #fragment — the browser
      // client defaults to responseMode: 'fragment', so params arrive in the hash.
      const params = client.readCallbackParams();
      const result = await client.initCallback(params);
      if (result?.session?.did) {
        didInput.value = result.session.did;
        formEl.requestSubmit();
      } else {
        errorMessage = 'Authentication failed: no session returned.';
      }
    } catch (e) {
      errorMessage = e instanceof Error ? e.message : 'Authentication failed.';
    }
  });
</script>

{#if errorMessage}
  <p>{errorMessage}</p>
  <a href="/login">Try again</a>
{:else}
  <p>Completing sign in…</p>
{/if}

<form bind:this={formEl} method="POST" action="?/createSession" use:enhance>
  <input bind:this={didInput} type="hidden" name="did" value="" />
</form>
```

```ts
// src/routes/auth/callback/+page.server.ts
import type { Actions } from './$types';
import { redirect, error } from '@sveltejs/kit';
import { createSession } from '$lib/server/session';

export const actions: Actions = {
  createSession: async ({ request, platform, cookies }) => {
    const did = (await request.formData()).get('did');
    if (typeof did !== 'string' || !did) error(400, 'Missing DID');
    await createSession(cookies, did, platform!);
    redirect(302, '/');
  },
};
```

---

## Scope guidance

```
atproto                                    — always required
atproto transition:generic                 — LEGACY, broad access, avoid in browser clients
repo:com.example.mycollection              — write access to a specific lexicon collection
rpc:app.bsky.actor.getProfile?aud=*        — call a specific Bluesky AppView method
```

**App that only needs identity** (no API calls): `scope: 'atproto'`

**App using Bluesky APIs**: `scope: 'atproto rpc:app.bsky.actor.getProfile?aud=* ...'`

**App with custom lexicons**: `scope: 'atproto repo:com.your.collection'`

Never use `transition:generic` in browser clients — it's a server-side legacy scope.

---

## Making authenticated API calls

After OAuth the browser client holds an `OAuthSession`. Only needed if your app calls ATProto APIs.

```ts
import { Agent } from '@atproto/api';

// fetchHandler MUST be bound — loses `this` context when passed as callback
const agent = new Agent(session.fetchHandler.bind(session));
const profile = await agent.getProfile({ actor: session.sub });
```

`session.sub` is the user's DID.

---

## Logout

```ts
// Must call revoke() — clearing the store leaves IndexedDB session active,
// which means client.init() restores it on the next page load.
const client = await createOAuthClient();
await client.revoke(session.sub);
destroySession(cookies); // server-side cookie
```

---

## Env vars

| Variable | Required | Description |
|----------|----------|-------------|
| `SESSION_SECRET` | Yes | Random string, min 32 chars. Used for HMAC cookie signing |

No `ATPROTO_CLIENT_ID` needed — `client_id` is derived from the request origin at runtime. Add project-specific vars (e.g. `DB` binding) as needed.

Use `locals.user.did` to scope all database queries to the authenticated user.

---

## Pitfalls

| Error | Root cause | Fix |
|-------|-----------|-----|
| `URL must use "https:" protocol` on `client_id` | Passing `clientMetadata` inline with an `http:` URL | Use `BrowserOAuthClient.load()`, never `new BrowserOAuthClient({ clientMetadata })` directly |
| `localhost hostname not allowed` | RFC 8252 bans `localhost` in redirect URIs | Use `127.0.0.1` in redirect URI; Vite `host: '127.0.0.1'` |
| `Loopback redirect URIs only for native apps` | Registering `http://127.0.0.1` in HTTPS metadata with `application_type: 'web'` | Never add loopback URIs to prod metadata. The loopback client_id format handles local dev separately |
| `Missing "state" parameter` after PDS redirect | `initCallback()` without args reads query string; browser client uses `#fragment` by default | Always: `readCallbackParams()` then `initCallback(params)` |
| Callback redirects to production during local dev | `client_id` is production HTTPS URL; redirect URI derives from it | Use protocol-detecting factory — `http:` → loopback client_id |
| `127.0.0.1:5173` not reachable after redirect | Vite only binds `localhost` by default | `vite.config.ts`: `server: { host: '127.0.0.1' }` |
| "Illegal invocation" in Safari | `fetch` loses `window` binding when passed as callback | `fetch: window.fetch.bind(window)` in `BrowserOAuthClient.load()` |
| Session restored after logout | Only cleared store / cookie, not IndexedDB | Call `client.revoke(did)` before clearing anything |
| `BrowserOAuthClient` fails during SSR | Library uses `window` / IndexedDB | Only call `createOAuthClient()` inside `onMount`, never in `load()` |

---

## Checklist

- [ ] `pnpm add @atproto/oauth-client-browser`
- [ ] `vite.config.ts` — `server: { host: '127.0.0.1' }`
- [ ] `src/routes/oauth-client-metadata.json/+server.ts` — dynamic route using `url.origin`
- [ ] `src/lib/auth/client.ts` — protocol-detecting factory using `BrowserOAuthClient.load()`
- [ ] `src/lib/server/session.ts` — HMAC-SHA256 cookie (stores DID only)
- [ ] `src/app.d.ts` — `Platform.env` has `SESSION_SECRET`; add `DB` binding if using D1
- [ ] `src/hooks.server.ts` — populates `locals.user`
- [ ] `src/routes/+layout.server.ts` — auth guard
- [ ] `src/routes/login/+page.server.ts` — redirects if already logged in
- [ ] `src/routes/login/+page.svelte` — handle input + form calls `client.signIn(handle)`
- [ ] `src/routes/auth/callback/+page.svelte` — `readCallbackParams()` + `initCallback(params)` + form submit
- [ ] `src/routes/auth/callback/+page.server.ts` — form action creates session cookie for any valid DID
- [ ] Env var set: `SESSION_SECRET`
- [ ] Dev: open `http://127.0.0.1:5173` not `localhost:5173`
