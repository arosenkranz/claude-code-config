#!/bin/bash
# SessionStart Hook - Load previous context on new session

CLAUDE_DIR="$HOME/.claude"
SESSIONS_DIR="$CLAUDE_DIR/sessions"
LEARNED_SKILLS_DIR="$CLAUDE_DIR/skills/learned"
ALIASES_FILE="$CLAUDE_DIR/session-aliases.json"

# Find recent session files (last 7 days)
find_recent_sessions() {
    if [[ -d "$SESSIONS_DIR" ]]; then
        # Find .tmp files modified in last 7 days, sorted by modification time (newest first)
        find "$SESSIONS_DIR" -name "*-session.tmp" -type f -mtime -7 2>/dev/null | \
            while read -r file; do
                # Get modification time and file path
                if [[ -f "$file" ]]; then
                    stat -f "%m %N" "$file" 2>/dev/null || stat -c "%Y %n" "$file" 2>/dev/null
                fi
            done | sort -rn | cut -d' ' -f2-
    fi
}

# Count learned skills
count_learned_skills() {
    if [[ -d "$LEARNED_SKILLS_DIR" ]]; then
        find "$LEARNED_SKILLS_DIR" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' '
    else
        echo "0"
    fi
}

# List session aliases
list_aliases() {
    if [[ -f "$ALIASES_FILE" ]] && command -v jq >/dev/null 2>&1; then
        jq -r '.aliases | keys[]' "$ALIASES_FILE" 2>/dev/null | head -5 | tr '\n' ', ' | sed 's/,$//'
    else
        echo ""
    fi
}

# Kill stale dev server processes scoped to the current project directory
kill_stale_project_servers() {
    local project_dir="$PWD"
    # Skip if not in a Code project directory
    [[ "$project_dir" != */Code/* ]] && return

    local killed=0
    local pids
    pids=$(pgrep -f "node.*${project_dir}" 2>/dev/null || true)

    for pid in $pids; do
        local cmd
        cmd=$(ps -p "$pid" -o command= 2>/dev/null || true)

        # Only kill likely dev server processes, skip MCP servers and tsserver
        if echo "$cmd" | grep -qE "(vite|nitro|next|webpack|dev|serve)" && \
           ! echo "$cmd" | grep -qE "(mcp-server|tsserver|task-master|context7)"; then
            kill "$pid" 2>/dev/null || true
            echo "[SessionStart] Killed stale process (PID $pid): ${cmd:0:80}" >&2
            ((killed++))
        fi
    done

    if [[ $killed -gt 0 ]]; then
        echo "[SessionStart] Cleaned up $killed stale dev server(s) in $project_dir" >&2
    fi
}

# Detect package manager
detect_package_manager() {
    local pm_name="npm"
    local pm_source="default"

    # 1. Check CLAUDE_PACKAGE_MANAGER environment variable
    if [[ -n "$CLAUDE_PACKAGE_MANAGER" ]]; then
        pm_name="$CLAUDE_PACKAGE_MANAGER"
        pm_source="environment variable"
        echo "$pm_name|$pm_source"
        return
    fi

    # 2. Check project .claude/package-manager.json
    if [[ -f ".claude/package-manager.json" ]] && command -v jq >/dev/null 2>&1; then
        local project_pm=$(jq -r '.packageManager // empty' .claude/package-manager.json 2>/dev/null)
        if [[ -n "$project_pm" ]]; then
            pm_name="$project_pm"
            pm_source="project config"
            echo "$pm_name|$pm_source"
            return
        fi
    fi

    # 3. Check package.json packageManager field
    if [[ -f "package.json" ]] && command -v jq >/dev/null 2>&1; then
        local pkg_pm=$(jq -r '.packageManager // empty' package.json 2>/dev/null | cut -d'@' -f1)
        if [[ -n "$pkg_pm" ]]; then
            pm_name="$pkg_pm"
            pm_source="package.json"
            echo "$pm_name|$pm_source"
            return
        fi
    fi

    # 4. Check lock files
    if [[ -f "pnpm-lock.yaml" ]]; then
        pm_name="pnpm"
        pm_source="pnpm-lock.yaml"
    elif [[ -f "bun.lockb" ]]; then
        pm_name="bun"
        pm_source="bun.lockb"
    elif [[ -f "yarn.lock" ]]; then
        pm_name="yarn"
        pm_source="yarn.lock"
    elif [[ -f "package-lock.json" ]]; then
        pm_name="npm"
        pm_source="package-lock.json"
    else
        # 5. Check global config
        if [[ -f "$HOME/.claude/package-manager.json" ]] && command -v jq >/dev/null 2>&1; then
            local global_pm=$(jq -r '.packageManager // empty' "$HOME/.claude/package-manager.json" 2>/dev/null)
            if [[ -n "$global_pm" ]]; then
                pm_name="$global_pm"
                pm_source="global config"
                echo "$pm_name|$pm_source"
                return
            fi
        fi

        # 6. Check which package managers are installed (priority: pnpm > bun > yarn > npm)
        if command -v pnpm >/dev/null 2>&1; then
            pm_name="pnpm"
            pm_source="fallback (installed)"
        elif command -v bun >/dev/null 2>&1; then
            pm_name="bun"
            pm_source="fallback (installed)"
        elif command -v yarn >/dev/null 2>&1; then
            pm_name="yarn"
            pm_source="fallback (installed)"
        elif command -v npm >/dev/null 2>&1; then
            pm_name="npm"
            pm_source="fallback (installed)"
        else
            pm_name="npm"
            pm_source="default (not found)"
        fi
    fi

    echo "$pm_name|$pm_source"
}

# Main execution
main() {
    # Kill stale dev servers from previous sessions
    kill_stale_project_servers

    # Find recent sessions
    recent_sessions=($(find_recent_sessions))
    session_count=${#recent_sessions[@]}

    if [[ $session_count -gt 0 ]]; then
        echo "[SessionStart] Found $session_count recent session(s)" >&2
        echo "[SessionStart] Latest: ${recent_sessions[0]}" >&2
    fi

    # Check for learned skills
    skill_count=$(count_learned_skills)
    if [[ $skill_count -gt 0 ]]; then
        echo "[SessionStart] $skill_count learned skill(s) available in $LEARNED_SKILLS_DIR" >&2
    fi

    # Check for session aliases
    aliases=$(list_aliases)
    if [[ -n "$aliases" ]]; then
        alias_count=$(echo "$aliases" | tr ',' '\n' | grep -v '^$' | wc -l | tr -d ' ')
        echo "[SessionStart] $alias_count session alias(es) available: $aliases" >&2
        echo "[SessionStart] Use /sessions load <alias> to continue a previous session" >&2
    fi

    # Hint wade when uncommitted work exists
    if git -C "$PWD" rev-parse --git-dir >/dev/null 2>&1; then
        if git -C "$PWD" status --porcelain 2>/dev/null | grep -q '^'; then
            echo "[SessionStart] Uncommitted changes detected. Consider invoking wade for a project briefing." >&2
        fi
    fi

    # Detect package manager
    pm_info=$(detect_package_manager)
    pm_name=$(echo "$pm_info" | cut -d'|' -f1)
    pm_source=$(echo "$pm_info" | cut -d'|' -f2)

    echo "[SessionStart] Package manager: $pm_name (detected from $pm_source)" >&2

    # Show configuration prompt if using fallback or default
    if [[ "$pm_source" == "fallback"* ]] || [[ "$pm_source" == "default"* ]]; then
        echo "[SessionStart] No package manager preference found." >&2
        echo "[SessionStart] To set your preferred package manager:" >&2
        echo "[SessionStart]   - Global: export CLAUDE_PACKAGE_MANAGER=pnpm" >&2
        echo "[SessionStart]   - Or add to ~/.claude/package-manager.json: {\"packageManager\": \"pnpm\"}" >&2
        echo "[SessionStart]   - Or add to package.json: {\"packageManager\": \"pnpm@8\"}" >&2
    fi

    exit 0
}

main "$@"
