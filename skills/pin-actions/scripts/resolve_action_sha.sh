#!/usr/bin/env bash
# resolve_action_sha.sh - Resolve a GitHub Action tag to its commit SHA
#
# Usage: ./resolve_action_sha.sh <owner/repo[/path]> <tag>
# Output: 40-character commit SHA on stdout
# Errors: descriptive message on stderr, exit 1

set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <owner/repo[/path]> <tag>" >&2
  exit 1
fi

ACTION_REF="$1"
TAG="$2"

# Extract owner/repo from first two path segments (handles sub-path actions like docker/build-push-action/push)
IFS='/' read -ra PARTS <<< "$ACTION_REF"
if [[ ${#PARTS[@]} -lt 2 ]]; then
  echo "Error: Invalid action reference '${ACTION_REF}'. Expected format: owner/repo[/path]" >&2
  exit 1
fi
OWNER="${PARTS[0]}"
REPO="${PARTS[1]}"

# Fetch the tag ref
TAG_REF_JSON=$(gh api "repos/${OWNER}/${REPO}/git/ref/tags/${TAG}" 2>/dev/null) || {
  echo "Error: Could not resolve tag '${TAG}' for ${OWNER}/${REPO}. Tag may not exist." >&2
  exit 1
}

OBJECT_TYPE=$(echo "$TAG_REF_JSON" | jq -r '.object.type')
OBJECT_SHA=$(echo "$TAG_REF_JSON" | jq -r '.object.sha')

if [[ "$OBJECT_TYPE" == "commit" ]]; then
  # Lightweight tag — points directly to a commit
  echo "$OBJECT_SHA"
elif [[ "$OBJECT_TYPE" == "tag" ]]; then
  # Annotated tag — dereference to get the underlying commit SHA
  ANNOTATED_JSON=$(gh api "repos/${OWNER}/${REPO}/git/tags/${OBJECT_SHA}" 2>/dev/null) || {
    echo "Error: Could not dereference annotated tag for ${OWNER}/${REPO}@${TAG}" >&2
    exit 1
  }
  COMMIT_SHA=$(echo "$ANNOTATED_JSON" | jq -r '.object.sha')
  echo "$COMMIT_SHA"
else
  echo "Error: Unexpected object type '${OBJECT_TYPE}' for tag '${TAG}'" >&2
  exit 1
fi
