#!/bin/sh
# link-skills.sh: repoのskillを ~/.claude/skills に追加（既存は上書きしない）
repo="$(cd "$(dirname "$0")" && pwd)"
dest="$HOME/.claude/skills"
for dir in "$repo"/skills/*/; do
  name="$(basename "$dir")"
  if [ -e "$dest/$name" ] || [ -L "$dest/$name" ]; then
    echo "skip: $name (already exists)"
  else
    ln -s "${dir%/}" "$dest/$name" && echo "linked: $name"
  fi
done
