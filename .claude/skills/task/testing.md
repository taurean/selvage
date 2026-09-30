# Checks that earn their keep

Selvage has no test suite. It is config that becomes files under `~/`, so the
unit of verification is one observable check per user story in the brief:
named as the story, run through the seam the story's user touches, and recorded
with its command and result in the PR description. The story list is the check
list — nothing more, nothing less.

Write the check from the story's "Done when" line, never from the change you
just made. A check derived from the change inherits its misunderstandings and
passes anyway.

## Seams

Run each check through the seam the story's user actually touches:

- **A file reaches (or leaves) its target** → `chezmoi managed`,
  `chezmoi diff`, and `chezmoi cat <target>` show what apply would write. A
  target that should not deploy is absent from `chezmoi managed`.
- **Claude Code picks up a skill, command, agent, or setting** → the rendered
  file under its target path (`chezmoi cat ~/.claude/skills/<name>/SKILL.md`),
  with frontmatter that parses. A skill with `disable-model-invocation: true`
  is expected to be missing from the model's list.
- **A repo-local skill or agent (`.claude/` at the repo root)** → the file is
  absent from `chezmoi managed` and present in `.claude/`. Claude Code loads it
  only when cwd is selvage.
- **Shell, terminal, or editor behavior** → `zsh -n` for syntax, `nvim
  --headless +qa` for a clean start, `tmux -f <file> start-server \; kill-server`
  for config parse. Behavior beyond parsing (a prompt, a keybinding) is observed
  on the Mac after apply and listed as a post-merge check.

## What runs when

- **Every slice** — the check for each story the slice completes, plus
  `chezmoi managed` and `chezmoi diff` for the whole source tree. A broken
  symlink or template error fails every chezmoi command, so a clean run of
  both is the baseline.
- **Before the version bump** — `chezmoi apply --dry-run --verbose` on the
  merged state, and every post-merge check still open in the PR description.

## Red flags

- A check that reads the source file instead of what chezmoi would write
- A check that passes whether or not the change was made
- "Looks right" in place of a command and its output
- A post-merge check the human can't run in under a minute
