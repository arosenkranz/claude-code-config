#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Extract information from JSON
model_name=$(echo "$input" | jq -r '.model.display_name')
current_dir=$(echo "$input" | jq -r '.workspace.current_dir')
session_name=$(echo "$input" | jq -r '.session_name // empty')
output_style=$(echo "$input" | jq -r '.output_style.name // "default"')
vim_mode=$(echo "$input" | jq -r '.vim.mode // empty')
agent_name=$(echo "$input" | jq -r '.agent.name // empty')

# Extract context window information using pre-calculated percentages
context_remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')

# Get directory name (basename)
dir_name=$(basename "$current_dir")

# Colors (using printf-compatible escape sequences for dimmed display)
printf -v BLUE '\033[34m'
printf -v CYAN '\033[36m'
printf -v GREEN '\033[32m'
printf -v YELLOW '\033[33m'
printf -v RED '\033[31m'
printf -v MAGENTA '\033[35m'
printf -v GRAY '\033[90m'
printf -v BOLD '\033[1m'
printf -v DIM '\033[2m'
printf -v NC '\033[0m'

# Change to the current directory to get git info
cd "$current_dir" 2>/dev/null || cd /

# Get git branch (skip optional locks like Starship does)
if git --no-optional-locks rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    branch=$(git --no-optional-locks branch --show-current 2>/dev/null || echo "detached")

    # Get git status with file counts
    status_output=$(git --no-optional-locks status --porcelain 2>/dev/null)

    if [ -n "$status_output" ]; then
        # Count files and get basic line stats
        total_files=$(echo "$status_output" | wc -l | xargs)
        line_stats=$(git --no-optional-locks diff --numstat HEAD 2>/dev/null | awk '{added+=$1; removed+=$2} END {print added+0, removed+0}')

        added=$(echo $line_stats | cut -d' ' -f1)
        removed=$(echo $line_stats | cut -d' ' -f2)

        # Build status display (Starship/Spaceship style)
        git_info=" ${YELLOW}${branch}${NC}"

        [ "$added" -gt 0 ] && git_info="${git_info} ${GREEN}+${added}${NC}"
        [ "$removed" -gt 0 ] && git_info="${git_info} ${RED}-${removed}${NC}"
        git_info="${git_info} ${YELLOW}*${total_files}${NC}"
    else
        git_info=" ${GREEN}${branch}${NC}"
    fi
else
    git_info=""
fi

# Build status line components
components="${CYAN}${dir_name}${NC}"

# Add git info if present
[ -n "$git_info" ] && components="${components}${git_info}"

# Add model name (with agent if present)
if [ -n "$agent_name" ]; then
    components="${components} ${GRAY}via${NC} ${MAGENTA}${agent_name}${NC}"
else
    components="${components} ${GRAY}via${NC} ${BLUE}${model_name}${NC}"
fi

# Add context remaining percentage if available
if [ -n "$context_remaining" ]; then
    # Color code based on remaining percentage
    if (( $(echo "$context_remaining < 20" | bc -l 2>/dev/null || echo 0) )); then
        ctx_color="${RED}"
    elif (( $(echo "$context_remaining < 40" | bc -l 2>/dev/null || echo 0) )); then
        ctx_color="${YELLOW}"
    else
        ctx_color="${GREEN}"
    fi

    # Format percentage to one decimal
    ctx_pct=$(printf "%.0f" "$context_remaining")
    components="${components} ${DIM}[${NC}${ctx_color}${ctx_pct}%${NC}${DIM}]${NC}"
fi

# Add output style if not default
if [ -n "$output_style" ] && [ "$output_style" != "default" ]; then
    components="${components} ${DIM}(${output_style})${NC}"
fi

# Add vim mode if present
if [ -n "$vim_mode" ]; then
    if [ "$vim_mode" = "NORMAL" ]; then
        components="${components} ${BOLD}${GREEN}[N]${NC}"
    else
        components="${components} ${DIM}[I]${NC}"
    fi
fi

# Add session name if present
if [ -n "$session_name" ]; then
    components="${components} ${DIM}\"${session_name}\"${NC}"
fi

# Output the status line
printf "%b\n" "$components"
