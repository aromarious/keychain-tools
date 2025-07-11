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
kc-list [APP_NAME]
```

`APP_NAME`に紐づくキー一覧を表示します。引数を指定した場合は、そのアプリ名のキー一覧を表示します。

#### kc-apps - アプリ一覧

```bash
kc-apps
```

キーチェーンに登録されているすべてのアプリ名（APP_NAME）を表示します。

#### kc-dup - 値のコピー

```bash
kc-dup SOURCE_APP_NAME KEY
```

指定したソースアプリから現在の`APP_NAME`にキーと値をコピーします。

例：
```bash
kc-dup portfolio02 MOTHERDUCK_TOKEN
```

内部的には以下を実行：
- ソースアプリからキーの値を取得
- 現在のアプリの同名キーを削除（エラー無視）
- 現在のアプリに値を追加

## shell補完

### zsh

```bash
# ~/.zshrc に追加
_kc_complete() { compadd $(kc-list) }
_kc_dup_complete() {
    local context state line
    _arguments \
        '1:app name:($(kc-apps))' \
        '2:key:($(kc-list ${words[2]}))'
}
compdef _kc_complete kc-get kc-set
compdef _kc_dup_complete kc-dup
```

### bash

```bash
# ~/.bashrc に追加
_kc_complete() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    COMPREPLY=( $(compgen -W "$(kc-list)" -- "$cur") )
}
_kc_dup_complete() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    case $COMP_CWORD in
        1)
            COMPREPLY=( $(compgen -W "$(kc-apps)" -- "$cur") )
            ;;
        2)
            if [ -n "${COMP_WORDS[1]}" ]; then
                COMPREPLY=( $(compgen -W "$(kc-list "${COMP_WORDS[1]}")" -- "$cur") )
            fi
            ;;
    esac
}
complete -F _kc_complete kc-get kc-set
complete -F _kc_dup_complete kc-dup
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