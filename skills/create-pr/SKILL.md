---
name: create-pr
description: GitHub PR を自動作成するスキル。現在のブランチの差分を分析し、リポジトリの PR テンプレートに沿った適切なタイトルと description を生成して gh コマンドで PR を作成する。PRを作りたい、プルリクを出したい、レビューに出したい、といった依頼があった時に使用する。
---

# create-pr

現在のブランチの変更内容を分析し、リポジトリの慣習に従った PR を `gh` CLI で作成するスキル。

## 処理フロー

### 1. 事前チェック

以下を並列で実行する：

```bash
# 未コミットの変更がないか確認（-uall は使わない）
git status

# 現在のブランチ名を取得
git branch --show-current

# リモートとの同期状態を確認
git status -sb

# main ブランチからの全コミットを取得（差分の全体像を把握）
git log main..HEAD --oneline

# main ブランチからのコード差分
git diff main...HEAD --stat
```

**中断条件：**
- `main` や `master` ブランチにいる場合 → ユーザーに警告して中断
- 未コミットの変更がある場合 → ユーザーにコミットするか確認

### 2. 変更内容の分析

```bash
# 全コミットの詳細（最新のコミットだけでなく、PR に含まれる全コミットを分析する）
git log main..HEAD --format="%h %s%n%b"

# コード差分の全体像
git diff main...HEAD
```

全コミットとコード差分を読み、以下を判断する：
- 変更の種類（feat / fix / chore / refactor 等）
- 変更の概要
- 影響範囲（frontend / backend / mobile / infra 等）

未コミットの変更があれば、formatterを実行した後コミットする。

### 3. PR テンプレートの取得

```bash
# リポジトリの PR テンプレートを探す
cat .github/pull_request_template.md 2>/dev/null || \
cat .github/PULL_REQUEST_TEMPLATE.md 2>/dev/null || \
echo "テンプレートなし"
```

テンプレートが存在する場合、そのフォーマットに従って description を構成する。

### 4. PR タイトルの生成

リポジトリの既存 PR のタイトル慣習に合わせる。このリポジトリでは以下のパターンが一般的：

- `feat: 機能の説明` / `fix: 修正の説明` / `chore: 作業の説明`
- Linear Issue がある場合: `feat: MOBL-1234` や `fix: WEB-2941 説明`
- 日本語のタイトルも使われる

ブランチ名に Issue ID が含まれている場合（例: `aono/web-2941`）はタイトルに反映する。

### 5. PR description の生成

テンプレートのセクションを埋める形で生成する。コメント（`<!-- -->`）部分は削除し、実際の内容に置き換える。

- **タイトル行**（テンプレート1行目）: `fix: WEB-2941 変更の概要` のように変更種別と概要を記載
- **懸念点・相談事項**: 実装上の懸念があれば記載、なければセクション自体を空にする
- **チェックリスト**: 影響範囲に応じて該当するチェックボックスをチェック済みにする

### 6. リモートへのプッシュと PR 作成

```bash
# リモートにプッシュ（未プッシュの場合）
git push -u origin HEAD

# PR 作成（HEREDOC で body を渡す）
gh pr create --title "タイトル" --body "$(cat <<'EOF'
description の内容
EOF
)" -a @me
```

### 8. 完了報告

作成された PR の URL を表示する。

## 注意事項

- `--force` push は絶対にしない
- main ブランチや master ブランチにいる場合は PR を作成せず、ユーザーに警告する
- description の Co-Authored-By は不要（コミットメッセージにのみ付与するもの）
- 基本的に上記のフローで承認を求めるのは不要。
