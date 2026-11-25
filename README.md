# Selvage

Personal dotfiles, managed with [chezmoi](https://www.chezmoi.io/): shell,
terminal, and editor configuration.

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
Read the diff first. Tools write their own config at runtime (installers
append to `~/.zshrc`), and apply
discards those edits. To keep one, run `chezmoi re-add <path>` before applying.

`chezmoi update` does the pull and apply in one step, but it skips the diff, so
you see drift only as an overwrite prompt mid-apply. Run chezmoi from the main
checkout, never a task worktree.

## Setting it up as dotfiles

Install [Homebrew](https://brew.sh), then:

```sh
brew install chezmoi
git clone https://github.com/taurean/selvage.git ~/Developer/selvage
chezmoi init --source ~/Developer/selvage
chezmoi diff
chezmoi apply
```

`chezmoi apply` also installs everything in the `Brewfile`, then Node and the
global JS tools in `dot_config/mise/config.toml`.

`chezmoi init` asks for machine-local values (a 1Password account address)
once and keeps them out of the repo. `CONTEXT.md` covers the non-obvious
parts.
