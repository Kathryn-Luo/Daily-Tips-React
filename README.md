# Daily-Tips-React

每日 AI 學習內容自動產生系統

## 專案說明

使用 Claude Code 自動產生每日學習內容，幫助準備轉職與技能提升。

## 學習主題

| 類別 | 內容方向 | 權重 |
|------|----------|------|
| React | Hooks、狀態管理、Next.js、生態系 | 40% |
| TypeScript | 進階型別、泛型、實戰技巧 | 20% |
| 前端架構 | 設計模式、效能優化、測試策略 | 20% |
| 跨領域 | CI/CD、後端基礎、系統設計、AI 工具 | 20% |

## 專案結構

```
.
├── README.md
├── learning-notes/          # 學習筆記
│   ├── README.md            # 筆記索引（自動產生）
│   └── 2026/
│       └── 01/
├── scripts/                 # 執行腳本
│   ├── daily-learning.sh
│   ├── com.kathryn.daily-learning.plist.example  # launchd 排程範例
│   └── prompts/
│       └── learning-prompt.txt
└── docs/                    # 需求文件
    ├── daily-learning-system-requirements.md
    └── daily-learning-system-claude-code.md
```

## 首次設定

1. 複製 launchd 設定範例檔：
   ```bash
   cp scripts/com.kathryn.daily-learning.plist.example scripts/com.kathryn.daily-learning.plist
   ```

2. 編輯 `scripts/com.kathryn.daily-learning.plist`，修改 `ProgramArguments` 中的路徑為你的實際路徑

3. 將設定檔複製到 LaunchAgents：
   ```bash
   cp scripts/com.kathryn.daily-learning.plist ~/Library/LaunchAgents/
   launchctl load ~/Library/LaunchAgents/com.kathryn.daily-learning.plist
   ```

## 執行方式

每日台灣時間早上 11:00 由 launchd 自動執行。

手動執行：
```bash
./scripts/daily-learning.sh
```

## 輸出管道

1. **GitHub** - 自動 commit & push 筆記
2. **Email** - 寄送當日學習摘要
3. **Discord** - Webhook 通知

## 相關文件

- [需求規格 (GitHub Actions 方案)](./docs/daily-learning-system-requirements.md)
- [需求規格 (Claude Code 方案)](./docs/daily-learning-system-claude-code.md)
