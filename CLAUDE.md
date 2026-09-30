# CLAUDE.md — selvage

## Scope

The whole repo. Project-level instructions for Claude Code working in selvage.

The global `~/.claude/CLAUDE.md` — also deployed from this repo — carries voice,
identity, boundaries, and the always-on glossary. This file does not duplicate
those.

## Context

**What this repo is.** Personal chezmoi-managed dotfiles, configs, docs, and
Claude Code skills and agents. Not a shipped application — no users, no tests,
no CI in the conventional sense.

**Deployment model.** chezmoi's default copy mode. Every target under `~/` is a
regular file, and nothing reaches it until `chezmoi apply`. Editing selvage
changes nothing on the machine by itself.

**Docs are repo-only.** `.chezmoiignore` excludes top-level `*.md`, so
`README.md`, `CONTEXT.md`, `SYSTEMS_MAP.md`, and this file live only in the
repo, never at a home-dir target.

**Read on first work in this repo:**

- `CONTEXT.md` — non-obvious chezmoi and agent-config gotchas. The Symptom/Fix
  entries are the load-bearing ones.
- `SYSTEMS_MAP.md` — what's in the repo, where the seams are, what's fragile.

## Rules

**[S1] Edit the source, then apply.** Targets are copies. An edit made at
`~/.<path>` stays local until `chezmoi re-add ~/.<path>` copies it back into
selvage, and the next apply overwrites it (chezmoi prompts first when the target
changed since its last write). Run `chezmoi diff` before `chezmoi apply` to see
what will change.

**[S2] Source prefixes apply at every depth.** A file that should become
`.stylua.toml` inside `dot_config/nvim/` must be named `dot_stylua.toml` in the
source. The same holds for `exact_` ([S5]). Forgetting the `dot_` rename is the
most common "file not appearing at target" bug.

**[S3] Top-level `*.md` files are not deployed.** `.chezmoiignore` patterns
match target paths and `*` does not cross `/`, so `*.md` covers only the repo
root. `dot_claude/CLAUDE.md` and every `SKILL.md` deploy normally.

**[S4] `tmp/` is scratch.** Research notes, working drafts, briefs. Not
load-bearing — delete when the content migrates into `CONTEXT.md` or a skill.
Gitignored and chezmoiignored; a new scratch directory needs both.

**[S5] Skills, agents, and commands are `exact_` directories.** On apply,
chezmoi deletes anything in `~/.claude/skills`, `~/.claude/agents`, or
`~/.claude/commands` that is not in selvage, so removing a skill here removes
it there. The survivors are what other tools install at runtime and
`.chezmoiignore` excludes: `synced/` (Claude.ai skill sync) and `reflect-*`
(the Reflect app, which rewrites them on update). A skill dropped into
`~/.claude/skills` by hand is deleted on the next apply; a tool-installed skill
gets a `.chezmoiignore` entry, not a copy in selvage.

**[S6] Personal skills shadow project skills.** Claude Code resolves name
collisions enterprise over personal over project, so a skill in selvage silently
wins over a same-named skill in any project. Never give a selvage skill a name a
project already uses. This is why `review`, `task`, and `project-plan` live in
suede and not here, and why `systems-map` lives here and not in suede — one
home per name, decided deliberately.

**[S7] The global `CLAUDE.md` is code.** It carries voice, identity, boundaries,
and the glossary. The voice anti-patterns are part of the agent's contract.
Don't paraphrase or "improve" them — treat changes as code, not as a personal
blog.

**[S8] Don't scope a permission override to selvage.** Selvage owns the global
permission policy. A project-level `.claude/settings.json` at this repo's root
would only apply when cwd is selvage — wrong scope for universal policy.
Per-project rules belong in the project that needs them.

**[S9] `Brewfile` is reference only.** Its header says manual, one-at-a-time
install; `brew bundle install` is for VM dry-runs. Adding an entry won't install
it on the live machine.

**[S10] Tools write their own config at runtime.** Claude Code rewrites
`~/.claude/settings.json` when preferences change in the UI; installers append
to `~/.zshrc`. Those edits land in the target only. Before applying, check
`chezmoi diff`: keep a change with `chezmoi re-add <path>` (or move it to the
right source file, e.g. a PATH line into `dot_zshrc.d/path.zsh`), or let the
apply discard it.

## Examples

**Good**

- [S1] Editing `dot_zshrc.d/aliases.zsh`, running `chezmoi diff`, then
  `chezmoi apply`.
- [S2] Naming a Neovim config file `dot_config/nvim/dot_stylua.toml` so the
  rename applies inside the managed directory.
- [S6] Putting `systems-map` in selvage only, after moving it out of suede,
  rather than leaving both.
- [S10] Changing the model in `/config`, then `chezmoi re-add
  ~/.claude/settings.json` to keep it.

**Bad**

- [S1] Editing `~/.zshrc` directly and expecting selvage to see it.
- [S2] Adding `.luarc.json` directly inside `dot_config/nvim/lua/` instead of
  `dot_luarc.json`.
- [S5] Copying a vendor skill into `~/.claude/skills/` by hand. The next apply
  deletes it.
- [S8] Creating a `.claude/settings.json` at the selvage root to scope
  selvage-specific permission rules. Wrong scope.
