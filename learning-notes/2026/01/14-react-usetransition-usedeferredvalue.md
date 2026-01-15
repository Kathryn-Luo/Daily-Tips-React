# React useTransition 與 useDeferredValue：打造流暢的使用者體驗

> 透過 Concurrent Features 讓 UI 在繁重運算時依然保持回應能力

## 為什麼要學這個？

在現代 Web 應用中，使用者期待即時的互動回饋。然而，當應用需要處理大量資料渲染（如搜尋結果過濾、大型列表更新）時，UI 很容易出現卡頓。React 18 引入的 `useTransition` 和 `useDeferredValue` 讓我們能夠區分「緊急更新」與「非緊急更新」，確保使用者輸入等關鍵互動始終流暢。

**應用場景：**
- 搜尋框即時過濾大量資料
- Tab 切換時載入複雜內容
- 大型表格排序與篩選
- 任何可能造成 UI 阻塞的狀態更新

## 核心概念

想像你在餐廳點餐：

- **緊急更新（Urgent Update）**：服務生記下你說的每個字 → 輸入框的文字變化
- **非緊急更新（Transition）**：廚房開始準備餐點 → 根據輸入過濾搜尋結果

`useTransition` 讓你告訴 React：「這個更新不急，如果有更重要的事，可以先處理。」

```
使用者輸入 "react"
    │
    ├─→ 緊急：立即更新輸入框顯示 "react" ✓
    │
    └─→ 非緊急：過濾 10,000 筆資料（可被中斷）
            │
            └─→ 使用者繼續輸入 "react hooks"
                    │
                    └─→ 放棄舊的過濾，開始新的過濾
```

## Vue vs React 對比

| 面向 | Vue 3 | React 18 |
|------|-------|----------|
| 概念 | 無直接對應，需手動實作 | 內建 Concurrent Features |
| 延遲更新 | `watchEffect` + `debounce` | `useDeferredValue` |
| 標記非緊急 | 無原生支援 | `useTransition` |
| 載入狀態 | 手動管理 | `isPending` 自動提供 |

**Vue 的做法（手動 debounce）：**
```vue
<script setup>
import { ref, computed } from 'vue'
import { useDebounceFn } from '@vueuse/core'

const searchText = ref('')
const debouncedSearch = ref('')

const updateSearch = useDebounceFn((value) => {
  debouncedSearch.value = value
}, 300)

const filteredList = computed(() => {
  return hugeList.filter(item => 
    item.includes(debouncedSearch.value)
  )
})
</script>
```

**React 的做法（useTransition）：**
```jsx
function SearchList() {
  const [searchText, setSearchText] = useState('')
  const [isPending, startTransition] = useTransition()
  const [filteredList, setFilteredList] = useState([])

  const handleChange = (e) => {
    // 緊急：立即更新輸入框
    setSearchText(e.target.value)
    
    // 非緊急：可被中斷的過濾
    startTransition(() => {
      setFilteredList(filterHugeList(e.target.value))
    })
  }

  return (
    <>
      <input value={searchText} onChange={handleChange} />
      {isPending && <Spinner />}
      <List items={filteredList} />
    </>
  )
}
```

## 實作範例

### 範例一：基礎 useTransition

```jsx
import { useState, useTransition } from 'react'

function TabContainer() {
  const [tab, setTab] = useState('home')
  const [isPending, startTransition] = useTransition()

  function selectTab(nextTab) {
    // 將 tab 切換標記為非緊急更新
    startTransition(() => {
      setTab(nextTab)
    })
  }

  return (
    <div>
      <nav>
        {['home', 'posts', 'settings'].map((t) => (
          <button
            key={t}
            onClick={() => selectTab(t)}
            // 利用 isPending 顯示載入狀態
            style={{ opacity: isPending && tab !== t ? 0.7 : 1 }}
          >
            {t}
          </button>
        ))}
      </nav>
      
      {/* isPending 為 true 時可顯示 loading 指示 */}
      <div style={{ opacity: isPending ? 0.6 : 1 }}>
        {tab === 'home' && <Home />}
        {tab === 'posts' && <Posts />}  {/* 假設這是個很慢的元件 */}
        {tab === 'settings' && <Settings />}
      </div>
    </div>
  )
}
```

### 範例二：useDeferredValue 過濾大量資料

```jsx
import { useState, useDeferredValue, useMemo } from 'react'

function ProductSearch({ products }) {  // products: 10,000+ 筆
  const [query, setQuery] = useState('')
  
  // 建立 query 的延遲版本
  // 當有更緊急的更新時，deferredQuery 會暫時保持舊值
  const deferredQuery = useDeferredValue(query)
  
  // 判斷是否正在「追趕」中
  const isStale = query !== deferredQuery

  // 使用 deferredQuery 進行過濾，避免每次輸入都重新計算
  const filteredProducts = useMemo(() => {
    return products.filter((product) =>
      product.name.toLowerCase().includes(deferredQuery.toLowerCase())
    )
  }, [products, deferredQuery])

  return (
    <div>
      <input
        value={query}
        onChange={(e) => setQuery(e.target.value)}
        placeholder="搜尋商品..."
      />
      
      {/* 當資料過時時顯示視覺提示 */}
      <div style={{ opacity: isStale ? 0.7 : 1 }}>
        <p>找到 {filteredProducts.length} 筆結果</p>
        <ul>
          {filteredProducts.slice(0, 100).map((product) => (
            <li key={product.id}>{product.name}</li>
          ))}
        </ul>
      </div>
    </div>
  )
}
```

### 範例三：結合 Suspense 使用

```jsx
import { useState, useTransition, Suspense } from 'react'

// 假設這個元件內部會觸發 data fetching
const UserProfile = lazy(() => import('./UserProfile'))
const UserPosts = lazy(() => import('./UserPosts'))
const UserPhotos = lazy(() => import('./UserPhotos'))

function UserDashboard({ userId }) {
  const [view, setView] = useState('profile')
  const [isPending, startTransition] = useTransition()

  const handleViewChange = (newView) => {
    startTransition(() => {
      setView(newView)
    })
  }

  return (
    <div>
      <nav className="tab-nav">
        {['profile', 'posts', 'photos'].map((v) => (
          <button
            key={v}
            onClick={() => handleViewChange(v)}
            className={view === v ? 'active' : ''}
            disabled={isPending}
          >
            {v}
            {/* 切換到此 tab 時顯示載入中 */}
            {isPending && view !== v && ' ⏳'}
          </button>
        ))}
      </nav>

      {/* 
        使用 Suspense 搭配 transition
        - 切換時不會立即顯示 fallback
        - 而是保持舊內容直到新內容準備好
      */}
      <Suspense fallback={<Loading />}>
        <div className={isPending ? 'pending' : ''}>
          {view === 'profile' && <UserProfile userId={userId} />}
          {view === 'posts' && <UserPosts userId={userId} />}
          {view === 'photos' && <UserPhotos userId={userId} />}
        </div>
      </Suspense>
    </div>
  )
}
```

## 常見錯誤與最佳實踐

### ❌ 錯誤一：在 transition 中更新受控輸入

```jsx
// 錯誤：輸入會有明顯延遲
function BadSearch() {
  const [query, setQuery] = useState('')
  const [isPending, startTransition] = useTransition()

  return (
    <input
      value={query}
      onChange={(e) => {
        // ❌ 不要這樣做！輸入框會變得很卡
        startTransition(() => {
          setQuery(e.target.value)
        })
      }}
    />
  )
}

// 正確：分離緊急與非緊急更新
function GoodSearch() {
  const [inputValue, setInputValue] = useState('')
  const [searchQuery, setSearchQuery] = useState('')
  const [isPending, startTransition] = useTransition()

  return (
    <input
      value={inputValue}
      onChange={(e) => {
        setInputValue(e.target.value)  // ✅ 緊急更新
        startTransition(() => {
          setSearchQuery(e.target.value)  // ✅ 非緊急更新
        })
      }}
    />
  )
}
```

### ❌ 錯誤二：對所有更新都使用 transition

```jsx
// 錯誤：過度使用
function OveruseTransition() {
  const [count, setCount] = useState(0)
  const [isPending, startTransition] = useTransition()

  return (
    <button onClick={() => {
      // ❌ 簡單的計數器不需要 transition
      startTransition(() => {
        setCount(c => c + 1)
      })
    }}>
      {count}
    </button>
  )
}
```

### ✅ 最佳實踐

1. **只對「計算昂貴」的更新使用 transition**
   - 大量資料過濾
   - 複雜元件樹渲染
   - 會觸發 Suspense 的內容切換

2. **useDeferredValue vs useTransition 選擇指南**
   ```jsx
   // 當你「控制」狀態更新時 → useTransition
   const [isPending, startTransition] = useTransition()
   startTransition(() => setState(newValue))

   // 當你「接收」已存在的值時 → useDeferredValue
   // 例如：從 props 傳入、從 context 取得
   const deferredValue = useDeferredValue(propValue)
   ```

3. **搭配 isPending 提供視覺回饋**
   ```jsx
   <div style={{ 
     opacity: isPending ? 0.7 : 1,
     pointerEvents: isPending ? 'none' : 'auto'
   }}>
     {content}
   </div>
   ```

4. **useMemo 搭配 useDeferredValue 避免重複計算**
   ```jsx
   const deferredQuery = useDeferredValue(query)
   const results = useMemo(
     () => expensiveFilter(data, deferredQuery),
     [data, deferredQuery]  // 只在 deferredQuery 變化時重算
   )
   ```

## 面試考點

### Q1: useTransition 和 useDeferredValue 有什麼差別？什麼時候用哪個？

**答：**
- `useTransition`：當你主動觸發狀態更新，想將某些更新標記為「可被中斷」時使用。回傳 `isPending` 狀態和 `startTransition` 函式。
- `useDeferredValue`：當你接收一個值（從 props、context 等），想要延遲這個值的更新時使用。回傳延遲版本的值。

簡單判斷：控制更新來源用 `useTransition`，控制更新消費用 `useDeferredValue`。

### Q2: 為什麼不能在 startTransition 裡面更新受控輸入的值？

**答：**
因為 transition 是「可被中斷」的低優先級更新。如果把輸入值放在 transition 中更新，使用者的每次按鍵都可能被延遲處理，導致輸入體驗非常差。

正確做法是分離兩個狀態：一個即時更新的「顯示值」給輸入框，一個用 transition 更新的「搜尋值」給資料過濾。

### Q3: Concurrent Features 和 debounce/throttle 有什麼不同？

**答：**
- **Debounce/Throttle**：延遲執行，時間到了才觸發，無論 UI 是否閒置
- **Concurrent Features**：立即開始執行，但可被中斷。如果 UI 閒置，馬上完成；如果有新輸入，立即中斷舊工作

Concurrent Features 更智慧，因為它根據實際狀況調整，而不是固定等待時間。在快速裝置上幾乎無延遲，在慢速裝置上自動降級。

## 延伸學習

1. **React 18 Concurrent Rendering 深入原理**
   - 了解 Fiber 架構如何實現可中斷渲染
   - Time Slicing 的運作機制

2. **Suspense for Data Fetching**
   - 搭配 React Server Components
   - 使用 TanStack Query 或 SWR 的 Suspense 模式

3. **效能量測與優化**
   - 使用 React DevTools Profiler 找出渲染瓶頸
   - Scheduling API (`scheduler` package) 進階控制
