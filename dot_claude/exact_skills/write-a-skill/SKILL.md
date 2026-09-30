---
name: write-a-skill
description: >
  Create, audit, or revise Claude Code skills, subagents, and hooks. Routes an
  instruction to the right home first (model-triggered skill, user-invoked
  skill, subagent, hook, CLAUDE.md rule, or nowhere), then applies house style
  and Claude Code's actual loading mechanics. Use when creating a new skill or
  agent, cleaning up, auditing, or reworking an existing one, or deciding where
  a new instruction should live.
---

# Writing and rewriting skills

## First: does this belong in a skill?

Route before writing. The wrong home is the most common defect, and no amount
of polish fixes it.

- **The model should reach for it on its own** → skill. This is the case that
  earns a description slot in the listing every conversation carries.
- **Only the user invokes it, and it has side effects or timing that must stay
  under their control** → skill with `disable-model-invocation: true`. Kept out
  of the listing entirely; the body loads when they type `/<name>`. `/task`,
  `/project-plan`, and `/suede-kickoff` are all this shape.
- **Only the model should see it, and it isn't a meaningful thing to invoke** →
  skill with `user-invocable: false`. Background knowledge, not an action.
  `engineering-discipline` is this shape.
- **It's a job that needs its own context** — reviewing a diff without seeing
  the conversation, writing a test without seeing the implementation → a
  subagent in `.claude/agents/<name>.md`, not a skill. The isolation is the
  feature. A skill with `context: fork` is the alternative when the task is
  one-shot and the prompt *is* the skill body.
- **It must happen deterministically, whether or not the model decides to** →
  a hook. Skills are instructions the model may follow; hooks are events that
  fire. If the rule matters when the model is distracted, it isn't a skill.
- **It applies to every conversation** → a `CLAUDE.md` rule, global or project.
  Skills load on demand; identity, voice, and standing boundaries don't.
- **It should not exist** → say so. Present the argument for why a skill is the
  wrong solution to what's being proposed, and ask whether your understanding
  has gaps. A skill nobody invokes still costs its description in every
  conversation.

## Claude Code mechanics

**Location.** A skill is a directory containing `SKILL.md`. Personal:
`~/.claude/skills/<name>/`. Project: `<project>/.claude/skills/<name>/`.
Personal skills don't load in Cowork or cloud sessions; project skills
committed to the repo do.

**The command name comes from the directory**, not from frontmatter. For a
personal or project skill, `name` is only a display label in listings. Get the
directory name right; it's what the user types.

**Collisions.** Personal shadows project when names match. Never give a personal
skill a name a project already uses, or the project's version silently never
runs.

**`description` is recommended, not required** — without one, Claude uses the
first paragraph of the body, which is almost never what you want. Write one.

**Frontmatter Claude Code actually reads:** `name`, `description`,
`when_to_use`, `argument-hint`, `arguments`, `disable-model-invocation`,
`user-invocable`, `allowed-tools`, `disallowed-tools`, `model`, `effort`,
`context`, `agent`, `background`, `hooks`, `paths`, `shell`, `metadata`,
`license`, `compatibility`. Anything else is ignored.

Three worth knowing well:

- **`paths`** — glob patterns limiting when the skill auto-loads. A stack skill
  scoped to `**/*.svelte` costs nothing on a Worker task. Use it whenever a
  skill only applies to some files.
- **`allowed-tools`** — pre-approves tools for the turn that invokes the skill,
  clearing on the next message. It grants, it doesn't restrict. Note that a
  project skill's grants apply even in an untrusted folder, so review this
  field on any skill you didn't write.
- **`context: fork`** with `agent:` — runs the skill as a subagent with the body
  as its prompt. Only makes sense when the body is an actionable task.
  Guidelines without a task produce a subagent with nothing to do.

**Arguments.** `$ARGUMENTS` for everything, `$0`/`$1` by position, or named via
the `arguments` field. If a skill takes arguments but no placeholder receives
them, Claude appends them as `ARGUMENTS: <value>` at the end.

**Dynamic context.** `` !`command` `` at the start of a line runs before the
body reaches Claude, and the output replaces the placeholder. A failed command
aborts the whole invocation, so append `|| true` to anything expected to exit
non-zero.

**Lifecycle.** Once invoked, the rendered body stays in context across turns and
is not re-read. Write guidance that should hold for a whole task as standing
instruction, not as a one-time step.

**Live reload.** Edits to `SKILL.md` are picked up within the session. A new
top-level skills directory needs a restart.

**When unsure what Claude Code supports, check the docs rather than trusting
memory** — the feature set moves. `claude plugin validate .claude/skills` finds
frontmatter that doesn't parse.

## The description is the entire trigger

The model decides whether to load a skill from its description alone, sitting
alongside every other installed skill.

- First sentence: what it does. Then the triggers — the literal phrasings a task
  or user would present. Commands, file types, quoted phrases.
- Third person.
- **Put the key use case first.** Descriptions get truncated when the listing
  overflows its budget, and the truncation takes the tail.
- Every description rides in every conversation, so shorter is a shared win.
  `disable-model-invocation: true` removes it from the listing entirely — that's
  a real context saving for a skill only you invoke.
- The body must not restate when it applies. By the time it loads, the trigger
  already fired. Open with the behavior.

Run `/skill-doctor` to see which skills are costing context without ever being
invoked.

## Body house style

- Imperative prose addressed to the agent doing the work. Open with the
  behavior, not a preamble about the skill.
- Structure only when the content demands it. Headers and lists are for
  genuinely multi-branch or reference material; a skill that fits in a paragraph
  is a paragraph.
- Genuinely distinct branches get their own files, routed from `SKILL.md` and
  linked one level deep. No file links to further files.
- Keep `SKILL.md` readable in one pass. Around 100 lines is the smell; 500 is
  the documented ceiling.
- Add a script when the operation is deterministic and would otherwise be
  regenerated every invocation. Reference it with `${CLAUDE_SKILL_DIR}` so it
  resolves from any working directory, and put the same variable in
  `allowed-tools` so it runs without a prompt.
- No time-sensitive facts. Nothing derivable from the code it sits next to.
- **Cite rules rather than restating them.** When a rule lives in
  `engineering-discipline`, reference its ID. Two copies drift, and the reviewer
  agents cite IDs.
- When requirements are unclear, ask one question at a time — the single unknown
  that most changes the shape.

## Writing a subagent

`.claude/agents/<name>.md`, flat — no directory per agent. Frontmatter takes
`name`, `description`, `tools`, `model`, and more.

- **`tools` is an allowlist.** Omit it and the agent inherits everything. A
  reviewer gets `Read, Grep, Glob`; something that must not write gets no
  `Write` or `Edit`. Narrow it deliberately.
- **The agent carries its own brief.** The dispatching skill passes inputs only.
  If the skill has to explain the job in its delegation message, the job belongs
  in the agent file.
- **State the output shape.** The parent receives whatever the agent returns, so
  say what a report looks like and how long it should be.
- **One job, one definition of done.** An agent with two jobs will do the easier
  one well.
- `model: inherit` unless there's a reason to pin.

## Audit checklist

For each existing skill or agent, in order:

- [ ] Right home? Better as a subagent, a hook, a `CLAUDE.md` rule, or gone?
- [ ] Description states the capability plus concrete triggers, third person,
      key use case first?
- [ ] Body opens with behavior and never restates its own trigger conditions?
- [ ] No frontmatter Claude Code ignores, and no invented fields?
- [ ] `paths` set, if it only applies to some files?
- [ ] `disable-model-invocation` set, if only the user should invoke it?
- [ ] No internal contradictions or stale thresholds, paths, versions?
- [ ] Bundled files referenced from `SKILL.md`, one level deep, all
      load-bearing?
- [ ] Cross-skill links resolve? They're load-bearing paths — recheck whenever
      anything is moved or renamed.
- [ ] Directory name correct, and not colliding with a project skill it would
      silently shadow?
- [ ] Rules cited rather than duplicated from `engineering-discipline` or
      `CLAUDE.md`?
