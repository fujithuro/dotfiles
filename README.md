# dotfiles

開発環境の設定ファイルを管理するリポジトリ。

## 仕組み

`install.sh` を実行すると、各設定ファイルへのシンボリックリンクがホームディレクトリ配下に作成される。
設定の実体はこのリポジトリで一元管理し、Git で変更を追跡する。

## ディレクトリ構成

```
dotfiles/
├── claude/          # Claude Code の設定
│   ├── CLAUDE.md    # グローバル指示ファイル → ~/.claude/CLAUDE.md
│   ├── settings.json # 権限・設定 → ~/.claude/settings.json
│   ├── scripts/     # ステータスライン等のスクリプト → ~/.claude/scripts
│   └── skills/      # カスタムスキル定義 → ~/.claude/skills
├── zsh/             # Zsh の設定（予定）
├── install.sh       # シンボリックリンク作成スクリプト
└── README.md
```

## セットアップ

```sh
git clone <this-repo> ~/dotfiles
cd ~/dotfiles
bash install.sh
```

## install.sh の冪等性

`install.sh` は繰り返し実行しても安全に動作するよう設計されている。

### シンボリックリンク

`ln` には `-n` オプションを付与している。これがないと、リンク先が既にシンボリックリンクの場合にそれを辿ってしまい、リンク先ディレクトリ内に循環リンクが作成される。

### MCP Server の追加

`claude mcp add-json` は既存サーバーが存在するとエラーを返すが、上書きや存在チェックのオプションが提供されていない。`claude mcp list` によるチェックはヘルスチェックを伴い低速なため、現時点では `|| true` でエラーを無視する方式を採用している。
