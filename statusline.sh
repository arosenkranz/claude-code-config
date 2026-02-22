#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Extract information from JSON
model_display=$(echo "$input" | jq -r '.model.display_name // empty')
model_id=$(echo "$input" | jq -r '.model.id // "claude"')
current_dir=$(echo "$input" | jq -r '.workspace.current_dir')
session_name=$(echo "$input" | jq -r '.session_name // empty')
output_style=$(echo "$input" | jq -r '.output_style.name // "default"')
vim_mode=$(echo "$input" | jq -r '.vim.mode // empty')
agent_name=$(echo "$input" | jq -r '.agent.name // empty')

# Use display_name as-is if available (e.g. "Sonnet 4.6"), otherwise shorten model.id
if [ -n "$model_display" ]; then
    model_short="$model_display"
else
    model_short=$(echo "$model_id" | sed 's/^claude-//i' | sed 's/-[0-9][0-9-]*$//')
    [ -z "$model_short" ] && model_short="$model_id"
fi

# Extract context window information
context_remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')
ctx_used_tokens=$(echo "$input" | jq -r '.context_window.total_input_tokens // empty')
ctx_total=$(echo "$input" | jq -r '.context_window.context_window_size // empty')

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

# --- Directory: show up to 2 path segments relative to home ---
home_rel="${current_dir/#$HOME/~}"
# Split into parts and take last 2 segments
IFS='/' read -ra parts <<< "$home_rel"
count=${#parts[@]}
if [ "$count" -le 2 ]; then
    dir_display="$home_rel"
elif [ "${parts[0]}" = "~" ] && [ "$count" -eq 3 ]; then
    dir_display="${parts[0]}/${parts[1]}/${parts[2]}"
else
    dir_display="…/${parts[$((count-2))]}/${parts[$((count-1))]}"
fi

# --- Git info ---
cd "$current_dir" 2>/dev/null || cd /

if git --no-optional-locks rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    branch=$(git --no-optional-locks branch --show-current 2>/dev/null || echo "detached")

    # Dirty state
    status_output=$(git --no-optional-locks status --porcelain 2>/dev/null)

    if [ -n "$status_output" ]; then
        total_files=$(echo "$status_output" | wc -l | xargs)
        line_stats=$(git --no-optional-locks diff --numstat HEAD 2>/dev/null | awk '{added+=$1; removed+=$2} END {print added+0, removed+0}')
        added=$(echo $line_stats | cut -d' ' -f1)
        removed=$(echo $line_stats | cut -d' ' -f2)

        git_info=" ${YELLOW}${branch}${NC}"
        [ "$added" -gt 0 ] && git_info="${git_info} ${GREEN}+${added}${NC}"
        [ "$removed" -gt 0 ] && git_info="${git_info} ${RED}-${removed}${NC}"
        git_info="${git_info} ${YELLOW}*${total_files}${NC}"
    else
        git_info=" ${GREEN}${branch}${NC}"
    fi

    # Upstream divergence: ↑ ahead, ↓ behind
    upstream=$(git --no-optional-locks rev-parse --abbrev-ref '@{upstream}' 2>/dev/null)
    if [ -n "$upstream" ]; then
        ahead=$(git --no-optional-locks rev-list --count "@{upstream}..HEAD" 2>/dev/null || echo 0)
        behind=$(git --no-optional-locks rev-list --count "HEAD..@{upstream}" 2>/dev/null || echo 0)
        diverge=""
        [ "$ahead" -gt 0 ] && diverge="${diverge}${GREEN}↑${ahead}${NC}"
        [ "$behind" -gt 0 ] && diverge="${diverge}${RED}↓${behind}${NC}"
        [ -n "$diverge" ] && git_info="${git_info} ${diverge}"
    fi
else
    git_info=""
fi

# --- Session/agent IDs for file lookups ---
session_id=$(echo "$input" | jq -r '.session_id // empty')

# --- Todo count: read from ~/.claude/todos/{session_id}-agent-{session_id}.json ---
todo_count=0
if [ -n "$session_id" ]; then
    todo_file="$HOME/.claude/todos/${session_id}-agent-${session_id}.json"
    if [ -f "$todo_file" ]; then
        todo_count=$(jq '[.[] | select(.status == "pending" or .status == "in_progress")] | length' "$todo_file" 2>/dev/null || echo 0)
    fi
fi


# --- Build status line ---
components="${CYAN}${dir_display}${NC}"

[ -n "$git_info" ] && components="${components}${git_info}"

# Model / agent name
if [ -n "$agent_name" ]; then
    components="${components} ${GRAY}via${NC} ${MAGENTA}${agent_name}${NC}"
else
    components="${components} ${GRAY}via${NC} ${BLUE}${model_short}${NC}"
fi

# Context: used tokens / total + remaining %
if [ -n "$context_remaining" ]; then
    if (( $(echo "$context_remaining < 20" | bc -l 2>/dev/null || echo 0) )); then
        ctx_color="${RED}"
    elif (( $(echo "$context_remaining < 40" | bc -l 2>/dev/null || echo 0) )); then
        ctx_color="${YELLOW}"
    else
        ctx_color="${GREEN}"
    fi

    ctx_pct=$(printf "%.0f" "$context_remaining")

    # Format token counts as Nk if available
    if [ -n "$ctx_used_tokens" ] && [ -n "$ctx_total" ] && [ "$ctx_used_tokens" != "null" ] && [ "$ctx_total" != "null" ]; then
        used_k=$(awk "BEGIN {printf \"%.0f\", $ctx_used_tokens/1000}")
        total_k=$(awk "BEGIN {printf \"%.0f\", $ctx_total/1000}")
        components="${components} ${DIM}[${NC}${ctx_color}${used_k}k/${total_k}k ${ctx_pct}%${NC}${DIM}]${NC}"
    else
        components="${components} ${DIM}[${NC}${ctx_color}${ctx_pct}%${NC}${DIM}]${NC}"
    fi
fi

# Todo count
if [ "$todo_count" -gt 0 ]; then
    components="${components} ${YELLOW}✓${todo_count}${NC}"
fi


# Output style if not default
if [ -n "$output_style" ] && [ "$output_style" != "default" ]; then
    components="${components} ${DIM}(${output_style})${NC}"
fi

# Vim mode
if [ -n "$vim_mode" ]; then
    if [ "$vim_mode" = "NORMAL" ]; then
        components="${components} ${BOLD}${GREEN}[N]${NC}"
    else
        components="${components} ${DIM}[I]${NC}"
    fi
fi

# Session name
if [ -n "$session_name" ]; then
    components="${components} ${DIM}\"${session_name}\"${NC}"
fi

printf "%b\n" "$components"
