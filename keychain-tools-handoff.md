# keychain-tools 

## 概要
macOSの`security`コマンドを簡単に使えるようにするCLIツール群を作成する。

## 背景
- `.envrc`でsecurityコマンドを使う際の不便さを解消
- `security add-generic-password -a "$APP_NAME" -s "key" -w "value"` の長いコマンドを簡略化
- 更新時の`delete` → `add`の2ステップを1コマンドに統合
- 値の確認も簡単にしたい
- bash/zsh completionも効かせたい

## 要件
- `APP_NAME`環境変数が設定済み前提（なければエラー）
- `-a "$APP_NAME" -s -w` の定型部分を省略
- 新規/更新を自動判定（あったら delete→add、なかったら add）
- 表示専用コマンドも必要
- 候補をbash/zsh completionで効かせる

## 作成するコマンド

### kc-set
```bash
kc-set SECRET_KEY "value"
```
- 内部で `security delete-generic-password -a "$APP_NAME" -s "SECRET_KEY" 2>/dev/null || true`
- その後 `security add-generic-password -a "$APP_NAME" -s "SECRET_KEY" -w "value"`

### kc-get  
```bash
kc-get SECRET_KEY
```
- 内部で `security find-generic-password -a "$APP_NAME" -s "SECRET_KEY" -w`

### kc-list
```bash
kc-list
```
- 補完用に使用可能なキー一覧を表示
- `security dump-keychain | grep -o "\"$APP_NAME\".*" | cut -d'"' -f4`

## 補完設定
```bash
# ~/.zshrc に追加
_kc_complete() { compadd $(kc-list) }
compdef _kc_complete kc-get kc-set
```

## 配布方法
既存のHomebrew tap (https://github.com/aromarious/homebrew-private) を使用:
1. keychain-toolsに `v*` タグを付ける
2. `update-brew` workflowが自動でPR作成
3. PRを承認してマージ
4. `brew install aromarious/private/keychain-tools`

## 作業場所
- GitHub: https://github.com/aromarious/keychain-tools
- ローカル: ~/Garage/keychain-tools

## 次のステップ
1. kc-set, kc-get, kc-list の実装
2. エラーハンドリング（APP_NAME未設定等）
3. 実行権限付与
4. README作成
5. 初回タグ作成 (v1.0.0)
