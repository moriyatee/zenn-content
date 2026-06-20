# zenn-content

[Zenn](https://zenn.dev) の記事を GitHub 連携（Zenn Connect）で公開するためのコンテンツリポジトリ。

## リポジトリ構成

| パス | 役割 |
|---|---|
| `articles/` | 記事の Markdown（1 ファイル = 1 記事）。ファイル名がスラッグ（公開後の URL）になる |
| `books/` | 本（あれば）。Zenn の book 形式 |
| `scripts/deploy-zenn.sh` | main へ「履歴 1 コミット」で force push するデプロイスクリプト |

### 記事ファイルの規約（Zenn）
- 置き場所: `articles/<slug>.md`
- スラッグ: 半角英小文字 `a-z` / 数字 `0-9` / `-` / `_`、**12〜50 文字**。**公開後は URL になるので変更しない**
- フロントマター必須キー:
  - `title` / `emoji` / `type`（`tech` or `idea`）/ `topics`（配列・最大 5）/ `published`（`true` で公開・`false` で下書き）

---

## デプロイ

### 仕組み（重要）
Zenn Connect は **このリポジトリの `main` ブランチ**を見てデプロイする。
公開リポに中間状態の履歴を残したくないので、**`main` は常に履歴 1 コミット**に保つ。

そのため main へは通常の `git push` ではなく、必ず **`scripts/deploy-zenn.sh`** を使う
（orphan な 1 コミットを作って force push する）。これは jidoshokki の
`deploy-privacy-policy.sh` と同じ思想。

### 役割分担
| ブランチ | 役割 |
|---|---|
| 作業ブランチ（`claude/...` など） | **source-of-truth**。記事・スクリプト・この CLAUDE.md を通常の履歴で管理。普段の編集・PR はここ |
| `main` | **公開対象**。`articles/` 等のコンテンツのみ・履歴は常に 1 コミット。直接コミットしない（force push で消える） |

### フロー
```bash
# 1. 作業ブランチで記事を編集・コミット・push（通常の履歴）
git add articles/ && git commit -m "..." && git push

# 2. main にデプロイ（履歴 1 コミットで force push）
./scripts/deploy-zenn.sh
#   または: ./scripts/deploy-zenn.sh "Custom commit message"

# 3. 反映確認（通常 1〜2 分）
#   https://zenn.dev/dashboard/deploys
```

### 注意
- **main を直接編集しない**。次のデプロイで force push されて消える。編集は必ず作業ブランチで。
- `deploy-zenn.sh` が main に載せるのは `CONTENT_PATHS`（`articles/` `books/` `README.md`）だけ。
  スクリプトや CLAUDE.md は公開対象に含めない（Zenn からは無視されるが、main をコンテンツのみで保つ方針）。
- 下書き（`published: false`）でも main に載せれば Zenn 上で本人プレビューが可能。一般公開は `published: true` にしてから再デプロイ。

---

## ローカルプレビュー（任意）
```bash
npx zenn preview   # localhost:8000
```
