# Linux / macOS / Windows インストールスクリプト比較

## 1. 基本情報

| 項目 | Linux | macOS | Windows |
|------|-------|-------|---------|
| スクリプト言語 | Bash | Bash | PowerShell |
| インストール先 | `$HOME/.local/lmlight` | `$HOME/.local/lmlight` | `%LOCALAPPDATA%\lmlight` |
| アーキテクチャ | amd64/arm64 自動検出 | amd64/arm64 自動検出 | amd64のみ |
| バイナリ名 | `api` | `api` | `api.exe` |

## 2. ダウンロード方法

| 項目 | Linux | macOS | Windows |
|------|-------|-------|---------|
| HTTP取得 | `curl -fSL` | `curl -fSL` | `Invoke-WebRequest` |
| tar展開 | `tar -xzf` | `tar -xzf` | `$env:SystemRoot\System32\tar.exe` (※1) |

※1: Git付属のtarを回避するため、Windows標準のtar.exeをフルパス指定

## 3. PostgreSQL 関連

| 項目 | Linux | macOS | Windows |
|------|-------|-------|---------|
| デフォルトポート | 5432 | 5432 | 5432 |
| ポート自動検出 | なし | なし | あり (5432→5433) (※2) |
| psql実行 | `sudo -u postgres psql` | `psql -U postgres` | `psql -U postgres -p $DB_PORT` |
| パスワード認証 | peer認証 (不要) | trust認証 (不要) | パスワード認証 (`postgres`) |
| サービス管理 | systemd (手動) | brew services (手動) | `Get-Service/Start-Service` |

※2: ポート自動検出は環境依存の問題に対応するための機能であり、OS固有の要件ではない。Linux/macOSにも追加可能。

## 4. .env ファイル

| 項目 | Linux | macOS | Windows |
|------|-------|-------|---------|
| 既存ファイル保持 | ✅ 上書きしない | ✅ 上書きしない | ❌ 常に上書き (※3) |
| NEXTAUTH_SECRET | 固定値 `randomsecret123` | 固定値 `randomsecret123` | ランダム32文字生成 |
| AUTH_SECRET/URL | なし | なし | あり (Auth.js v5対応) |
| パス区切り | `/` | `/` | `\` |

※3: Windowsの上書き動作は要検討。Linux/macOS同様に既存ファイルを保持すべき。

## 5. 起動スクリプト (start.sh / start.ps1)

| 項目 | Linux | macOS | Windows |
|------|-------|-------|---------|
| 実行方式 | フォアグラウンド | フォアグラウンド | バックグラウンド |
| プロセス管理 | `trap` + `wait` | `trap` + `wait` | `Start-Process -WindowStyle Hidden` |
| 終了方法 | Ctrl+C | Ctrl+C | stop.ps1 実行 |
| PostgreSQLチェック | `pg_isready -q` | `pg_isready -q` | `Get-Service` |
| Ollamaチェック | `pgrep -x ollama` | `pgrep -x ollama` | `Get-Process -Name "ollama"` |
| Auth.js v5環境変数 | なし | なし | `AUTH_TRUST_HOST=true` |
| Tesseract PATH設定 | なし | なし | 自動追加 |
| ブラウザ自動起動 | なし | なし | `Start-Process` |

## 6. 停止スクリプト (stop.sh / stop.ps1)

| 項目 | Linux | macOS | Windows |
|------|-------|-------|---------|
| プロセス検索 | `pkill -f` (正規表現) | `pkill -f` (正規表現) | `Get-Process + Where-Object` |
| 対象プロセス | `start.sh`, `./api`, `server.js` | 同左 | `api`, `node` (Pathフィルタ) |

## 7. トグル/アプリ統合

| 項目 | Linux | macOS | Windows |
|------|-------|-------|---------|
| トグル機能 | なし | .app内に統合 | `toggle.ps1` |
| アプリ形式 | なし | `/Applications/LM Light.app` | スタートメニュー ショートカット |
| 通知機能 | なし | `osascript` (macOS通知) | Windowsトースト通知 |
| ヘルスチェック | なし | `curl /health` | `Invoke-WebRequest /health` |

## 8. 依存関係チェック

| 項目 | Linux | macOS | Windows |
|------|-------|-------|---------|
| 起動前チェック | 簡易 (Node, PostgreSQL) | 簡易 (Node, PostgreSQL) | 詳細 (Node, PostgreSQL, Ollama, Tesseract) |
| 自動インストール | なし | なし | winget対応 (管理者権限時) |

## 9. 実装状況サマリー

| 機能 | Linux | macOS | Windows | 備考 |
|------|:-----:|:-----:|:-------:|------|
| AUTH_SECRET/AUTH_URL | ❌ | ❌ | ✅ | Auth.js v5に必須 |
| AUTH_TRUST_HOST設定 | ❌ | ❌ | ✅ | Auth.js v5に必須 |
| ポート自動検出 | ❌ | ❌ | ✅ | 環境依存、OSに依らない |
| Tesseract PATH設定 | ❌ | ❌ | ✅ | 画像OCR用、オプション |
| 依存関係詳細チェック | ❌ | ❌ | ✅ | UX向上 |
| 自動インストール | ❌ | ❌ | ✅ | winget/brew対応可能 |
| ブラウザ自動起動 | ❌ | ✅ | ✅ | xdg-openで対応可能 |
| 通知機能 | ❌ | ✅ | ✅ | notify-sendで対応可能 |
| NEXTAUTH_SECRETランダム生成 | ❌ | ❌ | ✅ | セキュリティ向上 |
| 既存.env保持 | ✅ | ✅ | ❌ | Windowsも保持すべき |

## 10. 命名規則 (共通)

| レイヤー | 命名規則 | 例 |
|----------|----------|-----|
| Next.js (Prisma) | camelCase | `userId`, `createdAt`, `defaultModel` |
| Python API (pgvector) | snake_case | `bot_id`, `user_id`, `created_at` |
| テーブル名 | PascalCase | `"User"`, `"UserSettings"`, `"Chat"` |

## 11. 推奨改善項目

### Linux/macOS に追加すべき機能

1. **Auth.js v5 対応 (必須)**
   ```bash
   # .env に追加
   AUTH_SECRET=$NEXTAUTH_SECRET
   AUTH_URL=$NEXTAUTH_URL

   # start.sh に追加
   export AUTH_TRUST_HOST=true
   ```

2. **NEXTAUTH_SECRET ランダム生成**
   ```bash
   NEXTAUTH_SECRET=$(openssl rand -base64 32 | tr -dc 'a-zA-Z0-9' | head -c 32)
   ```

3. **(オプション) ブラウザ自動起動**
   ```bash
   # Linux
   xdg-open "http://localhost:3000" 2>/dev/null &
   # macOS
   open "http://localhost:3000"
   ```

### Windows に修正すべき項目

1. **既存.envファイルの保持**
   ```powershell
   if (-not (Test-Path "$INSTALL_DIR\.env")) {
       # .env作成処理
   }
   ```