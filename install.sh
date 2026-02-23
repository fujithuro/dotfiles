#!/bin/bash

set -eu

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# Claude Code
mkdir -p ~/.claude
ln -sf "$DOTFILES_DIR/claude/CLAUDE.md" ~/.claude/CLAUDE.md
ln -sf "$DOTFILES_DIR/claude/skills" ~/.claude/skills
ln -sf "$DOTFILES_DIR/claude/settings.json" ~/.claude/settings.json
ln -sf "$DOTFILES_DIR/claude/scripts" ~/.claude/scripts

# Claude Code MCP Servers
# NOTE: claude mcp add-json は既存サーバーが存在するとエラーになるが、
# 上書きや存在チェックのオプションがないため || true で無視している。
# 本来はサーバーの存在確認後にスキップすべきだが、claude mcp list は
# ヘルスチェックを伴い低速なため、現時点ではこの方法を採用。
claude mcp add-json --scope user github '{
  "type": "http",
  "url": "https://api.githubcopilot.com/mcp",
  "headers": {
    "Authorization": "Bearer ${GPR_TOKEN}"
  }
}' || true
