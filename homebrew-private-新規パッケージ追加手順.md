# homebrew-private 新規パッケージ追加手順

## 概要
aromarious/homebrew-privateリポジトリに新しいパッケージを追加する手順書

## リポジトリ構造
```
aromarious/homebrew-private/
├── Formula/           # 実際のFormula（.rb）ファイル
├── templates/         # テンプレート（.rb.tmpl）ファイル
├── scripts/update.js  # テンプレートからFormulaを生成するスクリプト
└── .github/workflows/update-brew.yml  # 自動化ワークフロー
```

## 新規パッケージ追加手順

### 1. テンプレートファイル作成（homebrew-private側）

#### 1-1. 既存テンプレートをコピー
```bash
cd ~/path/to/homebrew-private
cp templates/clear-notifications.rb.tmpl templates/keychain-tools.rb.tmpl
```

#### 1-2. テンプレートファイル編集
```ruby
class {{ formula }} < Formula
  desc "{{ description }}"
  homepage "{{ homepage }}"
  url "{{ url }}"
  sha256 "{{ sha256 }}"
  license "{{ license }}"

  def install
    # パッケージ固有のインストール処理
    bin.install "kc-get", "kc-list", "kc-set"
  end

  test do
    # テスト処理
    system "#{bin}/kc-list", "--help"
  end
end
```

#### 1-3. scripts/update.jsでの対応確認
- 新しいパッケージ名がupdate.jsで処理されるかを確認
- 必要に応じてupdate.jsにパッケージ固有の処理を追加

### 2. パッケージリポジトリ側の準備

#### 2-1. リリース準備
```bash
# パッケージリポジトリで
git add .
git commit -m "リリース準備"
git tag v1.0.0
git push origin main
git push origin v1.0.0
```

#### 2-2. 自動化ワークフロー追加（オプション）
```yaml
# .github/workflows/release.yml
name: Release
on:
  push:
    tags: ['v*']
jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - name: Trigger Homebrew Update
        run: |
          curl -X POST \
            -H "Authorization: token ${{ secrets.PERSONAL_ACCESS_TOKEN }}" \
            -H "Accept: application/vnd.github.v3+json" \
            https://api.github.com/repos/aromarious/homebrew-private/dispatches \
            -d '{"event_type":"update-brew","client_payload":{"package":"keychain-tools"}}'
```

### 3. Formula生成（手動または自動）

#### 3-1. 自動化利用（推奨）
1. **リリースタグ作成** → 自動でrepository_dispatchイベント送信
2. **update-brewワークフロー実行** → テンプレートからFormula自動生成
3. **PR自動作成** → 生成されたFormulaでPR作成
4. **PR承認・マージ** → 手動で確認後マージ

#### 3-2. 手動実行（緊急時）
```bash
# homebrew-privateリポジトリで
cd scripts
node update.js \
  --package=keychain-tools \
  --version=1.0.0 \
  --description="macOSキーチェーン操作用CLIツール群" \
  --homepage="https://github.com/aromarious/keychain-tools" \
  --url="https://github.com/aromarious/keychain-tools/archive/refs/tags/v1.0.0.tar.gz" \
  --license="MIT"
```

### 4. インストール確認

#### 4-1. ローカルテスト
```bash
# 生成されたFormulaをテスト
brew install --build-from-source ./Formula/keychain-tools.rb
```

#### 4-2. タップ経由インストール
```bash
# PRマージ後
brew tap aromarious/private
brew install aromarious/private/keychain-tools
```

#### 4-3. 動作確認
```bash
# インストール確認
which kc-get kc-list kc-set
# 動作テスト
export APP_NAME="test-app"
kc-set test-key "test-value"
kc-get test-key
kc-list
```

## 注意点

### テンプレート作成時
- インストール方法はパッケージの構造に合わせて調整
- 依存関係（depends_on）が必要な場合は適切に設定
- testブロックでの動作確認方法を適切に記述

### リリース時
- セマンティックバージョニング（v1.0.0形式）を使用
- タグ付けは必須（自動化のトリガー）
- 変更内容をCHANGELOG.mdに記録（推奨）

### 自動化設定時
- PERSONAL_ACCESS_TOKENの設定が必要
- repository_dispatchのイベント名は"update-brew"固定
- client_payloadでパッケージ名を指定

## トラブルシューティング

### よくある問題
1. **SHA256ハッシュ不一致**: リリースファイルの再生成が必要
2. **テンプレート構文エラー**: プレースホルダーの記述ミス
3. **依存関係エラー**: Formula内のdepends_on設定不備
4. **インストールパス問題**: binディレクトリへの配置ミス

### デバッグ方法
```bash
# Formulaの構文チェック
brew audit --strict Formula/keychain-tools.rb

# インストールプロセスの詳細表示
brew install --verbose --debug Formula/keychain-tools.rb
```

## 参考リンク
- [Homebrew Formula Cookbook](https://docs.brew.sh/Formula-Cookbook)
- [aromarious/homebrew-private](https://github.com/aromarious/homebrew-private)
- [GitHub Actions repository_dispatch](https://docs.github.com/en/rest/repos/repos#create-a-repository-dispatch-event)