#!/bin/bash
# ============================================================
# setup.sh — 新規プロジェクトの初期化スクリプト
#
# 使い方:
#   1. テンプレートをコピーしてリネーム
#        cp -R app-dev-template MyNewApp
#      （またはGitHubの "Use this template" → clone）
#   2. プロジェクトルートで実行
#        cd MyNewApp && ./setup.sh
#
# やること:
#   - CLAUDE.md / GEMINI.md のシンボリックリンクを（再）作成
#   - テンプレート由来の .git を削除し、新規リポジトリとして git init
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
if [ -d ".git" ]; then
  read -p "既存の .git があります。削除して新規リポジトリとして初期化しますか? [y/N]: " ans
  if [ "${ans:-N}" = "y" ] || [ "${ans:-N}" = "Y" ]; then
    rm -rf .git
    echo "  テンプレートのGit履歴を削除しました"
  else
    echo "  Git初期化をスキップしました（リンク作成のみ実施）"
    exit 0
  fi
fi

git init -b main
git add -A
git commit -m "Initialize project from app-dev-template"
echo ""
echo "完了！ 次のステップ:"
echo "  1. AGENTS.md の「プロジェクト概要」を書き換える"
echo "  2. Docs/01_concept.md にコンセプトメモを書く"
echo "  3. バックアップ用にGitHubへpush:"
echo "       gh repo create ${PROJECT_NAME} --private --source=. --push"
echo "  4. プロジェクトルートで claude / gemini を起動して開発開始"
