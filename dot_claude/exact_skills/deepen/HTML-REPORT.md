# HTML report format

A single self-contained HTML file in the OS temp directory. Tailwind and Mermaid
from CDNs, no other scripts, no app code.

The report exists because before/after diagrams communicate architecture in a
way prose can't, and because comparing six candidates in a chat transcript is
worse than comparing them side by side. Everything below serves those two
things. It is a throwaway artifact — don't spend effort past what the comparison
needs.

## Scaffold

```html
<!doctype html>
<html lang="en">
	<head>
		<meta charset="utf-8" />
		<title>Architecture review — {{repo name}}</title>
		<script src="https://cdn.tailwindcss.com"></script>
		<script type="module">
			import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs';
			mermaid.initialize({ startOnLoad: true, theme: 'neutral', securityLevel: 'loose' });
		</script>
		<style>
			.seam {
				stroke-dasharray: 4 4;
			}
			.leak {
				stroke: #dc2626;
			}
		</style>
	</head>
	<body class="bg-stone-50 text-slate-900 font-sans">
		<main class="max-w-5xl mx-auto px-6 py-12 space-y-12">
			<header>...</header>
			<section id="candidates" class="space-y-10">...</section>
			<section id="top-recommendation">...</section>
		</main>
	</body>
</html>
```

**Header:** repo name, date, and a compact legend — solid box is a module,
dashed line is a seam, red arrow is leakage, thick dark box is a deep module. No
introduction paragraph; straight into the candidates.

## Candidate card

One `<article>` per candidate. The diagram carries the weight; prose is sparse.

- **Title** — short, names the deepening. "Collapse the Order intake pipeline."
- **Badges** — recommendation strength (`Strong` emerald, `Worth exploring`
  amber, `Speculative` slate), plus the dependency category from
  [DEEPENING.md](DEEPENING.md): `in-process`, `local-substitutable`, `ports &
adapters`, `mock`.
- **Files** — monospaced list.
- **Before / after diagram** — two columns, side by side. The centrepiece.
- **Problem** — one sentence. What hurts.
- **Solution** — one sentence. What changes.
- **Wins** — bullets, six words or fewer. "Tests hit one interface." "Pricing
  stops leaking." "Delete four shallow wrappers."
- **Decision callout**, if the candidate contradicts a recorded decision — one
  line, amber box.

No paragraphs of explanation. If a diagram needs a paragraph to be understood,
redraw the diagram.

## Diagrams

Two patterns cover almost everything. Mix them; don't make every diagram look
the same.

**Mermaid flowchart** — for dependencies and call flow, when the point is "X
calls Y calls Z, and look at the mess." Wrap it in a bordered card so it doesn't
feel parachuted in. Use `classDef` to colour leakage edges red.

```html
<div class="rounded-lg border border-slate-200 bg-white p-4">
	<pre class="mermaid">
    flowchart LR
      A[OrderHandler] --> B[OrderValidator]
      B --> C[OrderRepo]
      C -.leak.-> D[PricingClient]
      classDef leak stroke:#dc2626,stroke-width:2px;
      class C,D leak
  </pre
	>
</div>
```

**Mass diagram** — for "interface as wide as implementation." Two rectangles per
module, one for interface surface area and one for implementation. Before: the
interface rectangle is nearly as tall as the implementation. After: interface
short, implementation tall. Hand-built divs; Mermaid won't render this with the
right weight.

Other shapes are fine when they fit — a cross-section of layers a call passes
through, a call graph collapsing into one box. Keep diagrams around 320px tall
so before and after sit side by side without scrolling.

## Top recommendation

One larger card. Candidate name, one sentence on why, anchor link to its card.

## Tone

Plain English, concise, with architectural nouns and verbs straight from
[LANGUAGE.md](LANGUAGE.md). Concision is not an excuse to drift.

**Use exactly:** module, interface, implementation, depth, deep, shallow, seam,
adapter, leverage, locality.

**Never substitute:** component, service, unit (for module) · API, signature
(for interface) · boundary (for seam) · layer, wrapper (for module).

Wins name the gain in those terms — _"locality: bugs concentrate in one
module"_, _"leverage: one interface, N call sites"_. Not _"easier to
maintain"_ or _"cleaner code"_; those aren't in the vocabulary and don't earn
their place.

No hedging, no throat-clearing. If a sentence could be a bullet, make it a
bullet. If a bullet could be cut, cut it.
