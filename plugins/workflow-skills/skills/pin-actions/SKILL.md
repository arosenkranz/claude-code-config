---
name: pin-actions
description: >
  Pin GitHub Actions from mutable tags (e.g., @v4) to immutable commit SHAs to prevent
  supply chain attacks. Use when editing .github/workflows files, hardening CI security,
  looking up action SHAs, pinning actions to specific commits, or replacing
  "uses: owner/repo@tag" references with SHA-pinned equivalents.
---

# pin-actions

GitHub Actions referenced by mutable tags (`@v4`) are vulnerable to supply chain attacks —
a compromised maintainer can silently move the tag to malicious code. Pinning to a commit
SHA makes the reference immutable and tamper-evident.

## Script Location

```
~/.claude/skills/pin-actions/scripts/resolve_action_sha.sh
```

**Interface**: `./resolve_action_sha.sh <owner/repo[/path]> <tag>` → prints 40-char SHA to stdout

## Workflow 1: Scan Mode (pin all unpinned actions in a workflow file)

1. **Read the workflow file** to identify all `uses:` lines
2. **Filter to unpinned actions** — skip:
   - Already-pinned: `uses: owner/repo@<40-char hex SHA>`
   - Docker-based: `uses: docker://...`
   - Local actions: `uses: ./path/to/action`
3. **For each unpinned action**, extract `owner/repo[/subpath]` and `ref`:
   - Pattern: `uses: {owner}/{repo}@{ref}`
   - Pattern: `uses: {owner}/{repo}/{path}@{ref}` (sub-path actions)
4. **Resolve each SHA** using the script:
   ```bash
   SHA=$(~/.claude/skills/pin-actions/scripts/resolve_action_sha.sh "owner/repo" "v4")
   ```
5. **Replace** `owner/repo@v4` → `owner/repo@<SHA> # v4`
   - Always preserve the original tag as a trailing comment for human readability

### Example transformation

Before:
```yaml
- uses: actions/checkout@v4
- uses: pnpm/action-setup@v4
- uses: docker/build-push-action/push@v6
```

After:
```yaml
- uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4
- uses: pnpm/action-setup@a3252b7a1b87b11f31ef2a5405c6fe64a35b06b8 # v4
- uses: docker/build-push-action/push@263435318d21b8e681c14492fe198d362a7d2c83 # v6
```

## Workflow 2: Lookup Mode (resolve a single action on demand)

When asked to look up the SHA for a specific action:

```bash
~/.claude/skills/pin-actions/scripts/resolve_action_sha.sh "actions/checkout" "v4"
# → 11bd71901bbe5b1630ceea73d27597364c9af683
```

Report the SHA and the pinned form:
```
actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4
```

## Tag Types

The script handles both GitHub tag types transparently:
- **Lightweight tags**: point directly to a commit (most common for action releases)
- **Annotated tags**: contain metadata and point to a tag object, which in turn points to a commit — the script dereferences this automatically

## Error Handling

If the script exits with code 1, the tag likely doesn't exist for that repo. Verify:
1. Correct owner/repo spelling
2. Tag exists: `gh api repos/{owner}/{repo}/git/ref/tags/{tag}`
3. The repo has releases (not all action repos use tags)
