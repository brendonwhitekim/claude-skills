#!/usr/bin/env bash

input=$(cat)

# --- Extract fields from JSON ---
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
model=$(echo "$input" | jq -r '.model.display_name // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
ctx_size=$(echo "$input" | jq -r '.context_window.context_window_size // empty')
input_tokens=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // empty')
output_tokens=$(echo "$input" | jq -r '.context_window.current_usage.output_tokens // empty')
cache_write=$(echo "$input" | jq -r '.context_window.current_usage.cache_creation_input_tokens // 0')
cache_read=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // 0')

# --- Git branch (skip optional locks to avoid blocking) ---
git_branch=""
if [ -n "$cwd" ]; then
  git_branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)
fi

# --- Progress bar (10 chars wide) ---
bar=""
if [ -n "$used_pct" ]; then
  filled=$(echo "$used_pct" | awk '{printf "%d", ($1 / 10 + 0.5)}')
  filled=$(( filled > 10 ? 10 : filled ))
  empty=$(( 10 - filled ))
  bar=$(printf '%0.s█' $(seq 1 $filled 2>/dev/null) 2>/dev/null || true)
  # Fallback if seq with no args fails
  bar=""
  for i in $(seq 1 $filled); do bar="${bar}█"; done
  for i in $(seq 1 $empty); do bar="${bar}░"; done
fi

# --- Cost estimate (cumulative session tokens, rough estimate) ---
cost_str=""
if [ -n "$input_tokens" ] && [ -n "$output_tokens" ]; then
  # Use awk for floating point arithmetic
  # Pricing approximation (varies by model, using Sonnet-class as default):
  #   Input:  $3.00 / 1M tokens
  #   Output: $15.00 / 1M tokens
  #   Cache write: $3.75 / 1M, Cache read: $0.30 / 1M
  total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
  total_output=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
  cost=$(awk -v ti="$total_input" -v to="$total_output" \
    'BEGIN { cost = (ti * 3.00 + to * 15.00) / 1000000; printf "%.4f", cost }')
  cost_str="\$${cost}"
fi

# --- ANSI colors (will appear dimmed in status line) ---
RESET='\033[0m'
BOLD='\033[1m'
CYAN='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
MAGENTA='\033[35m'
BLUE='\033[34m'

# --- Assemble output ---
parts=()

# Current directory (basename to keep it short, like PS1 %1~)
if [ -n "$cwd" ]; then
  dir_display=$(basename "$cwd")
  parts+=("$(printf "${CYAN}%s${RESET}" "$dir_display")")
fi

# Git branch
if [ -n "$git_branch" ]; then
  parts+=("$(printf "${GREEN} %s${RESET}" "$git_branch")")
fi

# Model
if [ -n "$model" ]; then
  parts+=("$(printf "${MAGENTA}%s${RESET}" "$model")")
fi

# Context progress bar + percentage
if [ -n "$bar" ] && [ -n "$used_pct" ]; then
  pct_display=$(printf "%.0f" "$used_pct")
  parts+=("$(printf "${YELLOW}ctx [%s] %s%%${RESET}" "$bar" "$pct_display")")
fi

# Cost
if [ -n "$cost_str" ]; then
  parts+=("$(printf "${BLUE}%s${RESET}" "$cost_str")")
fi

# Join parts with separator
output=""
for part in "${parts[@]}"; do
  if [ -z "$output" ]; then
    output="$part"
  else
    output="$output  $part"
  fi
done

printf "%b\n" "$output"
