# React 自訂 Hooks：打造可重用的邏輯封裝

> 將元件邏輯抽離成可重用的函式，是 React 開發中最強大的程式碼組織模式。

## 為什麼要學這個？

在實際專案開發中，你會發現許多元件共享相似的邏輯：表單驗證、資料獲取、事件監聽、本地儲存同步等。如果每個元件都重複撰寫這些邏輯，不僅造成程式碼冗餘，維護成本也會急劇上升。

自訂 Hooks 讓你能將這些重複邏輯抽離成獨立函式，在多個元件間共享，同時保持程式碼的可測試性與可讀性。這是 React 函數式元件架構的核心優勢之一。

## 核心概念

自訂 Hook 本質上就是一個以 `use` 開頭的函式，內部可以呼叫其他 Hooks。這個命名慣例讓 React 能夠自動檢查 Hooks 規則。

你可以把自訂 Hook 想像成「邏輯元件」——它不回傳 JSX，而是回傳狀態與操作函式。就像你把 UI 拆分成小元件一樣，自訂 Hook 讓你把邏輯拆分成小單元。

**關鍵原則：**
- 每次呼叫 Hook 都會獲得獨立的狀態
- Hook 之間可以傳遞資料
- Hook 的名稱必須以 `use` 開頭

## Vue vs React 對比

| 面向 | Vue 3 Composables | React Custom Hooks |
|------|-------------------|-------------------|
| 命名慣例 | `useXxx` 或任意名稱 | 必須以 `use` 開頭 |
| 響應性 | 使用 `ref`/`reactive` | 使用 `useState`/`useReducer` |
| 生命週期 | `onMounted`、`onUnmounted` | `useEffect` 統一處理 |
| 依賴追蹤 | 自動追蹤 | 手動宣告依賴陣列 |

**Vue Composable 範例：**
```javascript
// useCounter.js (Vue)
import { ref } from 'vue'

export function useCounter(initialValue = 0) {
  const count = ref(initialValue)
  const increment = () => count.value++
  const decrement = () => count.value--
  
  return { count, increment, decrement }
}
```

**React Hook 範例：**
```javascript
// useCounter.js (React)
import { useState, useCallback } from 'react'

export function useCounter(initialValue = 0) {
  const [count, setCount] = useState(initialValue)
  const increment = useCallback(() => setCount(c => c + 1), [])
  const decrement = useCallback(() => setCount(c => c - 1), [])
  
  return { count, increment, decrement }
}
```

主要差異在於 Vue 的響應性是自動追蹤的，而 React 需要明確使用 `useCallback` 來避免不必要的重新渲染。

## 實作範例

### 範例一：基礎 - useLocalStorage

將狀態與 localStorage 同步，頁面重整後資料仍然保留。

```typescript
import { useState, useEffect } from 'react'

function useLocalStorage<T>(key: string, initialValue: T) {
  // 初始化時從 localStorage 讀取，若無則使用預設值
  const [storedValue, setStoredValue] = useState<T>(() => {
    try {
      const item = window.localStorage.getItem(key)
      return item ? JSON.parse(item) : initialValue
    } catch (error) {
      console.warn(`Error reading localStorage key "${key}":`, error)
      return initialValue
    }
  })

  // 當值改變時同步到 localStorage
  useEffect(() => {
    try {
      window.localStorage.setItem(key, JSON.stringify(storedValue))
    } catch (error) {
      console.warn(`Error setting localStorage key "${key}":`, error)
    }
  }, [key, storedValue])

  return [storedValue, setStoredValue] as const
}

// 使用方式
function SettingsPanel() {
  const [theme, setTheme] = useLocalStorage('theme', 'light')
  
  return (
    <button onClick={() => setTheme(theme === 'light' ? 'dark' : 'light')}>
      目前主題：{theme}
    </button>
  )
}
```

### 範例二：進階 - useFetch

封裝資料獲取邏輯，包含載入狀態與錯誤處理。

```typescript
import { useState, useEffect, useCallback } from 'react'

interface FetchState<T> {
  data: T | null
  loading: boolean
  error: Error | null
}

function useFetch<T>(url: string, options?: RequestInit) {
  const [state, setState] = useState<FetchState<T>>({
    data: null,
    loading: true,
    error: null,
  })

  // 重新獲取資料的函式
  const refetch = useCallback(async () => {
    setState(prev => ({ ...prev, loading: true, error: null }))
    
    try {
      const response = await fetch(url, options)
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }
      const data = await response.json()
      setState({ data, loading: false, error: null })
    } catch (error) {
      setState({ data: null, loading: false, error: error as Error })
    }
  }, [url, options])

  // 初次載入與 URL 改變時自動獲取
  useEffect(() => {
    refetch()
  }, [refetch])

  return { ...state, refetch }
}

// 使用方式
function UserProfile({ userId }: { userId: string }) {
  const { data: user, loading, error, refetch } = useFetch<User>(
    `/api/users/${userId}`
  )

  if (loading) return <div>載入中...</div>
  if (error) return <div>錯誤：{error.message}</div>

  return (
    <div>
      <h1>{user?.name}</h1>
      <button onClick={refetch}>重新整理</button>
    </div>
  )
}
```

### 範例三：複合應用 - useForm

結合多個 Hooks 建構表單管理邏輯。

```typescript
import { useState, useCallback, ChangeEvent, FormEvent } from 'react'

interface UseFormOptions<T> {
  initialValues: T
  validate?: (values: T) => Partial<Record<keyof T, string>>
  onSubmit: (values: T) => void | Promise<void>
}

function useForm<T extends Record<string, any>>({
  initialValues,
  validate,
  onSubmit,
}: UseFormOptions<T>) {
  const [values, setValues] = useState<T>(initialValues)
  const [errors, setErrors] = useState<Partial<Record<keyof T, string>>>({})
  const [isSubmitting, setIsSubmitting] = useState(false)

  // 處理欄位變更
  const handleChange = useCallback((
    e: ChangeEvent<HTMLInputElement | HTMLTextAreaElement>
  ) => {
    const { name, value } = e.target
    setValues(prev => ({ ...prev, [name]: value }))
    // 清除該欄位的錯誤
    setErrors(prev => ({ ...prev, [name]: undefined }))
  }, [])

  // 處理表單送出
  const handleSubmit = useCallback(async (e: FormEvent) => {
    e.preventDefault()
    
    // 執行驗證
    if (validate) {
      const validationErrors = validate(values)
      if (Object.keys(validationErrors).length > 0) {
        setErrors(validationErrors)
        return
      }
    }

    setIsSubmitting(true)
    try {
      await onSubmit(values)
    } finally {
      setIsSubmitting(false)
    }
  }, [values, validate, onSubmit])

  // 重置表單
  const reset = useCallback(() => {
    setValues(initialValues)
    setErrors({})
  }, [initialValues])

  return {
    values,
    errors,
    isSubmitting,
    handleChange,
    handleSubmit,
    reset,
    setValues,
  }
}

// 使用方式
function LoginForm() {
  const { values, errors, isSubmitting, handleChange, handleSubmit } = useForm({
    initialValues: { email: '', password: '' },
    validate: (values) => {
      const errors: Record<string, string> = {}
      if (!values.email) errors.email = '請輸入 Email'
      if (!values.password) errors.password = '請輸入密碼'
      return errors
    },
    onSubmit: async (values) => {
      await loginAPI(values)
    },
  })

  return (
    <form onSubmit={handleSubmit}>
      <input
        name="email"
        value={values.email}
        onChange={handleChange}
      />
      {errors.email && <span>{errors.email}</span>}
      
      <input
        name="password"
        type="password"
        value={values.password}
        onChange={handleChange}
      />
      {errors.password && <span>{errors.password}</span>}
      
      <button type="submit" disabled={isSubmitting}>
        {isSubmitting ? '登入中...' : '登入'}
      </button>
    </form>
  )
}
```

## 常見錯誤與最佳實踐

### ❌ 錯誤一：在條件式中呼叫 Hook

```javascript
// 錯誤！違反 Hooks 規則
function Component({ isEnabled }) {
  if (isEnabled) {
    const [value, setValue] = useState(0) // 不可以！
  }
}

// 正確做法
function Component({ isEnabled }) {
  const [value, setValue] = useState(0)
  // 在使用時判斷條件
  if (!isEnabled) return null
}
```

### ❌ 錯誤二：忘記處理 cleanup

```javascript
// 錯誤！可能造成記憶體洩漏
function useWindowSize() {
  const [size, setSize] = useState({ width: 0, height: 0 })
  
  useEffect(() => {
    const handler = () => setSize({
      width: window.innerWidth,
      height: window.innerHeight,
    })
    window.addEventListener('resize', handler)
    // 忘記清除監聽器！
  }, [])
}

// 正確做法
useEffect(() => {
  const handler = () => { /* ... */ }
  window.addEventListener('resize', handler)
  return () => window.removeEventListener('resize', handler) // cleanup
}, [])
```

### ✅ 最佳實踐一：回傳穩定的物件結構

```javascript
// 使用 useMemo 避免每次渲染都建立新物件
function useAuth() {
  const [user, setUser] = useState(null)
  const [loading, setLoading] = useState(true)
  
  const actions = useMemo(() => ({
    login: async (credentials) => { /* ... */ },
    logout: async () => { /* ... */ },
  }), [])
  
  return { user, loading, ...actions }
}
```

### ✅ 最佳實踐二：提供合理的預設值與型別

```typescript
// 明確的泛型與預設值讓 Hook 更易用
function useToggle(initialValue = false) {
  const [value, setValue] = useState(initialValue)
  
  const toggle = useCallback(() => setValue(v => !v), [])
  const setTrue = useCallback(() => setValue(true), [])
  const setFalse = useCallback(() => setValue(false), [])
  
  return [value, { toggle, setTrue, setFalse }] as const
}
```

### ✅ 最佳實踐三：將複雜邏輯拆分成多個小 Hook

```javascript
// 大型 Hook 應拆分成可組合的小 Hook
function useShoppingCart() {
  const items = useCartItems()
  const { total, discount } = useCartCalculations(items)
  const { checkout, isProcessing } = useCheckout(items)
  
  return { items, total, discount, checkout, isProcessing }
}
```

## 面試考點

### Q1：自訂 Hook 與一般函式有什麼差別？

**答：** 自訂 Hook 必須以 `use` 開頭，且內部可以使用其他 Hooks（useState、useEffect 等）。一般函式若使用 Hooks 會違反 Hooks 規則。命名慣例讓 React 和 ESLint 能檢查是否正確使用 Hooks。此外，每個元件呼叫同一個自訂 Hook 時，會獲得完全獨立的狀態副本。

### Q2：如何在自訂 Hook 中處理競態條件（Race Condition）？

**答：** 在 useFetch 類型的 Hook 中，若快速切換參數，可能導致舊請求的回應覆蓋新請求。解決方式是使用 cleanup function 設置取消標記：

```javascript
useEffect(() => {
  let cancelled = false
  
  fetchData().then(data => {
    if (!cancelled) setData(data)
  })
  
  return () => { cancelled = true }
}, [url])
```

或使用 AbortController 實際取消請求。

### Q3：什麼時候應該把邏輯抽成自訂 Hook？

**答：** 當符合以下條件時考慮抽離：
1. 相同邏輯在兩個以上元件重複出現
2. 元件邏輯過於複雜，需要拆分以提高可讀性
3. 邏輯需要獨立測試
4. 想要在邏輯層面進行抽象與復用

不應該為了「看起來整齊」而過度抽離簡單邏輯。

## 延伸學習

1. **useReducer 搭配自訂 Hook**：處理複雜狀態邏輯時，結合 useReducer 可以讓狀態管理更有條理
2. **React Query / SWR**：了解這些資料獲取函式庫如何設計 Hooks API，學習業界最佳實踐
3. **Testing Custom Hooks**：使用 `@testing-library/react-hooks` 進行 Hook 單元測試，確保邏輯正確性
