# Repo/

アプリ本体のソースコードをここに配置します。

- このフォルダの中身はルートリポジトリの管理対象外です（`.gitignore`で除外）
- アプリごとに独立したGitリポジトリとして作成してください
- **GitHub上の名前は接尾辞なしのクリーンな名前**にします（ルート側が`-workspace`を名乗る。`TEMPLATE_README.md`の命名ルール参照）
- ルートをコミットしてもここのコードは1行も入りません。**アプリのコミットは必ずこのフォルダ内で行うこと**

```bash
# 例: 既にローカルで git init 済みのアプリをGitHubに上げる
cd Repo/my-app
gh repo create my-app --private --source=. --remote=origin --push
```
