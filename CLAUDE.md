# CLAUDE.md — selvage

Facts about this repository a newcomer would get wrong without being told. The
process for working on it comes from the `suede-process` plugin. The global
`~/.claude/CLAUDE.md`, also deployed from here, carries voice, identity,
boundaries, and the glossary; this file does not repeat them.

**What this repo is.** Personal chezmoi-managed dotfiles, configs, docs, and
Claude Code skills and agents. Not a shipped application — no users, no tests,
no CI in the conventional sense.

**Deployment model.** chezmoi's default copy mode. Every target under `~/` is a
regular file, and nothing reaches it until `chezmoi apply`. Editing selvage
changes nothing on the machine by itself.

**Docs are repo-only.** `.chezmoiignore` excludes top-level `*.md`, so
`README.md`, `CONTEXT.md`, `SYSTEMS_MAP.md`, and this file live only in the
repo, never at a home-dir target.

**Read on first work in this repo:** `CONTEXT.md` for non-obvious chezmoi and
agent-config gotchas (the Symptom/Fix entries are the load-bearing ones), and
`SYSTEMS_MAP.md` for what's in the repo, where the seams are, what's fragile.

## Two `.claude` directories

- `dot_claude/` deploys to `~/.claude/` and applies in every project: the global
  `CLAUDE.md`, `settings.json`, and the personal skills, commands, and agents.
- `.claude/` at the repo root is selvage's own project config, with no process
  (that is the `suede-process` plugin's). chezmoi skips dot-prefixed source
  entries, so it never deploys; Claude Code loads it only when cwd is selvage
  or a worktree of it. A skill for every project goes in
  `dot_claude/exact_skills/`; a selvage-only one in `.claude/skills/`.

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

**[S5] Skills, agents, commands, and output styles are `exact_` directories.**
On apply, chezmoi deletes anything in `~/.claude/skills`, `~/.claude/agents`,
`~/.claude/commands`, or `~/.claude/output-styles` that is not in selvage, so
removing a skill here removes it there. The survivors are what other tools
install at runtime and `.chezmoiignore` excludes: `synced/` (Claude.ai skill
sync) and `reflect-*` (the Reflect app, which rewrites them on update). A skill
dropped into `~/.claude/skills` by hand is deleted on the next apply; a
tool-installed skill gets a `.chezmoiignore` entry, not a copy in selvage.

**[S6] Personal skills shadow project skills.** Claude Code resolves name
collisions enterprise over personal over project, so a skill in selvage silently
wins over a same-named skill in any project. Never give a selvage skill a name a
project already uses. This is why `systems-map` lives here and not in suede —
one home per name, decided deliberately.

**[S7] The global `CLAUDE.md` is code.** It carries voice, identity, boundaries,
and the glossary. The voice anti-patterns are part of the agent's contract.
Don't paraphrase or "improve" them — treat changes as code, not as a personal
blog.

**[S8] Don't scope a permission override to selvage.** Selvage owns the global
permission policy, in `dot_claude/settings.json`. Selvage has no root
`.claude/settings.json`. If one is ever added, for project hooks say, it must
not carry `permissions`: rules there apply only when cwd is selvage — wrong
scope for universal policy. Per-project rules belong in the project that needs
them.

**[S9] The `Brewfile` installs on apply, and only adds.** A
`run_onchange_before_` script runs `brew bundle install --no-upgrade` against
the source `Brewfile` whenever the file changes, before any dotfile is written.
Adding an entry installs it on the next apply. Removing one uninstalls nothing,
and apply never upgrades. The `Brewfile` itself never deploys.

**[S10] Tools write their own config at runtime.** Claude Code rewrites
`~/.claude/settings.json` when preferences change in the UI; installers append
to `~/.zshrc`. Those edits land in the target only. Before applying, check
`chezmoi diff`: keep a change with `chezmoi re-add <path>` (or move it to the
right source file, e.g. a PATH line into `dot_zshrc.d/path.zsh`), or let the
apply discard it.

**[S11] Repo-only top-level files never deploy.** `package.json`,
`pnpm-lock.yaml`, and `node_modules` are in `.chezmoiignore`; without those
entries they land in `~/`. Any new top-level non-dot file that exists for the
repository, not the home directory, needs the same entry. Dot-prefixed entries
(`.claude/`, `.github/`) need none.

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
- [S11] Adding `package.json` to `.chezmoiignore` in the same commit that adds
  the file.

**Bad**

- [S1] Editing `~/.zshrc` directly and expecting selvage to see it.
- [S2] Adding `.luarc.json` directly inside `dot_config/nvim/lua/` instead of
  `dot_luarc.json`.
- [S5] Copying a vendor skill into `~/.claude/skills/` by hand. The next apply
  deletes it.
- [S8] Adding a `permissions` block to the root `.claude/settings.json` to
  scope selvage-specific rules. Wrong scope.
- [S6] A selvage-only `review` skill in `dot_claude/exact_skills/`: it shadows
  every project's own. It belongs in `.claude/skills/`.

## Commit messages

`<type>(<scope>): <subject>`, scope optional, subject present-tense imperative;
`chore(release):` is reserved for the version-bump commit.

Types (conventional-commits 1.0.0), as they apply here: `feat` (new skill,
command, agent, or config area) · `fix` (broken or wrong behavior at a target)
· `chore` (maintenance, tool bumps, version bumps) · `docs` (repo-only
markdown) · `refactor` (neither fixes nor adds) · `test` · `build` (chezmoi
source layout, `Brewfile`) · `ci` · `perf` · `style` (formatting, no behavior
change).

## Releases

Selvage uses **semver**. The version lives in `package.json#version`, and it
changes when the human cuts a release, not on every branch.

- **major** — a change that needs a manual step on the machine beyond
  `chezmoi apply`: re-running `chezmoi init`, moving the checkout, a migration.
- **minor** — a new skill, command, agent, or config area.
- **patch** — a change to something that already exists.

## Guardrails

- Never commit secrets. Machine-local values go through chezmoi data or
  1Password (`CONTEXT.md`, "Secrets").
- Never run `chezmoi apply` against the live home directory from an agent
  session. The human applies after merge.

## Verification

From the checkout or worktree holding the change:

- `chezmoi --source . managed` — runs clean, and lists no repo-only file
  (`*.md` at the root, `package.json`, `pnpm-lock.yaml`, anything under
  `.claude/` or `tmp/`).
- `chezmoi --source . diff` — runs clean and shows only the intended changes.
  A bare `chezmoi diff` in a worktree compares the main checkout instead.

Both need `chezmoi`, which a cloud session lacks; a cloud worker lists them for
the human under `## Asks` in the pull request. Anything observable only after
apply is a post-merge check for the human.
