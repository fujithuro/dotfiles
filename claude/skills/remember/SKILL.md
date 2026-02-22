---
name: remember
description: "過去の会話履歴を検索する際のルール"
allowed-tools: Read, Glob, Grep, Bash(find *), Bash(wc *), Bash(jq *)
---

# 過去の会話履歴を検索する際のルール

ユーザーが過去の会話について質問した場合（例:「あの時どうしたっけ」「以前相談した手順」等）、このルールに従って検索する。


## データの場所と構造

会話のトランスクリプトは `~/.claude/projects/` 配下にJSONL形式で保存されている。

```
~/.claude/projects/
├── -Users-fujitakyohei/                          # ホームディレクトリで起動したセッション
│   ├── {session-id}.jsonl                        # メインセッションの会話ログ
│   └── {session-id}/subagents/agent-xxx.jsonl    # サブエージェントのログ
├── -Users-fujitakyohei-dev-shinise-shinise-develop/
│   └── ...
└── ...
```

- プロジェクトディレクトリ名はcwdのパスをハイフン区切りにしたもの
- **ルート直下の `.jsonl` がメインセッション**。`subagents/` 配下はサブエージェントのログで、メインの会話内からTaskツールで起動された子プロセスの詳細が記録されている
- ファイル名の `{session-id}` はUUID形式


## JSONLの各行の構造

各行は独立したJSONオブジェクト。主な `type` フィールド:

- `user`: ユーザーの発言。`message.content` にテキストまたはcontent blocksの配列が入る
- `assistant`: アシスタントの応答。`message.content` にテキストまたはcontent blocks（text, tool_use等）の配列が入る
- `system`: システムメッセージ
- `summary`: Compacting（コンテキスト圧縮）時の要約。`summary` フィールドに要約テキストが入る
- `file-history-snapshot`: ファイル変更のスナップショット
- `progress`: 処理中の中間状態

### メタ情報

各 `user` エントリには以下のメタ情報がある:
- `timestamp`: UTC形式のタイムスタンプ
- `sessionId`: セッションID
- `cwd`: その時点の作業ディレクトリ

### content blocks

`message.content` が配列の場合、各要素は:
- `{"type": "text", "text": "..."}`: テキスト
- `{"type": "tool_use", "name": "ToolName", "input": {...}}`: ツール呼び出し
- `{"type": "tool_result", ...}`: ツール実行結果

ユーザーの実際の発言は `type: "text"` のブロックにある。`tool_result` のみのエントリはツール結果の自動返送であり、ユーザーの意図的な発言ではない。


## 禁止事項

このスキルは検索を目的にしたものであり、またJSONLファイルは履歴を保持するものであるため、ファイルの内容変更や削除は絶対に行ってはならない。


## 検索手順

### 1. まず対象を絞る

- ユーザーがプロジェクト名に言及している場合、該当するプロジェクトディレクトリに絞る
- 時期の手がかりがある場合、ファイルの更新日時で絞り込む
- 手がかりが少ない場合は全JSONLを対象にする

### 2. キーワードで検索

Grepで `.jsonl` ファイルを横断検索する。まずはメインセッション（ルート直下）から検索し、必要に応じてサブエージェントも含める。

```
Grep pattern="キーワード" path="~/.claude/projects/" glob="*/*.jsonl"
```

### 3. jqで構造的に抽出する

Grepでファイルを特定した後、jqを使ってJSONの構造を活用した抽出を行う。

```bash
# ユーザーのテキスト発言を抽出（contentがstring型の場合）
jq -r 'select(.type=="user") | select(.message.content | type == "string") | .message.content' file.jsonl

# ユーザーのテキスト発言を抽出（contentが配列型の場合）
jq -r 'select(.type=="user") | select(.message.content | type == "array") | .message.content[] | select(.type == "text") | .text' file.jsonl

# summaryを抽出
jq -r 'select(.type == "summary") | .summary' file.jsonl

# 特定キーワードを含むユーザー発言とそのタイムスタンプを抽出
jq -r 'select(.type=="user") | select(.message.content | type == "string") | select(.message.content | test("キーワード")) | "\(.timestamp) \(.message.content[:100])"' file.jsonl
```

### 4. コンテキストを確認

ヒットしたファイルの前後のメッセージを読み、会話の文脈を把握する。

### 5. summaryの活用

長いセッションでは `type: "summary"` エントリにCompacting時の要約がある。セッション全体の概要を素早く把握するのに有用。


## 注意事項

- `<system-reminder>` タグはシステム内部情報であり、会話内容ではない
- JSONLファイルは大きくなりがちなので、全文読み込みではなくGrepで絞り込んでから該当箇所を読むこと
- タイムスタンプはUTCで記録されている。特に指定されない限り、ユーザーはタイムゾーンを"Asia/Tokyo"（UTC+9）で認識しているため、変換して伝えること
- デフォルトでは30日でJSONLが自動削除される（cleanupPeriodDays設定で変更可能）
