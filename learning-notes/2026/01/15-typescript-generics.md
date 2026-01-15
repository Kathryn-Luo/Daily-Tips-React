# React 19 useTransition 深度解析：打造流暢的使用者體驗

> useTransition 讓你標記某些狀態更新為「可中斷的過渡」，確保 UI 在複雜更新時仍保持回應。

## 為什麼要學這個？

在現代 Web 應用中，使用者期待即時的互動回饋。當應用需要處理大量資料或複雜的 UI 更新時，畫面可能會「卡住」，導致糟糕的使用者體驗。

useTransition 是 React 18 引入、React 19 強化的並發特性，它讓你能夠：
- 區分「緊急更新」與「非緊急更新」
- 保持輸入框、按鈕等互動元素的即時回應
- 在過渡期間顯示 loading 狀態
- 避免不必要的 loading spinner 閃爍

## 核心概念

想像你在餐廳點餐：

- **緊急更新**：服務生立即回應「好的，收到您的點餐」（輸入回饋）
- **過渡更新**：廚房開始準備餐點，需要一些時間（資料載入、大量渲染）

useTransition 就是告訴 React：「這個更新不緊急，可以被其他更緊急的更新中斷」。

```typescript
const [isPending, startTransition] = useTransition();
```

- `isPending`：布林值，表示是否有過渡正在進行
- `startTransition`：函式，將狀態更新包裝為過渡

## Vue vs React 對比

| 面向 | Vue 3 | React 19 |
|------|-------|----------|
| 並發模式 | 無原生支援 | 內建 Concurrent Features |
| 過渡狀態 | 需手動管理 loading 狀態 | useTransition 自動追蹤 |
| 優先級控制 | 無 | startTransition 標記低優先級 |
| 實作方式 | 通常用 debounce/throttle | 原生排程器處理 |

**Vue 的做法**：
```vue
<script setup>
import { ref } from 'vue'
import { useDebounceFn } from '@vueuse/core'

const searchQuery = ref('')
const results = ref([])
const isLoading = ref(false)

const search = useDebounceFn(async (query) => {
  isLoading.value = true
  results.value = await fetchResults(query)
  isLoading.value = false
}, 300)
</script>
```

**React 的做法**：
```tsx
function SearchComponent() {
  const [query, setQuery] = useState('')
  const [results, setResults] = useState([])
  const [isPending, startTransition] = useTransition()

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    // 緊急：立即更新輸入框
    setQuery(e.target.value)
    
    // 非緊急：可被中斷的搜尋結果更新
    startTransition(() => {
      setResults(filterResults(e.target.value))
    })
  }

  return (
    <>
      <input value={query} onChange={handleChange} />
      {isPending && <Spinner />}
      <ResultList results={results} />
    </>
  )
}
```

## 實作範例

### 範例一：基礎搜尋過濾

```tsx
import { useState, useTransition } from 'react'

// 模擬大量資料
const allItems = Array.from({ length: 10000 }, (_, i) => ({
  id: i,
  name: `Item ${i}`,
}))

function FilterList() {
  const [query, setQuery] = useState('')
  const [filteredItems, setFilteredItems] = useState(allItems)
  const [isPending, startTransition] = useTransition()

  const handleSearch = (e: React.ChangeEvent<HTMLInputElement>) => {
    const value = e.target.value
    
    // 立即更新輸入框，保持打字流暢
    setQuery(value)
    
    // 過濾操作標記為過渡，可被中斷
    startTransition(() => {
      const filtered = allItems.filter(item =>
        item.name.toLowerCase().includes(value.toLowerCase())
      )
      setFilteredItems(filtered)
    })
  }

  return (
    <div>
      <input
        type="text"
        value={query}
        onChange={handleSearch}
        placeholder="搜尋..."
      />
      
      {/* isPending 自動追蹤過渡狀態 */}
      {isPending && <div className="loading-bar" />}
      
      <ul style={{ opacity: isPending ? 0.7 : 1 }}>
        {filteredItems.map(item => (
          <li key={item.id}>{item.name}</li>
        ))}
      </ul>
    </div>
  )
}
```

### 範例二：Tab 切換與內容載入

```tsx
import { useState, useTransition, Suspense } from 'react'

type Tab = 'posts' | 'comments' | 'profile'

function TabContainer() {
  const [tab, setTab] = useState<Tab>('posts')
  const [isPending, startTransition] = useTransition()

  const selectTab = (nextTab: Tab) => {
    // 使用 startTransition 讓 tab 切換更平滑
    // 如果新 tab 內容載入較慢，舊內容會保持顯示
    startTransition(() => {
      setTab(nextTab)
    })
  }

  return (
    <div>
      <nav>
        {(['posts', 'comments', 'profile'] as const).map(t => (
          <button
            key={t}
            onClick={() => selectTab(t)}
            className={tab === t ? 'active' : ''}
            // 過渡中禁用按鈕防止重複點擊
            disabled={isPending}
          >
            {t}
            {/* 顯示哪個 tab 正在載入 */}
            {isPending && tab !== t && ' ⏳'}
          </button>
        ))}
      </nav>

      <div className={isPending ? 'pending' : ''}>
        <Suspense fallback={<Loading />}>
          <TabContent tab={tab} />
        </Suspense>
      </div>
    </div>
  )
}
```

### 範例三：React 19 搭配 Actions 使用

```tsx
import { useTransition } from 'react'

// React 19 新特性：startTransition 支援 async 函式
function SubmitForm() {
  const [isPending, startTransition] = useTransition()
  const [error, setError] = useState<string | null>(null)

  const handleSubmit = async (formData: FormData) => {
    setError(null)
    
    // React 19: startTransition 可以包裝 async 函式
    startTransition(async () => {
      try {
        const response = await fetch('/api/submit', {
          method: 'POST',
          body: formData,
        })
        
        if (!response.ok) {
          throw new Error('提交失敗')
        }
        
        // 成功後的狀態更新也在 transition 中
        const data = await response.json()
        // 更新相關狀態...
        
      } catch (e) {
        setError(e instanceof Error ? e.message : '未知錯誤')
      }
    })
  }

  return (
    <form action={handleSubmit}>
      <input name="title" required />
      <textarea name="content" required />
      
      <button type="submit" disabled={isPending}>
        {isPending ? '提交中...' : '送出'}
      </button>
      
      {error && <p className="error">{error}</p>}
    </form>
  )
}
```

## 常見錯誤與最佳實踐

### ❌ 錯誤一：把所有更新都放進 startTransition

```tsx
// 錯誤：輸入框更新也放進 transition
const handleChange = (e) => {
  startTransition(() => {
    setQuery(e.target.value) // 這會讓打字變得遲鈍
    setResults(filter(e.target.value))
  })
}

// 正確：只有非緊急更新放進 transition
const handleChange = (e) => {
  setQuery(e.target.value) // 緊急：立即更新
  startTransition(() => {
    setResults(filter(e.target.value)) // 非緊急：可延遲
  })
}
```

### ❌ 錯誤二：在 startTransition 中執行副作用

```tsx
// 錯誤：transition 中不應有副作用
startTransition(() => {
  console.log('這會執行多次') // React 可能多次呼叫
  localStorage.setItem('key', value) // 副作用！
  setState(value)
})

// 正確：副作用放在 transition 外部
console.log('執行一次')
localStorage.setItem('key', value)
startTransition(() => {
  setState(value)
})
```

### ❌ 錯誤三：忽略 isPending 狀態

```tsx
// 不佳：沒有視覺回饋
startTransition(() => setTab(newTab))

// 較佳：利用 isPending 提供回饋
<div style={{ opacity: isPending ? 0.6 : 1 }}>
  {content}
</div>
```

### ✅ 最佳實踐：結合 useDeferredValue

```tsx
import { useDeferredValue, useMemo } from 'react'

function SearchResults({ query }: { query: string }) {
  // useDeferredValue 是另一種處理方式
  const deferredQuery = useDeferredValue(query)
  const isStale = query !== deferredQuery

  const results = useMemo(
    () => heavyFilter(deferredQuery),
    [deferredQuery]
  )

  return (
    <ul style={{ opacity: isStale ? 0.7 : 1 }}>
      {results.map(r => <li key={r.id}>{r.name}</li>)}
    </ul>
  )
}
```

### ✅ 最佳實踐：設定合理的 loading 延遲

```tsx
// 使用 CSS 延遲顯示 spinner，避免閃爍
.loading-indicator {
  opacity: 0;
  transition: opacity 0.2s;
  transition-delay: 0.5s; /* 500ms 後才顯示 */
}

.loading-indicator.visible {
  opacity: 1;
}
```

## 面試考點

### Q1: useTransition 和 useDeferredValue 有什麼差別？

**答**：
- `useTransition`：用於**你可以控制的狀態更新**，主動將更新標記為低優先級
- `useDeferredValue`：用於**你無法控制的值**（如 props），讓 React 延遲更新該值
- 簡單說：useTransition 包裝「設定狀態的動作」，useDeferredValue 包裝「值本身」

### Q2: 為什麼 startTransition 中的更新可以被中斷？

**答**：React 的並發渲染器會將 transition 更新標記為低優先級。當有新的高優先級更新（如使用者輸入）進來時，React 會：
1. 暫停正在進行的低優先級渲染
2. 處理高優先級更新
3. 之後再繼續或重新開始低優先級渲染

這是透過 React 內部的排程器（Scheduler）和 Fiber 架構實現的。

### Q3: React 19 的 useTransition 相比 React 18 有什麼改進？

**答**：
1. **支援 async 函式**：startTransition 現在可以包裝 async 函式，自動追蹤 Promise 狀態
2. **與 Actions 整合**：可用於 form actions，自動處理 pending 狀態
3. **錯誤處理**：async transition 中的錯誤會被 Error Boundary 捕獲

## 延伸學習

1. **React 官方文件 - Concurrent React**
   深入了解並發特性的設計理念與完整 API

2. **useOptimistic Hook（React 19）**
   學習如何在 transition 中實現樂觀更新

3. **React Scheduler 原理**
   理解 React 如何實現優先級排程，掌握 Lane 模型
