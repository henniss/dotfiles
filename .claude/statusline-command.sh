#!/usr/bin/env bash
# Claude Code status line - mirrors harrise zsh theme

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
model=$(echo "$input" | jq -r '.model.display_name // ""')

# Trailing directory component (mirrors %c)
dir=$(basename "$cwd")

# Host display: prefer CODER_WORKSPACE_NAME, then check for MacBook shorthand, else hostname
if [ -n "${CODER_WORKSPACE_NAME:-}" ]; then
    host="$CODER_WORKSPACE_NAME"
else
    raw_host=$(hostname)
    if echo "$raw_host" | grep -qE '(.*-MacBook-Pro\.local|.*-MBP\.localdomain)'; then
        host="MB"
    else
        host=$(hostname -s)
    fi
fi

# Git branch and dirty state (skip optional locks)
git_branch=""
git_dirty=""
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
    git_branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
    if [ -n "$(git -C "$cwd" status --porcelain 2>/dev/null)" ]; then
        git_dirty=" ✗"
    fi
fi

# ANSI colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BLUE_BOLD='\033[1;34m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
RESET='\033[0m'

# Assemble output
printf "${GREEN}%s${RESET}" "$host"
printf " ${CYAN}%s${RESET}" "$dir"

if [ -n "$git_branch" ]; then
    printf " ${BLUE_BOLD}git:(${RED}%s${BLUE_BOLD})${RESET}" "$git_branch"
    if [ -n "$git_dirty" ]; then
        printf "${YELLOW}%s${RESET}" "$git_dirty"
    fi
fi

if [ -n "$model" ]; then
    printf " ${CYAN}[%s]${RESET}" "$model"
fi

echo ""
