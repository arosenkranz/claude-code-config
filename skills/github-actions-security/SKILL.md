---
name: github-actions-security
description: Pin GitHub Actions to commit SHAs to prevent supply chain attacks. Use when updating workflow files to pin third-party actions to full 40-character commit SHAs instead of mutable tags. Handles tag resolution, annotated tags, and validates against GitHub API. Also use when scanning workflow files to update all third-party actions to their latest versions.
disable-model-invocation: true
---

# GitHub Actions Security

Pin actions to immutable commit SHAs to prevent supply chain attacks.

## Why This Matters

GitHub Actions tags are **mutable** - they can be deleted and recreated by attackers. In 2023, the `tj-actions/changed-files` action had all its tags tampered with malicious code. Pinning to commit SHAs provides:

1. **Immutability**: SHAs cannot be changed once committed
1. **Supply chain security**: Protection against tag manipulation
1. **GitHub recommendation**: Official best practice for action security

## Instructions

When user requests updating GitHub Actions workflows (or when you detect unpinned actions):

### Step 1: Identify Actions to Update

1. Ask which workflow file to scan (if not specified)
1. For each `uses:` line with a third-party action:
   * Skip if already pinned to 40-character SHA
   * Skip local paths (`uses: ./path`)
   * Skip Docker images (`uses: docker://...`)
   * Extract `OWNER/REPO` and current reference

### Step 2: Resolve Each Action to SHA

For each action needing updates:

1. **Try releases first** (most common):
   ```bash
   # Use GITHUB_TOKEN if available for better rate limits
   AUTH_HEADER=""
   if [ -n "$GITHUB_TOKEN" ]; then
     AUTH_HEADER="Authorization: Bearer $GITHUB_TOKEN"
   fi

   TAG=$(curl -s -H "$AUTH_HEADER" \
     "https://api.github.com/repos/OWNER/REPO/releases/latest" \
     | jq -r '.tag_name')
   ```

1. **Fallback to tags** if no releases exist:
   ```bash
   TAG=$(curl -s -H "$AUTH_HEADER" \
     "https://api.github.com/repos/OWNER/REPO/tags" \
     | jq -r '.[0].name')
   ```

1. **Get tag reference**:
   ```bash
   TAG_DATA=$(curl -s -H "$AUTH_HEADER" \
     "https://api.github.com/repos/OWNER/REPO/git/ref/tags/$TAG" \
     | jq -r '.object')

   TAG_TYPE=$(echo "$TAG_DATA" | jq -r '.type')
   TAG_SHA=$(echo "$TAG_DATA" | jq -r '.sha')
   ```

1. **Handle annotated tags** (dereference if needed):
   ```bash
   if [ "$TAG_TYPE" = "tag" ]; then
     # Annotated tag - need to dereference to get commit
     SHA=$(curl -s -H "$AUTH_HEADER" \
       "https://api.github.com/repos/OWNER/REPO/git/tags/$TAG_SHA" \
       | jq -r '.object.sha')
   else
     # Lightweight tag - SHA points directly to commit
     SHA="$TAG_SHA"
   fi
   ```

1. **Validate SHA is exactly 40 characters** (security requirement)

1. **Format as**: `owner/repo@<FULL_SHA> # <TAG>`
   * Preserve subdirectory paths if present: `owner/repo/path@<SHA> # <TAG>`

### Step 3: Present and Apply

1. Show all proposed changes to user
1. Explain what each action is being updated to and why
1. Wait for user approval
1. Apply changes to workflow file

### Authentication

**Strongly recommend** using `GITHUB_TOKEN` environment variable:

* **Unauthenticated**: 60 requests/hour (will hit limits quickly)
* **Authenticated**: 5,000 requests/hour

Set token:
```bash
export GITHUB_TOKEN="ghp_your_token_here"
```

Or check for it in code:
```bash
if [ -z "$GITHUB_TOKEN" ]; then
  echo "Warning: GITHUB_TOKEN not set. Rate limits: 60 req/hour"
  echo "Set token for 5000 req/hour: export GITHUB_TOKEN='ghp_...'"
fi
```

### Edge Cases to Handle

* **Annotated vs lightweight tags**: Always dereference annotated tags to get commit SHA
* **No releases**: Many repos use tags but don't create GitHub Releases - fall back to tags API
* **Prereleases**: `releases/latest` excludes prereleases - may not be the "latest" you expect
* **Already pinned**: Skip actions already using 40-character SHAs
* **Subdirectories**: Preserve path in `owner/repo/path@sha`
* **Rate limits**: Detect 403 responses and advise setting GITHUB_TOKEN
* **Invalid responses**: Handle repos that don't exist or have no tags/releases

### Security Requirements

* **MUST** use full 40-character commit SHAs (not shortened 7-char versions)
* **MUST** validate SHA format matches `^[a-f0-9]{40}$`
* Comment format preserves human readability: `@<SHA> # <TAG>`

## Examples

### Example 1: Basic Update

**Input workflow:**
```yaml
name: CI
on: [push]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: docker/build-push-action@v5.0.0
```

**Process:**
1. Resolve `actions/checkout@v4`:
   * Get latest release: `v4.1.1`
   * Get commit SHA: `b4ffde65f46336ab88eb53be808477a3936bae11`
   * Format: `actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11 # v4.1.1`

1. Resolve `docker/build-push-action@v5.0.0`:
   * Tag already exists: `v5.0.0`
   * Get commit SHA: `0565240e2d4ab88bba5387d719585280857ece09`
   * Format: `docker/build-push-action@0565240e2d4ab88bba5387d719585280857ece09 # v5.0.0`

**Output workflow:**
```yaml
name: CI
on: [push]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11 # v4.1.1
      - uses: docker/build-push-action@0565240e2d4ab88bba5387d719585280857ece09 # v5.0.0
```

### Example 2: Handling Edge Cases

**Input workflow:**
```yaml
steps:
  # Already pinned - skip
  - uses: actions/setup-node@1a4442cacd436585916779262731d5b162bc6ec7 # v3.8.2

  # Local action - skip
  - uses: ./.github/actions/custom-action

  # Docker image - skip
  - uses: docker://alpine:3.18

  # Subdirectory action - preserve path
  - uses: aws-actions/configure-aws-credentials/v4

  # Needs updating
  - uses: actions/cache@v3
```

**Process:**
* Skip first three (already pinned, local, Docker)
* For `aws-actions/configure-aws-credentials/v4`:
  * Resolve to SHA with subdirectory preserved
* For `actions/cache@v3`:
  * Update to latest v3.x.x with SHA

**Output workflow:**
```yaml
steps:
  # Already pinned - unchanged
  - uses: actions/setup-node@1a4442cacd436585916779262731d5b162bc6ec7 # v3.8.2

  # Local action - unchanged
  - uses: ./.github/actions/custom-action

  # Docker image - unchanged
  - uses: docker://alpine:3.18

  # Subdirectory preserved with SHA
  - uses: aws-actions/configure-aws-credentials/v4@e3dd6b9699d61f23e0e6b29e75fc7c3e56c6c7a2 # v4.0.1

  # Updated to latest
  - uses: actions/cache@13aacd865c20de90d75de3b17ebe84f7a17d57d2 # v3.3.2
```

### Example 3: Annotated Tag Handling

**Scenario**: Repo uses annotated tags (common in many actions)

**API Response Sequence:**
```bash
# Step 1: Get tag reference
GET /repos/actions/checkout/git/ref/tags/v4.1.1
{
  "object": {
    "type": "tag",  # <-- Annotated tag!
    "sha": "abc123..."
  }
}

# Step 2: Dereference annotated tag
GET /repos/actions/checkout/git/tags/abc123...
{
  "object": {
    "type": "commit",
    "sha": "b4ffde65f46336ab88eb53be808477a3936bae11"  # <-- Real commit
  }
}
```

**Result**: `actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11 # v4.1.1`

## References

**Official Documentation:**
* [GitHub Security: Pinning Actions](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions#using-third-party-actions)
* [GitHub API: Git References](https://docs.github.com/en/rest/git/refs)
* [GitHub API: Tags](https://docs.github.com/en/rest/git/tags)

**Security Guides:**
* [StepSecurity: Pinning GitHub Actions](https://www.stepsecurity.io/blog/pinning-github-actions)
* [Why Pin Actions by Commit Hash](https://blog.rafaelgss.dev/why-you-should-pin-actions-by-commit-hash)

**Real-World Incidents:**
* [tj-actions/changed-files compromise](https://www.stepsecurity.io/blog/the-dangers-of-using-mutable-tags-in-github-actions)
