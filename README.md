# Selvage

Personal dotfiles, managed with [chezmoi](https://www.chezmoi.io/): shell,
terminal, editor, and Claude Code configuration, including the skills and
commands I use in every project.

It is published for reference. It is set up for one machine and one person, so
read before applying any of it.

## Updating your machine from selvage

Once it's set up (see [Setting it up as dotfiles](#setting-it-up-as-dotfiles)),
bring the home directory in line with the repo's current state:

```sh
git -C ~/Developer/selvage pull
chezmoi diff
chezmoi apply
```

chezmoi runs in copy mode, so nothing under `~/` changes until `chezmoi apply`.
Read the diff first. Tools write their own config at runtime (Claude Code
rewrites `~/.claude/settings.json`, installers append to `~/.zshrc`), and apply
discards those edits. To keep one, run `chezmoi re-add <path>` before applying.

`chezmoi update` does the pull and apply in one step, but it skips the diff, so
you see drift only as an overwrite prompt mid-apply. Run chezmoi from the main
checkout, never a task worktree.

## Using the Claude Code skills on their own

The skills in `dot_claude/exact_skills/` work without the rest of this repo.
Copy a skill's folder into `~/.claude/skills/<name>/` (drop the `exact_` prefix
from the path; it is a chezmoi convention). Projects built from
[suede](https://github.com/taurean/suede) expect these three:

- [`engineering-discipline`](dot_claude/exact_skills/engineering-discipline)
- [`poke-holes`](dot_claude/exact_skills/poke-holes)
- [`systems-map`](dot_claude/exact_skills/systems-map)

## Setting it up as dotfiles

```sh
git clone https://github.com/taurean/selvage.git ~/Developer/selvage
chezmoi init --source ~/Developer/selvage
chezmoi diff
chezmoi apply
```

`chezmoi init` asks for machine-local values (a 1Password account address)
once and keeps them out of the repo. `CONTEXT.md` covers the non-obvious
parts.

## How work on selvage runs

Selvage is a [suede](https://github.com/taurean/suede) project with no runtime
stack: it uses suede's process layer (task pipeline, git workflow, semver
releases, decision graph) to manage its own changes. The process skills and
reviewer agents live in `.claude/` at the repo root. They load only when Claude
Code runs inside selvage and never deploy to `~/.claude`. `CLAUDE.md` has the
rules.

## Credits

[Matt Pocock's skills](https://github.com/mattpocock/skills) are a significant
reference for the skills and commands here. Several, including `deepen`,
`diagnose`, `prototype`, and `teach`, started from or drew heavily on them.
