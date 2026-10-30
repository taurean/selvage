#!/bin/bash
# Claude Code status line: dir · branch* · model · context% · 5h%
# Selvage-managed. See ~/Developer/selvage/dot_claude/executable_statusline.sh
#
# Claude Code pipes session JSON on stdin
# (https://code.claude.com/docs/en/statusline). Colors are ANSI palette slots,
# not hex, so they follow the terminal theme. Fields Claude Code leaves out
# (rate_limits before the first response, or on API-key auth) are dropped,
# not shown as empty.
set -uo pipefail

input=$(cat)
field() { jq -r "$1 // empty" <<<"$input"; }

dir=$(field '.workspace.current_dir')
model=$(field '.model.display_name')
context_pct=$(field '.context_window.used_percentage')
five_hour_pct=$(field '.rate_limits.five_hour.used_percentage')

dim=$'\033[2m'
blue=$'\033[34m'
magenta=$'\033[35m'
reset=$'\033[0m'

display_dir=$dir
[[ "$dir" == "$HOME"* ]] && display_dir="~${dir#"$HOME"}"

segments=()
[[ -n "$dir" ]] && segments+=("${blue}${display_dir}${reset}")

if [[ -n "$dir" ]] && branch=$(git -C "$dir" branch --show-current 2>/dev/null) && [[ -n "$branch" ]]; then
  dirty=""
  [[ -n $(git -C "$dir" status --porcelain 2>/dev/null | head -1) ]] && dirty="*"
  segments+=("${magenta}${branch}${dirty}${reset}")
fi

[[ -n "$model" ]] && segments+=("$model")
[[ -n "$context_pct" ]] && segments+=("ctx $(printf '%.0f' "$context_pct")%")
[[ -n "$five_hour_pct" ]] && segments+=("5h $(printf '%.0f' "$five_hour_pct")%")

separator=" ${dim}·${reset} "
line=""
for segment in "${segments[@]}"; do
  line+="${line:+$separator}$segment"
done
printf '%s\n' "$line"
