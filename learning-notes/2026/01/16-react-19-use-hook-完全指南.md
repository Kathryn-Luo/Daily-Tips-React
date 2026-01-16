# React 19 `use()` Hook 完全指南

> React 19 新增的 `use()` Hook 讓你可以在 render 時直接讀取 Promise 和 Context，徹底改變非同步資料處理的方式。

## 為什麼要學這個？

React 19 引入的 `use()` 是一個革命性的 Hook，它打破了過去 Hooks 必須在元件頂層呼叫的限制。這個新 API 讓你能夠：

1. **簡化非同步資料載入**：不再需要 `useEffect` + `useState` 的組合來處理 Promise
2. **條件式讀取 Context**：可以在條件判斷內使用 Context
3. **更好的 Suspense 整合**：原生支援 Suspense 邊界，自動處理 loading 狀態
4. **減少樣板程式碼**：用更少的程式碼完成相同的功能

## 核心概念

`use()` 可以想像成一個「等待器」，它會暫停元件的渲染直到 Promise 解決，並將結果交給 Suspense 處理 loading 狀態。

```
傳統方式：發起請求 → 設定 loading → 等待 → 設定資料 → 重新渲染
use() 方式：發起請求 → Suspense 接管 → Promise 解決 → 直接使用資料
```

關鍵特性：
- **可在條件式中呼叫**：與其他 Hooks 不同，`use()` 可以在 `if`、迴圈內使用
- **支援兩種資源**：Promise 和 Context
- **與 Suspense 深度整合**：自動處理載入中狀態

## Vue vs React 對比

| 功能 | Vue 3 | React 19 |
|------|-------|----------|
| 非同步資料 | `<Suspense>` + `async setup()` | `use()` + `<Suspense>` |
| 條件式注入 | 不支援條件式 `inject()` | `use(Context)` 可條件式呼叫 |
| 資料等待 | `await` 在 setup 中 | `use(promise)` 在 render 中 |

**Vue 的非同步元件：**
```vue
<script setup>
// Vue 3 async setup
const data = await fetchData() // 需要整個 setup 是 async
</script>
```

**React 19 的 use()：**
```tsx
function Component({ dataPromise }) {
  const data = use(dataPromise) // 直接在 render 中使用
  return <div>{data.name}</div>
}
```

## 實作範例

### 範例一：基礎 Promise 讀取

```tsx
import { use, Suspense } from 'react'

// 建立一個 Promise（注意：必須在元件外部建立，避免每次 render 都產生新 Promise）
const userPromise = fetch('/api/user').then(res => res.json())

function UserProfile() {
  // use() 會暫停渲染直到 Promise 解決
  const user = use(userPromise)
  
  return (
    <div className="profile">
      <h1>{user.name}</h1>
      <p>{user.email}</p>
    </div>
  )
}

// 父元件需要包裹 Suspense 處理載入狀態
function App() {
  return (
    <Suspense fallback={<div>載入中...</div>}>
      <UserProfile />
    </Suspense>
  )
}
```

### 範例二：條件式 Context 讀取

```tsx
import { use, createContext } from 'react'

const ThemeContext = createContext('light')
const AuthContext = createContext(null)

function Dashboard({ showTheme }: { showTheme: boolean }) {
  // 傳統的 useContext 不能在條件式中使用
  // 但 use() 可以！
  
  const auth = use(AuthContext)
  
  if (!auth) {
    return <div>請先登入</div>
  }
  
  // 條件式讀取 Context
  let theme = 'light'
  if (showTheme) {
    theme = use(ThemeContext) // 這在傳統 Hook 中是不允許的
  }
  
  return (
    <div className={`dashboard ${theme}`}>
      <h1>歡迎, {auth.username}</h1>
    </div>
  )
}
```

### 範例三：搭配 Error Boundary 處理錯誤

```tsx
import { use, Suspense } from 'react'
import { ErrorBoundary } from 'react-error-boundary'

// 建立資料獲取函式，回傳 Promise
function fetchPosts(userId: string): Promise<Post[]> {
  return fetch(`/api/users/${userId}/posts`)
    .then(res => {
      if (!res.ok) throw new Error('載入失敗')
      return res.json()
    })
}

function PostList({ postsPromise }: { postsPromise: Promise<Post[]> }) {
  const posts = use(postsPromise)
  
  return (
    <ul>
      {posts.map(post => (
        <li key={post.id}>
          <h3>{post.title}</h3>
          <p>{post.excerpt}</p>
        </li>
      ))}
    </ul>
  )
}

function UserPosts({ userId }: { userId: string }) {
  // 在元件內建立 Promise 時，需使用 cache 或 useMemo 避免重複建立
  const postsPromise = fetchPosts(userId)
  
  return (
    <ErrorBoundary fallback={<div>載入文章時發生錯誤</div>}>
      <Suspense fallback={<div>載入文章中...</div>}>
        <PostList postsPromise={postsPromise} />
      </Suspense>
    </ErrorBoundary>
  )
}
```

### 範例四：結合 React 19 cache 函式

```tsx
import { use, Suspense, cache } from 'react'

// 使用 cache 確保相同參數只會發起一次請求
const getUser = cache(async (id: string) => {
  const res = await fetch(`/api/users/${id}`)
  return res.json()
})

function UserCard({ userId }: { userId: string }) {
  // 即使多個元件呼叫相同的 userId，也只會發起一次請求
  const user = use(getUser(userId))
  
  return (
    <div className="user-card">
      <img src={user.avatar} alt={user.name} />
      <span>{user.name}</span>
    </div>
  )
}

function App() {
  return (
    <Suspense fallback={<div>載入中...</div>}>
      {/* 這兩個元件共享同一個快取的請求 */}
      <UserCard userId="123" />
      <UserCard userId="123" />
    </Suspense>
  )
}
```

## 常見錯誤與最佳實踐

### ❌ 錯誤一：在元件內直接建立 Promise

```tsx
// 錯誤：每次 render 都會建立新的 Promise，造成無限迴圈
function BadComponent() {
  const data = use(fetch('/api/data').then(r => r.json()))
  return <div>{data.name}</div>
}
```

### ✅ 正確做法：在元件外部建立或使用 cache

```tsx
// 正確：Promise 在元件外部建立
const dataPromise = fetch('/api/data').then(r => r.json())

function GoodComponent() {
  const data = use(dataPromise)
  return <div>{data.name}</div>
}
```

### ❌ 錯誤二：忘記包裹 Suspense

```tsx
// 錯誤：沒有 Suspense，Promise pending 時會拋出錯誤
function App() {
  return <UserProfile /> // 會導致錯誤
}
```

### ✅ 正確做法：使用 Suspense 包裹

```tsx
function App() {
  return (
    <Suspense fallback={<Loading />}>
      <UserProfile />
    </Suspense>
  )
}
```

### ❌ 錯誤三：混淆 use() 與 await

```tsx
// 錯誤：use() 不需要 await
function BadComponent({ promise }) {
  const data = await use(promise) // use() 會自動處理等待
}
```

### 最佳實踐清單

1. **搭配 Error Boundary**：處理 Promise rejection 的情況
2. **使用 cache()**：避免重複請求相同資料
3. **適當設置 Suspense 邊界**：根據 UI 區塊設定多個 Suspense
4. **Promise 穩定性**：確保傳入的 Promise 是穩定的參照

## 面試考點

### Q1: `use()` 和 `useEffect` + `useState` 有什麼差異？

**簡答**：`use()` 在 render 階段直接讀取 Promise 值並暫停渲染，透過 Suspense 處理載入狀態；而 `useEffect` + `useState` 是在 commit 階段後才發起請求，需要手動管理 loading/error 狀態。`use()` 讓程式碼更簡潔，且與 Suspense 原生整合。

### Q2: 為什麼 `use()` 可以在條件式中呼叫，但 `useContext` 不行？

**簡答**：傳統 Hooks 依賴呼叫順序來對應內部狀態，所以必須保持一致的呼叫順序。`use()` 的設計不依賴呼叫順序，它直接讀取傳入的資源（Promise 或 Context），因此可以在條件式或迴圈中使用。

### Q3: 使用 `use()` 時如何避免重複發起請求？

**簡答**：三種方式：
1. 在元件外部建立 Promise
2. 使用 React 19 的 `cache()` 函式包裝資料獲取函式
3. 使用支援快取的資料獲取庫（如 TanStack Query、SWR）

## 延伸學習

1. **React 19 Server Components**：`use()` 在 Server Components 中的應用，搭配 async/await 直接在伺服器端獲取資料

2. **Suspense 進階模式**：學習 `SuspenseList`、巢狀 Suspense、以及 Suspense 與 Transition 的搭配使用

3. **TanStack Query 整合**：了解如何將 `use()` 與現有的資料獲取庫整合，享受快取、重試、背景更新等進階功能
