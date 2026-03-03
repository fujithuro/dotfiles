#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name // "?"')
DIR_RAW=$(echo "$input" | jq -r '.workspace.current_dir // "?"')
DIR=$(echo "$DIR_RAW" | sed "s|^$HOME|~|")
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0')

# プログレスバー
BAR_WIDTH=10
FILLED=$((PCT * BAR_WIDTH / 100))
EMPTY=$((BAR_WIDTH - FILLED))
BAR=$(printf "%${FILLED}s" | tr ' ' '▓')$(printf "%${EMPTY}s" | tr ' ' '░')

# Gitブランチ
BRANCH=$(git -C "$DIR_RAW" branch --show-current 2>/dev/null || echo "-")

# モデル | ディレクトリ | ブランチ | コンテキスト使用率
echo "[$MODEL] $DIR | $BRANCH | $BAR $PCT%"
