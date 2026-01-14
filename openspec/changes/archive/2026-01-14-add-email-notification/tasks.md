# Tasks: 新增 Email 通知功能

## 1. 環境變數設定

- [x] 1.1 更新 `scripts/.env.example`，新增 `EMAIL_TO` 變數說明
- [x] 1.2 更新 `CLAUDE.md` 文件，說明 Email 相關環境變數

## 2. Email 發送實作

- [x] 2.1 在 `daily-learning.sh` 實作 `send_email()` 函數
- [x] 2.2 使用 `curl` 透過 Gmail SMTP 發送郵件
- [x] 2.3 組裝郵件內容（HTML 或純文字格式）
- [x] 2.4 新增錯誤處理，發送失敗時記錄 log

## 3. 測試驗證

- [x] 3.1 手動執行腳本測試 Email 發送
- [x] 3.2 確認郵件內容格式正確
- [x] 3.3 測試環境變數未設定時的 graceful fallback
