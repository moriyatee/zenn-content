#!/usr/bin/env bash
# Zenn の公開対象（articles/ など）を main ブランチに
# 「履歴 1 コミット」に保ったまま force push でデプロイする。
#
# 背景:
#   Zenn Connect は moriyatee/zenn-content の **main ブランチ** を見てデプロイする。
#   公開リポに中間状態の履歴を積み上げたくないので、毎回 orphan な 1 コミットに
#   まとめて main を force push で上書きする（privacy-policy の deploy と同じ思想）。
#
# 役割分担:
#   - 作業ブランチ (claude/...) = source-of-truth。記事・スクリプト・CLAUDE.md を通常の履歴で管理。
#   - main                      = 公開対象。CONTENT_PATHS の中身だけ・履歴は常に 1 コミット。
#
# 仕組み:
#   1. CONTENT_PATHS（articles/ など）を一時ディレクトリにコピー
#   2. そこで git init して 1 コミット
#   3. 現在の origin（リモート URL は git remote から取得）の main に force push
#
# 詳細: ../CLAUDE.md の「デプロイ」節
#
# 使い方:
#   ./scripts/deploy-zenn.sh
#   ./scripts/deploy-zenn.sh "Custom commit message"

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEPLOY_BRANCH="main"
COMMIT_MSG="${1:-Deploy Zenn content}"

# 公開対象（ここに列挙したものだけが main に載る）
# images/ は Zenn が記事内の /images/... 参照を解決するためのディレクトリ。
CONTENT_PATHS=(articles books images README.md)

cd "$REPO_ROOT"

if [[ ! -d "$REPO_ROOT/articles" ]]; then
    echo "Error: articles/ not found at $REPO_ROOT" >&2
    echo "       公開する記事が無い状態でデプロイすると main が空になります。" >&2
    exit 1
fi

REMOTE_URL="$(git -C "$REPO_ROOT" remote get-url origin)"

TMP_DIR="$(mktemp -d -t deploy-zenn.XXXXXX)"
trap 'rm -rf "$TMP_DIR"' EXIT

echo "==> Snapshotting deploy content to $TMP_DIR"
for p in "${CONTENT_PATHS[@]}"; do
    if [[ -e "$REPO_ROOT/$p" ]]; then
        cp -R "$REPO_ROOT/$p" "$TMP_DIR/"
    fi
done

cd "$TMP_DIR"
find . -name '.DS_Store' -delete

echo "==> Creating single-commit history"
git init -q
git checkout -q -b "$DEPLOY_BRANCH"
git add .
git commit -q -m "$COMMIT_MSG"

echo "==> Force pushing to origin/$DEPLOY_BRANCH"
git remote add origin "$REMOTE_URL"

n=0
until git push -f -q origin "$DEPLOY_BRANCH"; do
    n=$((n + 1))
    if [[ $n -ge 4 ]]; then
        echo "Error: push to $DEPLOY_BRANCH failed after $n attempts" >&2
        exit 1
    fi
    wait_sec=$((2 ** n))
    echo "   push failed, retrying in ${wait_sec}s ($n/4)..." >&2
    sleep "$wait_sec"
done

echo "==> Done."
echo
echo "Zenn Connect が main を検知して再デプロイします（通常 1〜2 分）。"
echo "確認: https://zenn.dev/dashboard/deploys"
