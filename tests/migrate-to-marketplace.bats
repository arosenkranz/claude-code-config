#!/usr/bin/env bats
# Tests for scripts/migrate-to-marketplace.sh

setup() {
    REPO_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
    SCRIPT="$REPO_DIR/scripts/migrate-to-marketplace.sh"
    TEST_HOME="$(mktemp -d)"
    CLAUDE_DIR="$TEST_HOME/.claude"
    mkdir -p "$CLAUDE_DIR"/{skills,agents,hooks,rules}

    # Minimal settings.json with hooks key
    cat > "$CLAUDE_DIR/settings.json" <<'JSON'
{
  "hooks": {
    "SessionStart": [{"hooks": [{"type": "command", "command": "echo start"}]}],
    "PostToolUse": [{"hooks": [{"type": "command", "command": "echo post"}]}]
  },
  "permissions": {"allow": [], "deny": []}
}
JSON
}

teardown() {
    rm -rf "$TEST_HOME"
}

# Helper: run script with TEST_HOME as HOME
run_migrate() {
    HOME="$TEST_HOME" bash "$SCRIPT" "$@"
}

# ── Dependency / pre-flight ───────────────────────────────────────────────────

@test "dry-run completes without error" {
    run run_migrate --dry-run
    [ "$status" -eq 0 ]
}

@test "dry-run makes no changes to settings.json" {
    local before
    before=$(cat "$CLAUDE_DIR/settings.json")
    run run_migrate --dry-run
    local after
    after=$(cat "$CLAUDE_DIR/settings.json")
    [ "$before" = "$after" ]
}

# ── Backup ────────────────────────────────────────────────────────────────────

@test "backup directory is created on run" {
    run run_migrate
    [ "$status" -eq 0 ]
    local backup_count
    backup_count=$(ls -d "$REPO_DIR"/.backup/migrate-* 2>/dev/null | wc -l | tr -d ' ')
    [ "$backup_count" -ge 1 ]
}

@test "backup contains copy of .claude" {
    run run_migrate
    local latest_backup
    latest_backup=$(ls -d "$REPO_DIR"/.backup/migrate-* 2>/dev/null | sort | tail -1)
    [ -d "$latest_backup/claude" ]
}

@test "restore from backup recreates claude dir" {
    run run_migrate
    local latest_backup
    latest_backup=$(ls -d "$REPO_DIR"/.backup/migrate-* 2>/dev/null | sort | tail -1)
    rm -rf "$CLAUDE_DIR"
    HOME="$TEST_HOME" bash "$SCRIPT" --restore
    [ -d "$CLAUDE_DIR" ]
    # Cleanup backup created by this test
    rm -rf "$latest_backup"
}

# ── Idempotency ───────────────────────────────────────────────────────────────

@test "running migration twice does not error" {
    run run_migrate
    [ "$status" -eq 0 ]
    run run_migrate
    [ "$status" -eq 0 ]
}

# ── Symlink removal ───────────────────────────────────────────────────────────

@test "old-repo symlinks in agents dir are removed" {
    local fake_repo="$TEST_HOME/fake-claude-code-config"
    mkdir -p "$fake_repo/agents"
    touch "$fake_repo/agents/boris.md"
    ln -s "$fake_repo/agents/boris.md" "$CLAUDE_DIR/agents/boris.md"

    run run_migrate
    [ "$status" -eq 0 ]
    [ ! -L "$CLAUDE_DIR/agents/boris.md" ]
}

@test "dead agent symlinks are removed" {
    ln -s "/nonexistent/path/brag-doc.md" "$CLAUDE_DIR/agents/brag-doc.md"
    [ -L "$CLAUDE_DIR/agents/brag-doc.md" ]

    run run_migrate
    [ "$status" -eq 0 ]
    [ ! -e "$CLAUDE_DIR/agents/brag-doc.md" ]
}

# ── settings.json: hooks stripped ────────────────────────────────────────────

@test "hooks key is removed from settings.json" {
    run run_migrate
    [ "$status" -eq 0 ]
    run python3 -c "
import json, sys
with open('$CLAUDE_DIR/settings.json') as f:
    data = json.load(f)
sys.exit(0 if 'hooks' not in data else 1)
"
    [ "$status" -eq 0 ]
}

@test "settings.json remains valid JSON after hook strip" {
    run run_migrate
    [ "$status" -eq 0 ]
    run python3 -c "import json; json.load(open('$CLAUDE_DIR/settings.json'))"
    [ "$status" -eq 0 ]
}

@test "non-hooks keys are preserved after hook strip" {
    run run_migrate
    [ "$status" -eq 0 ]
    run python3 -c "
import json
with open('$CLAUDE_DIR/settings.json') as f:
    data = json.load(f)
assert 'permissions' in data, 'permissions key missing'
"
    [ "$status" -eq 0 ]
}

# ── settings.json: marketplace registered ─────────────────────────────────────

@test "marketplace is registered in settings.json" {
    run run_migrate
    [ "$status" -eq 0 ]
    run python3 -c "
import json
with open('$CLAUDE_DIR/settings.json') as f:
    data = json.load(f)
assert 'arosenkranz-claude-plugins' in data.get('extraKnownMarketplaces', {}), 'marketplace not registered'
"
    [ "$status" -eq 0 ]
}

@test "all 3 plugins are enabled in settings.json" {
    run run_migrate
    [ "$status" -eq 0 ]
    run python3 -c "
import json
with open('$CLAUDE_DIR/settings.json') as f:
    data = json.load(f)
plugins = data.get('enabledPlugins', {})
for p in ['workflow-skills@arosenkranz-claude-plugins', 'goldeneye-agents@arosenkranz-claude-plugins', 'dev-environment@arosenkranz-claude-plugins']:
    assert plugins.get(p) is True, f'Plugin not enabled: {p}'
"
    [ "$status" -eq 0 ]
}

# ── settings.json symlink dereference ─────────────────────────────────────────

@test "settings.json symlink is dereferenced to real file" {
    local real_settings="$TEST_HOME/real-settings.json"
    cp "$CLAUDE_DIR/settings.json" "$real_settings"
    rm "$CLAUDE_DIR/settings.json"
    ln -s "$real_settings" "$CLAUDE_DIR/settings.json"

    run run_migrate
    [ "$status" -eq 0 ]
    [ ! -L "$CLAUDE_DIR/settings.json" ]
    [ -f "$CLAUDE_DIR/settings.json" ]
}

# ── Rules symlinks ────────────────────────────────────────────────────────────

@test "coding-style.md is symlinked into rules dir" {
    run run_migrate
    [ "$status" -eq 0 ]
    [ -L "$CLAUDE_DIR/rules/coding-style.md" ]
}

@test "rules symlinks point to plugin commands dir" {
    run run_migrate
    [ "$status" -eq 0 ]
    local target
    target=$(readlink "$CLAUDE_DIR/rules/coding-style.md")
    [[ "$target" == *"plugins/dev-environment/commands/coding-style.md"* ]]
}

# ── Hook coverage verification ────────────────────────────────────────────────

@test "migration fails if dev-environment hooks.json missing required event" {
    # Temporarily rename the hooks.json so verification fails
    local hooks_json="$REPO_DIR/plugins/dev-environment/hooks/hooks.json"
    local tmp_backup="$TEST_HOME/hooks.json.bak"
    cp "$hooks_json" "$tmp_backup"

    python3 -c "
import json
with open('$hooks_json') as f:
    data = json.load(f)
del data['hooks']['SessionStart']
with open('$hooks_json', 'w') as f:
    json.dump(data, f, indent=2)
"

    run run_migrate
    local exit_code="$status"

    # Restore
    cp "$tmp_backup" "$hooks_json"

    [ "$exit_code" -ne 0 ]
}
