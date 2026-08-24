#!/usr/bin/env bash
set -euo pipefail

message="${1:-}"

if [[ -z "${message}" ]]; then
  echo "Usage: $0 \"commit message\""
  exit 2
fi

branch="$(git branch --show-current)"

if [[ -z "${branch}" ]]; then
  echo "Unable to determine the current branch."
  exit 1
fi

if [[ "${branch}" == "main" ]]; then
  echo "Refusing to commit directly on main."
  exit 1
fi

git status

git add -A

if git diff --cached --quiet; then
  echo "Nothing to commit."
  exit 0
fi

echo
echo "Staged changes:"
git diff --cached --stat
echo

git commit -m "${message}"
git push -u origin "${branch}"

echo
echo "Published branch: ${branch}"
echo "Open a pull request to main from GitHub."
