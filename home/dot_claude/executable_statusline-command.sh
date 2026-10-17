#!/usr/bin/env bash
# Status line: user, directory, git branch, model, context used, 5-hour and 7-day
# usage, and the time. Claude Code passes the session as JSON on stdin.
# Adapted from sgaabdu4/claude-code-tips (MIT). Differences: one jq call; bash
# arithmetic instead of bc, which isn't always installed; the model's version is
# the number after its family name, so "Opus 5.5 (1M context)" shows as o5.5, not
# o1; no Nerd Font glyph before the branch; and the clock the article describes.
# Written for bash 3.2 too, which is what macOS runs as `bash`.
input=$(cat)

# Fields are split on \x1f, because `read` merges runs of tabs and an empty field
# would shift the rest.
IFS=$'\x1f' read -r dir model ctx five five_reset week < <(jq -r '[
    .workspace.current_dir // .cwd // "",
    .model.display_name // "",
    .context_window.used_percentage // "",
    .rate_limits.five_hour.used_percentage // "",
    .rate_limits.five_hour.resets_at // "",
    .rate_limits.seven_day.used_percentage // ""
  ] | map(tostring) | join("\u001f")' <<<"$input" 2>/dev/null)

reset=$'\033[0m' bold=$'\033[1m' gray=$'\033[90m' white=$'\033[97m'
cyan=$'\033[96m' blue=$'\033[94m' magenta=$'\033[95m'
sep="$gray │ $reset"

# A 4-cell bar and the percentage, coloured by how full it is.
meter() {
  local pct bar="" color i
  pct=$(printf '%.0f' "$1" 2>/dev/null) || pct=0
  for (( i = 0; i < 4; i++ )); do
    if (( i < (pct * 4 + 50) / 100 )); then bar+="█"; else bar+="░"; fi
  done
  if (( pct < 50 )); then color=$'\033[92m'
  elif (( pct < 75 )); then color=$'\033[93m'
  elif (( pct < 90 )); then color=$'\033[38;5;208m'
  else color=$'\033[91m'
  fi
  printf '%s%s %d%%%s' "$color" "$bar" "$pct" "$reset"
}

# ~/a/b stays as is; deeper paths keep their last two folders.
where=${dir/#$HOME/\~}
IFS=/ read -ra parts <<<"$where"
n=${#parts[@]}
if (( n > 3 )); then where="…/${parts[n-2]}/${parts[n-1]}"; fi

branch=""
if [ -n "$dir" ]; then
  branch=$(GIT_OPTIONAL_LOCKS=0 git -C "$dir" symbolic-ref --short HEAD 2>/dev/null ||
    GIT_OPTIONAL_LOCKS=0 git -C "$dir" rev-parse --short HEAD 2>/dev/null)
fi

if [[ $model =~ (Opus|Sonnet|Haiku|Fable)[[:space:]]+([0-9]+(\.[0-9]+)?) ]]; then
  version=${BASH_REMATCH[2]}
  case ${BASH_REMATCH[1]} in
    Opus) model="o$version" ;;
    Sonnet) model="s$version" ;;
    Haiku) model="h$version" ;;
    Fable) model="f$version" ;;
  esac
fi

out="$bold$cyan${USER:-$(id -un)}$reset"
[ -n "$where" ] && out+="$gray in $reset$white$where$reset"
[ -n "$branch" ] && out+="$gray on $reset$magenta$branch$reset"
[ -n "$model" ] && out+="$sep$blue⬡ $model$reset"
[ -n "$ctx" ] && out+="${sep}${gray}ctx $(meter "$ctx")"
if [ -n "$five" ]; then
  out+="${sep}${gray}5h $(meter "$five")"
  if [[ $five_reset =~ ^[0-9]+$ ]]; then
    left=$(( (five_reset - $(date +%s)) / 60 ))
    if (( left >= 60 )); then out+=" $gray↺$((left / 60))h$((left % 60))m$reset"
    elif (( left > 0 )); then out+=" $gray↺${left}m$reset"
    fi
  fi
fi
[ -n "$week" ] && out+="${sep}${gray}7d $(meter "$week")"
out+="$sep$gray$(date +%H:%M)$reset"

printf '%s' "$out"
