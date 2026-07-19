# app-dev-template

個人アプリ開発（Web / macOS / iOS）用のプロジェクトテンプレート。
複数のAI（Claude Code / Gemini CLI 等）が同じコンテキストを共有し、途中交代できる構成になっています。

> **注**: このファイルはテンプレート自体の説明書です。新規プロジェクト作成後は削除して構いません
> （プロジェクトの運用ルールはすべて `AGENTS.md` に書かれています）。

## 構成

```
app-dev-template/
├─ AGENTS.md              # AI共通コンテキストの実体（運用ルール・標準スタック）
├─ CLAUDE.md → AGENTS.md  # シンボリックリンク（Claude Code用）
├─ GEMINI.md → AGENTS.md  # シンボリックリンク（Gemini CLI用）
├─ AI/                    # AIの作業メモ（STATUS / DECISIONS / PROMPTS）
├─ Docs/                  # 成果物（コンセプト / 要件定義 / 設計）
├─ Repo/                  # アプリ本体（独立Gitリポジトリ。ルート管理外）
├─ Sandbox/               # PoC・実験コード
├─ .vscode/               # エディタ共通設定
├─ .gitignore             # 2層構成の要（Repo/を除外）
└─ setup.sh               # 新規プロジェクト初期化スクリプト
```

## Git管理の全体像（3つのリポジトリ）

| リポジトリ | 場所 | 役割 |
|---|---|---|
| ① テンプレート | `app-dev-template` | テンプレート自体の進化を管理。GitHubで**テンプレートリポジトリ**に設定 |
| ② プロジェクトルート | `MyNewApp/` | AGENTS.md・AI/・Docs/・Sandbox/ の履歴管理とバックアップ（Repo/は除外） |
| ③ アプリ本体 | `MyNewApp/Repo/my-app/` | ソースコード。アプリごとに独立 |

①と②は `setup.sh` が履歴を切り離すので、テンプレートの更新履歴が各プロジェクトに混ざることはありません。

## 新規プロジェクトの始め方

```bash
# 方法A: GitHubテンプレートリポジトリから（推奨）
gh repo create MyNewApp --private --template <あなたのアカウント>/app-dev-template --clone
cd MyNewApp && ./setup.sh

# 方法B: ローカルコピーから
cp -R app-dev-template MyNewApp
cd MyNewApp && ./setup.sh
```

その後:
1. `AGENTS.md` のプロジェクト概要を書き換える
2. `Docs/01_concept.md` にアイデアを書く
3. プロジェクトルートで `claude`（または `gemini`）を起動 → 「AGENTS.mdとAI/STATUS.mdを読んで開始して」

## テンプレート自体のバージョン管理

このテンプレートは1つのGitリポジトリとして管理します。

```bash
# 初回セットアップ（テンプレート自体）
cd app-dev-template
./setup.sh   # リンク作成 + git init + 初回コミット
gh repo create app-dev-template --private --source=. --push

# GitHub上で Settings → Template repository にチェックを入れる
```

### 運用ルール
- プロジェクトを回す中で得た改善（AGENTS.mdの書き方、雛形の項目追加など）は、**テンプレート側にも反映してコミット**する。これで次のプロジェクトから恒久的に効く
- 標準スタックの更新（例: Next.jsのメジャーバージョンアップ）もテンプレートのAGENTS.mdを更新する
- 大きな変更にはタグを打つと、どの世代のテンプレートから作ったプロジェクトかを追いやすい
  ```bash
  git tag v1.0 && git push --tags
  ```
- 既存プロジェクトへの遡及適用は無理にしない（差分が必要なら該当ファイルだけ手動コピーで十分）

## AI引き継ぎの使い方（Claude → Gemini 等）

1. 交代前のAIに: 「`AI/STATUS.md` を最新化して」（AGENTS.mdのルール上、区切りごとに自動更新されているはずだが念のため）
2. 交代後のAIをプロジェクトルートで起動: 「AGENTS.mdとAI/STATUS.mdを読んで、続きから開始して」

これだけです。定型文は `AI/PROMPTS.md` にストックしてあります。
