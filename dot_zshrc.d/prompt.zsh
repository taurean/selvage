autoload -Uz vcs_info add-zsh-hook
zmodload zsh/datetime
setopt PROMPT_SUBST

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr   '+'
zstyle ':vcs_info:git:*' unstagedstr '*'
zstyle ':vcs_info:git:*' formats       '%b DIRTY:%c%u'
zstyle ':vcs_info:git:*' actionformats '%b|%a DIRTY:%c%u'

_c_dim=$'%{\e[38;5;244m%}'
_c_dir=$'%{\e[38;5;179m%}'
_c_branch=$'%{\e[38;5;73m%}'
_c_dirty=$'%{\e[38;5;173m%}'
_c_glyph=$'%{\e[38;5;140m%}'
_c_reset=$'%{\e[0m%}'

_ordinal() {
  case $1 in
    1|21|31) print -n st ;;
    2|22)    print -n nd ;;
    3|23)    print -n rd ;;
    *)       print -n th ;;
  esac
}

_build_prompt() {
  vcs_info

  # "wed 24th, 2:35pm"
  local dow=${(L)$(strftime '%a' $EPOCHSECONDS)}
  local day=${$(strftime '%e' $EPOCHSECONDS)## }   # strip leading space from %e
  local tod_raw=${$(strftime '%l:%M %p' $EPOCHSECONDS)## }  # strip leading space from %l
  local tod=${(L)tod_raw}  # AM/PM → am/pm
  local date_str="${dow} ${day}$(_ordinal $day), ${tod}"

  # Git segment — plain copy for width math, colored copy for display
  local git_plain='' git_colored=''
  if [[ -n "${vcs_info_msg_0_}" ]]; then
    local raw="${vcs_info_msg_0_}"
    local branch="${raw%% DIRTY:*}"
    local markers="${raw##*DIRTY:}"
    git_plain="  [${branch}"
    git_colored="  ${_c_dim}[${_c_reset}${_c_branch}${branch}${_c_reset}"
    if [[ -n "$markers" ]]; then
      git_plain+=" · ${markers}"
      git_colored+="${_c_dim} ·${_c_reset} ${_c_dirty}${markers}${_c_reset}"
    fi
    git_plain+=']'
    git_colored+="${_c_dim}]${_c_reset}"
  fi

  local right_plain="${git_plain}  ${date_str}"
  local right_colored="${git_colored}  ${_c_dim}${date_str}${_c_reset}"

  # Expand %~ to get the actual display string and its character width
  local path_display=${(%):-%~}
  local pad=$(( COLUMNS - ${#path_display} - ${#right_plain} ))
  (( pad < 1 )) && pad=1

  _PROMPT_LINE1="${_c_dir}${path_display}${_c_reset}${(l:$pad:: :)}${right_colored}"
}

add-zsh-hook precmd _build_prompt

PROMPT='
$_PROMPT_LINE1
${_c_glyph}❊${_c_reset} '
