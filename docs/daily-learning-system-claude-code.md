# 每日 AI 學習內容產生系統（Claude Code 方案）

## 專案目標

建立一個自動化系統，每日使用 Claude Code 在本地 Mac mini 產生學習內容，無需支付 API 費用。

---

## 系統架構

```
launchd (每日定時觸發)
    ↓
Shell Script
    ↓
Claude Code (claude -p "prompt")
    ↓
┌─────────────┬─────────────┬─────────────┐
│  存成 MD    │  發送 Email │  Discord    │
│  push repo  │  (Gmail)    │  Webhook    │
└─────────────┴─────────────┴─────────────┘
```

---

## 技術選型

| 項目 | 選擇 | 原因 |
|------|------|------|
| 定時執行 | macOS launchd | 系統內建，穩定可靠 |
| AI | Claude Code | 使用 Claude 訂閱額度，內容品質較佳 |
| Email | Gmail SMTP | 現有資源 |
| 通知 | Discord Webhook | 免費、易整合 |

---

## 與 GitHub Actions 方案比較

| 項目 | GitHub Actions + Gemini | Mac mini + Claude Code |
|------|-------------------------|------------------------|
| 費用 | 免費 | 免費（使用訂閱額度） |
| 內容品質 | 一般 | 較佳 |
| 需保持開機 | ❌ 不需要 | ✅ 需要 |
| 依賴網路 | GitHub 執行環境 | 本地執行 |
| 設定複雜度 | 中等 | 較低 |

---

## 學習主題規劃

### 目標

- 準備轉職（目標：React 相關職位）
- 補足前端工程師技能缺口
- 跨領域學習（因應 AI 時代）

### 主題分配

| 類別 | 內容方向 | 權重 |
|------|----------|------|
| React | Hooks、狀態管理、Next.js、生態系 | 40% |
| TypeScript | 進階型別、泛型、實戰技巧 | 20% |
| 前端架構 | 設計模式、效能優化、測試策略 | 20% |
| 跨領域 | CI/CD、後端基礎、系統設計、AI 工具 | 20% |

---

## 筆記結構設計

### 資料夾結構

```
learning-notes/
├── README.md              ← 自動產生的索引，按主題分類
├── 2025/
│   └── 01/
│       ├── 07-react-hooks-deep-dive.md
│       ├── 08-typescript-utility-types.md
│       └── 09-frontend-testing-strategies.md
```

### 命名規則

- 格式：`DD-主題關鍵字.md`
- 範例：`07-react-hooks-deep-dive.md`

### README.md 索引格式

自動維護按主題分類的索引，方便查找：

```markdown
## 📚 學習筆記索引

### React
- [React Hooks 深入理解](./2025/01/07-react-hooks-deep-dive.md)

### TypeScript
- [TypeScript Utility Types 實戰](./2025/01/08-typescript-utility-types.md)

### 軟體工程
- [前端測試策略](./2025/01/09-frontend-testing-strategies.md)
```

---

## Claude Code 使用方式

### 非互動模式

```bash
# 基本用法
claude -p "你的 prompt" --output-format text

# 範例：產生學習內容
claude -p "請產生一篇關於 React Hooks 的學習筆記，包含概念說明與程式碼範例" --output-format text
```

### 前置條件

1. 已安裝 Claude Code
2. 已執行 `claude` 並完成登入認證
3. 確認 Claude 訂閱有效

---

## launchd 設定

### plist 檔案位置

```
~/Library/LaunchAgents/com.kathryn.daily-learning.plist
```

### 執行時間

- 每日台灣時間早上 8:00
- launchd 使用本地時區，直接設定 Hour = 8 即可

### 載入/卸載指令

```bash
# 載入（啟用）
launchctl load ~/Library/LaunchAgents/com.kathryn.daily-learning.plist

# 卸載（停用）
launchctl unload ~/Library/LaunchAgents/com.kathryn.daily-learning.plist

# 手動執行測試
launchctl start com.kathryn.daily-learning
```

---

## 輸出管道

### 1. GitHub Repository

- 執行 `git add` + `git commit` + `git push`
- 自動更新 README.md 索引

### 2. Email 通知

- 使用 `curl` 或 Node.js 呼叫 Gmail SMTP
- 每日寄送當日學習主題摘要

### 3. Discord 通知

- 使用 `curl` 呼叫 Discord Webhook
- 推送當日學習內容連結與摘要

---

## 需要準備的環境變數

建議存放於 `~/.daily-learning-env`：

```bash
export GMAIL_USER="your-email@gmail.com"
export GMAIL_APP_PASSWORD="your-app-password"
export DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/..."
export LEARNING_REPO_PATH="/path/to/learning-notes"
```

---

## 注意事項

### Mac mini 必須保持開機

- 休眠或關機時 launchd 不會執行
- 建議設定「永不休眠」：
  - 系統設定 → 電池 → 選項 → 防止自動進入睡眠

### 錯過的任務

- 如果排程時間 Mac 未開機，launchd 不會補執行
- 可考慮加上 `StartInterval` 作為備案

### Claude 訂閱額度

- 留意每日使用量，避免超出限制
- 學習內容產生通常不會消耗太多額度

### 日誌查看

```bash
# 查看執行日誌
cat /tmp/daily-learning.log
cat /tmp/daily-learning-error.log
```

---

## 待辦事項

- [ ] 確認 Mac mini 已安裝 Claude Code
- [ ] 執行 `claude` 確認已登入
- [ ] 建立學習筆記 GitHub Repository
- [ ] 設定 Gmail 應用程式密碼
- [ ] 建立 Discord Webhook
- [ ] 建立環境變數檔案 `~/.daily-learning-env`
- [ ] 撰寫執行 Shell Script
- [ ] 建立 launchd plist 檔案
- [ ] 設定 Mac mini 永不休眠
- [ ] 測試完整流程

---

## 檔案清單（待建立）

| 檔案 | 說明 |
|------|------|
| `~/Library/LaunchAgents/com.kathryn.daily-learning.plist` | launchd 設定檔 |
| `~/scripts/daily-learning.sh` | 主執行 script |
| `~/.daily-learning-env` | 環境變數 |
| `~/scripts/prompts/learning-prompt.txt` | AI prompt 模板 |

---

## 備註

- 此方案的優勢是 Claude 的內容品質較佳，且使用現有訂閱
- 缺點是依賴 Mac mini 保持開機
- 可與 GitHub Actions 方案互補：平日用 Claude Code，假日或外出時用 GitHub Actions + Gemini
