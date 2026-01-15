# React 19 Server Actions 完全指南

> Server Actions 讓你直接在 React 元件中呼叫伺服器端函式，無需手動建立 API 端點。

## 為什麼要學這個？

Server Actions 是 React 19 引入的革命性功能，它徹底改變了前後端資料互動的方式。在傳統開發中，你需要建立 API 路由、處理 fetch 請求、管理載入狀態等繁瑣工作。Server Actions 將這些全部簡化為一個函式呼叫。

應用場景包括：
- 表單提交（註冊、登入、留言）
- 資料庫 CRUD 操作
- 檔案上傳處理
- 第三方 API 整合（需要隱藏 API Key）

## 核心概念

Server Actions 是標記了 `'use server'` 的非同步函式，它們：

1. **只在伺服器端執行**：程式碼不會打包到客戶端 bundle
2. **自動處理序列化**：參數和回傳值自動 JSON 序列化
3. **可直接操作資料庫**：無需額外的 API 層
4. **內建 Progressive Enhancement**：即使 JavaScript 停用也能運作

可以把 Server Actions 想像成「魔法傳送門」——你在前端呼叫函式，但函式實際在後端執行，結果自動傳回前端。

## Vue vs React 對比

| 特性 | Vue (Nuxt 3) | React 19 |
|------|--------------|----------|
| 伺服器函式 | `server/api/*.ts` 路由 | `'use server'` 標記函式 |
| 呼叫方式 | `useFetch('/api/...')` | 直接函式呼叫 |
| 表單處理 | 手動綁定 + fetch | `action` 屬性直接綁定 |
| 型別推導 | 需要額外設定 | 自動推導參數與回傳型別 |

**Vue/Nuxt 做法：**
```typescript
// server/api/users.post.ts
export default defineEventHandler(async (event) => {
  const body = await readBody(event)
  return await db.user.create({ data: body })
})

// 元件中
const { data } = await useFetch('/api/users', {
  method: 'POST',
  body: { name: 'John' }
})
```

**React 19 做法：**
```typescript
// 同一個檔案或獨立 actions.ts
'use server'
export async function createUser(name: string) {
  return await db.user.create({ data: { name } })
}

// 元件中直接呼叫
const user = await createUser('John')
```

## 實作範例

### 範例一：基礎表單提交

```typescript
// app/actions.ts
'use server'

export async function submitContact(formData: FormData) {
  const email = formData.get('email') as string
  const message = formData.get('message') as string
  
  // 直接操作資料庫，這段程式碼只在伺服器執行
  await db.contact.create({
    data: { email, message, createdAt: new Date() }
  })
  
  // 重新驗證快取，讓頁面顯示最新資料
  revalidatePath('/contacts')
  
  return { success: true }
}
```

```tsx
// app/contact/page.tsx
import { submitContact } from '../actions'

export default function ContactPage() {
  return (
    // action 屬性直接綁定 Server Action
    <form action={submitContact}>
      <input name="email" type="email" required />
      <textarea name="message" required />
      <button type="submit">送出</button>
    </form>
  )
}
```

### 範例二：搭配 useActionState 處理狀態

```tsx
'use client'
import { useActionState } from 'react'
import { createPost } from './actions'

// 定義狀態型別
type State = {
  error?: string
  success?: boolean
}

export function CreatePostForm() {
  // useActionState 管理 action 的狀態
  const [state, formAction, isPending] = useActionState<State, FormData>(
    createPost,
    { error: undefined, success: false }
  )

  return (
    <form action={formAction}>
      <input name="title" disabled={isPending} />
      <textarea name="content" disabled={isPending} />
      
      {/* 顯示錯誤訊息 */}
      {state.error && (
        <p className="text-red-500">{state.error}</p>
      )}
      
      {/* 按鈕自動顯示載入狀態 */}
      <button type="submit" disabled={isPending}>
        {isPending ? '發布中...' : '發布文章'}
      </button>
    </form>
  )
}
```

```typescript
// actions.ts
'use server'

import { z } from 'zod'

const PostSchema = z.object({
  title: z.string().min(1, '標題必填').max(100),
  content: z.string().min(10, '內容至少 10 字')
})

export async function createPost(
  prevState: State,
  formData: FormData
): Promise<State> {
  // 驗證輸入
  const validated = PostSchema.safeParse({
    title: formData.get('title'),
    content: formData.get('content')
  })

  if (!validated.success) {
    return { error: validated.error.errors[0].message }
  }

  try {
    await db.post.create({ data: validated.data })
    revalidatePath('/posts')
    return { success: true }
  } catch (e) {
    return { error: '發布失敗，請稍後再試' }
  }
}
```

### 範例三：樂觀更新（Optimistic Updates）

```tsx
'use client'
import { useOptimistic } from 'react'
import { toggleLike } from './actions'

type Post = { id: string; likes: number; isLiked: boolean }

export function LikeButton({ post }: { post: Post }) {
  // useOptimistic 實現即時 UI 回饋
  const [optimisticPost, addOptimistic] = useOptimistic(
    post,
    (current, _action: 'toggle') => ({
      ...current,
      isLiked: !current.isLiked,
      likes: current.isLiked ? current.likes - 1 : current.likes + 1
    })
  )

  async function handleClick() {
    // 立即更新 UI（不等伺服器回應）
    addOptimistic('toggle')
    // 背景執行實際的伺服器操作
    await toggleLike(post.id)
  }

  return (
    <button onClick={handleClick}>
      {optimisticPost.isLiked ? '❤️' : '🤍'} {optimisticPost.likes}
    </button>
  )
}
```

## 常見錯誤與最佳實踐

### ❌ 錯誤一：在 Server Action 中存取瀏覽器 API

```typescript
'use server'
export async function trackClick() {
  // ❌ 錯誤：localStorage 只存在於瀏覽器
  const userId = localStorage.getItem('userId')
  await db.click.create({ data: { userId } })
}
```

**✅ 正確做法：從參數傳入必要資訊**
```typescript
'use server'
export async function trackClick(userId: string) {
  await db.click.create({ data: { userId } })
}
```

### ❌ 錯誤二：忘記驗證輸入資料

```typescript
'use server'
export async function updateUser(formData: FormData) {
  // ❌ 直接信任前端資料，可能導致注入攻擊
  const role = formData.get('role')
  await db.user.update({ where: { id }, data: { role } })
}
```

**✅ 正確做法：永遠驗證並清理輸入**
```typescript
'use server'
import { z } from 'zod'

const RoleSchema = z.enum(['user', 'editor']) // 不允許 'admin'

export async function updateUser(formData: FormData) {
  const role = RoleSchema.parse(formData.get('role'))
  await db.user.update({ where: { id }, data: { role } })
}
```

### ❌ 錯誤三：忘記處理錯誤狀態

```typescript
// ❌ 沒有錯誤處理，使用者不知道發生什麼事
<form action={submitForm}>
  <button>送出</button>
</form>
```

**✅ 正確做法：使用 useActionState 處理完整狀態**

### ✅ 最佳實踐：將 Server Actions 集中管理

```
app/
├── actions/
│   ├── index.ts      # 統一匯出
│   ├── auth.ts       # 認證相關
│   ├── posts.ts      # 文章相關
│   └── comments.ts   # 留言相關
```

### ✅ 最佳實踐：善用 revalidatePath 和 revalidateTag

```typescript
'use server'
import { revalidatePath, revalidateTag } from 'next/cache'

export async function createComment(postId: string, content: string) {
  await db.comment.create({ data: { postId, content } })
  
  // 重新驗證特定頁面
  revalidatePath(`/posts/${postId}`)
  
  // 或重新驗證特定標籤的快取
  revalidateTag(`post-${postId}`)
}
```

## 面試考點

### Q1: Server Actions 與傳統 API Routes 有什麼差異？

**回答要點：**
- Server Actions 是 RPC 風格，直接呼叫函式；API Routes 是 REST 風格，需要 HTTP 請求
- Server Actions 自動處理序列化，型別安全；API Routes 需要手動處理
- Server Actions 可以在 Server Component 中直接使用
- 兩者可以並存，API Routes 適合需要對外開放的端點

### Q2: 如何在 Server Action 中處理認證？

**回答要點：**
```typescript
'use server'
import { cookies } from 'next/headers'
import { verify } from 'jsonwebtoken'

export async function protectedAction(data: FormData) {
  // 從 cookies 取得 token
  const token = cookies().get('session')?.value
  
  if (!token) {
    throw new Error('未登入')
  }
  
  const user = verify(token, process.env.JWT_SECRET)
  // 繼續執行授權後的操作
}
```

### Q3: useActionState 和 useFormStatus 有什麼不同？

**回答要點：**
- `useActionState`：管理 action 的回傳狀態（成功/錯誤訊息），需要在表單元件中使用
- `useFormStatus`：只取得表單的 pending 狀態，必須在 `<form>` 的子元件中使用
- 通常會一起搭配使用，`useFormStatus` 用於 Submit 按鈕的載入狀態

## 延伸學習

1. **React 19 新增 Hooks 完整指南**
   - `use()`、`useOptimistic()`、`useFormStatus()` 的進階用法

2. **Next.js App Router 資料策略**
   - 何時用 Server Actions vs Route Handlers vs Server Components 直接 fetch

3. **Zod + Server Actions 表單驗證**
   - 建立可重用的表單驗證 schema
   - 前後端共用驗證邏輯
