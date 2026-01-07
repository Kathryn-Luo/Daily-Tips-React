# 專案開發紀錄

## 2026-01-07：專案初始化

### 已完成事項

- [x] 初始化 Git repository
- [x] 建立資料夾結構
  - `learning-notes/` - 學習筆記存放處
  - `scripts/` - 執行腳本
  - `docs/` - 需求文件
- [x] 建立 `.gitignore`
- [x] 建立 `README.md` 專案說明
- [x] 建立 `learning-notes/README.md` 筆記索引
- [x] 建立 AI prompt 模板 (`scripts/prompts/learning-prompt.txt`)
  - 目標讀者：Vue 轉 React 的中階前端工程師
  - React 主題包含 Vue vs React 對比章節
- [x] 建立主執行腳本 (`scripts/daily-learning.sh`)
- [x] 建立 launchd plist 設定檔（每日 11:00 執行）
- [x] 建立環境變數範例檔 (`scripts/.env.example`)
- [x] 建立 `CLAUDE.md` 專案文件

### 待辦事項

#### 環境設定（需手動完成）

- [x] 建立環境變數檔案 `~/.daily-learning-env`
  ```bash
  cp .env ~/.daily-learning-env
  # 編輯填入實際值
  ```
- [x] 設定 Gmail 應用程式密碼
- [x] 建立 Discord Webhook
- [x] 建立 GitHub Repository 並設定 remote
- [x] 推送程式碼到 GitHub

#### 啟用排程

- [x] 安裝 plist 到 LaunchAgents
  ```bash
  cp scripts/com.kathryn.daily-learning.plist ~/Library/LaunchAgents/
  launchctl load ~/Library/LaunchAgents/com.kathryn.daily-learning.plist
  ```
- [ ] 設定 Mac mini 永不休眠

#### 測試驗證

- [x] 手動執行 `./scripts/daily-learning.sh` 測試
- [x] 確認筆記正確產生並 push 到 GitHub
- [x] 確認 Discord 通知正常發送
- [ ] 確認 Email 通知正常發送

#### 功能優化（未來）

- [x] 實作自動更新 `learning-notes/README.md` 索引
- [ ] 實作 Email 通知功能（目前為 placeholder）
- [ ] 新增錯誤重試機制
- [ ] 新增主題輪替邏輯（避免重複）

---

## Commits 紀錄

1. `chore: 初始化專案結構` - 建立基本資料夾與 README
2. `fix: 修正年份資料夾 2025 → 2026`
3. `feat: 新增執行腳本與設定檔` - 新增 shell script、plist、prompt 模板
