# A fresh tmux server (bare `tmux`, no server running yet) should start where the
# git repos live. Attaches and all explicit subcommands pass through untouched.
tmux() {
  if (( $# == 0 )) && ! command tmux ls &>/dev/null; then
    command tmux new-session -c "$HOME/Developer"
  else
    command tmux "$@"
  fi
}
