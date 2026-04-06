#!/usr/bin/env bash
# migrate-to-marketplace.sh
# Migrates ~/.claude from symlink-based setup to plugin marketplace model.
#
# Usage:
#   ./scripts/migrate-to-marketplace.sh           # Run migration
#   ./scripts/migrate-to-marketplace.sh --dry-run # Preview without changes
#   ./scripts/migrate-to-marketplace.sh --restore # Restore from latest backup

set -euo pipefail

CLAUDE_DIR="$HOME/.claude"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
BACKUP_DIR="$REPO_DIR/.backup/migrate-$(date +%Y%m%d-%H%M%S)"
DRY_RUN=false
RESTORE_MODE=false

log()    { echo "[migrate] $*"; }
warn()   { echo "[migrate] WARNING: $*" >&2; }
drylog() { echo "[migrate][dry-run] $*"; }

# Parse args
for arg in "$@"; do
    case "$arg" in
        --dry-run|-n) DRY_RUN=true ;;
        --restore)    RESTORE_MODE=true ;;
        *)            echo "Unknown argument: $arg"; exit 1 ;;
    esac
done

# ── Restore mode ──────────────────────────────────────────────────────────────

restore_from_backup() {
    local latest
    latest=$(ls -d "$REPO_DIR"/.backup/migrate-* 2>/dev/null | sort | tail -1)
    if [[ -z "$latest" ]]; then
        echo "No backups found in $REPO_DIR/.backup/"
        exit 1
    fi
    log "Restoring from: $latest"
    if [[ -d "$latest/claude" ]]; then
        rm -rf "$CLAUDE_DIR"
        cp -a "$latest/claude" "$CLAUDE_DIR"
        log "Restored ~/.claude from backup"
    fi
    log "Restore complete."
}

if [[ "$RESTORE_MODE" == true ]]; then
    restore_from_backup
    exit 0
fi

# ── Pre-flight checks ─────────────────────────────────────────────────────────

check_dependencies() {
    local missing=()
    for cmd in python3 git; do
        if ! command -v "$cmd" &>/dev/null; then
            missing+=("$cmd")
        fi
    done
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo "Missing required commands: ${missing[*]}"
        exit 1
    fi
}

verify_hooks_in_plugin() {
    local hooks_json="$REPO_DIR/plugins/dev-environment/hooks/hooks.json"
    if [[ ! -f "$hooks_json" ]]; then
        echo "ERROR: $hooks_json not found — cannot verify hook coverage"
        exit 1
    fi
    local required_events=("SessionStart" "SessionEnd" "PreToolUse" "PostToolUse" "PreCompact" "Stop")
    for event in "${required_events[@]}"; do
        if ! python3 -c "
import json, sys
with open('$hooks_json') as f:
    data = json.load(f)
if '$event' not in data.get('hooks', {}):
    sys.exit(1)
" 2>/dev/null; then
            echo "ERROR: $event missing from $hooks_json — hook coverage gap detected"
            exit 1
        fi
    done
    log "All required hook events verified in plugin hooks.json"
}

# ── Backup ────────────────────────────────────────────────────────────────────

create_backup() {
    if [[ "$DRY_RUN" == true ]]; then
        drylog "Would create backup at $BACKUP_DIR"
        return
    fi
    mkdir -p "$BACKUP_DIR"
    if [[ -d "$CLAUDE_DIR" ]]; then
        cp -a "$CLAUDE_DIR" "$BACKUP_DIR/claude"
        log "Backed up ~/.claude → $BACKUP_DIR/claude"
    fi
}

# ── Step 1: Remove symlinks for old structure ─────────────────────────────────

remove_old_symlinks() {
    local dirs=("skills" "agents" "hooks")
    for dir in "${dirs[@]}"; do
        local target="$CLAUDE_DIR/$dir"
        if [[ -L "$target" ]]; then
            if [[ "$DRY_RUN" == true ]]; then
                drylog "Would remove symlink: $target"
            else
                rm "$target"
                log "Removed symlink: $target"
            fi
        elif [[ -d "$target" ]]; then
            # Remove individual symlinks inside the dir that point into the old repo structure
            while IFS= read -r -d '' link; do
                local link_target
                link_target=$(readlink "$link" 2>/dev/null || true)
                if [[ "$link_target" == *"claude-code-config/skills"* ]] || \
                   [[ "$link_target" == *"claude-code-config/agents"* ]] || \
                   [[ "$link_target" == *"claude-code-config/hooks"* ]]; then
                    if [[ "$DRY_RUN" == true ]]; then
                        drylog "Would remove old symlink: $link → $link_target"
                    else
                        rm "$link"
                        log "Removed old symlink: $(basename "$link")"
                    fi
                fi
            done < <(find "$target" -maxdepth 1 -type l -print0 2>/dev/null)
        fi
    done
}

# ── Step 2: Remove dead symlinks ──────────────────────────────────────────────

remove_dead_symlinks() {
    local dead_agents=("brag-doc" "deployment-engineer" "devops-troubleshooter" "docs-architect" "execplan-executor" "ops-responder")
    local agents_dir="$CLAUDE_DIR/agents"
    for agent in "${dead_agents[@]}"; do
        local link="$agents_dir/${agent}.md"
        if [[ -L "$link" ]] && [[ ! -e "$link" ]]; then
            if [[ "$DRY_RUN" == true ]]; then
                drylog "Would remove dead symlink: $link"
            else
                rm "$link"
                log "Removed dead symlink: ${agent}.md"
            fi
        fi
    done
}

# ── Step 3: Dereference settings.json symlink ─────────────────────────────────

dereference_settings() {
    local settings="$CLAUDE_DIR/settings.json"
    if [[ -L "$settings" ]]; then
        local real_target
        real_target=$(readlink -f "$settings")
        if [[ "$DRY_RUN" == true ]]; then
            drylog "Would dereference settings.json symlink → real file (from $real_target)"
            return
        fi
        local content
        content=$(cat "$real_target")
        rm "$settings"
        echo "$content" > "$settings"
        log "Dereferenced settings.json → real file"
    fi
}

# ── Step 4: Strip hooks from settings.json ────────────────────────────────────

strip_hooks_from_settings() {
    local settings="$CLAUDE_DIR/settings.json"
    if [[ ! -f "$settings" ]]; then
        warn "settings.json not found at $settings, skipping hook strip"
        return
    fi

    if [[ "$DRY_RUN" == true ]]; then
        drylog "Would strip 'hooks' key from settings.json"
        return
    fi

    python3 - "$settings" <<'PYEOF'
import json, sys

path = sys.argv[1]
with open(path) as f:
    data = json.load(f)

if 'hooks' in data:
    removed = list(data.pop('hooks').keys())
    with open(path, 'w') as f:
        json.dump(data, f, indent=2)
        f.write('\n')
    print(f"[migrate] Stripped hooks from settings.json: {', '.join(removed)}")
else:
    print("[migrate] No hooks key in settings.json — nothing to strip")
PYEOF
}

# ── Step 5: Register marketplace in settings.json ────────────────────────────

register_marketplace() {
    local settings="$CLAUDE_DIR/settings.json"
    if [[ ! -f "$settings" ]]; then
        warn "settings.json not found, copying from template"
        if [[ "$DRY_RUN" == false ]]; then
            cp "$REPO_DIR/config-templates/settings.json.template" "$settings"
        else
            drylog "Would copy settings.json.template → settings.json"
        fi
        return
    fi

    if [[ "$DRY_RUN" == true ]]; then
        drylog "Would register marketplace and enable plugins in settings.json"
        return
    fi

    python3 - "$settings" "$REPO_DIR" <<'PYEOF'
import json, sys

settings_path = sys.argv[1]
with open(settings_path) as f:
    data = json.load(f)

data.setdefault('extraKnownMarketplaces', {})['arosenkranz-claude-plugins'] = {
    'source': {'source': 'github', 'repo': 'arosenkranz/claude-code-config'}
}

data.setdefault('enabledPlugins', {}).update({
    'workflow-skills@arosenkranz-claude-plugins': True,
    'goldeneye-agents@arosenkranz-claude-plugins': True,
    'dev-environment@arosenkranz-claude-plugins': True,
})

data['_comment'] = 'Hooks are defined per-plugin in hooks.json — do not add hooks here.'

with open(settings_path, 'w') as f:
    json.dump(data, f, indent=2)
    f.write('\n')

print("[migrate] Registered marketplace and enabled 3 plugins in settings.json")
PYEOF
}

# ── Step 6: Dereference CLAUDE.md symlink ─────────────────────────────────────

dereference_claude_md() {
    local claude_md="$CLAUDE_DIR/CLAUDE.md"
    if [[ -L "$claude_md" ]]; then
        local real_target
        real_target=$(readlink -f "$claude_md")
        if [[ "$DRY_RUN" == true ]]; then
            drylog "Would dereference CLAUDE.md symlink → real file (from $real_target)"
            return
        fi
        local content
        content=$(cat "$real_target")
        rm "$claude_md"
        echo "$content" > "$claude_md"
        log "Dereferenced CLAUDE.md → real file"
    fi
}

# ── Step 7: Symlink rules from plugin commands ────────────────────────────────

symlink_rules() {
    local rules_dir="$CLAUDE_DIR/rules"
    local commands_dir="$REPO_DIR/plugins/dev-environment/commands"

    if [[ ! -d "$commands_dir" ]]; then
        warn "Commands dir not found at $commands_dir"
        return
    fi

    if [[ "$DRY_RUN" == false ]]; then
        mkdir -p "$rules_dir"
    fi

    while IFS= read -r -d '' cmd_file; do
        local name
        name=$(basename "$cmd_file")
        local link="$rules_dir/$name"

        if [[ -e "$link" ]] && [[ ! -L "$link" ]]; then
            warn "Real file exists at $link — skipping (not overwriting)"
            continue
        fi

        if [[ "$DRY_RUN" == true ]]; then
            drylog "Would symlink $link → $cmd_file"
        else
            ln -sf "$cmd_file" "$link"
            log "Symlinked rule: $name"
        fi
    done < <(find "$commands_dir" -maxdepth 1 -name "*.md" -print0 2>/dev/null)
}

# ── Step 8: Dereference statusline.sh symlink ─────────────────────────────────

dereference_statusline() {
    local statusline="$CLAUDE_DIR/statusline.sh"
    if [[ -L "$statusline" ]]; then
        local real_target
        real_target=$(readlink -f "$statusline")
        if [[ "$DRY_RUN" == true ]]; then
            drylog "Would dereference statusline.sh symlink → real file"
            return
        fi
        local content
        content=$(cat "$real_target")
        rm "$statusline"
        echo "$content" > "$statusline"
        chmod +x "$statusline"
        log "Dereferenced statusline.sh → real file"
    fi
}

# ── Main ──────────────────────────────────────────────────────────────────────

main() {
    log "Starting migration to marketplace model"
    [[ "$DRY_RUN" == true ]] && log "(dry-run mode — no changes will be made)"

    check_dependencies
    verify_hooks_in_plugin
    create_backup

    log "Step 1: Removing old symlinks"
    remove_old_symlinks

    log "Step 2: Removing dead agent symlinks"
    remove_dead_symlinks

    log "Step 3: Dereferencing settings.json"
    dereference_settings

    log "Step 4: Stripping hooks from settings.json"
    strip_hooks_from_settings

    log "Step 5: Registering marketplace in settings.json"
    register_marketplace

    log "Step 6: Dereferencing CLAUDE.md"
    dereference_claude_md

    log "Step 7: Symlinking coding standard rules"
    symlink_rules

    log "Step 8: Dereferencing statusline.sh"
    dereference_statusline

    log "Migration complete."
    log ""
    log "Next steps:"
    log "  1. Restart Claude Code to load plugins"
    log "  2. Verify hooks: start a session and check for errors"
    log "  3. Test a skill: /morning-plan"
    log "  4. Test an agent: invoke 'wade' or 'm'"
    log ""
    log "To rollback: $0 --restore"
}

main "$@"
