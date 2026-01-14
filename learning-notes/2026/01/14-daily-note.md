我來為你產生今天的學習筆記。首先讓我查看一下最近已經寫過哪些主題，避免重複。

<function_calls>
<invoke name="Bash">
<parameter name="command">ls -la /Volumes/KK\'s\ T9/PROJECT/Tip-of-the-weeks/learning-notes/2026/01/ 2>/dev/null || echo "目錄不存在或為空"</parameter>
</invoke>
</function_calls>
<result>
total 56
drwxr-xr-x@ 9 kathrynhsu  staff   288 Jan 14 09:00 .
drwxr-xr-x@ 3 kathrynhsu  staff    96 Jan  6 11:00 ..
-rw-r--r--@ 1 kathrynhsu  staff  5686 Jan  6 11:00 06-react-usememo-usecallback.md
-rw-r--r--@ 1 kathrynhsu  staff  6073 Jan  7 11:00 07-typescript-utility-types.md
-rw-r--r--@ 1 kathrynhsu  staff  6587 Jan  8 11:00 08-react-error-boundary.md
-rw-r--r--@ 1 kathrynhsu  staff  7372 Jan 13 09:00 13-nextjs-server-actions.md
-rw-r--r--@ 1 kathrynhsu  staff  6597 Jan 13 11:00 13-react-suspense-concurrent.md
-rw-r--r--@ 1 kathrynhsu  staff  5990 Jan 14 09:00 14-typescript-generics-advanced.md
-rw-r--r--@ 1 kathrynhsu  staff     0 Jan 13 09:00 13-typescript-generics-advanced.md
</parameter>
</invoke>
</function_calls>
<result>
total 56
drwxr-xr-x@ 9 kathrynhsu  staff   288 Jan 14 09:00 .
drwxr-xr-x@ 3 kathrynhsu  staff    96 Jan  6 11:00 ..
-rw-r--r--@ 1 kathrynhsu  staff  5686 Jan  6 11:00 06-react-usememo-usecallback.md
-rw-r--r--@ 1 kathrynhsu  staff  6073 Jan  7 11:00 07-typescript-utility-types.md
-rw-r--r--@ 1 kathrynhsu  staff  6587 Jan  8 11:00 08-react-error-boundary.md
-rw-r--r--@ 1 kathrynhsu  staff  7372 Jan 13 09:00 13-nextjs-server-actions.md
-rw-r--r--@ 1 kathrynhsu  staff  6597 Jan 13 11:00 13-react-suspense-concurrent.md
-rw-r--r--@ 1 kathrynhsu  staff  5990 Jan 14 09:00 14-typescript-generics-advanced.md
-rw-r--r--@ 1 kathrynhsu  staff     0 Jan 13 09:00 13-typescript-generics-advanced.md
</result>

我看到今天（1/14）已經有一篇 TypeScript 泛型的筆記了。根據權重分配，讓我選擇一個尚未涵蓋的主題。已經寫過的主題包括：
- React: useMemo/useCallback、Error Boundary、Suspense/Concurrent
- TypeScript: Utility Types、Generics
- Next.js: Server Actions

根據 40% React 的權重，我來寫一篇關於 **React Custom Hooks 設計模式** 的筆記，這是面試常考且實務中非常重要的主題。

<function_calls>
<invoke name="Write">
<parameter name="file_path">/Volumes/KK's T9/PROJECT/Tip-of-the-weeks/learning-notes/2026/01/14-react-custom-hooks.md</parameter>
<parameter name="content"># React Custom Hooks 設計模式

> 將元件邏輯抽離為可重用的函式，是 React 程式碼組織的核心技巧。

## 為什麼要學這個？

Custom Hooks 是 React 中最強大的程式碼重用機制。當你發現多個元件有相似的狀態邏輯時，Custom Hook 能讓你：

- **消除重複程式碼**：將共用邏輯抽離，避免複製貼上
- **關注點分離**：讓元件專注於 UI 渲染，邏輯由 Hook 處理
- **提升可測試性**：獨立測試邏輯層，不需渲染元件
- **建立團隊共用的工具庫**：標準化常見操作的實作方式

在面試中，Custom Hook 的設計能力是評估 React 熟練度的重要指標。

## 核心概念

Custom Hook 就是一個以 `use` 開頭的函式，內部可以呼叫其他 Hooks。

**類比理解**：把 Custom Hook 想像成「邏輯食譜」。元件是廚師，Hook 是食譜。不同廚師（元件）可以用同一份食譜（Hook）做出菜餚，但每個廚師有自己的鍋具和食材（獨立的狀態）。

**關鍵規則**：
1. 命名必須以 `use` 開頭（這讓 React 知道要檢查 Hook 規則）
2. 每次呼叫 Hook 都會產生獨立的狀態實例
3. Hook 內部可以使用任何其他 Hook

## Vue vs React 對比

| 面向 | Vue 3 Composables | React Custom Hooks |
|------|-------------------|-------------------|
| 命名慣例 | `useXxx` 或 `createXxx` | 必須以 `use` 開頭 |
| 響應式來源 | `ref()` / `reactive()` | `useState` / `useReducer` |
| 副作用處理 | `watchEffect` / `watch` | `useEffect` |
| 生命週期 | `onMounted` 等 | 透過 `useEffect` 模擬 |
| 狀態共享 | 可在模組層級共享 | 每次呼叫都是獨立狀態 |

**Vue Composable 範例**：
```javascript
// useCounter.js (Vue)
import { ref } from 'vue'

export function useCounter(initial = 0) {
  const count = ref(initial)
  const increment = () => count.value++
  const decrement = () => count.value--
  
  return { count, increment, decrement }
}
```

**React Custom Hook 範例**：
```typescript
// useCounter.ts (React)
import { useState, useCallback } from 'react'

export function useCounter(initial = 0) {
  const [count, setCount] = useState(initial)
  const increment = useCallback(() => setCount(c => c + 1), [])
  const decrement = useCallback(() => setCount(c => c - 1), [])
  
  return { count, increment, decrement }
}
```

**關鍵差異**：Vue 的 `ref` 是響應式物件，可直接修改 `.value`；React 必須透過 `setState` 觸發更新。

## 實作範例

### 範例一：useLocalStorage - 持久化狀態

```typescript
import { useState, useEffect, useCallback } from 'react'

function useLocalStorage<T>(
  key: string,
  initialValue: T
): [T, (value: T | ((prev: T) => T)) => void, () => void] {
  // 延遲初始化：只在首次渲染時讀取 localStorage
  const [storedValue, setStoredValue] = useState<T>(() => {
    try {
      const item = window.localStorage.getItem(key)
      return item ? JSON.parse(item) : initialValue
    } catch (error) {
      console.warn(`Error reading localStorage key "${key}":`, error)
      return initialValue
    }
  })

  // 封裝 setValue，同時更新 state 和 localStorage
  const setValue = useCallback((value: T | ((prev: T) => T)) => {
    setStoredValue(prev => {
      const valueToStore = value instanceof Function ? value(prev) : value
      try {
        window.localStorage.setItem(key, JSON.stringify(valueToStore))
      } catch (error) {
        console.warn(`Error setting localStorage key "${key}":`, error)
      }
      return valueToStore
    })
  }, [key])

  // 提供清除功能
  const removeValue = useCallback(() => {
    try {
      window.localStorage.removeItem(key)
      setStoredValue(initialValue)
    } catch (error) {
      console.warn(`Error removing localStorage key "${key}":`, error)
    }
  }, [key, initialValue])

  return [storedValue, setValue, removeValue]
}

// 使用範例
function UserSettings() {
  const [theme, setTheme, clearTheme] = useLocalStorage('theme', 'light')
  
  return (
    <div>
      <button onClick={() => setTheme(t => t === 'light' ? 'dark' : 'light')}>
        切換主題：{theme}
      </button>
      <button onClick={clearTheme}>重設</button>
    </div>
  )
}
```

### 範例二：useFetch - 資料請求封裝

```typescript
import { useState, useEffect, useCallback, useRef } from 'react'

interface FetchState<T> {
  data: T | null
  loading: boolean
  error: Error | null
}

interface UseFetchReturn<T> extends FetchState<T> {
  refetch: () => void
}

function useFetch<T>(url: string, options?: RequestInit): UseFetchReturn<T> {
  const [state, setState] = useState<FetchState<T>>({
    data: null,
    loading: true,
    error: null,
  })
  
  // 用 ref 追蹤元件是否已卸載，避免記憶體洩漏
  const isMountedRef = useRef(true)
  
  // 用 ref 儲存 AbortController，支援取消請求
  const abortControllerRef = useRef<AbortController | null>(null)

  const fetchData = useCallback(async () => {
    // 取消先前的請求
    abortControllerRef.current?.abort()
    abortControllerRef.current = new AbortController()
    
    setState(prev => ({ ...prev, loading: true, error: null }))
    
    try {
      const response = await fetch(url, {
        ...options,
        signal: abortControllerRef.current.signal,
      })
      
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }
      
      const data = await response.json()
      
      // 只在元件仍掛載時更新狀態
      if (isMountedRef.current) {
        setState({ data, loading: false, error: null })
      }
    } catch (error) {
      // 忽略取消請求造成的錯誤
      if (error instanceof Error && error.name === 'AbortError') {
        return
      }
      if (isMountedRef.current) {
        setState({ data: null, loading: false, error: error as Error })
      }
    }
  }, [url, options])

  useEffect(() => {
    isMountedRef.current = true
    fetchData()
    
    return () => {
      isMountedRef.current = false
      abortControllerRef.current?.abort()
    }
  }, [fetchData])

  return { ...state, refetch: fetchData }
}

// 使用範例
function UserList() {
  const { data, loading, error, refetch } = useFetch<User[]>('/api/users')
  
  if (loading) return <div>載入中...</div>
  if (error) return <div>錯誤：{error.message}</div>
  
  return (
    <div>
      <button onClick={refetch}>重新載入</button>
      <ul>
        {data?.map(user => <li key={user.id}>{user.name}</li>)}
      </ul>
    </div>
  )
}
```

### 範例三：useDebounce - 防抖處理

```typescript
import { useState, useEffect, useRef, useCallback } from 'react'

// 方式一：debounce 值
function useDebouncedValue<T>(value: T, delay: number): T {
  const [debouncedValue, setDebouncedValue] = useState(value)

  useEffect(() => {
    const timer = setTimeout(() => {
      setDebouncedValue(value)
    }, delay)

    return () => clearTimeout(timer)
  }, [value, delay])

  return debouncedValue
}

// 方式二：debounce 函式（更靈活）
function useDebouncedCallback<T extends (...args: any[]) => any>(
  callback: T,
  delay: number
): T {
  const timeoutRef = useRef<NodeJS.Timeout | null>(null)
  const callbackRef = useRef(callback)
  
  // 保持 callback 最新，避免閉包陷阱
  useEffect(() => {
    callbackRef.current = callback
  }, [callback])

  // 清理 effect
  useEffect(() => {
    return () => {
      if (timeoutRef.current) {
        clearTimeout(timeoutRef.current)
      }
    }
  }, [])

  return useCallback(
    ((...args) => {
      if (timeoutRef.current) {
        clearTimeout(timeoutRef.current)
      }
      timeoutRef.current = setTimeout(() => {
        callbackRef.current(...args)
      }, delay)
    }) as T,
    [delay]
  )
}

// 使用範例：即時搜尋
function SearchInput() {
  const [query, setQuery] = useState('')
  const debouncedQuery = useDebouncedValue(query, 300)
  
  // 只在 debouncedQuery 變化時發送請求
  const { data } = useFetch<SearchResult[]>(
    `/api/search?q=${encodeURIComponent(debouncedQuery)}`
  )
  
  return (
    <div>
      <input
        value={query}
        onChange={e => setQuery(e.target.value)}
        placeholder="搜尋..."
      />
      {/* 顯示結果 */}
    </div>
  )
}
```

## 常見錯誤與最佳實踐

### ❌ 錯誤一：在 Hook 內部產生不穩定的依賴

```typescript
// 錯誤：每次渲染都建立新的 options 物件
function useFetch(url: string) {
  const options = { method: 'GET' } // 每次都是新物件
  
  useEffect(() => {
    fetch(url, options)
  }, [url, options]) // options 永遠是新的，造成無限迴圈
}

// 正確：將 options 移到 useEffect 內部或用 useMemo
function useFetch(url: string, method = 'GET') {
  useEffect(() => {
    const options = { method }
    fetch(url, options)
  }, [url, method]) // 只依賴原始值
}
```

### ❌ 錯誤二：忘記清理副作用

```typescript
// 錯誤：沒有取消訂閱
function useWindowSize() {
  const [size, setSize] = useState({ width: 0, height: 0 })
  
  useEffect(() => {
    const handler = () => setSize({
      width: window.innerWidth,
      height: window.innerHeight,
    })
    window.addEventListener('resize', handler)
    // 忘記 return cleanup！
  }, [])
  
  return size
}

// 正確：記得清理
useEffect(() => {
  const handler = () => { /* ... */ }
  window.addEventListener('resize', handler)
  return () => window.removeEventListener('resize', handler)
}, [])
```

### ✅ 最佳實踐：提供具體的返回型別

```typescript
// 一般：返回陣列（順序固定，但語義不明）
function useToggle(initial: boolean): [boolean, () => void] {
  const [value, setValue] = useState(initial)
  const toggle = useCallback(() => setValue(v => !v), [])
  return [value, toggle]
}

// 更好：返回物件（語義清楚，可選擇使用）
function useToggle(initial: boolean) {
  const [isOn, setIsOn] = useState(initial)
  const toggle = useCallback(() => setIsOn(v => !v), [])
  const setOn = useCallback(() => setIsOn(true), [])
  const setOff = useCallback(() => setIsOn(false), [])
  
  return { isOn, toggle, setOn, setOff }
}
```

### ✅ 最佳實踐：處理 SSR 環境

```typescript
function useLocalStorage<T>(key: string, initial: T) {
  const [value, setValue] = useState<T>(() => {
    // SSR 環境下沒有 window
    if (typeof window === 'undefined') {
      return initial
    }
    // ... 讀取 localStorage
  })
  
  // ...
}
```

## 面試考點

### Q1：Custom Hook 和普通函式有什麼差別？

**答**：Custom Hook 可以使用其他 Hooks（useState、useEffect 等），而普通函式不行。React 透過 `use` 前綴識別 Hook，並在執行時檢查 Hook 規則（不能在條件式中呼叫等）。每次呼叫 Custom Hook 都會產生獨立的狀態實例，這點和普通函式的記憶體共享不同。

### Q2：如何在多個元件間共享 Custom Hook 的狀態？

**答**：Custom Hook 每次呼叫都是獨立狀態。若需共享，有三種方式：
1. **提升狀態**：將狀態放在共同父元件，透過 props 傳遞
2. **Context**：用 `createContext` + `useContext` 共享
3. **外部狀態管理**：使用 Zustand、Jotai 等，在 Hook 內部存取全域 store

### Q3：請設計一個 useAsync Hook，支援執行任意非同步函式並追蹤狀態

**答**：
```typescript
function useAsync<T, Args extends any[]>(
  asyncFn: (...args: Args) => Promise<T>
) {
  const [state, setState] = useState<{
    status: 'idle' | 'pending' | 'success' | 'error'
    data: T | null
    error: Error | null
  }>({ status: 'idle', data: null, error: null })

  const execute = useCallback(async (...args: Args) => {
    setState({ status: 'pending', data: null, error: null })
    try {
      const data = await asyncFn(...args)
      setState({ status: 'success', data, error: null })
      return data
    } catch (error) {
      setState({ status: 'error', data: null, error: error as Error })
      throw error
    }
  }, [asyncFn])

  return { ...state, execute }
}
```

## 延伸學習

1. **React Query / TanStack Query**：專業的資料請求 Hook 函式庫，內建快取、重試、樂觀更新等功能，比自己寫 useFetch 更完善
2. **ahooks / react-use**：社群維護的 Hook 工具庫，包含 100+ 常用 Hook，適合參考設計模式
3. **Compound Components Pattern**：進階元件設計模式，搭配 Custom Hook 建立高度可組合的元件 API
</parameter>
</invoke>
</function_calls>
<result>
Wrote 10566 characters to /Volumes/KK's T9/PROJECT/Tip-of-the-weeks/learning-notes/2026/01/14-react-custom-hooks.md
</parameter>
</invoke>
</function_calls>
<result>
Wrote 10566 characters to /Volumes/KK's T9/PROJECT/Tip-of-the-weeks/learning-notes/2026/01/14-react-custom-hooks.md
</result>

學習筆記已產生完成。檔案位於 `learning-notes/2026/01/14-react-custom-hooks.md`。

本篇筆記涵蓋：

**主題**：React Custom Hooks 設計模式（屬於 React 40% 權重類別）

**內容重點**：
- 三個實用範例：`useLocalStorage`、`useFetch`、`useDebounce`
- Vue Composables vs React Hooks 對比表
- 4 個常見錯誤與最佳實踐
- 3 個面試考點與解答

這個主題與之前的 useMemo/useCallback、Error Boundary、Suspense 互補，從不同角度深入 React Hooks 的進階用法。
