# React useCallback 與 useMemo：效能優化的雙刀流

> 掌握 React 記憶化技巧，避免不必要的重新渲染與計算，是從「能用 React」到「用好 React」的關鍵跨越。

## 為什麼要學這個？

在 React 中，元件重新渲染是家常便飯。每當 state 或 props 改變，元件就會重新執行，這意味著：

1. **函式會被重新建立**：每次渲染都產生新的函式引用
2. **計算會被重新執行**：即使輸入沒變，複雜計算也會重跑

這在小型應用問題不大，但當你面對：
- 傳遞 callback 給使用 `React.memo` 的子元件
- 處理大型列表渲染
- 執行複雜的資料轉換或過濾

效能問題就會浮現。`useCallback` 和 `useMemo` 正是 React 提供的記憶化工具，讓你精準控制「什麼該重新計算，什麼該保持穩定」。

## 核心概念

### 類比理解

想像你是一位廚師：

- **useMemo** 像是「備料區」：把切好的菜放在一旁，只有食材變了才重新切。記憶的是「計算結果」。
- **useCallback** 像是「食譜卡」：把做菜步驟寫在卡片上重複使用，不用每次都重新想。記憶的是「函式本身」。

### 技術定義

```typescript
// useMemo：記憶計算結果
const memoizedValue = useMemo(() => computeExpensiveValue(a, b), [a, b]);

// useCallback：記憶函式引用
const memoizedCallback = useCallback(() => {
  doSomething(a, b);
}, [a, b]);
```

**關鍵差異**：
- `useMemo(() => fn)` 回傳 `fn()` 的執行結果
- `useCallback(fn)` 回傳 `fn` 本身

實際上，`useCallback(fn, deps)` 等同於 `useMemo(() => fn, deps)`。

## Vue vs React 對比

| 面向 | Vue 3 | React |
|------|-------|-------|
| 計算值快取 | `computed()` | `useMemo()` |
| 函式引用穩定性 | 通常不需要（響應式系統處理） | `useCallback()` |
| 依賴追蹤 | 自動追蹤 | 手動指定依賴陣列 |
| 快取失效 | 依賴變化時自動失效 | 依賴陣列比較（淺比較） |

### Vue 開發者常見困惑

在 Vue 中，你幾乎不需要關心「函式引用是否穩定」，因為 Vue 的響應式系統會處理這些。但 React 不同：

```vue
<!-- Vue：這樣寫完全沒問題 -->
<template>
  <ChildComponent :onClick="handleClick" />
</template>

<script setup>
const handleClick = () => {
  console.log('clicked');
};
</script>
```

```tsx
// React：如果 ChildComponent 用了 React.memo，每次渲染都會觸發子元件更新
function Parent() {
  // ❌ 每次渲染都是新的函式引用
  const handleClick = () => {
    console.log('clicked');
  };
  
  return <ChildComponent onClick={handleClick} />;
}
```

## 實作範例

### 範例一：基礎 useMemo - 過濾大型列表

```tsx
import { useMemo, useState } from 'react';

interface Product {
  id: number;
  name: string;
  category: string;
  price: number;
}

function ProductList({ products }: { products: Product[] }) {
  const [searchTerm, setSearchTerm] = useState('');
  const [sortBy, setSortBy] = useState<'name' | 'price'>('name');
  const [unrelatedState, setUnrelatedState] = useState(0);

  // ✅ 使用 useMemo：只有 products、searchTerm 或 sortBy 變化時才重新計算
  const filteredAndSortedProducts = useMemo(() => {
    console.log('🔄 執行過濾與排序'); // 觀察這個 log 何時出現
    
    return products
      .filter(p => p.name.toLowerCase().includes(searchTerm.toLowerCase()))
      .sort((a, b) => {
        if (sortBy === 'name') return a.name.localeCompare(b.name);
        return a.price - b.price;
      });
  }, [products, searchTerm, sortBy]); // 依賴陣列

  return (
    <div>
      <input 
        value={searchTerm}
        onChange={e => setSearchTerm(e.target.value)}
        placeholder="搜尋產品..."
      />
      
      {/* 點擊這個按鈕不會觸發重新過濾 */}
      <button onClick={() => setUnrelatedState(n => n + 1)}>
        無關操作 ({unrelatedState})
      </button>
      
      <ul>
        {filteredAndSortedProducts.map(p => (
          <li key={p.id}>{p.name} - ${p.price}</li>
        ))}
      </ul>
    </div>
  );
}
```

### 範例二：useCallback 搭配 React.memo

```tsx
import { useCallback, useState, memo } from 'react';

// 使用 memo 包裝的子元件：只有 props 真正改變時才重新渲染
const ExpensiveChild = memo(function ExpensiveChild({ 
  onClick,
  label 
}: { 
  onClick: () => void;
  label: string;
}) {
  console.log(`🎨 ${label} 渲染了`);
  
  // 模擬複雜的渲染邏輯
  return (
    <button onClick={onClick}>
      {label}
    </button>
  );
});

function Parent() {
  const [count, setCount] = useState(0);
  const [name, setName] = useState('React');

  // ❌ 沒有用 useCallback：每次 Parent 渲染都產生新函式
  const handleClickBad = () => {
    console.log('Bad click');
  };

  // ✅ 使用 useCallback：函式引用保持穩定
  const handleClickGood = useCallback(() => {
    console.log('Good click');
  }, []); // 空依賴 = 永遠是同一個函式

  // ✅ 有依賴的 useCallback：只有 name 變化時才產生新函式
  const handleClickWithDep = useCallback(() => {
    console.log(`Hello, ${name}`);
  }, [name]);

  return (
    <div>
      <button onClick={() => setCount(c => c + 1)}>
        Count: {count}
      </button>
      <input value={name} onChange={e => setName(e.target.value)} />
      
      {/* 每次 count 改變都會重新渲染（因為 handleClickBad 每次都是新的） */}
      <ExpensiveChild onClick={handleClickBad} label="Bad" />
      
      {/* count 改變不會重新渲染（handleClickGood 引用穩定） */}
      <ExpensiveChild onClick={handleClickGood} label="Good" />
      
      {/* 只有 name 改變時才重新渲染 */}
      <ExpensiveChild onClick={handleClickWithDep} label="WithDep" />
    </div>
  );
}
```

### 範例三：進階模式 - 結合使用與 Context 優化

```tsx
import { 
  createContext, 
  useContext, 
  useCallback, 
  useMemo, 
  useState,
  ReactNode 
} from 'react';

interface Todo {
  id: number;
  text: string;
  completed: boolean;
}

interface TodoContextValue {
  todos: Todo[];
  addTodo: (text: string) => void;
  toggleTodo: (id: number) => void;
  stats: { total: number; completed: number; pending: number };
}

const TodoContext = createContext<TodoContextValue | null>(null);

export function TodoProvider({ children }: { children: ReactNode }) {
  const [todos, setTodos] = useState<Todo[]>([]);

  // ✅ 使用 useCallback 確保函式引用穩定
  // 這樣消費這些函式的子元件不會因為 Provider 重新渲染而跟著渲染
  const addTodo = useCallback((text: string) => {
    setTodos(prev => [
      ...prev,
      { id: Date.now(), text, completed: false }
    ]);
  }, []);

  const toggleTodo = useCallback((id: number) => {
    setTodos(prev =>
      prev.map(todo =>
        todo.id === id ? { ...todo, completed: !todo.completed } : todo
      )
    );
  }, []);

  // ✅ 使用 useMemo 計算衍生資料
  const stats = useMemo(() => ({
    total: todos.length,
    completed: todos.filter(t => t.completed).length,
    pending: todos.filter(t => !t.completed).length,
  }), [todos]);

  // ✅ 記憶整個 context value，避免每次渲染都產生新物件
  const value = useMemo<TodoContextValue>(() => ({
    todos,
    addTodo,
    toggleTodo,
    stats,
  }), [todos, addTodo, toggleTodo, stats]);

  return (
    <TodoContext.Provider value={value}>
      {children}
    </TodoContext.Provider>
  );
}

// 自訂 Hook
function useTodo() {
  const context = useContext(TodoContext);
  if (!context) {
    throw new Error('useTodo must be used within TodoProvider');
  }
  return context;
}
```

## 常見錯誤與最佳實踐

### ❌ 錯誤一：過度使用

```tsx
// ❌ 不需要記憶化的簡單計算
const doubled = useMemo(() => count * 2, [count]);

// ✅ 直接計算即可，useMemo 本身也有成本
const doubled = count * 2;
```

**原則**：只有在以下情況才使用記憶化：
- 計算真的很昂貴（大型陣列處理、複雜演算法）
- 需要穩定引用（傳給 memo 元件、作為其他 Hook 的依賴）

### ❌ 錯誤二：依賴陣列不完整

```tsx
// ❌ 忘記加入 userId，會使用舊的 userId 值
const fetchUser = useCallback(() => {
  return api.getUser(userId);
}, []); // 缺少 userId

// ✅ 正確的依賴陣列
const fetchUser = useCallback(() => {
  return api.getUser(userId);
}, [userId]);
```

**提示**：使用 ESLint 的 `react-hooks/exhaustive-deps` 規則，它會自動檢查依賴。

### ❌ 錯誤三：在依賴中使用物件或陣列字面值

```tsx
// ❌ options 每次都是新物件，useMemo 形同虛設
const result = useMemo(() => {
  return processData(data, options);
}, [data, { sort: true, limit: 10 }]); // 物件字面值！

// ✅ 方法一：將物件移到外部或使用 useMemo
const options = useMemo(() => ({ sort: true, limit: 10 }), []);
const result = useMemo(() => processData(data, options), [data, options]);

// ✅ 方法二：拆解成原始值
const result = useMemo(() => {
  return processData(data, { sort: true, limit: 10 });
}, [data]); // 如果 options 是固定的，就不需要作為依賴
```

### ❌ 錯誤四：忽略 useCallback 內的 stale closure

```tsx
function Counter() {
  const [count, setCount] = useState(0);

  // ❌ 永遠 log 0，因為 count 被閉包捕獲且永不更新
  const logCount = useCallback(() => {
    console.log(count);
  }, []);

  // ✅ 加入 count 作為依賴
  const logCount = useCallback(() => {
    console.log(count);
  }, [count]);

  // ✅ 或者使用 ref 來存取最新值（當你需要穩定引用又要最新值時）
  const countRef = useRef(count);
  countRef.current = count;
  
  const logCountStable = useCallback(() => {
    console.log(countRef.current);
  }, []);
}
```

### ✅ 最佳實踐：使用 React DevTools Profiler

在優化前，先用 Profiler 確認效能瓶頸在哪。不要憑感覺優化。

## 面試考點

### Q1: useCallback 和 useMemo 的差別是什麼？什麼時候該用哪個？

**簡答**：
- `useMemo` 記憶「計算結果」，用於避免昂貴的重複計算
- `useCallback` 記憶「函式本身」，用於保持函式引用穩定

使用時機：
- 當你需要快取計算結果 → `useMemo`
- 當你需要傳遞穩定的 callback 給子元件（特別是 memo 元件）→ `useCallback`

實際上 `useCallback(fn, deps)` 等價於 `useMemo(() => fn, deps)`。

### Q2: 為什麼不該對所有東西都使用 useMemo/useCallback？

**簡答**：
1. **記憶化本身有成本**：每次渲染都要比較依賴陣列
2. **增加程式碼複雜度**：更多的程式碼意味著更高的維護成本
3. **可能阻止垃圾回收**：記憶化的值會持續佔用記憶體

應該只在「測量後確認有效能問題」或「確實需要穩定引用」時才使用。

### Q3: 以下程式碼有什麼問題？如何修復？

```tsx
function SearchResults({ query }) {
  const [results, setResults] = useState([]);
  
  const fetchResults = useCallback(async () => {
    const data = await api.search(query);
    setResults(data);
  }, []); // 問題在這裡
  
  useEffect(() => {
    fetchResults();
  }, [fetchResults]);
  
  return <ResultList items={results} />;
}
```

**簡答**：
依賴陣列缺少 `query`，導致：
1. `fetchResults` 永遠使用第一次渲染時的 `query` 值（stale closure）
2. 即使 `query` 改變，也不會重新搜尋

修復：將 `query` 加入依賴陣列 `[query]`。

## 延伸學習

1. **React.memo 深入理解**
   - 了解 memo 的第二個參數（自訂比較函式）
   - 何時該用 memo，何時不該

2. **useRef 與記憶化的搭配**
   - 使用 ref 解決 stale closure 問題
   - 「最新值 callback」模式

3. **React Compiler（React Forget）**
   - React 團隊正在開發的自動記憶化編譯器
   - 未來可能不需要手動使用 useMemo/useCallback
   - 追蹤官方進度：[React Compiler 文件](https://react.dev/learn/react-compiler)
