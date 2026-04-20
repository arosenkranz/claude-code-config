#!/bin/bash
# DEPRECATED: This script references a legacy flat-layout (skills/ at repo root) that no longer exists.
# The repo now uses the marketplace plugin layout under plugins/. Use the marketplace setup
# documented in .claude/rules/workflows.md instead.
# This script will be removed when the plugin split (PR 3) ships.
echo "WARNING: sync.sh is deprecated and targets a layout that no longer exists. See .claude/rules/workflows.md." >&2
exit 0

set -e

CONFIG_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$CONFIG_DIR/.backup"
DRY_RUN=false

# Colors
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
GRAY='\033[0;90m'
BOLD='\033[1m'
RESET='\033[0m'

# Usage info
usage() {
    echo "Usage: ./sync.sh [command] [options]"
    echo ""
    echo "Commands:"
    echo "  (none)             Show sync status of all items"
    echo "  add <type> <name>  Add local item to repo and create symlink"
    echo "  remove <type> <name>  Remove item from repo (keep local copy)"
    echo "  pull               Pull latest changes and reinstall"
    echo "  push               Commit and push changes"
    echo "  undo               Restore from last backup"
    echo "  validate           Check all skills for valid frontmatter"
    echo "  backups            List available backups"
    echo ""
    echo "Types: skill, agent, rule, hook"
    echo ""
    echo "Options:"
    echo "  -n, --dry-run      Preview changes without applying them"
    echo "  -h, --help         Show this help message"
}

# Parse dry-run flag
parse_flags() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -n|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                return 0
                ;;
        esac
    done
}

# Create backup
create_backup() {
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_path="$BACKUP_DIR/$timestamp"
    mkdir -p "$backup_path"
    echo "$backup_path"
}

# Write manifest
write_manifest() {
    local backup_path="$1"
    local operation="$2"
    shift 2
    local items=("$@")

    cat > "$backup_path/manifest.json" << EOF
{
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "operation": "$operation",
    "items": [$(printf '"%s",' "${items[@]}" | sed 's/,$//')],
    "user": "$USER",
    "hostname": "$(hostname)"
}
EOF
}

# Check item status
check_status() {
    local type="$1"
    local name="$2"
    local repo_path=""
    local local_path=""

    case $type in
        skill)
            repo_path="$CONFIG_DIR/skills/$name"
            local_path=~/.claude/skills/"$name"
            ;;
        agent)
            repo_path="$CONFIG_DIR/agents/$name.md"
            local_path=~/.claude/agents/"$name.md"
            ;;
        rule)
            repo_path="$CONFIG_DIR/rules/$name.md"
            local_path=~/.claude/rules/"$name.md"
            ;;
        hook)
            repo_path="$CONFIG_DIR/hooks/$name.sh"
            local_path=~/.claude/hooks/"$name.sh"
            ;;
    esac

    local in_repo=false
    local in_local=false
    local is_symlink=false
    local symlink_target=""

    [ -e "$repo_path" ] && in_repo=true
    [ -e "$local_path" ] && in_local=true

    if [ -L "$local_path" ]; then
        is_symlink=true
        symlink_target=$(readlink "$local_path")
    fi

    # Return status
    local symlink_target_norm="${symlink_target%/}"
    if $in_repo && $is_symlink && [[ "$symlink_target_norm" == "$repo_path" ]]; then
        echo "synced"
    elif $in_repo && $is_symlink && [[ "$symlink_target_norm" != "$repo_path" ]]; then
        echo "external"
    elif $in_repo && $in_local && ! $is_symlink; then
        echo "conflict"
    elif $in_repo && ! $in_local; then
        echo "missing"
    elif ! $in_repo && $in_local; then
        echo "local"
    else
        echo "none"
    fi
}

# Show status
show_status() {
    echo -e "${BOLD}Sync Status${RESET}"
    echo ""
    echo "Legend:"
    echo -e "  ${GREEN}✓${RESET} synced (symlinked to repo)"
    echo -e "  ${YELLOW}○${RESET} local only (not in repo)"
    echo -e "  ${RED}⚠${RESET} conflict (exists in both)"
    echo -e "  ${BLUE}→${RESET} external (symlinked elsewhere)"
    echo ""

    # Skills
    echo -e "${BOLD}Skills:${RESET}"
    local has_skills=false
    if [ -d "$CONFIG_DIR/skills" ]; then
        for skill_dir in "$CONFIG_DIR/skills"/*/; do
            [ -d "$skill_dir" ] || continue
            local name=$(basename "$skill_dir")
            [ "$name" = "archived" ] && continue
            has_skills=true
            local status=$(check_status skill "$name")
            case $status in
                synced) echo -e "  ${GREEN}✓${RESET} $name" ;;
                conflict) echo -e "  ${RED}⚠${RESET} $name" ;;
                external) echo -e "  ${BLUE}→${RESET} $name" ;;
                *) echo -e "  ${GRAY}?${RESET} $name" ;;
            esac
        done
    fi
    if [ -d ~/.claude/skills ]; then
        for skill_dir in ~/.claude/skills/*/; do
            [ -d "$skill_dir" ] || continue
            local name=$(basename "$skill_dir")
            local status=$(check_status skill "$name")
            if [ "$status" = "local" ]; then
                has_skills=true
                echo -e "  ${YELLOW}○${RESET} $name"
            fi
        done
    fi
    $has_skills || echo "  (none)"
    echo ""

    # Agents
    echo -e "${BOLD}Agents:${RESET}"
    local has_agents=false
    if [ -d "$CONFIG_DIR/agents" ]; then
        for agent_file in "$CONFIG_DIR/agents"/*.md; do
            [ -f "$agent_file" ] || continue
            has_agents=true
            local name=$(basename "$agent_file" .md)
            local status=$(check_status agent "$name")
            case $status in
                synced) echo -e "  ${GREEN}✓${RESET} $name" ;;
                conflict) echo -e "  ${RED}⚠${RESET} $name" ;;
                external) echo -e "  ${BLUE}→${RESET} $name" ;;
                *) echo -e "  ${GRAY}?${RESET} $name" ;;
            esac
        done
    fi
    if [ -d ~/.claude/agents ]; then
        for agent_file in ~/.claude/agents/*.md; do
            [ -f "$agent_file" ] || continue
            local name=$(basename "$agent_file" .md)
            local status=$(check_status agent "$name")
            if [ "$status" = "local" ]; then
                has_agents=true
                echo -e "  ${YELLOW}○${RESET} $name"
            fi
        done
    fi
    $has_agents || echo "  (none)"
    echo ""

    # Rules
    echo -e "${BOLD}Rules:${RESET}"
    local has_rules=false
    if [ -d "$CONFIG_DIR/rules" ]; then
        for rule_file in "$CONFIG_DIR/rules"/*.md; do
            [ -f "$rule_file" ] || continue
            has_rules=true
            local name=$(basename "$rule_file" .md)
            local status=$(check_status rule "$name")
            case $status in
                synced) echo -e "  ${GREEN}✓${RESET} $name" ;;
                conflict) echo -e "  ${RED}⚠${RESET} $name" ;;
                external) echo -e "  ${BLUE}→${RESET} $name" ;;
                *) echo -e "  ${GRAY}?${RESET} $name" ;;
            esac
        done
    fi
    if [ -d ~/.claude/rules ]; then
        for rule_file in ~/.claude/rules/*.md; do
            [ -f "$rule_file" ] || continue
            local name=$(basename "$rule_file" .md)
            local status=$(check_status rule "$name")
            if [ "$status" = "local" ]; then
                has_rules=true
                echo -e "  ${YELLOW}○${RESET} $name"
            fi
        done
    fi
    $has_rules || echo "  (none)"
    echo ""

    # Hooks
    echo -e "${BOLD}Hooks:${RESET}"
    local has_hooks=false
    if [ -d "$CONFIG_DIR/hooks" ]; then
        for hook_file in "$CONFIG_DIR/hooks"/*.sh; do
            [ -f "$hook_file" ] || continue
            has_hooks=true
            local name=$(basename "$hook_file" .sh)
            local status=$(check_status hook "$name")
            case $status in
                synced) echo -e "  ${GREEN}✓${RESET} $name" ;;
                conflict) echo -e "  ${RED}⚠${RESET} $name" ;;
                external) echo -e "  ${BLUE}→${RESET} $name" ;;
                *) echo -e "  ${GRAY}?${RESET} $name" ;;
            esac
        done
    fi
    if [ -d ~/.claude/hooks ]; then
        for hook_file in ~/.claude/hooks/*.sh; do
            [ -f "$hook_file" ] || continue
            local name=$(basename "$hook_file" .sh)
            local status=$(check_status hook "$name")
            if [ "$status" = "local" ]; then
                has_hooks=true
                echo -e "  ${YELLOW}○${RESET} $name"
            fi
        done
    fi
    $has_hooks || echo "  (none)"
}

# Validate skill frontmatter
validate_skill() {
    local skill_path="$1"
    local skill_md="$skill_path/SKILL.md"

    if [ ! -f "$skill_md" ]; then
        echo "false|Missing SKILL.md"
        return
    fi

    # Check for frontmatter
    if ! head -n 1 "$skill_md" | grep -q '^---$'; then
        echo "false|No frontmatter"
        return
    fi

    # Extract frontmatter
    local frontmatter=$(sed -n '/^---$/,/^---$/p' "$skill_md" | sed '1d;$d')

    # Check for name and description
    if ! echo "$frontmatter" | grep -q '^name:'; then
        echo "false|Missing name field"
        return
    fi

    if ! echo "$frontmatter" | grep -q '^description:'; then
        echo "false|Missing description field"
        return
    fi

    echo "true|Valid"
}

# Validate all skills
validate_all() {
    echo -e "${BOLD}Validating Skills${RESET}"
    echo ""

    local all_valid=true

    for skill_dir in "$CONFIG_DIR/skills"/*/; do
        [ -d "$skill_dir" ] || continue
        local name=$(basename "$skill_dir")
        [ "$name" = "archived" ] && continue
        local result=$(validate_skill "$skill_dir")
        local valid=$(echo "$result" | cut -d'|' -f1)
        local message=$(echo "$result" | cut -d'|' -f2)

        if [ "$valid" = "true" ]; then
            echo -e "  ${GREEN}✓${RESET} $name"
        else
            echo -e "  ${RED}✗${RESET} $name - $message"
            all_valid=false
        fi
    done

    echo ""
    if $all_valid; then
        echo "All skills valid!"
    else
        echo "Some skills have validation errors."
        exit 1
    fi
}

# Add item to repo
cmd_add() {
    local type="$1"
    local name="$2"

    if [ -z "$type" ] || [ -z "$name" ]; then
        echo "Usage: ./sync.sh add <type> <name>"
        exit 1
    fi

    local local_path=""
    local repo_path=""

    case $type in
        skill)
            local_path=~/.claude/skills/"$name"
            repo_path="$CONFIG_DIR/skills/$name"
            ;;
        agent)
            local_path=~/.claude/agents/"$name.md"
            repo_path="$CONFIG_DIR/agents/$name.md"
            ;;
        rule)
            local_path=~/.claude/rules/"$name.md"
            repo_path="$CONFIG_DIR/rules/$name.md"
            ;;
        hook)
            local_path=~/.claude/hooks/"$name.sh"
            repo_path="$CONFIG_DIR/hooks/$name.sh"
            ;;
        *)
            echo "Unknown type: $type"
            exit 1
            ;;
    esac

    if [ ! -e "$local_path" ]; then
        echo "Error: $local_path does not exist"
        exit 1
    fi

    if [ -e "$repo_path" ]; then
        echo "Error: $repo_path already exists in repo"
        exit 1
    fi

    # Validate skill if adding skill
    if [ "$type" = "skill" ]; then
        local result=$(validate_skill "$local_path")
        local valid=$(echo "$result" | cut -d'|' -f1)
        local message=$(echo "$result" | cut -d'|' -f2)

        if [ "$valid" != "true" ]; then
            echo "Error: Skill validation failed - $message"
            exit 1
        fi
    fi

    if $DRY_RUN; then
        echo "[dry-run] Would copy $local_path to $repo_path"
        echo "[dry-run] Would replace local with symlink"
    else
        mkdir -p "$(dirname "$repo_path")"
        cp -r "$local_path" "$repo_path"
        rm -rf "$local_path"
        ln -s "$repo_path" "$local_path"
        echo -e "${GREEN}✓${RESET} Added $type: $name"
        echo ""
        echo "Run './sync.sh push' to commit and push changes"
    fi
}

# Remove item from repo
cmd_remove() {
    local type="$1"
    local name="$2"

    if [ -z "$type" ] || [ -z "$name" ]; then
        echo "Usage: ./sync.sh remove <type> <name>"
        exit 1
    fi

    local repo_path=""

    case $type in
        skill)
            repo_path="$CONFIG_DIR/skills/$name"
            ;;
        agent)
            repo_path="$CONFIG_DIR/agents/$name.md"
            ;;
        rule)
            repo_path="$CONFIG_DIR/rules/$name.md"
            ;;
        hook)
            repo_path="$CONFIG_DIR/hooks/$name.sh"
            ;;
        *)
            echo "Unknown type: $type"
            exit 1
            ;;
    esac

    if [ ! -e "$repo_path" ]; then
        echo "Error: $repo_path does not exist in repo"
        exit 1
    fi

    if $DRY_RUN; then
        echo "[dry-run] Would remove $repo_path from repo"
        echo "[dry-run] Would keep local copy"
    else
        rm -rf "$repo_path"
        echo -e "${GREEN}✓${RESET} Removed $type: $name from repo"
        echo ""
        echo "Run './sync.sh push' to commit and push changes"
    fi
}

# Pull latest changes
cmd_pull() {
    if $DRY_RUN; then
        echo "[dry-run] Would git pull"
        echo "[dry-run] Would reinstall"
    else
        echo "Pulling latest changes..."
        git pull
        echo ""
        echo "Reinstalling..."
        ./install.sh
    fi
}

# Push changes
cmd_push() {
    if $DRY_RUN; then
        echo "[dry-run] Would commit and push changes"
    else
        git add -A
        echo "Enter commit message:"
        read -r message
        git commit -m "$message"
        git push
        echo -e "${GREEN}✓${RESET} Changes pushed"
    fi
}

# Undo last operation
cmd_undo() {
    local latest_backup=$(ls -t "$BACKUP_DIR" 2>/dev/null | head -1)

    if [ -z "$latest_backup" ]; then
        echo "No backups found"
        exit 1
    fi

    local backup_path="$BACKUP_DIR/$latest_backup"

    echo "Latest backup: $latest_backup"
    echo ""

    if $DRY_RUN; then
        echo "[dry-run] Would restore from $backup_path"
    else
        read -p "Restore from this backup? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            # TODO: Implement restore logic
            echo "Restore not yet implemented"
        fi
    fi
}

# List backups
cmd_backups() {
    echo -e "${BOLD}Available Backups${RESET}"
    echo ""

    if [ ! -d "$BACKUP_DIR" ] || [ -z "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]; then
        echo "No backups found"
        return
    fi

    for backup in $(ls -t "$BACKUP_DIR"); do
        local manifest="$BACKUP_DIR/$backup/manifest.json"
        if [ -f "$manifest" ]; then
            local timestamp=$(cat "$manifest" | grep timestamp | cut -d'"' -f4)
            local operation=$(cat "$manifest" | grep operation | cut -d'"' -f4)
            echo -e "${BLUE}$backup${RESET}"
            echo "  Time: $timestamp"
            echo "  Operation: $operation"
            echo ""
        else
            echo -e "${GRAY}$backup${RESET}"
            echo "  (no manifest)"
            echo ""
        fi
    done
}

# Main
main() {
    parse_flags "$@"

    # Remove parsed flags from args
    local args=()
    for arg in "$@"; do
        if [[ "$arg" != "-n" ]] && [[ "$arg" != "--dry-run" ]]; then
            args+=("$arg")
        fi
    done

    local command="${args[0]:-}"

    case $command in
        add)
            cmd_add "${args[1]}" "${args[2]}"
            ;;
        remove)
            cmd_remove "${args[1]}" "${args[2]}"
            ;;
        pull)
            cmd_pull
            ;;
        push)
            cmd_push
            ;;
        undo)
            cmd_undo
            ;;
        validate)
            validate_all
            ;;
        backups)
            cmd_backups
            ;;
        help|--help|-h)
            usage
            ;;
        "")
            show_status
            ;;
        *)
            echo "Unknown command: $command"
            usage
            exit 1
            ;;
    esac
}

main "$@"
