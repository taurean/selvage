# Selvage — Context

Non-obvious constraints, caveats, and decisions. Anything derivable from reading the code is not repeated here.

---

## chezmoi

**Copy mode.** `.chezmoi.toml.tmpl` renders `~/.config/chezmoi/chezmoi.toml` with no `mode`, so chezmoi uses its default: every target is a regular file, written only by `chezmoi apply`. The template also records `sourceDir`, so the repo can stay at `~/Developer/selvage` with no `~/.local/share/chezmoi` symlink. Until 2026-09-30 selvage ran in symlink mode; the switch removed the `run_once_` script and the three directory symlinks it created.

**Daily loop.** Edit selvage → `chezmoi diff` → `chezmoi apply`. To pull a change made at the target back into selvage: `chezmoi re-add <target>`. `chezmoi status` lists targets that differ from source in either direction.

**`dot_` and `exact_` prefixes apply at every level.** A file named `.stylua.toml` inside a managed directory must be `dot_stylua.toml` in selvage. `dot_claude/exact_skills`, `exact_agents`, `exact_commands`, and `exact_output-styles` mark those four directories exact: apply deletes anything in the target that isn't in source.

**`*.md` in `.chezmoiignore` matches top-level only.** Patterns match target paths and `*` does not cross `/`, so the repo docs are excluded while `.claude/CLAUDE.md` and every `SKILL.md` deploy. Verified against chezmoi 2.65 on 2026-09-30; the `!.claude/CLAUDE.md` negation that used to follow `*.md` was not needed and was removed.

**Ignored entries survive in an exact directory.** Claude.ai skill sync writes `~/.claude/skills/synced/`, and the Reflect app writes `~/.claude/skills/reflect-<graph>/` (its `SKILL.md` carries a `reflect-managed` hash and the app rewrites it on update). `.chezmoiignore` excludes both, and chezmoi leaves ignored paths alone even inside `exact_skills`, so apply keeps them. Verified 2026-09-30. Anything else placed in those four directories by hand is deleted on the next apply. Don't copy a tool-managed skill into selvage: the tool keeps rewriting its own copy, so there would be two versions. The `reflect-*` pattern also matches selvage's own `reflect-notes`, so `.chezmoiignore` negates it below the pattern; a new selvage skill named `reflect-…` needs the same negation or it silently never deploys.

**`.gitignore` and `.chezmoiignore` are independent.** A path being gitignored says nothing about whether chezmoi manages it. `tmp/` is in both. Any new scratch or vendor directory needs the same treatment in both files.

**Symptom:** `chezmoi managed`, `chezmoi apply`, and `chezmoi status` all fail with `stat <some path>: no such file or directory`, naming a file unrelated to whatever you were doing. **Cause:** a broken symlink anywhere in the chezmoi *source* tree. chezmoi stats every source file during its scan and hard-errors on the first dangling link. **Fix:** `find . -type l ! -exec test -e {} \; -print` to locate it, then delete it.

**Symptom:** `chezmoi apply` prompts that a target "has changed since chezmoi last wrote it." **Cause:** something wrote the target directly — Claude Code saving preferences to `~/.claude/settings.json`, or an installer appending a PATH line to `~/.zshrc` (Hermes did this in 2026-07). **Fix:** run `chezmoi diff <target>` and decide. Keep it with `chezmoi re-add <target>`, or move it where it belongs (PATH lines go in `dot_zshrc.d/path.zsh`, not the `dot_zshrc` fan-out) and let apply overwrite the target.

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

**Migrating a machine that ran symlink mode:** `chezmoi init --source ~/Developer/selvage` rewrites the config without `mode = "symlink"`, then `chezmoi diff` and `chezmoi apply` replace every file symlink and the three `~/.claude` directory symlinks with real files and directories. Apply does not write through the old symlinks into the repo. `~/.local/share/chezmoi` is unused afterwards and can be removed.

---

## Claude Code

**Config resolution.** Claude Code reads `~/.claude/CLAUDE.md` as the global instruction file, discovers skills from `~/.claude/skills/`, subagents from `~/.claude/agents/`, slash commands from `~/.claude/commands/`, output styles from `~/.claude/output-styles/`, custom themes from `~/.claude/themes/`, and settings from `~/.claude/settings.json`. All seven are deployed by `chezmoi apply` from `dot_claude/`.

**A skill edit reaches Claude Code only after apply.** Claude Code re-scans the three directories mid-session, so once applied, a new or changed skill, command, or agent is available without a restart.

**Skill name collisions: personal wins, project loses.** Claude Code resolves collisions enterprise > personal > project. A skill in selvage silently shadows a same-named skill in any project — the opposite of the intuitive precedence. This is why `review`, `task`, and `project-plan` live in suede and not here, and why `systems-map` lives here and not in suede. One home per name, decided deliberately.

**`disable-model-invocation: true` makes a skill user-invoked only.** `deepen` and `teach` both carry it, so they do not appear in the model's available-skills list and only run via `/deepen` and `/teach`. Their absence from that list is correct, not a loading failure — check the frontmatter before diagnosing a "missing" skill.

**Reference paths inside a skill must be skill-relative.** A skill that points at `~/.claude/skills/<name>/<file>.md` by absolute path breaks the moment the directory layout shifts, and breaks *silently* — the model simply fails to find the guide and improvises from training. Use `references/<file>.md` relative to the skill directory.

**`~/.claude/settings.json` drifts from selvage when Claude Code writes it at runtime.** Changing model, theme, effort level, or enabled plugins in the UI rewrites the target. The drift is expected and shows in `chezmoi diff`. Keep the new values with `chezmoi re-add ~/.claude/settings.json`; an apply without that discards them.

**`~/.claude/themes/` is not exact.** `/theme` writes a custom theme there when one is created ("New custom theme…") or edited (Ctrl+E). An `exact_` directory would delete UI-made themes on the next apply. Editing `flexoki` in the UI drifts its target like `settings.json` does; `re-add` it to keep the change.

**Symptom:** Claude Code uses the Default output style although `settings.json` names another. **Cause:** `outputStyle` matches the style's frontmatter `name` exactly and case-sensitively (`Report First`, not `report-first`); a mismatch falls back to Default without an error. **Fix:** copy the `name` value from the style's frontmatter.

**Symptom:** in Flexoki Light, Claude Code's body text or `!` entries are unreadable. **Cause:** the `flexoki` theme's `dark-ansi` base draws text in `whiteBright` and the `!` entry background in `black` (read from the preset in Claude Code 2.1.314). Ghostty's bundled Flexoki Light has `whiteBright` near the background. **Fix:** keep `dot_config/ghostty/themes/flexoki-light` palette 15 as ink (`#100f0f`) and the theme's `bashMessageBackgroundColor` override. Both halves are needed; neither works alone.

**Symptom:** the status line reads `statusline: jq not found`. **Cause:** the script parses Claude Code's JSON with `jq`, which macOS ships at `/usr/bin/jq` from macOS 15. **Fix:** upgrade macOS or add `brew "jq"` to the `Brewfile`.

---

## Suede process layer

**Two `.claude` directories, two scopes.** `dot_claude/` is source for `~/.claude/` and applies everywhere. `.claude/` at the repo root is selvage's project config: the `task`, `project-plan`, and `review` skills and the three reviewer agents. chezmoi ignores source entries whose names start with `.` (other than `.chezmoi*`), so the root `.claude/` never deploys and needs no `.chezmoiignore` entry. Verified against chezmoi 2.65 on 2026-09-30.

**Why the process skills are repo-local.** `review`, `task`, and `project-plan` are also the names of every suede project's skills. As personal skills they would shadow those in every project ([S6]). Repo-local, they apply only inside selvage and shadow nothing.

**`package.json` would deploy without its ignore entry.** It is not dot-prefixed, so chezmoi treats it as a target (`~/package.json`) unless `.chezmoiignore` lists it. The same goes for `pnpm-lock.yaml` and `node_modules`, which `suede task` produces by running `pnpm install` in each new worktree. The lockfile is committed so worktrees start clean.

**chezmoi reads the main checkout, not the worktree.** The rendered config's `sourceDir` is the main checkout, so a bare `chezmoi diff` in a task worktree shows `main`'s state. Pass `--source .` to check the branch. Never `apply` from a worktree: the target would take the unmerged branch's files.

**Worktrees land in `~/Developer/`.** Selvage stays at `~/Developer/selvage` rather than suede's `~/Developer/<name>/main` container, so `suede task feat/x` creates `~/Developer/feat-x`. Moving to the container layout means re-running `chezmoi init --source ~/Developer/selvage/main`.

---

## Permission policy

The policy lives in `permissions` in `dot_claude/settings.json`. It was ported from `@gotgenes/pi-permission-system` on 2026-09-09; the rule syntax is entirely different but the reasoning below carried over.

**Precedence is `deny` > `ask` > `allow`, with no exception mechanism.** A `deny` rule cannot be narrowed by a more specific `allow`. This is the single most important difference from the Pi package and it changes what a deny rule is *for*: it must be something you never want, not a default you sometimes override.

**Consequence, worth knowing before you add a deny:** Pi carried `"npm *": {"action": "deny", "reason": "Use pnpm instead"}` — a nudge that explained itself. Ported literally, it would have hard-blocked `npm run gen-api`, which the AT Proto work depends on, with no way to except it and no reason shown. It was deliberately dropped. A tooling *preference* belongs in `CLAUDE.md` as a rule, where it can explain itself and be overridden with judgement; `deny` is for things that should never run.

**Rules are scoped per-tool, unlike Pi's tool-agnostic `path` surface.** `Read(//Users/taurean/.ssh/**)` blocks the Read tool only — it does not stop `Bash(cat ~/.ssh/id_rsa)`. The `//` prefix means an absolute path; a single `/` is cwd-relative and will silently miss. When adding a path deny, consider every tool that could reach it.

**Bash is deny-only — no ask rules except `gh` mutations.** This is a deliberate policy shift (originally 2026-06-27, after observing 72 prompts in 45 minutes, 100% approved blindly — prompt fatigue makes the gate useless). The reasoning:

- This is a trusted local development environment — the agent runs commands the user would run.
- The protection that actually matters is already covered: `Read` denies catch `.env`, `~/.ssh`, `~/.aws/credentials`, `~/.gnupg`, `*.pem`, `*.key`; `Bash` denies catch `rm -rf`, `sudo`, `chmod 777`, `git reset --hard`, `git push --force`, `git push -f`, `git clean -f`.
- Mutations (`mv`, `git push`, `git commit`, `curl`) execute silently — except `gh` mutations, which prompt.

**`gh` mutations prompt before any external-system write (added 2026-07-15, preserved through the port).** The move to a deny-only posture traded prompt fatigue for silent external mutations; `gh` fell through and the agent submitted an issue to a third-party repo autonomously. All 32 high-blast-radius `gh` subcommands now sit in `permissions.ask` — `gh issue create/edit/comment/close/reopen/delete/lock/transfer`, `gh pr create/edit/comment/merge/review/close/reopen/lock`, `gh release create/edit/delete/upload`, `gh workflow run/enable/disable`, `gh repo create/edit/delete/archive/fork`, `gh secret set/delete`, plus `gh api -X` / `gh api --method` for any mutating HTTP verb. Read-only gh (`gh pr view`, `gh issue list`, `gh search`, bare `gh api` default GET) falls through and runs silently.

**Pi's `external_directory` allow-list has no analog and was dropped.** Claude Code governs out-of-cwd file access via `additionalDirectories`, not a path allow-list, and `defaultMode: auto` already covers the intent. The Pi entries (`~/Developer`, `~/.config`, `~/.local`, `/var/folders/*`) are not reproduced.

**Project-level overrides belong in the project.** Selvage owns the *global* policy. A project-level `.claude/settings.json` only applies when cwd is that project — the right scope for a per-project opt-out (e.g. letting `gh pr create` run silently in your own repo), and the wrong scope for universal policy. Per [S8], never add one at the selvage root.

**Lost protections worth re-adding if the threat model changes.** Currently silent, in order of how reversible the damage is. `gh` was here before 2026-07-15 and was added back to the asks after the third-party-issue incident; the rest remain by deliberate scope choice. Re-adding any is a single entry in `permissions.ask`.

- `mv`, `cp -r` — file overwrite / disk fill. Recoverable from backups but annoying.
- `git push`, `git commit`, `git pull`, `git merge`, `git rebase` — remote mutation. Hard to reverse once pushed (`--force` is still deny).
- `curl`, `wget` — data egress. The agent can read any permitted file and POST it anywhere.
- `ssh`, `scp`, `rsync` — remote shell and file copy.
- `chmod -R`, `chown -R` — recursive permission / ownership change.

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
- `~/.claude/.credentials.json` and anything under `~/.claude/` not listed as managed above — sessions, history, plugin caches, and auth are runtime state, not config
