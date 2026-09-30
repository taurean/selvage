# Base system paths
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:/opt/homebrew/sbin"

# Language managers: pyenv, rbenv, volta, go, rust, deno
export PATH="$HOME/.pyenv/shims:$HOME/.rbenv/shims:$HOME/.volta/bin:/usr/local/go/bin:$HOME/.cargo/bin:$HOME/.deno/bin:$PATH"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# Custom user bins
export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:$PATH"

# Tool-managed paths (installer-appended; do not reorder)
export PATH="$HOME/.cache/lm-studio/bin:$PATH"
export PATH="$HOME/.mavis/bin:$PATH"
export PATH="$HOME/.opencode/bin:$PATH"
export PATH="/Library/Frameworks/Python.framework/Versions/3.12/bin:$PATH"
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

# Re-prepend ~/.local/bin so it wins over the installer-appended paths above.
# Originally added to dot_zshrc by the Hermes installer (2026-07); Hermes was
# uninstalled 2026-09-09 and the line moved here, where PATH belongs.
# Its one remaining effect: uv's python3.12 in ~/.local/bin wins over the
# /Library/Frameworks build on line 21. Everything else in ~/.local/bin
# (claude, uv, uvx) is unique to it and resolves either way.
export PATH="$HOME/.local/bin:$PATH"
