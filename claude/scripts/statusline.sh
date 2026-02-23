#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name // "?"')
DIR_RAW=$(echo "$input" | jq -r '.workspace.current_dir // "?"')
DIR=$(echo "$DIR_RAW" | sed "s|^$HOME|~|")
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0')
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
DURATION_MS=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')

# プログレスバー
BAR_WIDTH=10
FILLED=$((PCT * BAR_WIDTH / 100))
EMPTY=$((BAR_WIDTH - FILLED))
BAR=$(printf "%${FILLED}s" | tr ' ' '▓')$(printf "%${EMPTY}s" | tr ' ' '░')

# 経過時間を分に変換
DURATION_MIN=$((DURATION_MS / 60000))

# コストを小数第2位まで表示
COST_FMT=$(printf "%.2f" "$COST")

# Gitブランチ
BRANCH=$(git -C "$DIR_RAW" branch --show-current 2>/dev/null || echo "-")

# 1行目: モデル | コンテキスト使用率 | コスト | 経過時間
echo "[$MODEL] $BAR $PCT% | \$$COST_FMT | ${DURATION_MIN}min"
# 2行目: ディレクトリ | ブランチ
echo "$DIR | $BRANCH"
