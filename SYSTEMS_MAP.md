# Selvage — Systems Map

A reader should be able to use this file to decide which small part of selvage is relevant to a task without opening anything else. Selvage is a personal chezmoi-managed dotfiles repo, not an application; the areas reflect how the repo is *deployed* (chezmoi), *configured* (shell, terminal, editor), and *documented* (decision logs and research notes).

## Areas

### Chezmoi source layer

For: How selvage's source-tree files are deployed to their targets in the home directory, and what installs on apply.
Lives at: `.chezmoi.toml.tmpl`, `.chezmoiignore`, `.chezmoiremove`, `Brewfile`, `.chezmoiscripts/`
Why this shape: chezmoi runs in its default copy mode — targets are regular files and change only on `chezmoi apply`. The config template records `sourceDir` so the repo lives at `~/Developer/selvage`. The `dot_` prefix applies at every depth, and top-level `*.md` files are excluded by `.chezmoiignore`. These are deployment concerns, not application concerns.
Seams: `Brewfile` is the extension point for system packages: an entry installs on the next apply (`run_onchange_before_10-brew-bundle`). `.chezmoiscripts/` is where anything that must run on apply goes: `before_` for system packages, `after_` for steps that read a deployed config. `.chezmoiignore` is where a target path that some tool writes at runtime gets excluded.
Fragile: (1) Targets drift when a tool writes them directly; `chezmoi diff` shows it, and apply overwrites it unless it was `re-add`ed first. (2) A broken symlink anywhere in the source tree hard-fails every chezmoi command with an error naming an unrelated path. (3) A `run_onchange_` script re-runs only when its rendered text changes, so each script `include`s the hash of the file it acts on; drop that line and edits stop re-running it. (4) The scripts hard-code `/opt/homebrew/bin`, as `path.zsh` does: Apple Silicon only. (5) `.chezmoiignore` beats `.chezmoiremove`, so a target whose source moves into the ignore list is never cleaned up. `CONTEXT.md` documents all five.

### Shell environment

For: The interactive shell session itself — zsh startup, language managers on PATH, git/ssh/npm identities, prompt, and secret resolution.
Lives at: `dot_zshrc` (sources `~/.zshrc.d/*.zsh`); `dot_zshrc.d/init.zsh` (pyenv/rbenv), `path.zsh`, `prompt.zsh`, `aliases.zsh`, `secrets.zsh`; `dot_gitconfig`, `dot_ssh/config`, `dot_npmrc`, `dot_config/git/ignore`; `dot_config/mise/config.toml` (Node and global JS tools)
Why this shape: `dot_zshrc` is intentionally a one-liner that fans out to `dot_zshrc.d/*.zsh`. Each `.zsh` file is a self-contained concern (init order, path, prompt, aliases, secrets) and is independently editable. Adding a new shell concern = adding a new file in `dot_zshrc.d/`, not editing the existing ones.
Seams: `dot_zshrc.d/secrets.zsh` is the canonical entry point for new secrets — its `_load_secret` helper is the pattern for "fetch from 1Password on first use, export into this shell." Nothing fetches at startup: `NPM_TOKEN` loads through the `npm`/`npx`/`pnpm` wrappers, the rest through `load-secrets`. Any new secret should reuse the helper and join `load-secrets` (or get its own tool wrapper), not invent a parallel mechanism or fetch at startup. `dot_config/mise/config.toml` is the one place to add Node or a global JS tool; `npm -g`, `pnpm add -g`, and `mise use -g` all bypass selvage.
Fragile: 1Password CLI must be invoked with `--account` (the address comes from the machine-local `onePasswordAccount` chezmoi value); without it, `op` errors when multiple accounts are configured, and the `2>/dev/null` in `_load_secret` can swallow that error silently. `dot_zshrc.d/path.zsh` lists tool-managed paths at the end ("installer-appended; do not reorder") that depend on installer-set ordering and would break if reordered for cleanliness. Project Node and pnpm pins work only because the mise config enables `idiomatic_version_file_enable_tools`; it's off by default.

### Terminal emulator

For: The terminal window. Ghostty opens a plain login zsh in `~/Developer`. No multiplexer.
Lives at: `dot_config/ghostty/config.tmpl`, `dot_config/ghostty/themes/flexoki-light`
Why this shape: one Ghostty config file plus one local theme. The template exists only for `{{ .chezmoi.homeDir }}` in `working-directory`. Ghostty picks Flexoki Light or Dark from macOS appearance.
Seams: Ghostty options and keybindings go in `config.tmpl`, never in `~/Library/Application Support/com.mitchellh.ghostty/config`, which Ghostty loads after it and lets override it (`.chezmoiremove` deletes that file); a local theme is a file in `dot_config/ghostty/themes/`.
Fragile: `flexoki-light` differs from Ghostty's bundled Flexoki Light in palette 15 (ink, not base-200). Apps that draw body text in `whiteBright` need that to stay readable on the light background. `Flexoki Dark` resolves by name from Ghostty's bundled set, so an upstream rename leaves it unresolved. tmux was removed in 0.2.0 and WezTerm in 1.1.1; `.chezmoiremove` deletes their old targets on apply. Drop those entries once every machine has applied past the version that removed them.

### Neovim editor

For: In-editor experience — options, plugins, LSP/completion/lint setup.
Lives at: `dot_config/nvim/init.lua` (single-file kickstart-style config); `dot_config/nvim/lua/custom/plugins/init.lua` (local customisations); `dot_config/nvim/lua/kickstart/plugins/*.lua` (kickstart's bundled plugin recipes)
Why this shape: The kickstart.nvim philosophy is "a starting point you can read top-to-bottom," so the init.lua is a single dense file rather than a modular layout. Local additions go in `lua/custom/plugins/` so they don't collide with kickstart's bundled recipes on update.
Seams: `lua/custom/plugins/init.lua` is the extension point — adding a new plugin or overriding a kickstart default happens there, not by editing the kickstart files.
Fragile: `dot_config/nvim/nvim-pack-lock.json` pins plugin versions and can drift if `:Lazy update` is run without committing the lock. Plugin recipes in `lua/kickstart/plugins/` are vendored from upstream kickstart; modifying them directly makes future kickstart merges painful. `.stylua.toml` inside a managed directory must be named `dot_stylua.toml` in the source — the `dot_` prefix applies at every depth.

### Project documentation and research notes

For: Markdown committed to the repo but excluded from chezmoi targets — durable decisions, ongoing evaluations, and research scratch.
Lives at: `README.md` (project identity), `CONTEXT.md` (non-obvious selvage decisions and gotchas), `CLAUDE.md` (project rules), `SYSTEMS_MAP.md` (this file), `tmp/` (research notes, working scratch, and the 2026-09-09 migration archives)
Why this shape: `.chezmoiignore` excludes top-level `*.md`, so these live only in the repo. This is intentional — docs aren't deployed; they're read by humans and by the agent on first work in this repo.
Seams: When a `tmp/` note matures into a durable rule, it migrates to `CONTEXT.md` — `tmp/` files are not load-bearing. The root `CLAUDE.md` "Read on first work in this repo" list points new sessions at `CONTEXT.md` and this file; that's the entry-point contract.
Fragile: `tmp/` is gitignored *and* chezmoiignored, but those are independent settings — a new scratch directory needs both, or it deploys to the home directory. `tmp/` currently holds the only copy of the vendor Cloudflare/goldfish skills and the herdr hook (`claude-archive-2026-09-09/`) alongside the Pi tree (`pi-archive-2026-09-09/`, also in git history); clearing `tmp/` destroys the former permanently. `CONTEXT.md` is the source of truth for chezmoi gotchas — deletions or rewrites should preserve the load-bearing facts (copy mode and `re-add`, top-level `*.md` matching, the dangling-symlink hard-fail, `op --account`).
