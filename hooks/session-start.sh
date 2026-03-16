#!/bin/bash
# SessionStart Hook - Load previous context on new session
# Recreated locally from everything-claude-code plugin

CLAUDE_DIR="$HOME/.claude"
SESSIONS_DIR="$CLAUDE_DIR/sessions"
LEARNED_SKILLS_DIR="$CLAUDE_DIR/skills/learned"
ALIASES_FILE="$CLAUDE_DIR/session-aliases.json"
CONFIG_REPO="$HOME/Code/claude-code-config"

# Sync a ~/.claude/<component> directory with its config repo counterpart.
# Works for both directory-based items (skills) and file-based items (agents, hooks).
# Args: $1=local dir, $2=config repo dir, $3=find type (d=directory, f=file), $4=label
sync_component() {
    local local_dir="$1"
    local config_dir="$2"
    local find_type="$3"
    local label="$4"
    local moved=0

    # Step 1: real items (not symlinks) in local dir → move to config repo, replace with symlink
    while IFS= read -r -d '' item; do
        local name
        name=$(basename "$item")
        local dest="$config_dir/$name"

        if [[ ! -e "$dest" ]]; then
            mv "$item" "$dest"
            ln -s "$dest" "$item"
            echo "[SessionStart] Synced new $label to config repo: $name" >&2
            ((moved++))
        fi
    done < <(find "$local_dir" -mindepth 1 -maxdepth 1 -type "$find_type" -print0 2>/dev/null)

    # Step 2: config repo items with no corresponding symlink → create symlink
    while IFS= read -r -d '' config_item; do
        local name
        name=$(basename "$config_item")
        local link="$local_dir/$name"

        if [[ ! -e "$link" ]]; then
            ln -s "$config_item" "$link"
            echo "[SessionStart] Created missing $label symlink: $name" >&2
        fi
    done < <(find "$config_dir" -mindepth 1 -maxdepth 1 -type "$find_type" -print0 2>/dev/null)

    if [[ $moved -gt 0 ]]; then
        echo "[SessionStart] $moved $label(s) need committing — run: git -C $CONFIG_REPO add $label && git commit" >&2
    fi
}

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

    # Sync skills, agents, and hooks with config repo
    if [[ -d "$CONFIG_REPO" ]]; then
        sync_component "$CLAUDE_DIR/skills"  "$CONFIG_REPO/skills"  "d" "skill"
        sync_component "$CLAUDE_DIR/agents"  "$CONFIG_REPO/agents"  "f" "agent"
        sync_component "$CLAUDE_DIR/hooks"   "$CONFIG_REPO/hooks"   "f" "hook"
    fi

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

    # Memory briefing from SQLite
    MEMORY_DB="${MEMORY_DB_PATH:-$HOME/.claude/memory.db}"
    if [[ -f "$MEMORY_DB" ]] && command -v sqlite3 >/dev/null 2>&1; then
        CWD_PATH="${PWD:-$HOME}"
        PROJECT_SCOPE=""
        if [[ "$CWD_PATH" == */Code/* ]]; then
            PROJECT_NAME=$(echo "$CWD_PATH" | sed 's|.*/Code/||' | cut -d'/' -f1)
            PROJECT_SCOPE="project:$PROJECT_NAME"
        fi

        if [[ -n "$PROJECT_SCOPE" ]]; then
            RECENT=$(sqlite3 "$MEMORY_DB" "SELECT e.name || ' (' || e.entity_type || '): ' || o.content FROM observations o JOIN entities e ON e.id = o.entity_id WHERE e.scope = '$PROJECT_SCOPE' AND o.created_at > strftime('%s','now','-7 days') ORDER BY o.created_at DESC LIMIT 10;" 2>/dev/null)
            if [[ -n "$RECENT" ]]; then
                echo "[Memory] Recent context for $PROJECT_SCOPE:" >&2
                echo "$RECENT" | while IFS= read -r line; do echo "[Memory]   * $line" >&2; done
            fi
        fi

        GLOBALS=$(sqlite3 "$MEMORY_DB" "SELECT e.name || ' (' || e.entity_type || '): ' || o.content FROM observations o JOIN entities e ON e.id = o.entity_id WHERE e.scope = 'global' AND o.confidence >= 0.8 ORDER BY o.confidence DESC, o.created_at DESC LIMIT 5;" 2>/dev/null)
        if [[ -n "$GLOBALS" ]]; then
            echo "[Memory] Key global context:" >&2
            echo "$GLOBALS" | while IFS= read -r line; do echo "[Memory]   * $line" >&2; done
        fi

        EXPIRING=$(sqlite3 "$MEMORY_DB" "SELECT e.name || ': ' || o.content || ' (expires ' || date(o.expires_at,'unixepoch') || ')' FROM observations o JOIN entities e ON e.id = o.entity_id WHERE o.expires_at IS NOT NULL AND o.expires_at < strftime('%s','now','+7 days') AND o.expires_at > strftime('%s','now') ORDER BY o.expires_at ASC LIMIT 5;" 2>/dev/null)
        if [[ -n "$EXPIRING" ]]; then
            echo "[Memory] Expiring soon:" >&2
            echo "$EXPIRING" | while IFS= read -r line; do echo "[Memory]   ! $line" >&2; done
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
