# Selvage Brewfile. `chezmoi apply` installs every entry
# (.chezmoiscripts/run_onchange_before_10-brew-bundle.sh.tmpl). It only adds:
# deleting an entry here doesn't uninstall the package.

# Dotfiles and repo
brew "chezmoi"
brew "gh"

# Terminal & shell
cask "wezterm"
cask "ghostty"
cask "font-monaspace"

# AI coding agents. claude comes from Claude Code's native installer instead.
brew "anomalyco/tap/opencode"

# Editor
brew "neovim"
brew "tree-sitter-cli"

# Search & navigation
brew "ripgrep"
brew "fd"

# Git
brew "git-lfs"

# 1Password CLI (`op`)
cask "1password-cli"

# Language managers. mise owns Node and global JS tools
# (dot_config/mise/config.toml).
brew "mise"
brew "pyenv"
brew "rbenv"
