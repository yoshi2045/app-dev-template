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

| リポジトリ | ローカルの場所 | GitHub上の名前 | 役割 |
|---|---|---|---|
| ① テンプレート | `app-dev-template/` | `app-dev-template` | テンプレート自体の進化を管理。GitHubで**テンプレートリポジトリ**に設定 |
| ② プロジェクトルート | `my-new-app/` | `my-new-app-workspace` | AGENTS.md・AI/・Docs/・Sandbox/ の履歴管理とバックアップ（Repo/は除外） |
| ③ アプリ本体 | `my-new-app/Repo/my-new-app/` | `my-new-app` | ソースコード。アプリごとに独立 |

### 命名ルール：接尾辞は②（ワークスペース）側に付ける

**プロジェクトルートフォルダ名、アプリ本体フォルダ名、アプリ本体リポジトリ名はすべて同じ名称（例: `my-new-app`）を使用し、ワークスペースである②のGitHubリポジトリ名にのみ `-workspace` を付けます。**
成果物である③がクリーンな名前を取り、ドキュメント作業場である②が `-workspace` を名乗ります。
③はいずれ clone / deploy / 公開 / CI の対象になる「外に出るリポジトリ」であり、URLに接尾辞が残ると長く不自然になるためです。
逆に③に `-app` を付ける案は、次の成果物がCLIやライブラリだったときに名前が実態と合わなくなります（`-workspace` は成果物の種類に依存しません）。

**接尾辞が付くのはGitHub上の名前だけで、ローカルのフォルダ名は `my-new-app/` のまま**です（`setup.sh` はフォルダ名をプロジェクト名として使うため）。
別マシンへcloneするときはフォルダ名を指定して合わせます:

```bash
git clone git@github.com:<あなたのアカウント>/my-new-app-workspace.git my-new-app
```

### ②を改名して③に名前を譲る場合の手順（既存プロジェクトの移行）

②が先にクリーンな名前を取ってしまっている場合は、**必ずこの順序**で行います。

```bash
cd my-new-app && gh repo rename my-new-app-workspace --yes   # ②を改名（ローカルremoteも自動更新される）
git remote -v                                            # ★ 向き先が -workspace になったことを必ず確認
cd Repo/my-new-app && gh repo create my-new-app --private --source=. --remote=origin --push   # ③を作成
```

逆順やremote更新漏れがあると、③が旧名を取った瞬間に②からの `git push` が③へ飛びます。
GitHubは改名時に旧URLからリダイレクトを張りますが、**旧名で新リポジトリを作った時点でそのリダイレクトは消える**ため、この順序が唯一の安全な経路です。

①と②は `setup.sh` が履歴を切り離すので、テンプレートの更新履歴が各プロジェクトに混ざることはありません。

## 新規プロジェクトの始め方

新規プロジェクト作成時に、**ワークスペース用（②）**と**アプリ本体用（③）**の2つのリポジトリを準備します。`setup.sh` を実行すれば、アプリ本体（③）の `git init` やGitHub作成も全自動で完了します。

```bash
# ------------------------------------------------------------
# 方法A: 2アクションで作成（推奨）
# ------------------------------------------------------------

# 1. ワークスペース用リポジトリ（②）を作成して clone
gh repo create my-new-app-workspace --private --template <あなたのアカウント>/app-dev-template
git clone git@github.com:<あなたのアカウント>/my-new-app-workspace.git my-new-app

# 2. 初期化スクリプトを実行（アプリ本体 ③ Repo/my-new-app のGitHub作成まで全自動完了）
cd my-new-app && ./setup.sh

# ------------------------------------------------------------
# 方法B: ローカルコピーから作成
# ------------------------------------------------------------
cp -R app-dev-template my-new-app
cd my-new-app && ./setup.sh
```

### 💡 1アクション（1コマンド）で完了させたい場合

お使いの端末（Macの `~/.zshrc` など）に以下のシェル関数を追加しておくと、ターミナルで `create-app my-new-app` と打つだけで**全工程が1発で完了**します。

```bash
# ~/.zshrc に追記
create-app() {
  if [ -z "$1" ]; then
    echo "使用方法: create-app <プロジェクト名>"
    return 1
  fi
  local PROJECT_NAME="$1"
  local GITHUB_USER="<あなたのアカウント名>"  # 例: yoshi2045

  echo "🚀 [1/3] ワークスペース (${PROJECT_NAME}-workspace) をGitHub上に作成中..."
  gh repo create "${PROJECT_NAME}-workspace" --private --template "${GITHUB_USER}/app-dev-template"

  echo "📥 [2/3] ローカル (${PROJECT_NAME}) へクローン中..."
  local count=0
  until git clone "git@github.com:${GITHUB_USER}/${PROJECT_NAME}-workspace.git" "${PROJECT_NAME}" 2>/dev/null || [ $count -ge 5 ]; do
    sleep 2
    count=$((count + 1))
  done

  if [ ! -d "${PROJECT_NAME}" ] || [ ! -f "${PROJECT_NAME}/setup.sh" ]; then
    echo "❌ エラー: クローンに失敗しました。GitHub上のリポジトリ (${PROJECT_NAME}-workspace) を確認してください。"
    return 1
  fi

  echo "⚙️ [3/3] 初期化スクリプトを実行中..."
  (cd "${PROJECT_NAME}" && ./setup.sh)
}
```

その後:
1. `AGENTS.md` のプロジェクト概要を書き換える
2. `Docs/01_concept.md` にアイデアを書く
3. プロジェクトルートで `claude`（または `gemini`）を起動 → 「AGENTS.mdとAI/STATUS.mdを読んで開始して」

### よくある落とし穴：②をコミットしてもアプリのコードは保存されない

`.gitignore` で `Repo/*` を除外しているため、**アプリ側の変更は②の `git status` に一切現れません。**
実際に「②のコミットメッセージはアプリの実装を語っているのに、中身は `AI/` の更新だけ」という状態が数週間続き、
アプリのコードがローカル1台にしか存在しなかった事例があります（investment-support、2026-07〜08）。
作業の区切りでは**②（`my-new-app-workspace`）と③（`my-new-app`）の両方**の `git status` を確認し、それぞれコミット・pushしてください。

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
