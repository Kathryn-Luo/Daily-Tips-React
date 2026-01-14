# Capability: notification-content-extraction

## Overview

從學習筆記內容中提取標題和摘要，用於 Discord 和 Email 通知。

## ADDED Requirements

### Requirement: 正確提取顯示標題

系統 MUST 從產生的 Markdown 內容中提取完整的顯示標題（DISPLAY_TITLE），用於通知訊息。

#### Scenario: Discord 通知使用完整標題

**Given** 學習筆記內容包含第一行標題 `# TypeScript 泛型（Generics）- 寫出靈活又型別安全的程式碼`
**When** 產生 Discord 通知訊息
**Then** 訊息中的主題應顯示為 `TypeScript 泛型（Generics）- 寫出靈活又型別安全的程式碼`
**And** 不應顯示檔名格式（如 `typescript-泛型generics--寫出靈活又型別安全的程式碼`）

---

### Requirement: 正確提取筆記摘要

系統 MUST 從產生的 Markdown 內容中提取 blockquote 格式的一句話摘要。

#### Scenario: 提取 blockquote 內容作為摘要

**Given** 學習筆記內容包含以下格式：
```markdown
# 標題

> 這是一句話摘要

## 為什麼要學這個？
```
**When** 提取摘要內容
**Then** 應提取到 `這是一句話摘要`（移除 `> ` 前綴）
**And** 不應提取到空白內容或後續章節標題

#### Scenario: Discord 通知包含摘要

**Given** 學習筆記包含摘要 `> 泛型讓你的函式和元件能夠處理多種型別，同時保持完整的型別檢查。`
**When** 產生 Discord 通知訊息
**Then** 訊息中的摘要應顯示為 `泛型讓你的函式和元件能夠處理多種型別，同時保持完整的型別檢查。`
**And** 摘要欄位不應為空白

#### Scenario: Email 通知包含摘要

**Given** 學習筆記包含摘要 `> 泛型讓你的函式和元件能夠處理多種型別，同時保持完整的型別檢查。`
**When** 產生 Email 通知
**Then** Email 內容中的摘要應顯示為 `泛型讓你的函式和元件能夠處理多種型別，同時保持完整的型別檢查。`
**And** 摘要欄位不應為空白

---

### Requirement: 摘要提取使用正確的 shell 命令

實作時 MUST 使用正確的命令組合來提取 blockquote 內容。

#### Scenario: 使用 grep 和 sed 提取摘要

**Given** 需要提取學習筆記的摘要
**When** 使用 shell 命令提取
**Then** 應使用 `grep "^>" | sed 's/^> //' | head -1` 提取第一個 blockquote 內容
**And** 不應使用 `grep -A1 "^>" | head -2 | tail -1`（會取得空行）
