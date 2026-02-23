#!/bin/bash
# 指定ディレクトリ内の各セッションの最初のユーザー発言を一覧する
# Usage: session-overview.sh <project-dir>
# Example: session-overview.sh ~/.claude/projects/-Users-fujitakyohei-dotfiles

set -eu

dir="${1:?Usage: session-overview.sh <project-dir>}"

for f in "$dir"/*.jsonl; do
  [ -f "$f" ] || continue
  first=$(jq -r 'select(.type=="user") | select(.message.content | type == "string") | .message.content[:100]' "$f" 2>/dev/null | head -1)
  [ -n "$first" ] && echo "$(basename "$f"): $first"
done
