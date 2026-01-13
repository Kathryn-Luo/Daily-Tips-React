<!-- OPENSPEC:START -->
# OpenSpec Instructions

These instructions are for AI assistants working in this project.

Always open `@/openspec/AGENTS.md` when the request:
- Mentions planning or proposals (words like proposal, spec, change, plan)
- Introduces new capabilities, breaking changes, architecture shifts, or big performance/security work
- Sounds ambiguous and you need the authoritative spec before coding

Use `@/openspec/AGENTS.md` to learn:
- How to create and apply change proposals
- Spec format and conventions
- Project structure and guidelines

Keep this managed block so 'openspec update' can refresh the instructions.

<!-- OPENSPEC:END -->

# Daily-Tips-React - 每日 AI 學習內容產生系統

## 專案概述

使用 Claude Code 自動產生每日學習筆記，幫助從 Vue 轉職到 React 相關職位。

## 專案結構

```
.
├── CLAUDE.md                 # Claude Code 專案文件（本檔案）
├── README.md                 # 專案說明
├── docs/                     # 需求文件
├── learning-notes/           # 學習筆記存放處
│   ├── README.md             # 筆記索引（自動產生）
│   └── {YYYY}/{MM}/          # 按年月分類
└── scripts/
    ├── daily-learning.sh     # 主執行腳本
    ├── com.kathryn.daily-learning.plist.example  # launchd 排程範例（需複製並修改路徑）
    ├── .env.example          # 環境變數範例
    └── prompts/
        └── learning-prompt.txt  # AI prompt 模板
```

## 常用指令

```bash
# 手動執行產生學習筆記
./scripts/daily-learning.sh

# 載入 launchd 排程（每日 11:00 執行）
launchctl load ~/Library/LaunchAgents/com.kathryn.daily-learning.plist

# 卸載 launchd 排程
launchctl unload ~/Library/LaunchAgents/com.kathryn.daily-learning.plist

# 手動觸發排程任務
launchctl start com.kathryn.daily-learning

# 查看執行日誌
cat /tmp/daily-learning.log
cat /tmp/daily-learning-error.log
```

## 學習主題權重

| 類別 | 權重 | 內容方向 |
|------|------|----------|
| React | 40% | Hooks、狀態管理、Next.js |
| TypeScript | 20% | 進階型別、泛型 |
| 前端架構 | 20% | 設計模式、效能優化、測試 |
| 跨領域 | 20% | CI/CD、後端基礎、系統設計 |

## 目標讀者設定

原本使用 Vue 的中階前端工程師，準備轉職 React 相關職位。
- React 主題會包含 Vue vs React 對比章節
- 非 React 主題則省略對比

## 輸出管道

1. **GitHub** - 自動 commit & push 到本 repo
2. **Discord** - Webhook 通知（需設定 `DISCORD_WEBHOOK_URL`）
3. **Email** - Gmail SMTP（需設定 `GMAIL_USER` 和 `GMAIL_APP_PASSWORD`）

## 環境變數

環境變數檔案位於專案根目錄的 `.env`，參考 `scripts/.env.example`。

必要變數：
- `GMAIL_USER` - Gmail 帳號（用於發送郵件）
- `GMAIL_APP_PASSWORD` - Gmail 應用程式密碼
- `EMAIL_TO` - 收件人 Email 地址
- `DISCORD_WEBHOOK_URL` - Discord Webhook URL（選填）
- `GITHUB_REPO_URL` - GitHub Repository URL

## 注意事項

- Mac mini 需保持開機，launchd 才會執行排程
- 筆記檔名格式：`DD-主題關鍵字.md`
- learning-notes/README.md 索引需手動或自動更新
- `com.kathryn.daily-learning.plist.example` 是範例檔，使用前需：
  1. 複製為 `com.kathryn.daily-learning.plist`
  2. 修改 `ProgramArguments` 中的路徑為實際路徑
  3. 實際的 plist 檔案已加入 `.gitignore`，不會被追蹤
