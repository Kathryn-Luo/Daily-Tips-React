# 每日 AI 學習內容產生系統

## 專案目標

建立一個自動化系統，每日使用 AI 產生學習內容，幫助轉職準備與技能提升。

---

## 系統架構

```
GitHub Actions (每日定時觸發)
    ↓
呼叫 Gemini API 產生學習內容
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
| 定時執行 | GitHub Actions | 個人帳號免費 2,000 分鐘/月，足夠每日執行 |
| AI API | Google Gemini API | 免費額度（15 次/分鐘） |
| Email | Gmail SMTP | 現有資源 |
| 通知 | Discord Webhook | 免費、易整合 |

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

## 輸出管道

### 1. GitHub Repository

- 每日自動 commit & push 新筆記
- 自動更新 README.md 索引

### 2. Email 通知

- 使用 Gmail SMTP
- 每日寄送當日學習主題摘要

### 3. Discord 通知

- 使用 Discord Webhook
- 推送當日學習內容連結與摘要

---

## 執行時間

- 每日台灣時間早上 8:00（UTC+8）
- GitHub Actions cron：`0 0 * * *`（UTC 00:00 = 台灣 08:00）

---

## 需要準備的 Secrets

在 GitHub Repository Settings → Secrets 中設定：

| Secret 名稱 | 說明 |
|-------------|------|
| `GEMINI_API_KEY` | Google Gemini API 金鑰 |
| `GMAIL_USER` | Gmail 帳號 |
| `GMAIL_APP_PASSWORD` | Gmail 應用程式密碼（非帳號密碼） |
| `DISCORD_WEBHOOK_URL` | Discord Webhook URL |

---

## 待辦事項

- [ ] 建立 GitHub Repository
- [ ] 取得 Gemini API Key
- [ ] 設定 Gmail 應用程式密碼
- [ ] 建立 Discord Webhook
- [ ] 撰寫 GitHub Actions workflow
- [ ] 撰寫 AI prompt 模板
- [ ] 撰寫 Node.js 執行 script
- [ ] 測試完整流程

---

## 備註

- Claude API 目前無免費額度，暫不採用
- 未來若預算允許，可考慮切換至 Claude API 以獲得更好的內容品質
