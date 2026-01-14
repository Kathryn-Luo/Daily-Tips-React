# Change: 修正通知內容提取錯誤

## Why

目前 `daily-learning.sh` 腳本中的 Email 和 Discord 通知功能存在內容提取錯誤：

1. **Discord 通知主題錯誤**：使用檔名格式的 `$TITLE`（如 `typescript-泛型generics--寫出靈活又型別安全的程式碼`）而非顯示用的 `$DISPLAY_TITLE`（如 `TypeScript 泛型（Generics）- 寫出靈活又型別安全的程式碼`）
2. **摘要提取失敗**：Discord 和 Email 的摘要（SUMMARY）皆為空白，因為提取邏輯錯誤
   - 當前邏輯：`grep -A1 "^>" | head -2 | tail -1` 會取得 blockquote **之後的空行**而非 blockquote 內容
   - 正確邏輯應該直接提取 blockquote 內容並移除 `> ` 前綴

這導致使用者收到的通知內容不完整，影響使用體驗。

## What Changes

**修正 `scripts/daily-learning.sh` 中的兩處錯誤：**

1. **Discord 通知（第 149 行）**：
   - 將 `$TITLE` 改為 `$DISPLAY_TITLE`

2. **摘要提取邏輯（第 146、157 行）**：
   - 從 `grep -A1 "^>" | head -2 | tail -1`
   - 改為 `grep "^>" | sed 's/^> //' | head -1`
   - 直接提取第一個 blockquote 內容並移除 `> ` 前綴

**不需修改環境變數或外部依賴。**

## Impact

- Affected specs: `notification-content-extraction`（新增）
- Affected code: `scripts/daily-learning.sh` (lines 146, 149, 157)
- Breaking changes: 無
- Risk level: 低（僅修正現有 bug，不改變行為邏輯）
