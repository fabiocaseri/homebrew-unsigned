#!/usr/bin/env bash
set -euo pipefail

branch="${1:-}"

if [[ -z "${branch}" ]]; then
  echo "Usage: $0 <branch-name>"
  exit 2
fi

if [[ "${branch}" == "main" ]]; then
  echo "Refusing to delete main."
  exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Refusing to close change: working tree is not clean."
  git status --short
  exit 1
fi

git fetch --prune
git checkout main
git pull --ff-only
git fetch --prune

if ! git show-ref --verify --quiet "refs/heads/${branch}"; then
  echo "Local branch '${branch}' does not exist."
  exit 0
fi

if git branch -d "${branch}"; then
  echo
  echo "Deleted local branch: ${branch}"
else
  echo
  echo "Branch '${branch}' was not recognized as merged locally."
  echo "If the pull request was merged on GitHub, delete it explicitly with:"
  echo "  git branch -D '${branch}'"
  exit 1
fi
