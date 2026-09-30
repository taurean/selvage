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

**A suede project.** Selvage runs suede's process layer: the pipeline, git
workflow, releases, and decision graph below, and the in-repo skills and agents
under `.claude/`. It takes none of suede's runtime stack. `package.json` holds
the version and `"suede": { "from": "<tag>", "versioning": "semver" }`, which is
also what lets `suede task`, `suede done`, and `suede release` find the project.

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

## Two `.claude` directories

- `dot_claude/` deploys to `~/.claude/` and applies in every project: the global
  `CLAUDE.md`, `settings.json`, and the personal skills, commands, and agents.
- `.claude/` at the repo root is selvage's own project config. chezmoi skips
  dot-prefixed source entries, so it never deploys; Claude Code loads it only
  when cwd is selvage or one of its worktrees. It holds the in-repo process
  skills (`task`, `project-plan`, `review`), the reviewer agents
  (`standards-reviewer`, `spec-reviewer`, `discipline-reviewer`), and what
  `deciduous` writes.

A skill that serves every project goes in `dot_claude/exact_skills/`. A skill
that serves only work on selvage goes in `.claude/skills/`.

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
permission policy, in `dot_claude/settings.json`. The root
`.claude/settings.json` exists for the hooks `deciduous` registers and must not
carry `permissions`: rules there apply only when cwd is selvage — wrong scope
for universal policy. Per-project rules belong in the project that needs them.

**[S9] `Brewfile` is reference only.** Its header says manual, one-at-a-time
install; `brew bundle install` is for VM dry-runs. Adding an entry won't install
it on the live machine.

**[S11] Suede project files never deploy.** `package.json`, `pnpm-lock.yaml`,
and `node_modules` are in `.chezmoiignore`; without those entries they land in
`~/`. Any new top-level non-dot file that exists for the process layer, not the
home directory, needs the same entry. Dot-prefixed entries (`.claude/`,
`.deciduous/`, `.github/`) need none.

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
- [S6] Putting the `review` skill in `dot_claude/exact_skills/`. It is a
  selvage process skill, belongs in `.claude/skills/`, and as a personal skill
  would shadow every suede project's own `review`.

## Git workflow

From suede. The mechanics match every suede project.

- Always branch from the **latest** `main`: fetch `origin`, base on
  `origin/main`, and verify the tree is clean.
- **Never branch off an in-flight branch.** While a PR is open, new work either
  becomes a follow-up commit on the _same_ branch or waits.
- All tasks are reviewed in a pull request.
- **The agent may push branches and apply tags, but never merges to `main` and
  never pushes directly to `main`.** The human reviews and merges.
- The human is the commit author for all commits. Agent-made commits add a
  `Co-authored-by:` trailer crediting the harness.

Task worktrees sit beside the checkout (`suede task <type>/<slug>`, or
`git worktree add ../<type>-<slug> -b <type>/<slug> origin/main`). chezmoi's
`sourceDir` points at the main checkout only, so run chezmoi from a worktree
with `--source .`; a bare `chezmoi diff` there compares `main`, not the branch.

### Branch and commit naming

Branch names are `<type>/<slug>`, `<slug>` short kebab-case. Commit messages are
`<type>(<scope>): <subject>`, scope optional, subject present-tense imperative.
`chore(release):` is reserved for the version-bump commit.

Types (conventional-commits 1.0.0): `feat` (new skill, command, agent, or config
area) · `fix` (broken or wrong behavior at a target) · `chore` (maintenance,
tool bumps, version bumps) · `docs` (repo-only markdown) · `refactor` (neither
fixes nor adds) · `test` · `build` (chezmoi source layout, `Brewfile`) · `ci` ·
`perf` · `style` (formatting, no behavior change).

## Process pipeline

The process is suede's; the details below are selvage's. If a stage doesn't fit
a task, compress it but keep the shape.

| Stage                                                             | Home               | When                                                             |
| ----------------------------------------------------------------- | ------------------ | ---------------------------------------------------------------- |
| 1. **Concept** — in conversation, an issue, or a bug report       | —                  | Always                                                           |
| 2. **Align** on goal, boundary, reversibility, and review posture | `/task` step 1     | Every task, per `/poke-holes`                                    |
| 3. **Cut plan**                                                   | `/project-plan`    | Only when the work cannot land as one PR. One plan issue         |
| 4. **Build**                                                      | `/task`            | Every task: worktree, systems map, brief, draft PR, then slices  |
| 5. **Verify**                                                     | `/task` step 4     | Every task. What chezmoi would write, not what the diff says     |
| 6. **Review**                                                     | `/review`          | Standards, Spec, Discipline in parallel subagents, before merge  |
| 7. **Release**                                                    | "Releases" below   | Version bump as the final commit; human tags the merge commit    |

Always on: `engineering-discipline` (personal skill, cited by rule ID in
reviews), the decision graph, and the git workflow above.

**Tracker.** GitHub Issues on `taurean/selvage`. `/project-plan` publishes the
plan issue there and `/review` reads specs from PR bodies and issues.

## Working style

In-repo skills (`.claude/skills/`), all user-invoked:

- `task` — the task spine. `brief.md` owns the brief format; `testing.md` owns
  what counts as a check in a repo with no test suite.
- `project-plan` — cut plan for work too big for one PR.
- `review` — three-axis review, dispatching to the reviewer agents in
  `.claude/agents/`.

Suede's `design`, `writing-css`, `suede-kickoff`, and `story-test-writer` are
not carried: selvage has no UI, and `/task` writes each story's check itself.

`engineering-discipline`, `poke-holes`, and `systems-map` are personal skills
that live in `dot_claude/exact_skills/` and reach this repo through
`~/.claude/skills/` like any other project.

## Releases

Selvage uses **semver**. The version lives in `package.json#version`.

- **major** — a change that needs a manual step on the machine beyond
  `chezmoi apply`: re-running `chezmoi init`, moving the checkout, a migration.
- **minor** — a new skill, command, agent, or config area.
- **patch** — a change to something that already exists.

Mechanics, from suede:

1. Every branch ready to merge ships as its own version. No versionless merges.
2. On the branch, clean tree: `suede release [patch|minor|major]` commits the
   bump as `chore(release): cut <version>`, the final commit. It doesn't push.
3. In the release PR description, note whether the decision graph answered a
   question this cycle.
4. After the human merges: `suede release --tag` tags `main`'s merge commit with
   the bare version, annotated, and pushes only the tag.
5. `git log <prev>..<new>` is the changelog. There is no `CHANGELOG.md`.

`package.json#suede.from` is the suede tag this process was taken from. When
suede's process layer changes, port what applies and move `from` to the new tag
in the same PR.

## Decision graph

Selvage tracks decisions with `deciduous`. Run `deciduous init` once in the main
checkout on the Mac; it writes its own Decision Graph Workflow section into this
file and its commands and hooks under `.claude/`. Don't hand-edit those, and
don't restate them here.

**Log in real time, not retroactively.** Once initialized, a pre-edit hook
blocks an edit unless a goal or action node was logged recently.

**The graph records the user's decisions, not the agent's process.** No nodes for
reading, exploring, planning, or tool use. Nodes for goals, options, decisions,
actions, outcomes, and observations that affect decisions. If it belongs on a
timeline or in a PR description, log it.

## Guardrails

Always:

- Run verification before claiming done, and capture the results in the PR
  description.

Never:

- Skip the PR description.
- Commit secrets. Machine-local values go through chezmoi data or 1Password
  (`CONTEXT.md`, "Secrets").
- Run `chezmoi apply` against the live home directory from an agent session.
  The human applies after merge.

## Verification before completion

From the task's worktree:

- `chezmoi --source . managed` — runs clean, and lists no repo-only file
  (`*.md` at the root, `package.json`, `pnpm-lock.yaml`, anything under
  `.claude/` or `tmp/`).
- `chezmoi --source . diff` — runs clean and shows only the intended changes.
- The story checks in `.claude/skills/task/testing.md`.
- Anything observable only after apply goes in the PR description as a
  post-merge check.

Claim done with evidence: command plus result.
