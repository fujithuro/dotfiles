#!/bin/bash
# 指定セッションのuser/assistant発言を抽出する
# Usage: session-messages.sh <jsonl-file> [role] [max-chars]
#   role: user | assistant | both (default: both)
#   max-chars: 各メッセージの最大文字数 (default: 300)
# Example: session-messages.sh ~/.claude/projects/-Users-fujitakyohei/xxx.jsonl user 500

set -eu

file="${1:?Usage: session-messages.sh <jsonl-file> [role] [max-chars]}"
role="${2:-both}"
max_chars="${3:-300}"

extract_role() {
  local target_type="$1"
  jq -r --argjson max "$max_chars" --arg role "$target_type" '
    select(.type==$role) |
    if (.message.content | type) == "string" then
      "\($role): \(.message.content[:$max])"
    elif (.message.content | type) == "array" then
      .message.content[] | select(.type == "text") | "\($role): \(.text[:$max])"
    else empty end
  ' "$file" 2>/dev/null
}

case "$role" in
  user)
    extract_role "user"
    ;;
  assistant)
    extract_role "assistant"
    ;;
  both)
    jq -r --argjson max "$max_chars" '
      select(.type=="user" or .type=="assistant") |
      .type as $t |
      if (.message.content | type) == "string" then
        "\($t): \(.message.content[:$max])"
      elif (.message.content | type) == "array" then
        .message.content[] | select(.type == "text") | "\($t): \(.text[:$max])"
      else empty end
    ' "$file" 2>/dev/null
    ;;
  *)
    echo "Unknown role: $role (use: user, assistant, both)" >&2
    exit 1
    ;;
esac
