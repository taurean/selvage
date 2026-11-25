# Selvage — Context

Non-obvious constraints, caveats, and decisions. Anything derivable from reading the code is not repeated here.

---

## chezmoi

**Copy mode.** `.chezmoi.toml.tmpl` renders `~/.config/chezmoi/chezmoi.toml` with no `mode`, so chezmoi uses its default: every target is a regular file, written only by `chezmoi apply`. The template also records `sourceDir`, so the repo can stay at `~/Developer/selvage` with no `~/.local/share/chezmoi` symlink. Until 2026-09-30 selvage ran in symlink mode; the switch removed the `run_once_` script and the three directory symlinks it created.

**Daily loop.** Edit selvage → `chezmoi diff` → `chezmoi apply`. To pull a change made at the target back into selvage: `chezmoi re-add <target>`. `chezmoi status` lists targets that differ from source in either direction.

**The `dot_` prefix applies at every level.** A file named `.stylua.toml` inside a managed directory must be `dot_stylua.toml` in selvage.

**`*.md` in `.chezmoiignore` matches top-level only.** Patterns match target paths and `*` does not cross `/`, so the repo docs are excluded while markdown in subdirectories deploys. Verified against chezmoi 2.65 on 2026-09-30.

**`.gitignore` and `.chezmoiignore` are independent.** A path being gitignored says nothing about whether chezmoi manages it. `tmp/` is in both. Any new scratch or vendor directory needs the same treatment in both files.

**Symptom:** `chezmoi managed`, `chezmoi apply`, and `chezmoi status` all fail with `stat <some path>: no such file or directory`, naming a file unrelated to whatever you were doing. **Cause:** a broken symlink anywhere in the chezmoi *source* tree. chezmoi stats every source file during its scan and hard-errors on the first dangling link. **Fix:** `find . -type l ! -exec test -e {} \; -print` to locate it, then delete it.

**Symptom:** `chezmoi apply` prompts that a target "has changed since chezmoi last wrote it." **Cause:** something wrote the target directly — an installer appending a PATH line to `~/.zshrc` (Hermes did this in 2026-07). **Fix:** run `chezmoi diff <target>` and decide. Keep it with `chezmoi re-add <target>`, or move it where it belongs (PATH lines go in `dot_zshrc.d/path.zsh`, not the `dot_zshrc` fan-out) and let apply overwrite the target. The prompt's choices: `diff` shows the change; `overwrite` discards the tool's change for that file; `all-overwrite` does that for every remaining file in the run; `skip` leaves the file alone so it can be kept with `chezmoi re-add`.

**Bootstrap on a new machine:** install [Homebrew](https://brew.sh) first; it is the one manual install. Then:

```sh
/opt/homebrew/bin/brew install chezmoi
git clone git@github.com:taurean/selvage.git ~/Developer/selvage
chezmoi init --source ~/Developer/selvage   # asks for the 1Password account address once
chezmoi diff
chezmoi apply                               # installs the Brewfile, then mise's tools
```

**Apply runs scripts from `.chezmoiscripts/`.** chezmoi runs `run_onchange_before_*` before writing any target and `run_onchange_after_*` once every target is written, each group in filename order. A `run_onchange_` script re-runs only when its *rendered* text changes, so a script that acts on a file embeds that file's hash (`{{ include "Brewfile" | sha256sum }}`); without it, editing the file never re-runs the script. Scripts run with `/opt/homebrew/bin` hard-coded, as `path.zsh` already is: Apple Silicon only.

**Symptom:** `chezmoi apply` stops in the brew script with `It seems there is already an App at '/Applications/<App>.app'`. **Cause:** a `Brewfile` cask whose app was installed outside Homebrew (WezTerm hit this on the current Mac, before 1.1.1 removed it). **Fix:** `brew install --cask --adopt <cask>` once, then apply again.

**`.chezmoiignore` beats `.chezmoiremove`.** An ignored path is never removed, so `.chezmoiremove` can't clean up a target whose source moved into `.chezmoiignore`. Verified against chezmoi 2.70.5 on 2026-10-29. `~/Brewfile`, deployed until 1.0.0, had to be deleted by hand.

**`chezmoi managed` lists a `.chezmoiremove` entry while its target still exists.** After a source file is deleted and its target added to `.chezmoiremove`, `managed` keeps printing the target path until apply removes it; a target already gone is not listed. To check that nothing still deploys to a path, use `chezmoi managed --exclude=remove`; `--include=remove` lists the pending removals. Verified against chezmoi 2.70.5 on 2026-10-30.

**Migrating a machine that ran symlink mode:** `chezmoi init --source ~/Developer/selvage` rewrites the config without `mode = "symlink"`, then `chezmoi diff` and `chezmoi apply` replace every file symlink with real files. Apply does not write through the old symlinks into the repo. `~/.local/share/chezmoi` is unused afterwards and can be removed.

---

## Claude Code

**Selvage deploys nothing to `~/.claude`.** Claude Code runs on its defaults while a new setup is built. Selvage's earlier config (settings, permission policy, sandbox, skills, commands, theme, status line, plugin install script) is in git history before `chore(claude): reset to default Claude Code`.

---

## Repository layout

**`package.json` would deploy without its ignore entry.** It is not dot-prefixed, so chezmoi treats it as a target (`~/package.json`) unless `.chezmoiignore` lists it. The same goes for `pnpm-lock.yaml` and `node_modules`, which `suede task` produces by running `pnpm install` in each new worktree. The lockfile is committed so worktrees start clean.

**chezmoi reads the main checkout, not the worktree.** The rendered config's `sourceDir` is the main checkout, so a bare `chezmoi diff` in a task worktree shows `main`'s state. Pass `--source .` to check the branch. Never `apply` from a worktree: the target would take the unmerged branch's files.

**Worktrees land in `~/Developer/`.** Selvage stays at `~/Developer/selvage` rather than suede's `~/Developer/<name>/main` container, so `suede task feat/x` creates `~/Developer/feat-x`. Moving to the container layout means re-running `chezmoi init --source ~/Developer/selvage/main`.

---

## Pi archive

The Pi layout was removed on 2026-09-09. `dot_agents/`, `dot_pi/`, and `PACKAGE_URLS.md` are archived to `tmp/pi-archive-2026-09-09/` (gitignored); the tracked files also remain in git history before that commit. The pre-migration `~/.claude` state — including `hooks/herdr-agent-state.sh`, the original `settings.json`, and the vendor Cloudflare and goldfish skills — is archived to `tmp/claude-archive-2026-09-09/`.

Both archives are local and untracked. They are the only copy of the vendor skills and the herdr hook. If you clear `tmp/`, those are gone for good; everything else is recoverable from git history.

The Pi permission package had several tokenizer-level gotchas (path tokens extracted from quoted strings, compound-command decomposition, `<opaque-bash-wrapper>` handling) that were documented here at length. None of them apply to Claude Code, and the package is no longer installed, so they were removed with the rest of the Pi content. The archived `config.json` still carries the rules if the history is ever needed.

---

## JS toolchain

**mise is the only owner of Node and global JS tools.** `dot_config/mise/config.toml` declares them, and `run_onchange_after_20-mise-install` runs `mise install` whenever that file changes. Nothing else installs them: `dot_npmrc` sets no `prefix`, so there is no npm global directory on PATH. `$PNPM_HOME` isn't set, so `pnpm add -g` refuses to run. Volta and corepack are gone. **Why:** until 1.0.0, four owners (Volta, npm's `~/.npm-global` prefix, pnpm globals, and corepack) each put shims on PATH, and PATH order picked the winner. On 2026-10-26 a stale corepack 0.32.0 in `~/.npm-global/bin` shadowed Volta's and broke `pnpm` (#3). Volta was the first choice for single owner but is unmaintained, and its maintainers point to mise (volta-cli/volta#2080).

**Shims, not `mise activate`.** `path.zsh` puts `~/.local/share/mise/shims` on PATH. A shim resolves the tool version for the current directory on every call, so it works in non-interactive shells (scripts, Claude Code's Bash tool) where an activate hook never runs. Shims don't load a project's `[env]` or run its `cd`/`enter` hooks; a project that needs those needs `mise activate zsh`. `which node` prints the shim, while `mise which node` prints the real binary.

**Project pins.** mise reads `.nvmrc`, `.node-version`, and `package.json` for Node, and `package.json` for pnpm, only because the global config turns on `idiomatic_version_file_enable_tools`. It's off by default. Without it, every project silently runs the global `node` and `pnpm`.

**Global tools with a different owner.** `claude` comes from Claude Code's native installer (`~/.local/bin`, self-updating) and `opencode` from Homebrew. Neither belongs in the mise config. Add a global tool by editing the source config. `mise use -g` writes the deployed copy, which drifts until `chezmoi re-add` ([S10]).

---

## Secrets

**npm token.** `~/.npmrc` references `${NPM_TOKEN}` as an env var, not a raw token. `dot_zshrc.d/secrets.zsh` wraps `npm`, `npx`, and `pnpm` so the first call in a shell runs `op read` from the `Private` vault in 1Password and exports the token. Nothing fetches at shell startup; `BRAVE_API_KEY` and `DEEPGRAM_API_KEY` load only through `load-secrets`.

**Symptom:** a terminal opened to run a script (the Stardew Valley SMAPI launcher's `/tmp/open-smapi-terminal.command`) never runs it. **Cause:** a 1Password prompt at shell startup blocks the shell, and the launcher deletes the script after 10 seconds. **Fix:** never call `op` at startup; load secrets on first use, as `secrets.zsh` does.

**`op read` requires `--account` when multiple accounts are configured.** Without it, `op` errors with "multiple accounts found" — silently if `2>/dev/null` is set. Always pin the account explicitly. The account address is machine-local chezmoi data (`onePasswordAccount`, asked once by `chezmoi init` and stored in `~/.config/chezmoi/chezmoi.toml`), so it never enters the repo; `dot_zshrc.d/secrets.zsh.tmpl` reads it:

```zsh
op read "op://Private/item-name/field" --account <account>
```

**Credentials never tracked.** The following are explicitly excluded from selvage:

- `~/.ssh/` private keys
- `~/.config/gh/hosts.yml` (GitHub tokens)
- `~/.config/stripe/`, `~/.config/sanity/` (service credentials)
- `~/.claude/` and `~/.claude.json`: settings, sessions, history, and auth
