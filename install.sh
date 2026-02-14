#!/bin/bash

set -eu

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# Claude Code
mkdir -p ~/.claude
ln -sf "$DOTFILES_DIR/claude/CLAUDE.md" ~/.claude/CLAUDE.md
ln -sf "$DOTFILES_DIR/claude/skills" ~/.claude/skills
ln -sf "$DOTFILES_DIR/claude/settings.json" ~/.claude/settings.json
