# Project Context

## Purpose

每日 AI 學習內容自動產生系統（Daily-Tips-React）

使用 Claude Code CLI 自動產生每日學習筆記，幫助從 Vue 轉職到 React 相關職位的中階前端工程師。系統每日自動執行，產生結構化的學習內容並透過多管道分發。

**目標**：
- 每日產生一篇高品質的技術學習筆記
- 自動分類、索引並推送到 GitHub
- 透過 Discord 和 Email 通知使用者

## Tech Stack

- **Shell Script (Bash)** - 主要自動化腳本
- **Claude Code CLI** - AI 內容產生引擎
- **Git** - 版本控制與自動推送
- **launchd (macOS)** - 排程任務執行
- **Markdown** - 筆記格式
- **curl** - HTTP 請求（Discord webhook、Email）

## Project Conventions

### Code Style

- Shell 腳本使用 `set -e` 確保錯誤時中斷
- 變數名稱使用大寫加底線（如 `NOTES_DIR`、`PROMPT_FILE`）
- 中文註解說明重要步驟
- 路徑使用變數而非硬編碼

### File Naming

- 學習筆記檔名格式：`DD-主題關鍵字.md`（如 `13-typescript-泛型generics.md`）
- 按年月分類存放：`learning-notes/YYYY/MM/`

### Architecture Patterns

自動化 Pipeline 架構：

```
launchd 排程觸發
    ↓
daily-learning.sh 執行
    ↓
Claude Code CLI 產生內容
    ↓
儲存 Markdown 檔案
    ↓
更新 README 索引（自動分類）
    ↓
Git commit & push
    ↓
Discord / Email 通知
```

### Testing Strategy

目前無自動化測試。手動驗證流程：
- 執行 `./scripts/daily-learning.sh` 檢查產出
- 檢查 `learning-notes/README.md` 索引更新是否正確
- 查看 `/tmp/daily-learning.log` 確認執行紀錄

### Git Workflow

- **主分支**：`main`
- **Commit 格式**：`feat: 新增 YYYY/MM/DD 學習筆記 - 主題關鍵字`
- 自動化腳本執行 `git add . && git commit && git push`
- 不使用 PR 流程，直接推送到 main

## Domain Context

**目標讀者設定**：
- 原本使用 Vue 的中階前端工程師
- 準備轉職 React 相關職位
- React 主題會包含「Vue vs React 對比」章節
- 非 React 主題省略對比章節

**學習主題權重**：

| 類別 | 權重 | 內容方向 |
|------|------|----------|
| React | 40% | Hooks、狀態管理、Next.js、生態系 |
| TypeScript | 20% | 進階型別、泛型、實戰技巧 |
| 前端架構 | 20% | 設計模式、效能優化、測試策略 |
| 跨領域 | 20% | CI/CD、後端基礎、系統設計、AI 工具 |

**筆記標準結構**：
1. 標題與一句話摘要
2. 為什麼要學這個？
3. 核心概念
4. Vue vs React 對比（僅限 React 主題）
5. 實作範例（2-3 個）
6. 常見錯誤與最佳實踐
7. 面試考點
8. 延伸學習

## Important Constraints

- **執行環境**：僅支援 macOS（使用 launchd 排程）
- **網路需求**：需要網路連線才能使用 Claude Code CLI
- **硬體需求**：Mac mini 需保持開機才會執行排程
- **環境變數**：敏感資訊存放於 `~/.daily-learning-env`（不納入版控）
- **launchd 設定**：`.plist` 檔案需手動複製並修改路徑後才能使用

## External Dependencies

| 服務 | 用途 | 設定方式 |
|------|------|----------|
| **GitHub** | 筆記儲存與版控 | SSH key 認證 |
| **Claude Code CLI** | AI 內容產生 | 需安裝並登入 |
| **Discord Webhook** | 通知推送 | `DISCORD_WEBHOOK_URL` 環境變數 |
| **Gmail SMTP** | Email 通知（待實作） | `GMAIL_USER`、`GMAIL_APP_PASSWORD` |
