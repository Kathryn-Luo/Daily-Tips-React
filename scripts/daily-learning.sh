#!/bin/bash

# 每日學習內容產生腳本
# 使用 Claude Code 產生學習筆記並推送到 GitHub

set -e

# === 設定 PATH（launchd 環境需要）===
export PATH="/Users/yk-luo/.nvm/versions/node/v22.16.0/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

# === 設定 ===
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
NOTES_DIR="$REPO_DIR/learning-notes"
PROMPT_FILE="$SCRIPT_DIR/prompts/learning-prompt.txt"
ENV_FILE="$REPO_DIR/.env"

# 載入環境變數
if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
else
    echo "錯誤：找不到環境變數檔案 $ENV_FILE"
    exit 1
fi

# === 日期與路徑 ===
YEAR=$(date +%Y)
MONTH=$(date +%m)
DAY=$(date +%d)
DATE_DIR="$NOTES_DIR/$YEAR/$MONTH"

# 確保目錄存在
mkdir -p "$DATE_DIR"

# === 產生學習內容 ===
echo "$(date): 開始產生學習內容..."

# 讀取 prompt 模板
PROMPT=$(cat "$PROMPT_FILE")

# 使用 Claude Code 產生內容
CONTENT=$(claude -p "$PROMPT" --output-format text --tools "")

# 從內容中提取標題（第一行的 # 標題）
TITLE=$(echo "$CONTENT" | grep -m1 "^# " | sed 's/^# //' | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')

# 如果無法提取標題，使用預設名稱
if [ -z "$TITLE" ]; then
    TITLE="daily-note"
fi

# 檔案名稱
FILENAME="$DAY-$TITLE.md"
FILEPATH="$DATE_DIR/$FILENAME"

# 寫入檔案
echo "$CONTENT" > "$FILEPATH"
echo "$(date): 筆記已儲存至 $FILEPATH"

# === 更新 README 索引 ===
README_FILE="$NOTES_DIR/README.md"
DISPLAY_TITLE=$(echo "$CONTENT" | grep -m1 "^# " | sed 's/^# //')
NOTE_DATE="$YEAR-$MONTH-$DAY"
NOTE_LINK="$YEAR/$MONTH/$FILENAME"
NEW_ENTRY="- [$NOTE_DATE] [$DISPLAY_TITLE]($NOTE_LINK)"

# 判斷分類
CATEGORY=""
if echo "$DISPLAY_TITLE" | grep -Eiq "react|hook|next\.js|usestate|useeffect|usetransition|usememo|usecallback|suspense|concurrent"; then
    CATEGORY="React"
elif echo "$DISPLAY_TITLE" | grep -Eiq "typescript|型別|泛型|type|interface"; then
    CATEGORY="TypeScript"
elif echo "$DISPLAY_TITLE" | grep -Eiq "設計模式|效能|測試|架構|pattern|performance|testing"; then
    CATEGORY="前端架構"
else
    CATEGORY="跨領域"
fi

# 在對應分類下插入新筆記
# 使用 awk 處理，避免 sed 對特殊字元的問題
if grep -q "## $CATEGORY" "$README_FILE"; then
    awk -v category="## $CATEGORY" -v entry="$NEW_ENTRY" '
    $0 == category {
        print
        getline  # 讀取空行
        print    # 印出空行
        getline  # 讀取下一行（可能是「尚無筆記」或已有的筆記）
        if ($0 ~ /^\*尚無筆記\*$/) {
            print entry  # 替換「尚無筆記」
        } else {
            print entry  # 插入新筆記
            print        # 印出原本的筆記
        }
        next
    }
    { print }
    ' "$README_FILE" > "$README_FILE.tmp" && mv "$README_FILE.tmp" "$README_FILE"
fi

echo "$(date): README 索引已更新 - 分類: $CATEGORY"

# === Git 推送 ===
cd "$REPO_DIR"
git add .
git commit -m "feat: 新增 $YEAR/$MONTH/$DAY 學習筆記 - $TITLE"
git push

echo "$(date): Git 推送完成"

# === 函數定義 ===
send_email() {
    local subject="$1"
    local body="$2"

    # 檢查必要環境變數
    if [ -z "$GMAIL_USER" ] || [ -z "$GMAIL_APP_PASSWORD" ] || [ -z "$EMAIL_TO" ]; then
        echo "$(date): Email 環境變數未設定，跳過發送"
        return 0
    fi

    # 組裝郵件內容
    local email_content="From: $GMAIL_USER
To: $EMAIL_TO
Subject: $subject
Content-Type: text/html; charset=UTF-8

$body"

    # 使用 curl 透過 Gmail SMTP 發送
    if echo "$email_content" | curl --ssl-reqd \
        --url 'smtps://smtp.gmail.com:465' \
        --user "$GMAIL_USER:$GMAIL_APP_PASSWORD" \
        --mail-from "$GMAIL_USER" \
        --mail-rcpt "$EMAIL_TO" \
        --upload-file - 2>&1; then
        echo "$(date): Email 發送成功"
        return 0
    else
        echo "$(date): Email 發送失敗" >&2
        return 1
    fi
}

# === 發送 Discord 通知 ===
if [ -n "$DISCORD_WEBHOOK_URL" ]; then
    SUMMARY=$(echo "$CONTENT" | grep -A1 "^>" | head -2 | tail -1)

    curl -H "Content-Type: application/json" \
         -d "{\"content\": \"📚 **今日學習筆記**\n\n**主題**: $TITLE\n**摘要**: $SUMMARY\n\n🔗 查看完整筆記：$GITHUB_REPO_URL/blob/main/learning-notes/$YEAR/$MONTH/$FILENAME\"}" \
         "$DISCORD_WEBHOOK_URL"

    echo "$(date): Discord 通知已發送"
fi

# === 發送 Email 通知 ===
if [ -n "$GMAIL_USER" ] && [ -n "$GMAIL_APP_PASSWORD" ] && [ -n "$EMAIL_TO" ]; then
    SUMMARY=$(echo "$CONTENT" | grep -A1 "^>" | head -2 | tail -1)

    # 組裝 HTML 郵件內容
    EMAIL_SUBJECT="[Daily Learning] $DISPLAY_TITLE"
    EMAIL_BODY="<html>
<body>
<h2>📚 每日學習筆記</h2>
<p><strong>日期：</strong>$YEAR-$MONTH-$DAY</p>
<p><strong>主題：</strong>$DISPLAY_TITLE</p>
<p><strong>摘要：</strong>$SUMMARY</p>
<hr>
<p>🔗 <a href=\"$GITHUB_REPO_URL/blob/main/learning-notes/$YEAR/$MONTH/$FILENAME\">查看完整筆記</a></p>
</body>
</html>"

    # 調用 send_email 函數
    if send_email "$EMAIL_SUBJECT" "$EMAIL_BODY"; then
        echo "$(date): Email 通知已發送至 $EMAIL_TO"
    else
        echo "$(date): Email 通知發送失敗，但不影響後續流程"
    fi
else
    echo "$(date): Email 環境變數未完整設定，跳過 Email 通知"
fi

echo "$(date): 每日學習任務完成！"
