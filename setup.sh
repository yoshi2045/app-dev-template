#!/bin/bash
# ============================================================
# setup.sh — 新規プロジェクトの初期化スクリプト
#
# 使い方:
#   1. テンプレートをコピーしてリネーム
#        cp -R app-dev-template my-new-app
#      （またはGitHubの "Use this template" → clone）
#   2. プロジェクトルートで実行
#        cd my-new-app && ./setup.sh
#
# やること:
#   - CLAUDE.md / GEMINI.md のシンボリックリンクを（再）作成
#   - テンプレート由来の .git を削除し、新規リポジトリとして git init
#   - コピー先で不要な TEMPLATE_README.md を削除
#   - 初回コミットを作成
# ============================================================
set -euo pipefail

# AGENTS.mdがある場所＝プロジェクトルートで実行されているか確認
if [ ! -f "AGENTS.md" ]; then
  echo "エラー: AGENTS.md が見つかりません。プロジェクトルートで実行してください。"
  exit 1
fi

PROJECT_NAME=$(basename "$PWD")
echo "プロジェクト「${PROJECT_NAME}」を初期化します..."

# --- 1. シンボリックリンクの（再）作成 ---
# コピー方法によってはリンクが実体ファイル化・破損することがあるため、常に張り直す
for f in CLAUDE.md GEMINI.md; do
  rm -f "$f"
  ln -s AGENTS.md "$f"
  echo "  リンク作成: $f -> AGENTS.md"
done

# --- 2. テンプレートのGit履歴を切り離して新規リポジトリ化 ---
IS_NEW_GIT=false
if [ -d ".git" ]; then
  REMOTE_URL=$(git remote get-url origin 2>/dev/null || true)
  if [ -n "$REMOTE_URL" ] && [[ "$REMOTE_URL" != *"app-dev-template"* ]]; then
    echo "  既存のワークスペースGit設定・リモートURLを維持します (${REMOTE_URL})"
  else
    rm -rf .git
    echo "  テンプレートの旧Git履歴を削除し、新規リポジトリとして初期化します"
    IS_NEW_GIT=true
  fi
else
  IS_NEW_GIT=true
fi

# テンプレート用の不要な説明ファイルを削除
if [ -f "TEMPLATE_README.md" ]; then
  rm -f TEMPLATE_README.md
  echo "  TEMPLATE_README.md を削除しました"
fi

if [ "$IS_NEW_GIT" = true ]; then
  git init -b main
  git add -A
  git commit -m "Initialize project from app-dev-template"
fi

# --- 3. アプリ本体リポジトリ（③）の初期化とGitHub作成 ---
if [ "$PROJECT_NAME" != "app-dev-template" ]; then
  REPO_DIR="Repo/${PROJECT_NAME}"
  if [ ! -d "$REPO_DIR/.git" ]; then
    echo "  アプリ本体リポジトリ (Repo/${PROJECT_NAME}) を自動初期化中..."
    mkdir -p "$REPO_DIR"
    (
      cd "$REPO_DIR"
      git init -b main
      if [ ! -f "README.md" ]; then
        echo "# ${PROJECT_NAME}" > README.md
      fi
      git add -A
      git commit -m "Initial commit"
      if command -v gh &> /dev/null && gh auth status &> /dev/null; then
        gh repo create "${PROJECT_NAME}" --private --source=. --remote=origin --push
        echo "  GitHubリポジトリ「${PROJECT_NAME}」を作成・pushしました"
      else
        echo "  注意: gh (GitHub CLI) が未認証のためGitHub作成をスキップしました。"
        echo "  後で Repo/${PROJECT_NAME} にて 'gh repo create ${PROJECT_NAME} --private --source=. --remote=origin --push' を実行してください。"
      fi
    )
  else
    echo "  Repo/${PROJECT_NAME} には既に .git が存在するため、作成をスキップしました"
  fi
fi

echo ""
echo "完了！ 次のステップ:"
echo "  1. AGENTS.md の「プロジェクト概要」を書き換える"
echo "  2. Docs/01_concept.md にコンセプトメモを書く"
echo "  3. プロジェクトルートで claude / gemini を起動して開発開始"
echo "     （※ Repo/ 配下のコードはワークスペース（②）のgit管理外です。"
echo "        作業の区切りでは②と③の両方で git status を確認してください）"
