#!/bin/bash
input=$(cat)
model=$(echo "$input" | jq -r '.model.display_name // "unknown"')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
cwd=$(echo "$input" | jq -r '.cwd // empty')

# ANSI colors
reset='\033[0m'
dim='\033[2m'
green='\033[32m'
orange='\033[38;2;232;133;92m'
red='\033[38;2;239;68;68m'
cyan='\033[36m'
magenta='\033[35m'

# Git branch
branch=""
if [ -n "$cwd" ] && [ -d "$cwd" ]; then
  branch=$(git -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null)
fi

# Shorten cwd: replace home with ~, then show only last 2 path segments
if [ -n "$cwd" ]; then
  short_cwd="${cwd/#$HOME/~}"
  depth=$(echo "$short_cwd" | tr '/' '\n' | wc -l)
  if [ "$depth" -gt 3 ]; then
    short_cwd="…/$(echo "$short_cwd" | rev | cut -d'/' -f1-2 | rev)"
  fi
fi

# Context bar
if [ -n "$used" ]; then
  pct=$(printf '%.0f' "$used")
else
  pct=0
fi

if [ "$pct" -lt 50 ]; then
  color="$green"
elif [ "$pct" -lt 80 ]; then
  color="$orange"
else
  color="$red"
fi

blocks=("" "▏" "▎" "▍" "▌" "▋" "▊" "▉" "█")
width=10
total_eighths=$(( pct * width * 8 / 100 ))
full_cells=$(( total_eighths / 8 ))
remainder=$(( total_eighths % 8 ))
empty_cells=$(( width - full_cells - (remainder > 0 ? 1 : 0) ))

bar=""
for ((i=0; i<full_cells; i++)); do bar+="█"; done
if [ "$remainder" -gt 0 ]; then
  bar+="${blocks[$remainder]}"
fi

empty_bar=""
for ((i=0; i<empty_cells; i++)); do empty_bar+="░"; done

ctx="${color}${bar}${reset}${dim}${empty_bar}${reset} ${color}${pct}%${reset}"

# Format cost
cost_str=""
if [ -n "$cost" ] && [ "$cost" != "0" ]; then
  cost_fmt=$(printf '%.2f' "$cost")
  cost_str="(\$${cost_fmt})"
fi

# Build output: model bar · $cost · dir (branch)
sep=" ${dim}│${reset} "
output="$model ${ctx}"
[ -n "$cost_str" ] && output+=" ${cost_str}"
[ -n "$short_cwd" ] && output+="${sep}${cyan}${short_cwd}${reset}"
[ -n "$branch" ] && output+=" ${dim}(${reset}${magenta}${branch}${reset}${dim})${reset}"

printf '%b' "$output"
