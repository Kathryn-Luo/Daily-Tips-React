# email-notification Specification

## Purpose
TBD - created by archiving change add-email-notification. Update Purpose after archive.
## Requirements
### Requirement: Email 通知發送

系統 SHALL 在學習筆記產生並推送到 GitHub 後，透過 Email 發送通知給使用者。

#### Scenario: 成功發送 Email 通知

- **WHEN** 學習筆記已成功產生且 `GMAIL_USER`、`GMAIL_APP_PASSWORD`、`EMAIL_TO` 環境變數皆已設定
- **THEN** 系統透過 Gmail SMTP 發送郵件至 `EMAIL_TO` 指定的收件人
- **AND** 郵件主題包含當日學習筆記標題
- **AND** 郵件內文包含筆記摘要與 GitHub 連結
- **AND** 發送成功後記錄 log

#### Scenario: 環境變數未設定時跳過發送

- **WHEN** `GMAIL_USER` 或 `GMAIL_APP_PASSWORD` 或 `EMAIL_TO` 任一環境變數未設定
- **THEN** 系統跳過 Email 發送步驟
- **AND** 不產生錯誤，腳本繼續執行

#### Scenario: Email 發送失敗時的錯誤處理

- **WHEN** Email 發送過程中發生錯誤（網路問題、認證失敗等）
- **THEN** 系統記錄錯誤訊息至 log
- **AND** 腳本繼續執行後續步驟（不因 Email 失敗而中斷）

### Requirement: Email 內容格式

系統 SHALL 發送結構化的郵件內容，方便使用者快速了解當日學習主題。

#### Scenario: 郵件內容結構

- **WHEN** 系統組裝 Email 內容
- **THEN** 郵件主題格式為：`[Daily Learning] {筆記標題}`
- **AND** 郵件內文包含：
  - 學習主題標題
  - 一句話摘要
  - GitHub 筆記連結
  - 發送日期

