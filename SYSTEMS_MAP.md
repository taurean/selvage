# Selvage — Systems Map

A reader should be able to use this file to decide which small part of selvage is relevant to a task without opening anything else. Selvage is a personal chezmoi-managed dotfiles + Claude Code agent-config repo, not an application; the areas reflect how the repo is *deployed* (chezmoi), *configured* (shell, terminal, editor, agent), and *documented* (decision logs and research notes).

## Areas

### Chezmoi source layer

For: How selvage's source-tree files are deployed to their targets in the home directory, and what gets run once on first apply.
Lives at: `.chezmoi.toml.tmpl`, `.chezmoiignore`, `Brewfile`
Why this shape: chezmoi runs in its default copy mode — targets are regular files and change only on `chezmoi apply`. The config template records `sourceDir` so the repo lives at `~/Developer/selvage`. The `dot_` and `exact_` prefixes apply at every depth, and top-level `*.md` files are excluded by `.chezmoiignore`. These are deployment concerns, not application concerns.
Seams: `Brewfile` is the extension point for system packages — brew-formula changes land here, not in a dotfile. `.chezmoiignore` is where a target path that some tool writes at runtime gets excluded (the `synced` skills entry is the worked example).
Fragile: (1) Targets drift when a tool writes them directly; `chezmoi diff` shows it, and apply overwrites it unless it was `re-add`ed first. (2) The three `exact_` directories delete anything not in source on apply, so a runtime-written path inside them must be in `.chezmoiignore`. (3) A broken symlink anywhere in the source tree hard-fails every chezmoi command with an error naming an unrelated path. `CONTEXT.md` documents all three.

### Shell environment

For: The interactive shell session itself — zsh startup, language managers on PATH, git/ssh/npm identities, prompt, and secret resolution.
Lives at: `dot_zshrc` (sources `~/.zshrc.d/*.zsh`); `dot_zshrc.d/init.zsh` (pyenv/rbenv), `path.zsh`, `prompt.zsh`, `aliases.zsh`, `tmux.zsh`, `secrets.zsh`; `dot_gitconfig`, `dot_ssh/config`, `dot_npmrc`, `dot_config/git/ignore`
Why this shape: `dot_zshrc` is intentionally a one-liner that fans out to `dot_zshrc.d/*.zsh`. Each `.zsh` file is a self-contained concern (init order, path, prompt, aliases, tmux wrapper, secrets) and is independently editable. Adding a new shell concern = adding a new file in `dot_zshrc.d/`, not editing the existing ones.
Seams: `dot_zshrc.d/secrets.zsh` is the canonical entry point for new secrets — its `_load_secret` helper is the pattern for "fetch from 1Password, cache, share with future tmux panes via `tmux set-environment -g`." Any new secret should reuse it, not invent a parallel mechanism.
Fragile: 1Password CLI must be invoked with `--account` (the address comes from the machine-local `onePasswordAccount` chezmoi value); without it, `op` errors when multiple accounts are configured, and the `2>/dev/null` in `_load_secret` can swallow that error silently. `dot_zshrc.d/path.zsh` lists tool-managed paths at the end ("installer-appended; do not reorder") that depend on installer-set ordering and would break if reordered for cleanliness.

### Terminal multiplexer and emulator

For: The persistent shell workspace — wezterm drops you into a named tmux session that survives across terminal restarts.
Lives at: `dot_config/tmux/tmux.conf`, `dot_config/wezterm/wezterm.lua`
Why this shape: wezterm's `default_prog` launches `tmux attach -t selvage 2>/dev/null || tmux new -s selvage`, so the session name `selvage` is the contract between the two configs. A third touchpoint lives in the shell environment (`dot_zshrc.d/tmux.zsh` makes a bare `tmux` invocation start a session at `~/Developer`); all three sites must agree.
Seams: `tmux.conf` binds tmux's mouse-menu entries and prefix menus to call `split-window -c "#{pane_current_path}"` so menu-driven creation inherits the current pane's directory (matching the keybind behaviour). New menu entries or new directory-aware bindings extend the existing pattern. The wezterm `default_prog` is the only place where the session-name contract lives — change the session name there, and `tmux.zsh` and any future wezterm changes have to follow.
Fragile: tmux plugins are managed by `tpm` (last line of `tmux.conf`); plugin install/update happens interactively in tmux (`prefix + I`), not via chezmoi apply, so the plugins on disk and the manifest in `tmux.conf` can drift.

### Neovim editor

For: In-editor experience — options, plugins, LSP/completion/lint setup.
Lives at: `dot_config/nvim/init.lua` (single-file kickstart-style config); `dot_config/nvim/lua/custom/plugins/init.lua` (local customisations); `dot_config/nvim/lua/kickstart/plugins/*.lua` (kickstart's bundled plugin recipes)
Why this shape: The kickstart.nvim philosophy is "a starting point you can read top-to-bottom," so the init.lua is a single dense file rather than a modular layout. Local additions go in `lua/custom/plugins/` so they don't collide with kickstart's bundled recipes on update.
Seams: `lua/custom/plugins/init.lua` is the extension point — adding a new plugin or overriding a kickstart default happens there, not by editing the kickstart files.
Fragile: `dot_config/nvim/nvim-pack-lock.json` pins plugin versions and can drift if `:Lazy update` is run without committing the lock. Plugin recipes in `lua/kickstart/plugins/` are vendored from upstream kickstart; modifying them directly makes future kickstart merges painful. `.stylua.toml` inside a managed directory must be named `dot_stylua.toml` in the source — the `dot_` prefix applies at every depth.

### Claude Code runtime config

For: What Claude Code loads at startup — model, theme, plugins, and the permission policy that governs every project the agent runs in.
Lives at: `dot_claude/settings.json`
Why this shape: Claude Code reads `~/.claude/settings.json` on launch; this file owns machine-state choices (model, effort level, TUI mode, enabled plugins) alongside `permissions`. Because the path is global, whatever rules land here govern every project, not just selvage. Permission precedence is `deny` > `ask` > `allow` with no exception mechanism, which makes `deny` a statement about what must never run rather than a default you sometimes override.
Seams: `permissions.ask` is the extension point for raising a recurring concern to a prompt — the 32 `gh` mutation rules are the worked example. `enabledPlugins` is the extension point for marketplace plugins, which is also where vendor skills belong now that `~/.claude/skills` is wholly owned by selvage.
Fragile: Claude Code rewrites this file at runtime on any `/config` change; `chezmoi re-add ~/.claude/settings.json` keeps the change, and an apply without it discards the change ([S10]). Deny rules are per-tool, not tool-agnostic: a `Read` deny on `~/.ssh` does not stop `Bash(cat ~/.ssh/id_rsa)`. The `//` prefix in a path rule means absolute; a single `/` is cwd-relative and silently misses. Never scope a permission override to selvage itself ([S8]) — per-project rules belong in the project that needs them.

### Agent identity layer

For: How the agent behaves — its self-description, working principles, tier boundaries, and voice.
Lives at: `dot_claude/CLAUDE.md` (global, deploys to `~/.claude/CLAUDE.md`); `CLAUDE.md` at the repo root (project-level, repo-only)
Why this shape: The global `CLAUDE.md` is read at every session and is the soul layer above per-project `CLAUDE.md` and `CONTEXT.md`. It is owned by selvage (not by Claude Code) because the user's identity and work-style preferences live here. Editing it changes the agent's behaviour contract — treat as a code change. The root `CLAUDE.md` carries selvage's own project rules ([S1]–[S10]) and, per `.chezmoiignore`, never deploys anywhere.
Seams: The tier-boundary rules are the seam for raising a recurring concern to a guardrail. The root `CLAUDE.md` rule list is the seam for a selvage-specific mechanic that agents keep getting wrong.
Fragile: The "how I talk" prose is load-bearing for the agent's voice — edits should preserve the stated anti-patterns. Treat changes here as code, not as a personal blog ([S7]).

### Agent capability library

For: The curated set of reusable capabilities the agent can invoke — skills it triggers itself and commands the user invokes.
Lives at: `dot_claude/exact_skills/<name>/SKILL.md`; `dot_claude/exact_commands/<name>.md`; `dot_claude/exact_agents/` (empty — `.keep` holds it so apply clears `~/.claude/agents`)
Why this shape: All three are `exact_` directories, so `chezmoi apply` deploys additions and edits and deletes removals; Claude Code picks up the result without a restart. The skill/command split follows one rule: model-self-triggered capability is a skill, user-commanded workflow is a command. `publish-lexicons` is a command because it takes a mode argument and mutates a public registry; `atprotocol-oauth` is a skill because it should fire whenever AT Proto work appears.
Seams: Adding a skill = a new directory with a `SKILL.md` whose front-matter follows the skill schema (see `/write-a-skill`, which also routes skill-vs-command-vs-agent). Reference docs a skill loads live alongside its `SKILL.md` under `references/`. Adding a command = a single `.md` with `description` front-matter. Adding a subagent = a single `.md` under `exact_agents/`. The review agents selvage itself uses live in the repo-root `.claude/` (see "Process layer"), not here; a personal agent or skill would shadow each suede project's own copy.
Fragile: A skill named the same as a project-level skill silently shadows it — personal beats project, the opposite of intuition — so global names must not collide with any project's ([S6]). Reference paths inside a skill must be skill-relative; an absolute `~/.claude/skills/...` path breaks silently on any layout change and the model just improvises. `disable-model-invocation: true` (on `deepen` and `teach`) removes a skill from the model's list by design — check the front-matter before diagnosing a missing skill. A skill dropped into `~/.claude/skills` by hand is deleted on the next apply; vendor skills belong in a plugin.

### Process layer

For: How changes to selvage itself are planned, built, reviewed, and released — suede's process, without its runtime stack.
Lives at: `.claude/skills/task/` (`SKILL.md`, `brief.md`, `testing.md`), `.claude/skills/project-plan/`, `.claude/skills/review/`, `.claude/agents/*-reviewer.md`, `package.json` (version and `suede` lineage), `pnpm-lock.yaml`, and the process sections of the root `CLAUDE.md`
Why this shape: selvage is a suede project. Suede's process skills are copied in from the tag in `package.json#suede.from` and adapted where they assumed an app: verification is what chezmoi would write, and each user story gets one observable check instead of a scenario test. They sit in the repo-root `.claude/`, which chezmoi skips, so they apply only while working on selvage. `package.json` exists for `suede task`, `suede done`, and `suede release`, which find a project by `suede.from`.
Seams: `testing.md` defines what counts as a check. Pulling a newer suede process means porting what applies and moving `suede.from` in the same PR. `deciduous init` adds its hooks and commands under `.claude/` once run.
Fragile: `package.json`, `pnpm-lock.yaml`, and `node_modules` deploy to `~/` unless `.chezmoiignore` lists them ([S11]). chezmoi's `sourceDir` is the main checkout, so checks in a worktree need `--source .`. The root `.claude/settings.json` must not carry `permissions` ([S8]).

### Project documentation and research notes

For: Markdown committed to the repo but excluded from chezmoi targets — durable decisions, ongoing evaluations, and research scratch.
Lives at: `README.md` (project identity), `CONTEXT.md` (non-obvious selvage decisions and gotchas), `CLAUDE.md` (project rules), `SYSTEMS_MAP.md` (this file), `tmp/` (research notes, working scratch, and the 2026-09-09 migration archives)
Why this shape: `.chezmoiignore` excludes top-level `*.md`, so these live only in the repo. This is intentional — docs aren't deployed; they're read by humans and by the agent on first work in this repo.
Seams: When a `tmp/` note matures into a durable rule, it migrates to `CONTEXT.md` — `tmp/` files are not load-bearing. The root `CLAUDE.md` "Read on first work in this repo" list points new sessions at `CONTEXT.md` and this file; that's the entry-point contract.
Fragile: `tmp/` is gitignored *and* chezmoiignored, but those are independent settings — a new scratch directory needs both, or it deploys to the home directory. `tmp/` currently holds the only copy of the vendor Cloudflare/goldfish skills and the herdr hook (`claude-archive-2026-09-09/`) alongside the Pi tree (`pi-archive-2026-09-09/`, also in git history); clearing `tmp/` destroys the former permanently. `CONTEXT.md` is the source of truth for chezmoi gotchas and Claude Code config resolution — deletions or rewrites should preserve the load-bearing facts (copy mode and `re-add`, `exact_` deletion and the `synced` ignore, top-level `*.md` matching, the dangling-symlink hard-fail, `op --account`).
