#!/usr/bin/env sh

set -e

CUSTOM_DIRS="web/modules/custom web/themes/custom"

MODE="changed"
if [ "$1" = "--all" ]; then
  MODE="all"
fi

if [ "$MODE" = "all" ]; then
  find $CUSTOM_DIRS \
    -type f \
    \( \
      -name "*.php" \
      -o -name "*.module" \
      -o -name "*.inc" \
      -o -name "*.install" \
      -o -name "*.theme" \
      -o -name "*.js" \
      -o -name "*.css" \
    \)
  exit 0
fi

# Prefer staged files (pre-commit), fall back to unstaged
FILES=$(git diff --name-only --cached)
if [ -z "$FILES" ]; then
  FILES=$(git diff --name-only)
fi

echo "$FILES" | grep -E '^web/(modules|themes)/custom/' || true
