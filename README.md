# LM Light 利用マニュアル (PyInstaller版)

> **Note**: このリポジトリはPyInstallerでビルドされたバイナリを配布しています。
> Nuitkaビルド版は [lmlight-app/dist](https://github.com/lmlight-app/dist) を参照してください。

## インストール

**macOS:**
```bash
curl -fsSL https://raw.githubusercontent.com/lmlight-app/dist_v2/main/scripts/install-macos.sh | bash
```

**Linux:**
```bash
curl -fsSL https://raw.githubusercontent.com/lmlight-app/dist_v2/main/scripts/install-linux.sh | bash
```

**Windows:**
```powershell
irm https://raw.githubusercontent.com/lmlight-app/dist_v2/main/scripts/install-windows.ps1 | iex
```

インストール先: `~/.local/lmlight` (Windows: `%LOCALAPPDATA%\lmlight`)

**Docker:**
```bash
curl -fsSL https://raw.githubusercontent.com/lmlight-app/dist_v2/main/scripts/install-docker.sh | bash
```

## 環境構築 (インストール前に実行)

### 必要な依存関係

| 依存関係 | macOS | Linux (Ubuntu/Debian) | Windows |
|---------|-------|----------------------|---------|
| Node.js 18+ | `brew install node` | `sudo apt install nodejs npm` | `winget install OpenJS.NodeJS.LTS` |
| PostgreSQL 16+ | `brew install postgresql@16` | `sudo apt install postgresql` | `winget install PostgreSQL.PostgreSQL` |
| pgvector | `brew install pgvector` | `sudo apt install postgresql-16-pgvector` | [手動インストール](https://github.com/pgvector/pgvector#windows) |
| Ollama | `brew install ollama` | `curl -fsSL https://ollama.com/install.sh \| sh` | `winget install Ollama.Ollama` |

### Ollamaモデル

```bash
ollama pull <model_name>        # 例: gemma3:4b, llama3.2, qwen2.5 など
ollama pull nomic-embed-text    # RAG用埋め込みモデル (推奨)
```

### 設定ファイル (.env)

インストール後、`~/.local/lmlight/.env` を編集:

| 環境変数 | 説明 | デフォルト |
|---------|------|-----------|
| `DATABASE_URL` | PostgreSQL接続URL | `postgresql://<user>:<password>@localhost:5432/<database>` |
| `OLLAMA_BASE_URL` | OllamaサーバーURL | `http://localhost:11434` |
| `LICENSE_FILE_PATH` | ライセンスファイルのパス | `~/.local/lmlight/license.lic` |
| `NEXTAUTH_SECRET` | セッション暗号化キー | - |
| `NEXTAUTH_URL` | WebアプリのURL | `http://localhost:3000` |
| `NEXT_PUBLIC_API_URL` | APIサーバーURL | `http://localhost:8000` |

### ライセンス

`license.lic` を `~/.local/lmlight/` に配置

## 起動・停止

```bash
# 起動
~/.local/lmlight/start.sh

# 停止
~/.local/lmlight/stop.sh
```

**Windows:**
```powershell
& "$env:LOCALAPPDATA\lmlight\start.ps1"
& "$env:LOCALAPPDATA\lmlight\stop.ps1"
```

## アクセス

- Web: http://localhost:3000
- API: http://localhost:8000

デフォルトログイン: `admin@local` / `admin123`

## Nuitka版との違い

| 項目 | PyInstaller (dist_v2) | Nuitka (dist) |
|------|----------------------|---------------|
| ビルド時間 | 〜10秒 | 〜5分 |
| バイナリサイズ | 〜44MB | 〜44MB |
| 難読化 | なし (bytecode) | あり (C変換) |
| 互換性 | 高い | macOS版に問題あり |
