#!/usr/bin/env bash
set -euo pipefail

branch="${1:-}"

if [[ -z "${branch}" ]]; then
  echo "Usage: $0 <branch-name>"
  exit 2
fi

current="$(git branch --show-current)"

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Refusing to start a new change: working tree is not clean."
  git status --short
  exit 1
fi

if git show-ref --verify --quiet "refs/heads/${branch}"; then
  echo "Refusing to create branch: local branch '${branch}' already exists."
  exit 1
fi

git fetch --prune
git checkout main
git pull --ff-only
git checkout -b "${branch}"

echo
echo "Ready on branch: ${branch}"
