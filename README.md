# keychain-tools

macOSキーチェーン操作用CLIツール群

## 概要

macOSの`security`コマンドを簡単に使えるようにするCLIツール群です。
`APP_NAME`環境変数を前提とした簡潔なキーチェーン操作を提供します。

## インストール

```bash
# Homebrew経由
brew tap aromarious/private
brew install aromarious/private/keychain-tools
```

## 使用方法

### 前提条件

`APP_NAME`環境変数の設定が必要です：

```bash
export APP_NAME="your-app-name"
```

### コマンド

#### kc-set - 値の設定

```bash
kc-set SECRET_KEY "your-secret-value"
```

内部的には以下を実行：
- 既存の同名キーを削除（エラー無視）
- 新しい値を追加

#### kc-get - 値の取得

```bash
kc-get SECRET_KEY
```

指定したキーの値をキーチェーンから取得します。

#### kc-list - キー一覧

```bash
kc-list
```

`APP_NAME`に紐づくキー一覧を表示します。

## shell補完

### zsh

```bash
# ~/.zshrc に追加
_kc_complete() { compadd $(kc-list) }
compdef _kc_complete kc-get kc-set
```

### bash

```bash
# ~/.bashrc に追加
_kc_complete() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    COMPREPLY=( $(compgen -W "$(kc-list)" -- "$cur") )
}
complete -F _kc_complete kc-get kc-set
```

## .envrcでの活用例

```bash
# .envrc
export APP_NAME="my-project"

# シークレットをキーチェーンから読み込み
export DATABASE_URL="$(kc-get DATABASE_URL)"
export API_KEY="$(kc-get API_KEY)"
```

初回設定：

```bash
kc-set DATABASE_URL "postgresql://..."
kc-set API_KEY "sk-..."
```

## エラーハンドリング

- `APP_NAME`環境変数が未設定の場合、エラーメッセージを表示して終了
- 引数の数が不正な場合、使用方法を表示して終了
- `kc-get`で存在しないキーを指定した場合、securityコマンドのエラーが表示

## ライセンス

MIT License