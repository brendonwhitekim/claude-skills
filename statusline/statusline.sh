#!/bin/bash
input=$(cat)

fmt_tok() {
  if [ "$1" -ge 1000 ]; then
    awk -v n="$1" 'BEGIN {printf "%.0fk", n/1000}'
  else
    echo "$1"
  fi
}

color_pct() {
  local p=$1
  if [ "$p" -ge 80 ]; then echo "\033[1;31m"
  elif [ "$p" -ge 50 ]; then echo "\033[1;33m"
  else echo "\033[1;32m"
  fi
}

MODEL_ID=$(echo "$input" | jq -r '.model.id // "claude"')

COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
COST_STR=$(awk "BEGIN {printf \"\$%.2f\", $COST}")

DURATION_MS=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')
DURATION_S=$((DURATION_MS / 1000))
if [ "$DURATION_S" -lt 60 ]; then
  DUR_STR="${DURATION_S}s"
elif [ "$DURATION_S" -lt 3600 ]; then
  DUR_STR="$((DURATION_S / 60))m"
else
  HOURS=$((DURATION_S / 3600))
  MINS=$(( (DURATION_S % 3600) / 60 ))
  DUR_STR="${HOURS}h${MINS}m"
fi

CWD=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // "."')
GIT_BRANCH=$(cd "$CWD" 2>/dev/null && git branch --show-current 2>/dev/null)
GIT_PART=""
if [ -n "$GIT_BRANCH" ]; then
  GIT_PART=" \033[2m|\033[0m \033[0;35m${GIT_BRANCH}\033[0m"
fi

LINES_ADDED=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
LINES_REMOVED=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')
LINES_PART=""
if [ "$LINES_ADDED" -gt 0 ] || [ "$LINES_REMOVED" -gt 0 ]; then
  LINES_PART=" \033[2m|\033[0m \033[1;32m+${LINES_ADDED}\033[0m \033[1;31m-${LINES_REMOVED}\033[0m"
fi

PCT_RAW=$(echo "$input" | jq -r '.context_window.used_percentage // 0')
PCT=$(awk "BEGIN {printf \"%d\", $PCT_RAW}")

BAR_WIDTH=15
FILLED=$(( PCT * BAR_WIDTH / 100 ))
[ "$FILLED" -gt "$BAR_WIDTH" ] && FILLED=$BAR_WIDTH
EMPTY=$(( BAR_WIDTH - FILLED ))
BAR=""
for ((i=0; i<FILLED; i++)); do BAR+="█"; done
for ((i=0; i<EMPTY; i++)); do BAR+="░"; done

IN_TOK=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // 0')
OUT_TOK=$(echo "$input" | jq -r '.context_window.current_usage.output_tokens // 0')
CACHE_READ=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // 0')
CACHE_CREATE=$(echo "$input" | jq -r '.context_window.current_usage.cache_creation_input_tokens // 0')

CACHE_TOTAL=$((CACHE_READ + CACHE_CREATE + IN_TOK))
if [ "$CACHE_TOTAL" -gt 0 ]; then
  CACHE_PCT=$((CACHE_READ * 100 / CACHE_TOTAL))
else
  CACHE_PCT=0
fi

IN_TOK_STR=$(fmt_tok "$IN_TOK")
OUT_TOK_STR=$(fmt_tok "$OUT_TOK")

RL_5H=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty' | cut -d. -f1)
RL_7D=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty' | cut -d. -f1)
RL_PART=""
if [ -n "$RL_5H" ] || [ -n "$RL_7D" ]; then
  RL_PART=" \033[2m|\033[0m"
  if [ -n "$RL_5H" ]; then
    C5=$(color_pct "$RL_5H")
    RL_PART="${RL_PART} ${C5}5h:${RL_5H}%\033[0m"
  fi
  if [ -n "$RL_7D" ]; then
    C7=$(color_pct "$RL_7D")
    RL_PART="${RL_PART} ${C7}7d:${RL_7D}%\033[0m"
  fi
fi

if [ "$PCT" -ge 85 ]; then
  COMPACT_WARN=" \033[1;31m[COMPACT-SOON]\033[0m"
elif [ "$PCT" -ge 75 ]; then
  COMPACT_WARN=" \033[1;33m[COMPACT-WARN]\033[0m"
else
  COMPACT_WARN=""
fi

if [ "$PCT" -ge 85 ]; then
  BAR_COLOR="\033[1;31m"
elif [ "$PCT" -ge 60 ]; then
  BAR_COLOR="\033[1;33m"
else
  BAR_COLOR="\033[1;32m"
fi

LINE1="\033[1;36m${MODEL_ID}\033[0m \033[2m|\033[0m \033[1;32m${COST_STR}\033[0m \033[2m|\033[0m \033[0;37m${DUR_STR}\033[0m${GIT_PART}${LINES_PART}"
LINE2="${BAR_COLOR}[${BAR}]\033[0m ${PCT}% \033[2m|\033[0m in:${IN_TOK_STR} out:${OUT_TOK_STR} cache:${CACHE_PCT}%${RL_PART}${COMPACT_WARN}"

printf "%b\n" "$LINE1"
printf "%b\n" "$LINE2"
