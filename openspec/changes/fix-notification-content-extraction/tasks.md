# Implementation Tasks

## Tasks

- [x] 修正 Discord 通知主題提取
  - 修改 `scripts/daily-learning.sh` 第 149 行
  - 將 `$TITLE` 改為 `$DISPLAY_TITLE`

- [x] 修正摘要提取邏輯（Discord）
  - 修改 `scripts/daily-learning.sh` 第 146 行
  - 將 `SUMMARY=$(echo "$CONTENT" | grep -A1 "^>" | head -2 | tail -1)`
  - 改為 `SUMMARY=$(echo "$CONTENT" | grep "^>" | sed 's/^> //' | head -1)`

- [x] 修正摘要提取邏輯（Email）
  - 修改 `scripts/daily-learning.sh` 第 157 行
  - 將 `SUMMARY=$(echo "$CONTENT" | grep -A1 "^>" | head -2 | tail -1)`
  - 改為 `SUMMARY=$(echo "$CONTENT" | grep "^>" | sed 's/^> //' | head -1)`

- [x] 手動測試修正後的腳本
  - 執行 `./scripts/daily-learning.sh`
  - 驗證產生的 Email 和 Discord 通知內容正確：
    - 主題顯示為完整標題（非檔名格式）
    - 摘要顯示為 blockquote 內容（非空白）

## Validation

- 執行腳本後檢查通知內容
- 確認 Discord 訊息中主題和摘要都正確顯示
- 確認 Email 內容中主題和摘要都正確顯示

## Dependencies

無外部依賴
