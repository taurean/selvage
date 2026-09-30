# UI prototype

Generate **several radically different UI variations** on a single route,
switchable from a floating bottom bar. The user flips between variants in the
browser, picks one (or steals bits from each), then throws the rest away.

If the question is about logic or state rather than what something looks like —
wrong branch, use [LOGIC.md](LOGIC.md).

The examples below assume SvelteKit, the house default. In another framework,
keep the pattern — one route, a `?variant=` search param, a dev-only floating
switcher — and swap the mechanics.

## When this is the right shape

- "What should this page look like?"
- "I want to see a few options for this dashboard before committing."
- "Try a different layout for the settings screen."
- Any time the user would otherwise spend a day picking between three vague
  mockups in their head.

## Authoring exception

Some projects reserve markup authoring — component markup, scoped CSS — for
humans; suede-family projects define this in `CLAUDE.md` under authoring
boundaries. Where such a boundary exists, prototype code is the explicit
exception: throwaway `.svelte` files for variants and the switcher may be
agent-authored, provided they're clearly marked as prototype and deleted or
rewritten when the prototype is done.

The exception covers prototype-marked code only. Folding a winning variant into
the real page is production markup and the boundary applies again there.

## Two sub-shapes — strongly prefer A

A UI prototype is much easier to judge when it's **butting up against the rest
of the app** — real header, real layout, real data, real density. A throwaway
route on its own is a vacuum: every variant looks fine in isolation.

### Sub-shape A — inside an existing page (preferred)

The route already exists. Variants render **on the same route**, gated by a
`?variant=` search param. The existing `load` function, params, and data all
stay; only the rendering swaps.

If the prototype is for something that doesn't have a page yet but *would
naturally live inside one* — a new dashboard section, a new card on the settings
screen, a new step in an existing flow — that's still sub-shape A. Mount the
variants inside the host page.

### Sub-shape B — a new route (last resort)

Only when the thing genuinely has no existing page to live inside: an entirely
new top-level surface, or a flow that can't be embedded anywhere sensible.

Create a throwaway route under the project's routing convention — a directory
under `src/routes/` with a `+page.svelte`, named so it's obviously a prototype
(`src/routes/prototype-settings/`, or a route group like
`src/routes/(prototype)/settings/`). Same `?variant=` pattern.

Before committing to B, sanity-check: is there really no existing page this
could be embedded in? An empty route hides design problems a populated one would
expose.

The floating bottom bar is identical in both.

## Process

### 1. State the question and pick N

Default to **3 variants**. More than 5 stops being radically different and
starts being noise — cap there.

Write the plan in one line, as a top-of-file comment in the host `+page.svelte`:

> "Three variants of the settings page, switchable via `?variant=`, on the
> existing `/settings` route."

### 2. Generate radically different variants

Draft each variant as its own component. Hold each to:

- The page's purpose and the data it has access to — the `load` function's
  return, passed in as `data`.
- The project's component library and styling system. In a stylebase project
  that means Bits UI primitives, layout utilities, and tokens per `writing-css`
  — prototype constraints relax the polish, not the token discipline. A variant
  full of hardcoded hex values tells you nothing about how it will look in the
  real design system.
- A clear component name: `VariantA.svelte`, `VariantB.svelte`,
  `VariantC.svelte`.

Variants must be **structurally different** — different layout, different
information hierarchy, different primary affordance. Not different colours.
Three slightly-tweaked card grids isn't a UI prototype, it's wallpaper. If two
drafts come out too similar, redo one with explicit "do not use a card grid"
guidance.

### 3. Wire them together

On the host route's `+page.svelte`, read the variant from the URL and render the
matching component. Keep the existing `load` data flowing to each variant.

```svelte
<script lang="ts">
	import { page } from '$app/state';
	import VariantA from './VariantA.svelte';
	import VariantB from './VariantB.svelte';
	import VariantC from './VariantC.svelte';
	import PrototypeSwitcher from '$lib/components/PrototypeSwitcher.svelte';

	let { data } = $props();

	const variants = ['A', 'B', 'C'];
	let current = $derived(page.url.searchParams.get('variant') ?? 'A');
</script>

{#if current === 'A'}
	<VariantA {...data} />
{:else if current === 'B'}
	<VariantB {...data} />
{:else if current === 'C'}
	<VariantC {...data} />
{/if}

<PrototypeSwitcher {variants} {current} />
```

For sub-shape A, keep the existing `load` untouched; only the rendered subtree
changes. For sub-shape B, the throwaway route mounts the same switcher over its
own minimal `load`.

### 4. Build the floating switcher

One shared component, `src/lib/components/PrototypeSwitcher.svelte`. A small
fixed-position bar at bottom-centre with three pieces: a left arrow that cycles
back with wraparound, a label showing the current variant key (and its name if
it has one — `B — Sidebar layout`), and a right arrow that cycles forward.

```svelte
<script lang="ts">
	import { goto } from '$app/navigation';
	import { page } from '$app/state';
	import { dev } from '$app/environment';

	let { variants, current }: { variants: string[]; current: string } = $props();

	function switchTo(variant: string) {
		const url = new URL(page.url);
		url.searchParams.set('variant', variant);
		goto(url, { replaceState: true, keepFocus: true, noScroll: true });
	}

	function cycle(direction: 1 | -1) {
		const i = variants.indexOf(current);
		const next = (i + direction + variants.length) % variants.length;
		switchTo(variants[next]);
	}

	function onKeydown(event: KeyboardEvent) {
		const el = document.activeElement;
		const typing =
			el instanceof HTMLInputElement ||
			el instanceof HTMLTextAreaElement ||
			(el instanceof HTMLElement && el.isContentEditable);
		if (typing) return;
		if (event.key === 'ArrowLeft') cycle(-1);
		if (event.key === 'ArrowRight') cycle(1);
	}
</script>

<svelte:window on:keydown={onKeydown} />

{#if dev}
	<div class="prototype-switcher">
		<button onclick={() => cycle(-1)} aria-label="Previous variant">←</button>
		<span>{current}</span>
		<button onclick={() => cycle(1)} aria-label="Next variant">→</button>
	</div>
{/if}

<style>
	.prototype-switcher {
		position: fixed;
		bottom: 1rem;
		left: 50%;
		transform: translateX(-50%);
		display: flex;
		align-items: center;
		gap: 0.75rem;
		padding: 0.5rem 0.75rem;
		border-radius: 999px;
		background: color-mix(in oklch, canvas, canvastext 12%);
		box-shadow: 0 4px 16px rgb(0 0 0 / 0.18);
		z-index: 9999;
		font: inherit;
	}
	.prototype-switcher button {
		border: 0;
		background: none;
		cursor: pointer;
		font-size: 1.1rem;
		line-height: 1;
		padding: 0.25rem 0.5rem;
	}
</style>
```

Notes:

- Switching updates the search param via `goto` with `replaceState: true`, so
  the variant is shareable and reload-stable without stacking history entries.
  `keepFocus` and `noScroll` keep the switch from disrupting the page being
  judged.
- Arrow keys cycle too. The guard ignores them when an `<input>`, `<textarea>`,
  or contenteditable element is focused.
- The whole bar is gated behind `dev`, so a stray prototype merge can't ship the
  switcher.
- The switcher is deliberately not built from the design system — a
  high-contrast pill with a shadow, obviously not part of the design being
  evaluated. This is the one place in a stylebase project where ignoring the
  tokens is correct.

### 5. Hand it over

Surface the URL and the `?variant=` keys. The interesting feedback is usually
**"I want the header from B with the sidebar from C"** — that's the actual
design they want.

### 6. Capture the answer and clean up

Once a variant wins, write down which and why — commit message, decision record,
issue, or a `NOTES.md` next to the prototype. Then:

- **Sub-shape A** — delete the losing variants, the switcher import, and its
  usage; fold the winner into the existing page as production markup. Where an
  authoring boundary exists, the exception no longer applies: hand the
  presentation work back to the human, or flag it for review.
- **Sub-shape B** — promote the winner to a real route, delete the throwaway
  route and the switcher.

Don't leave variant components or switcher usage lying around; they rot fast and
confuse the next reader. `PrototypeSwitcher.svelte` itself can stay in
`src/lib/components/` as reusable prototype infrastructure — it's inert in
production thanks to the `dev` gate — but every per-prototype variant file gets
deleted ([DEAD-1]).

## Anti-patterns

- **Variants that differ only in colour or copy.** That's a tweak. Real variants
  disagree about structure.
- **Sharing too much code between variants.** A shared child component is fine;
  a shared layout defeats the point. Each variant should be free to throw out
  the layout.
- **Wiring variants to real mutations.** Read-only is fine. If a variant needs
  to mutate, point it at a stub or a no-op — the question is what it should look
  like, not whether the backend works.
- **Promoting the prototype directly to production.** The variant code was
  written under prototype constraints — no tests, minimal error handling,
  agent-authored markup. Rewrite it properly when folding it in, back under the
  normal boundary.
