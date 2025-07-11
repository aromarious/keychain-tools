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

#### kc-delete - 値の削除

```bash
kc-delete KEY
```

現在の`APP_NAME`から指定したキーを削除します。

例：
```bash
kc-delete OLD_API_KEY
```

内部的には以下を実行：
- キーの存在を確認
- キーが存在する場合のみ削除

## shell補完

### zsh

```bash
# ~/.zshrc に追加
_kc_complete() { 
    if [[ -n "$APP_NAME" ]]; then
        local keys
        keys=($(kc-list 2>/dev/null | tr '\n' ' '))
        if [[ ${#keys[@]} -gt 0 ]]; then
            compadd "${keys[@]}"
        fi
    fi
}

_kc_dup_complete() {
    local state line
    case $CURRENT in
        2)
            # First argument: app name
            local apps
            apps=($(kc-apps 2>/dev/null | tr '\n' ' '))
            if [[ ${#apps[@]} -gt 0 ]]; then
                compadd "${apps[@]}"
            fi
            ;;
        3)
            # Second argument: key from specified app
            if [[ -n "${words[2]}" ]]; then
                local keys
                keys=($(kc-list "${words[2]}" 2>/dev/null | tr '\n' ' '))
                if [[ ${#keys[@]} -gt 0 ]]; then
                    compadd "${keys[@]}"
                fi
            fi
            ;;
    esac
}

compdef _kc_complete kc-get kc-set kc-delete
compdef _kc_dup_complete kc-dup
```

### bash

```bash
# ~/.bashrc に追加
_kc_complete() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    if [[ -n "$APP_NAME" ]]; then
        local keys
        keys=$(kc-list 2>/dev/null | paste -sd ' ' -)
        if [[ -n "$keys" ]]; then
            COMPREPLY=( $(compgen -W "$keys" -- "$cur") )
        fi
    fi
}

_kc_dup_complete() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    case $COMP_CWORD in
        1)
            local apps
            apps=$(kc-apps 2>/dev/null | paste -sd ' ' -)
            if [[ -n "$apps" ]]; then
                COMPREPLY=( $(compgen -W "$apps" -- "$cur") )
            fi
            ;;
        2)
            if [[ -n "${COMP_WORDS[1]}" ]]; then
                local keys
                keys=$(kc-list "${COMP_WORDS[1]}" 2>/dev/null | paste -sd ' ' -)
                if [[ -n "$keys" ]]; then
                    COMPREPLY=( $(compgen -W "$keys" -- "$cur") )
                fi
            fi
            ;;
    esac
}

complete -F _kc_complete kc-get kc-set kc-delete
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

## 補完のデバッグ

もし補完がうまく動作しない場合は、以下のデバッグ用スクリプトで問題を特定できます：

### zsh デバッグ用

```bash
# デバッグ用の簡易補完（~/.zshrc に一時的に追加）
_kc_debug() {
    echo "Debug: CURRENT=$CURRENT, words=(${words[@]})" >&2
    case $CURRENT in
        2) compadd portfolio01 portfolio02 test-app ;;
        3) compadd TEST_KEY SECRET_KEY API_KEY ;;
    esac
}
compdef _kc_debug kc-dup
```

### bash デバッグ用

```bash
# デバッグ用の簡易補完（~/.bashrc に一時的に追加）
_kc_debug_bash() {
    echo "Debug: CWORD=$COMP_CWORD, WORDS=(${COMP_WORDS[@]})" >&2
    case $COMP_CWORD in
        1) COMPREPLY=( portfolio01 portfolio02 test-app ) ;;
        2) COMPREPLY=( TEST_KEY SECRET_KEY API_KEY ) ;;
    esac
}
complete -F _kc_debug_bash kc-dup
```

## ライセンス

MIT License
