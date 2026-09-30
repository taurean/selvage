# Logic prototype

A tiny interactive terminal app that lets the user drive a state model by hand.
Use this when the question is about **business logic, state transitions, or data
shape** — the kind of thing that looks reasonable on paper but only feels wrong
once you push it through real cases.

## When this is the right shape

- "I'm not sure if this state machine handles the edge case where X then Y."
- "Does this data model actually let me represent the case where..."
- "I want to feel out what the API should look like before writing it."
- Anything where the user wants to **press buttons and watch state change**.

If the question is "what should this look like" — wrong branch, use
[UI.md](UI.md). If it's "what should this module's interface be" — also wrong
branch, use [INTERFACE.md](INTERFACE.md).

## Process

### 1. State the question

Before writing code, write down what state model and what question you're
prototyping. One paragraph, in the prototype's README or a comment at the top of
the file. A logic prototype that answers the wrong question is pure waste — make
the question explicit so it can be checked later, whether the user is watching
now or returning to it later.

### 2. Pick the language

Use whatever the host project uses. If the project has no obvious runtime (a
docs repo, say), ask. Match existing tooling conventions — don't add a new
package manager or runtime for a prototype.

### 3. Isolate the logic in a portable module

Put the logic — the part answering the question — behind a small, pure interface
that could be lifted out and dropped into the real codebase later. The TUI is
throwaway; the logic module shouldn't be.

The right shape depends on the question:

- **A pure reducer** — `(state, action) => state`. Good when actions are
  discrete events and state is a single value.
- **A state machine** — explicit states and transitions. Good when "which
  actions are even legal right now" is part of the question.
- **A small set of pure functions** over a plain data type. Good when there's no
  implicit current state, just transformations.
- **A class or module with a clear method surface**, when the logic genuinely
  owns ongoing internal state.

Pick whichever fits the question, _not_ whichever is easiest to wire to a TUI.
Keep it pure: no I/O, no terminal code, no `console.log` for control flow. The
TUI imports it and calls into it; nothing flows the other direction.

This is what makes the prototype useful past its own lifetime. When the question
is answered, the validated reducer, machine, or function set gets lifted into
the real module and the shell is deleted.

### 4. Build the smallest TUI that exposes the state

A **lightweight TUI**: on every tick, clear the screen (`console.clear()`,
`print("\033[2J\033[H")`, or equivalent) and re-render the whole frame. One
stable view, not an ever-growing scrollback.

Each frame has two parts, in order:

1. **Current state**, pretty-printed and diff-friendly — one field per line, or
   formatted JSON. Bold for field names and section headers, dim for less
   important context (timestamps, IDs, derived values). Native ANSI escapes are
   fine: `\x1b[1m` bold, `\x1b[2m` dim, `\x1b[0m` reset. No styling library
   unless the project already has one.
2. **Keyboard shortcuts** at the bottom:
   `[a] add user  [d] delete user  [t] tick clock  [q] quit`.

Behaviour:

1. **Initialise state** — a single in-memory object. Render the first frame on
   start.
2. **Read one keystroke or line** at a time, dispatch to a handler that mutates
   state.
3. **Re-render** the full frame after every action. Replace, don't append.
4. **Loop until quit.**

The whole frame should fit on one screen.

### 5. Make it runnable in one command

Add a script to the project's existing task runner — `package.json` scripts, a
`Makefile`, a `justfile`. The user runs `pnpm run <prototype-name>` and never
has to remember a path. If there's no task runner, put the command at the top of
the prototype's README.

### 6. Hand it over

Give the user the run command. They'll drive it themselves; the interesting
moments are "wait, that shouldn't be possible" and "huh, I assumed X would be
different." Those are bugs in the _idea_, which is the whole point. If they want
new actions, add them. Prototypes evolve.

### 7. Capture the answer

When the prototype has done its job, the answer is the only thing worth keeping.
If the user is around, ask what it taught them. If not, leave a `NOTES.md` next
to the prototype so the answer can be filled in before it gets deleted.

## Anti-patterns

- **Adding tests.** A prototype that needs tests is no longer a prototype.
- **Wiring it to the real database.** In-memory store, unless the question is
  specifically about persistence.
- **Generalising.** No "what if we wanted to support X later." The prototype
  answers one question.
- **Blurring the logic and the TUI.** If the reducer references `console.log`,
  prompts, or escape codes, it's no longer portable.
- **Shipping the TUI shell.** The shell is optimised for being driven by hand
  from a terminal. The logic module behind it is the part worth keeping.
