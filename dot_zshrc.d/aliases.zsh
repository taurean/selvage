# please — sudo wrapper: `please cmd` or `please` to re-run last command as sudo
please() {
  if [[ "$#" -gt 0 ]]; then
    sudo "$@"
  else
    sudo $SHELL -c "$(fc -ln -1)"
  fi
}

# Git release log — commits since last tag
alias releaselog='git log $(git describe --tags --abbrev=0)..HEAD --pretty=format:"%h %s"'
alias gitrecap=releaselog
alias git-recap=releaselog
alias taglog=releaselog
