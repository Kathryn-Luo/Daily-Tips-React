我來為你產生今天的學習筆記。首先讓我檢查一下已有的筆記，避免主題重複。

---

我會先查看現有的筆記來選擇今天的主題。

```task
subagent_type: Explore
prompt: "查看 learning-notes 資料夾中已經有哪些學習筆記主題，列出所有筆記的標題和日期，特別關注最近的筆記內容"
```

根據現有筆記的分析，我需要選擇一個尚未涵蓋的主題。讓我看看最近幾篇的具體內容，確保不重複。

根據權重分配和現有筆記分析：
- React 相關：已有 useReducer、React.memo、自定義 Hooks、React Router、Error Boundaries、Suspense、Context API、useState/useEffect、useRef、條件渲染等
- TypeScript：已有泛型基礎、型別守衛
- 前端架構：已有 React Testing Library、Vitest
- 跨領域：已有 CI/CD（GitHub Actions）

今天依照權重（React 40%），我會選擇一個重要但尚未涵蓋的 React 進階主題：**React Server Components（RSC）**，這是 React 18+ 和 Next.js 13+ 的核心新功能，對於準備面試非常重要。

現在讓我建立今天的學習筆記：

```write
file_path: learning-notes/2026/01/15-react-server-components.md
content:
# React Server Components（RSC）完全指南

> Server Components 是 React 架構的重大變革，讓元件可以在伺服器端執行，大幅改善首次載入效能與 SEO。

## 為什麼要學這個？

React Server Components 是 React 18 引入的革命性功能，在 Next.js 13+ 的 App Router 中成為預設行為。這項技術正在重新定義前端開發的邊界：

1. **效能提升**：將資料獲取移到伺服器端，減少 client-side JavaScript bundle 大小
2. **SEO 友善**：伺服器渲染的內容可被搜尋引擎直接索引
3. **簡化資料流**：可以直接在元件中使用 async/await 獲取資料
4. **降低客戶端負擔**：重度計算在伺服器完成，減輕行動裝置壓力

目前幾乎所有 React 職缺都要求熟悉 Next.js，而 RSC 是 Next.js App Router 的核心概念。

## 核心概念

### Server Components vs Client Components

想像你在餐廳點餐：

- **Server Components** = 廚房準備好的菜（伺服器做好，直接送到桌上）
- **Client Components** = 桌邊料理（在你面前現場烹調，可以互動）

```
┌─────────────────────────────────────────────────────────┐
│                      Server Side                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │  Server Component                                │   │
│  │  - 可以直接存取資料庫                             │   │
│  │  - 可以使用 fs、path 等 Node.js API              │   │
│  │  - 不能使用 useState、useEffect                  │   │
│  │  - 不能使用瀏覽器 API（window、document）         │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼ HTML + RSC Payload
┌─────────────────────────────────────────────────────────┐
│                      Client Side                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │  Client Component (加上 'use client')            │   │
│  │  - 可以使用所有 React Hooks                      │   │
│  │  - 可以使用瀏覽器 API                            │   │
│  │  - 可以處理使用者互動事件                         │   │
│  │  - 會被打包進 JavaScript bundle                  │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

### 關鍵規則

| 特性 | Server Component | Client Component |
|------|------------------|------------------|
| 檔案標記 | 預設（無需標記） | `'use client'` |
| 資料獲取 | 可直接 async/await | 需要 useEffect 或 React Query |
| Hooks | ❌ 不可用 | ✅ 可用 |
| 事件處理 | ❌ 不可用 | ✅ 可用 |
| 瀏覽器 API | ❌ 不可用 | ✅ 可用 |
| 可引入 Client Component | ✅ 可以 | ✅ 可以 |
| 可引入 Server Component | ✅ 可以 | ⚠️ 只能透過 children prop |

## Vue vs React 對比

### Vue 的做法：Nuxt 3 + Server Components

```vue
<!-- Nuxt 3 - 預設為通用渲染（Universal） -->
<!-- nuxt.config.ts 設定 -->
<script setup>
// Nuxt 使用 useFetch 或 useAsyncData 做伺服器端資料獲取
const { data: posts } = await useFetch('/api/posts')
</script>

<template>
  <div>
    <article v-for="post in posts" :key="post.id">
      {{ post.title }}
    </article>
  </div>
</template>
```

```vue
<!-- Nuxt 3 - 純客戶端元件 -->
<!-- components/ClientOnly.vue -->
<template>
  <ClientOnly>
    <!-- 只在客戶端渲染 -->
    <InteractiveChart :data="chartData" />
  </ClientOnly>
</template>
```

### React 的做法：Next.js App Router

```tsx
// Next.js 13+ - 預設為 Server Component
// app/posts/page.tsx

// 可以直接使用 async/await！
async function PostsPage() {
  // 直接在元件中獲取資料，無需 useEffect
  const posts = await fetch('https://api.example.com/posts').then(r => r.json())
  
  return (
    <div>
      {posts.map(post => (
        <article key={post.id}>{post.title}</article>
      ))}
    </div>
  )
}

export default PostsPage
```

```tsx
// 客戶端元件需要明確標記
// components/LikeButton.tsx
'use client'

import { useState } from 'react'

export function LikeButton({ postId }: { postId: string }) {
  const [liked, setLiked] = useState(false)
  
  return (
    <button onClick={() => setLiked(!liked)}>
      {liked ? '❤️' : '🤍'}
    </button>
  )
}
```

### 主要差異

| 概念 | Nuxt 3 (Vue) | Next.js 13+ (React) |
|------|--------------|---------------------|
| 預設渲染 | Universal（可配置） | Server Component |
| 客戶端標記 | `<ClientOnly>` 包裹 | `'use client'` 指令 |
| 資料獲取 | `useFetch`、`useAsyncData` | 直接 async/await |
| 思維模式 | 「哪些要在客戶端」 | 「哪些需要互動」 |

## 實作範例

### 範例 1：基礎 Server Component（資料獲取）

```tsx
// app/users/page.tsx
// 這是 Server Component（預設）

import { UserCard } from '@/components/UserCard'

// 定義資料型別
interface User {
  id: number
  name: string
  email: string
  avatar: string
}

// 伺服器端資料獲取函式
async function getUsers(): Promise<User[]> {
  // 可以直接存取資料庫或內部 API
  // 這段程式碼永遠不會出現在客戶端 bundle
  const res = await fetch('https://api.example.com/users', {
    // Next.js 擴充的快取選項
    cache: 'force-cache', // 預設：快取結果
    // cache: 'no-store',  // 每次都重新獲取
    next: { revalidate: 3600 } // 每小時重新驗證
  })
  
  if (!res.ok) throw new Error('Failed to fetch users')
  return res.json()
}

// Server Component 可以是 async function！
export default async function UsersPage() {
  const users = await getUsers()
  
  return (
    <main className="container mx-auto p-4">
      <h1 className="text-2xl font-bold mb-4">用戶列表</h1>
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        {users.map(user => (
          // UserCard 也是 Server Component
          <UserCard key={user.id} user={user} />
        ))}
      </div>
    </main>
  )
}
```

### 範例 2：混合 Server 與 Client Components

```tsx
// app/posts/[id]/page.tsx
// Server Component - 負責資料獲取

import { CommentSection } from '@/components/CommentSection'
import { ShareButton } from '@/components/ShareButton'

interface Post {
  id: string
  title: string
  content: string
  author: string
  createdAt: string
}

async function getPost(id: string): Promise<Post> {
  const res = await fetch(`https://api.example.com/posts/${id}`)
  if (!res.ok) throw new Error('Post not found')
  return res.json()
}

// 使用 generateMetadata 做動態 SEO
export async function generateMetadata({ params }: { params: { id: string } }) {
  const post = await getPost(params.id)
  return {
    title: post.title,
    description: post.content.slice(0, 160)
  }
}

export default async function PostPage({ params }: { params: { id: string } }) {
  const post = await getPost(params.id)
  
  return (
    <article className="max-w-2xl mx-auto p-4">
      {/* 靜態內容：Server Component 渲染 */}
      <header>
        <h1 className="text-3xl font-bold">{post.title}</h1>
        <p className="text-gray-500">
          {post.author} · {new Date(post.createdAt).toLocaleDateString('zh-TW')}
        </p>
      </header>
      
      <div className="prose mt-4">
        {post.content}
      </div>
      
      {/* 互動元件：Client Component */}
      <footer className="mt-8 flex gap-4">
        <ShareButton postId={post.id} title={post.title} />
      </footer>
      
      {/* 留言區：Client Component（需要即時互動） */}
      <CommentSection postId={post.id} />
    </article>
  )
}
```

```tsx
// components/ShareButton.tsx
'use client' // 👈 標記為 Client Component

import { useState } from 'react'

interface ShareButtonProps {
  postId: string
  title: string
}

export function ShareButton({ postId, title }: ShareButtonProps) {
  const [copied, setCopied] = useState(false)
  
  const handleShare = async () => {
    // 使用瀏覽器 API
    const url = window.location.href
    
    if (navigator.share) {
      // 原生分享 API
      await navigator.share({ title, url })
    } else {
      // 降級方案：複製連結
      await navigator.clipboard.writeText(url)
      setCopied(true)
      setTimeout(() => setCopied(false), 2000)
    }
  }
  
  return (
    <button 
      onClick={handleShare}
      className="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600"
    >
      {copied ? '✓ 已複製' : '分享文章'}
    </button>
  )
}
```

### 範例 3：Server Component 傳遞 Children 給 Client Component

```tsx
// 這是最常見的組合模式
// 讓 Server Component 的內容可以嵌入 Client Component

// components/InteractiveCard.tsx
'use client'

import { useState, ReactNode } from 'react'

interface InteractiveCardProps {
  children: ReactNode // 接收 Server Component 作為 children
  defaultExpanded?: boolean
}

export function InteractiveCard({ children, defaultExpanded = false }: InteractiveCardProps) {
  const [expanded, setExpanded] = useState(defaultExpanded)
  
  return (
    <div className="border rounded-lg overflow-hidden">
      <button
        onClick={() => setExpanded(!expanded)}
        className="w-full p-4 text-left bg-gray-100 hover:bg-gray-200"
      >
        {expanded ? '收合 ▲' : '展開 ▼'}
      </button>
      
      {expanded && (
        <div className="p-4">
          {/* children 是從 Server Component 傳入的 */}
          {/* 這些內容已經在伺服器渲染好了 */}
          {children}
        </div>
      )}
    </div>
  )
}
```

```tsx
// app/faq/page.tsx
// Server Component

import { InteractiveCard } from '@/components/InteractiveCard'

// 假設這是從 CMS 或資料庫獲取的 FAQ 資料
async function getFAQs() {
  return [
    {
      id: 1,
      question: '什麼是 Server Components？',
      answer: '...' // 可能是很長的 Markdown 內容
    },
    // ...
  ]
}

// Server Component 獲取資料
async function FAQContent({ id }: { id: number }) {
  // 模擬從資料庫獲取完整內容
  const content = await fetch(`/api/faq/${id}`).then(r => r.json())
  return <div className="prose">{content.answer}</div>
}

export default async function FAQPage() {
  const faqs = await getFAQs()
  
  return (
    <div className="space-y-4">
      {faqs.map(faq => (
        // InteractiveCard 是 Client Component
        // 但 FAQContent 是 Server Component
        <InteractiveCard key={faq.id}>
          <h3>{faq.question}</h3>
          {/* Server Component 作為 children 傳入 */}
          <FAQContent id={faq.id} />
        </InteractiveCard>
      ))}
    </div>
  )
}
```

## 常見錯誤與最佳實踐

### ❌ 錯誤 1：在 Server Component 使用 Hooks

```tsx
// ❌ 錯誤：Server Component 不能使用 Hooks
async function UserProfile() {
  const [user, setUser] = useState(null) // 💥 錯誤！
  
  useEffect(() => {
    fetchUser().then(setUser)
  }, [])
  
  return <div>{user?.name}</div>
}

// ✅ 正確：直接 async/await
async function UserProfile() {
  const user = await fetchUser()
  return <div>{user.name}</div>
}
```

### ❌ 錯誤 2：在 Client Component 直接引入 Server Component

```tsx
// ❌ 錯誤做法
'use client'

import { ServerDataComponent } from './ServerDataComponent' // 這會出錯！

export function Dashboard() {
  return (
    <div>
      <ServerDataComponent /> {/* 💥 Server Component 被強制轉為 Client */}
    </div>
  )
}

// ✅ 正確做法：使用 children pattern
'use client'

export function Dashboard({ children }: { children: ReactNode }) {
  return <div>{children}</div>
}

// 在 Server Component 中組合
// app/dashboard/page.tsx
export default function DashboardPage() {
  return (
    <Dashboard>
      <ServerDataComponent /> {/* ✅ 正確 */}
    </Dashboard>
  )
}
```

### ❌ 錯誤 3：過度使用 'use client'

```tsx
// ❌ 錯誤：整個頁面都標記為 client
'use client'

export default function ProductPage({ params }) {
  const [product, setProduct] = useState(null)
  
  useEffect(() => {
    fetch(`/api/products/${params.id}`).then(r => r.json()).then(setProduct)
  }, [params.id])
  
  // 整個頁面都在客戶端渲染，失去 SEO 和效能優勢
  return <ProductDetails product={product} />
}

// ✅ 正確：只將互動部分抽成 Client Component
// app/products/[id]/page.tsx (Server Component)
export default async function ProductPage({ params }) {
  const product = await getProduct(params.id)
  
  return (
    <div>
      {/* 靜態內容在伺服器渲染 */}
      <ProductInfo product={product} />
      {/* 只有購買按鈕需要互動 */}
      <AddToCartButton productId={product.id} />
    </div>
  )
}
```

### ✅ 最佳實踐 1：將 'use client' 邊界往下推

```tsx
// ✅ 盡量讓更多元件保持為 Server Component

// components/Navbar.tsx - Server Component
import { Logo } from './Logo'
import { NavLinks } from './NavLinks'
import { MobileMenuButton } from './MobileMenuButton' // 只有這個需要 'use client'

export function Navbar() {
  return (
    <nav>
      <Logo />
      <NavLinks />
      <MobileMenuButton /> {/* 互動邏輯封裝在最小範圍 */}
    </nav>
  )
}
```

### ✅ 最佳實踐 2：善用 Streaming 和 Suspense

```tsx
// app/dashboard/page.tsx
import { Suspense } from 'react'
import { SlowComponent } from './SlowComponent'

export default function Dashboard() {
  return (
    <div>
      <h1>Dashboard</h1>
      
      {/* 快速內容先顯示 */}
      <QuickStats />
      
      {/* 慢速內容使用 Suspense 包裹，不阻塞整頁 */}
      <Suspense fallback={<LoadingSkeleton />}>
        <SlowComponent />
      </Suspense>
    </div>
  )
}
```

## 面試考點

### Q1：Server Components 和 SSR（Server-Side Rendering）有什麼區別？

**答案要點：**

| 特性 | 傳統 SSR | Server Components |
|------|----------|-------------------|
| 渲染時機 | 每次請求時重新渲染 | 可快取和重用 |
| Hydration | 整頁需要 hydrate | 只有 Client Components 需要 |
| JS Bundle | 包含所有元件程式碼 | 只包含 Client Components |
| 資料獲取 | getServerSideProps 等 | 直接在元件內 async/await |
| 互動性 | 需要整頁 hydrate 後才能互動 | Client Components 可獨立 hydrate |

SSR 是「在伺服器產生 HTML」，但所有 JavaScript 程式碼仍要送到客戶端執行 hydration。Server Components 是「元件只在伺服器執行」，程式碼永遠不會送到客戶端。

### Q2：什麼情況下應該使用 Client Component？

**答案要點：**

需要 Client Component 的情況：
1. **使用 React Hooks**：useState、useEffect、useReducer 等
2. **事件處理**：onClick、onChange 等使用者互動
3. **瀏覽器 API**：window、document、localStorage 等
4. **第三方套件**：只支援客戶端的套件（如某些動畫庫）
5. **即時更新**：WebSocket、即時輪詢等

不需要 Client Component 的情況（保持 Server Component）：
- 純資料展示
- 靜態內容
- SEO 重要的內容
- 資料庫查詢

### Q3：如何在 Server Components 中處理錯誤？

**答案要點：**

```tsx
// 1. error.tsx - Error Boundary（Client Component）
'use client'

export default function Error({
  error,
  reset
}: {
  error: Error
  reset: () => void
}) {
  return (
    <div>
      <h2>出錯了！</h2>
      <button onClick={reset}>重試</button>
    </div>
  )
}

// 2. not-found.tsx - 404 處理
export default function NotFound() {
  return <h2>找不到資源</h2>
}

// 3. 在 Server Component 中觸發
import { notFound } from 'next/navigation'

async function getPost(id: string) {
  const post = await db.post.findUnique({ where: { id } })
  if (!post) notFound() // 觸發 not-found.tsx
  return post
}
```

## 延伸學習

1. **Server Actions**
   - 下一個要學的重點：在 Server Components 中定義可以從客戶端呼叫的函式
   - 簡化表單處理和資料變更
   - `'use server'` 指令的使用

2. **Partial Prerendering（PPR）**
   - Next.js 14 實驗性功能
   - 結合 Static 和 Dynamic 渲染的優點
   - 將是 Next.js 的下一代渲染策略

3. **React 官方 RSC 文件**
   - [React RFC: Server Components](https://github.com/reactjs/rfcs/pull/188)
   - 深入了解設計理念和規範
   - 適合想理解底層原理的讀者
```

現在更新索引檔案：

```read
file_path: learning-notes/README.md
```

```write
file_path: learning-notes/README.md
content:
# 學習筆記索引

這裡收錄了每日自動產生的學習筆記，幫助從 Vue 轉職到 React 相關職位。

## 2026 年 1 月

| 日期 | 主題 | 分類 |
|------|------|------|
| 01/15 | [React Server Components（RSC）完全指南](2026/01/15-react-server-components.md) | React |
| 01/14 | [React Suspense 深入解析](2026/01/14-react-suspense.md) | React |
| 01/13 | [Vitest 單元測試實戰](2026/01/13-vitest-testing.md) | 前端架構 |
| 01/12 | [TypeScript 型別守衛（Type Guards）](2026/01/12-typescript-type-guards.md) | TypeScript |
| 01/11 | [React Context API 狀態管理](2026/01/11-react-context-api.md) | React |
| 01/10 | [React Error Boundaries 錯誤邊界](2026/01/10-react-error-boundaries.md) | React |
| 01/09 | [GitHub Actions CI/CD 實戰](2026/01/09-github-actions-cicd.md) | 跨領域 |
| 01/08 | [React Testing Library 測試實戰](2026/01/08-react-testing-library.md) | 前端架構 |
| 01/07 | [React Router v6 路由管理](2026/01/07-react-router-v6.md) | React |
| 01/06 | [TypeScript 泛型基礎](2026/01/06-typescript-generics.md) | TypeScript |
| 01/05 | [React 自定義 Hooks](2026/01/05-custom-hooks.md) | React |
| 01/04 | [React.memo 效能優化](2026/01/04-react-memo.md) | React |
| 01/03 | [useReducer 狀態管理](2026/01/03-usereducer.md) | React |
| 01/02 | [useRef 完全指南](2026/01/02-useref.md) | React |
| 01/01 | [React 條件渲染技巧](2026/01/01-conditional-rendering.md) | React |

## 2025 年 12 月

| 日期 | 主題 | 分類 |
|------|------|------|
| 12/28 | [useState 與 useEffect 基礎](2025/12/28-usestate-useeffect.md) | React |

---

## 分類統計

- **React**：12 篇
- **TypeScript**：2 篇
- **前端架構**：2 篇
- **跨領域**：1 篇

## 學習路徑建議

### React 基礎 → 進階
1. useState 與 useEffect 基礎
2. useRef 完全指南
3. useReducer 狀態管理
4. React 條件渲染技巧
5. React.memo 效能優化
6. React 自定義 Hooks
7. React Context API 狀態管理
8. React Router v6 路由管理
9. React Error Boundaries 錯誤邊界
10. React Suspense 深入解析
11. **React Server Components（RSC）完全指南** ⬅️ 最新

### TypeScript 進階
1. TypeScript 泛型基礎
2. TypeScript 型別守衛

### 測試與工程化
1. React Testing Library 測試實戰
2. Vitest 單元測試實戰
3. GitHub Actions CI/CD 實戰
```

今天的學習筆記已經產生完成！

## 📝 今日筆記摘要

**主題**：React Server Components（RSC）完全指南

**選擇原因**：
- React Server Components 是 React 18+ 和 Next.js 13+ 的核心新功能
- 目前幾乎所有 React 職缺都要求熟悉 Next.js App Router
- 尚未在現有筆記中涵蓋此主題

**筆記亮點**：
1. 詳細解釋 Server Components vs Client Components 的差異
2. Vue（Nuxt 3）與 React（Next.js）的對比
3. 三個由淺入深的實作範例
4. 常見錯誤與最佳實踐（包含程式碼範例）
5. 三個面試高頻考題

**檔案位置**：`learning-notes/2026/01/15-react-server-components.md`
