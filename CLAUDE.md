# CLAUDE.md — selvage

Facts about this repository a newcomer would get wrong without being told.

**What this repo is.** Personal chezmoi-managed dotfiles, configs, and docs.
It deploys nothing to `~/.claude`: Claude Code runs on its defaults. Not a
shipped application — no users, no tests, no CI in the conventional sense.

**Deployment model.** chezmoi's default copy mode. Every target under `~/` is a
regular file, and nothing reaches it until `chezmoi apply`. Editing selvage
changes nothing on the machine by itself.

**Docs are repo-only.** `.chezmoiignore` excludes top-level `*.md`, so
`README.md`, `CONTEXT.md`, `SYSTEMS_MAP.md`, and this file live only in the
repo, never at a home-dir target.

**Read on first work in this repo:** `CONTEXT.md` for non-obvious chezmoi
gotchas (the Symptom/Fix entries are the load-bearing ones), and
`SYSTEMS_MAP.md` for what's in the repo, where the seams are, what's fragile.

## Rules

**[S1] Edit the source, then apply.** Targets are copies. An edit made at
`~/.<path>` stays local until `chezmoi re-add ~/.<path>` copies it back into
selvage, and the next apply overwrites it (chezmoi prompts first when the target
changed since its last write). Run `chezmoi diff` before `chezmoi apply` to see
what will change.

**[S2] Source prefixes apply at every depth.** A file that should become
`.stylua.toml` inside `dot_config/nvim/` must be named `dot_stylua.toml` in the
source. Forgetting the `dot_` rename is the most common
"file not appearing at target" bug.

**[S3] Top-level `*.md` files are not deployed.** `.chezmoiignore` patterns
match target paths and `*` does not cross `/`, so `*.md` covers only the repo
root. Markdown in subdirectories deploys normally.

**[S4] `tmp/` is scratch.** Research notes, working drafts, briefs. Not
load-bearing — delete when the content migrates into `CONTEXT.md`.
Gitignored and chezmoiignored; a new scratch directory needs both.

**[S9] The `Brewfile` installs on apply, and only adds.** A
`run_onchange_before_` script runs `brew bundle install --no-upgrade` against
the source `Brewfile` whenever the file changes, before any dotfile is written.
Adding an entry installs it on the next apply. Removing one uninstalls nothing,
and apply never upgrades. The `Brewfile` itself never deploys.

**[S10] Tools write their own config at runtime.** Installers append to
`~/.zshrc`, for example. Those edits land in the target only. Before applying, check
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
- [S11] Adding `package.json` to `.chezmoiignore` in the same commit that adds
  the file.

**Bad**

- [S1] Editing `~/.zshrc` directly and expecting selvage to see it.
- [S2] Adding `.luarc.json` directly inside `dot_config/nvim/lua/` instead of
  `dot_luarc.json`.

## Commit messages

`<type>(<scope>): <subject>`, scope optional, subject present-tense imperative;
`chore(release):` is reserved for the version-bump commit.

Types (conventional-commits 1.0.0), as they apply here: `feat` (new config
area) · `fix` (broken or wrong behavior at a target)
· `chore` (maintenance, tool bumps, version bumps) · `docs` (repo-only
markdown) · `refactor` (neither fixes nor adds) · `test` · `build` (chezmoi
source layout, `Brewfile`) · `ci` · `perf` · `style` (formatting, no behavior
change).

## Releases

Selvage uses **semver**. The version lives in `package.json#version`, and it
changes when the human cuts a release, not on every branch.

- **major** — a change that needs a manual step on the machine beyond
  `chezmoi apply`: re-running `chezmoi init`, moving the checkout, a migration.
- **minor** — a new config area.
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
