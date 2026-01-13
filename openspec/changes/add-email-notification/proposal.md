# Change: 新增學習筆記 Email 通知功能

## Why

目前 `daily-learning.sh` 腳本中 Email 通知功能尚未實作（顯示「Email 通知功能待實作」），使用者無法透過 Email 收到每日學習筆記摘要。新增此功能可讓使用者在 Discord 以外多一個接收管道，確保不會錯過每日學習內容。

## What Changes

- 實作 Gmail SMTP 發送功能，使用 `curl` 透過 Gmail API 發送郵件
- 郵件內容包含：
  - 主題：今日學習筆記標題
  - 內文：筆記摘要 + GitHub 連結
- 支援設定收件人 Email 地址
- 錯誤處理：發送失敗時記錄 log，不影響整體腳本執行

## Impact

- Affected specs: `email-notification`（新增）
- Affected code: `scripts/daily-learning.sh`
- 需要新增環境變數：`EMAIL_TO`（收件人地址）
