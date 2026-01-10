# React 條件渲染與列表渲染模式

> 掌握 React 中 JSX 的渲染控制，是寫出乾淨、高效能元件的基礎。

## 為什麼要學這個？

條件渲染與列表渲染是每個 React 開發者每天都會用到的基本功。與 Vue 使用 `v-if`、`v-for` 等指令不同，React 完全依賴 JavaScript 原生表達式來處理這些邏輯。理解這些模式不僅能讓你寫出更簡潔的程式碼，更能避免常見的效能陷阱與 bug。

**應用場景：**
- 根據使用者權限顯示不同 UI
- 載入狀態、錯誤狀態、空狀態的切換
- 動態渲染資料列表（商品清單、留言列表等）
- 表單欄位的動態顯示/隱藏

## 核心概念

### 條件渲染

React 的條件渲染就是 JavaScript 的條件判斷——沒有特殊語法，只有你熟悉的 `if`、三元運算子、`&&` 邏輯運算。

**類比理解：** 如果 Vue 的 `v-if` 是「內建的遙控器按鈕」，React 的條件渲染就是「自己用 JavaScript 接線」——更靈活，但也需要更清楚電路原理。

### 列表渲染

React 使用 `Array.map()` 將資料陣列轉換成元素陣列。關鍵在於 `key` 屬性——這是 React 用來追蹤元素身份的識別碼，直接影響渲染效能與正確性。

## Vue vs React 對比

| 功能 | Vue | React |
|------|-----|-------|
| 條件渲染 | `v-if` / `v-else` / `v-show` | `if`、`&&`、三元運算子 |
| 列表渲染 | `v-for="item in items"` | `items.map(item => ...)` |
| 列表 key | `:key="item.id"` | `key={item.id}` |
| 隱藏元素 | `v-show`（CSS display） | 需自行實作 style 或 className |

```vue
<!-- Vue 的做法 -->
<template>
  <div v-if="isLoading">載入中...</div>
  <div v-else-if="error">發生錯誤</div>
  <ul v-else>
    <li v-for="item in items" :key="item.id">
      {{ item.name }}
    </li>
  </ul>
</template>
```

```tsx
// React 的做法
function ItemList({ isLoading, error, items }) {
  if (isLoading) return <div>載入中...</div>;
  if (error) return <div>發生錯誤</div>;
  
  return (
    <ul>
      {items.map(item => (
        <li key={item.id}>{item.name}</li>
      ))}
    </ul>
  );
}
```

## 實作範例

### 範例一：基礎條件渲染模式

```tsx
// 條件渲染的四種常見模式

interface UserProps {
  isLoggedIn: boolean;
  isAdmin: boolean;
  notifications: number;
  user?: { name: string };
}

function UserPanel({ isLoggedIn, isAdmin, notifications, user }: UserProps) {
  // 模式 1: Early Return（提前返回）
  // 適合：整個元件根據條件完全不同時
  if (!isLoggedIn) {
    return <button>請先登入</button>;
  }

  return (
    <div>
      {/* 模式 2: 三元運算子 */}
      {/* 適合：兩種狀態的切換 */}
      <span>{isAdmin ? '👑 管理員' : '👤 一般用戶'}</span>

      {/* 模式 3: && 短路運算 */}
      {/* 適合：有/無的單純判斷 */}
      {notifications > 0 && (
        <span className="badge">{notifications}</span>
      )}

      {/* 模式 4: Optional Chaining 搭配 Nullish Coalescing */}
      {/* 適合：處理可能為 undefined/null 的資料 */}
      <p>歡迎，{user?.name ?? '訪客'}</p>
    </div>
  );
}
```

### 範例二：進階列表渲染與 Key 策略

```tsx
interface Task {
  id: string;
  title: string;
  completed: boolean;
  priority: 'high' | 'medium' | 'low';
}

interface TaskListProps {
  tasks: Task[];
  filter: 'all' | 'active' | 'completed';
}

function TaskList({ tasks, filter }: TaskListProps) {
  // 先過濾、再排序、最後渲染
  // 這種 chain 操作在 React 中很常見
  const filteredTasks = tasks
    .filter(task => {
      if (filter === 'all') return true;
      if (filter === 'active') return !task.completed;
      return task.completed;
    })
    .sort((a, b) => {
      // 高優先級排前面
      const priority = { high: 0, medium: 1, low: 2 };
      return priority[a.priority] - priority[b.priority];
    });

  // 空狀態處理——別忘了這個常被忽略的 UX
  if (filteredTasks.length === 0) {
    return (
      <div className="empty-state">
        <p>🎉 沒有任務！</p>
      </div>
    );
  }

  return (
    <ul>
      {filteredTasks.map(task => (
        // ✅ key 使用穩定且唯一的 id
        // ❌ 不要用 index，除非列表永不變動
        <li 
          key={task.id}
          className={task.completed ? 'completed' : ''}
        >
          <TaskItem task={task} />
        </li>
      ))}
    </ul>
  );
}

// 將列表項目抽成獨立元件，有助於效能優化
function TaskItem({ task }: { task: Task }) {
  return (
    <div>
      <input type="checkbox" checked={task.completed} readOnly />
      <span>{task.title}</span>
      <span className={`priority-${task.priority}`}>
        {task.priority}
      </span>
    </div>
  );
}
```

### 範例三：複雜狀態的渲染模式

```tsx
// 使用 Discriminated Union 處理複雜的非同步狀態
// 這種模式比多個 boolean flag 更安全

type AsyncState<T> =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: T }
  | { status: 'error'; error: Error };

interface Product {
  id: string;
  name: string;
  price: number;
}

function ProductPage() {
  const [state, setState] = useState<AsyncState<Product[]>>({ 
    status: 'idle' 
  });

  // 渲染函式：使用 switch 處理所有可能狀態
  // TypeScript 會確保你處理了所有 case
  const renderContent = () => {
    switch (state.status) {
      case 'idle':
        return <button onClick={fetchProducts}>載入商品</button>;
      
      case 'loading':
        return <LoadingSpinner />;
      
      case 'success':
        // 在 success case 中，TypeScript 知道 data 一定存在
        return (
          <div>
            {state.data.length === 0 ? (
              <EmptyState message="目前沒有商品" />
            ) : (
              <ProductGrid products={state.data} />
            )}
          </div>
        );
      
      case 'error':
        // 在 error case 中，TypeScript 知道 error 一定存在
        return (
          <ErrorMessage 
            message={state.error.message}
            onRetry={fetchProducts}
          />
        );
      
      // exhaustive check：如果漏了任何 case，TypeScript 會報錯
      default:
        const _exhaustive: never = state;
        return null;
    }
  };

  return (
    <main>
      <h1>商品列表</h1>
      {renderContent()}
    </main>
  );
}
```

## 常見錯誤與最佳實踐

### ❌ 錯誤 1：使用 index 作為 key

```tsx
// ❌ 不好：當列表順序改變或有增刪時，會導致錯誤的元件重用
{items.map((item, index) => (
  <Item key={index} data={item} />
))}

// ✅ 好：使用穩定且唯一的識別碼
{items.map(item => (
  <Item key={item.id} data={item} />
))}
```

**為什麼重要：** React 用 key 來判斷哪些元素需要更新。錯誤的 key 會導致狀態錯亂、動畫異常、效能下降。

### ❌ 錯誤 2：&& 運算子遇到 0 的陷阱

```tsx
// ❌ 危險：當 count 為 0 時，會渲染出 "0"
{count && <span>{count} 則通知</span>}

// ✅ 安全：明確轉換成 boolean
{count > 0 && <span>{count} 則通知</span>}

// ✅ 或使用三元運算子
{count ? <span>{count} 則通知</span> : null}
```

### ❌ 錯誤 3：在 render 中直接過濾/排序大量資料

```tsx
// ❌ 不好：每次 render 都重新計算
function ProductList({ products, sortBy }) {
  return (
    <ul>
      {products
        .filter(p => p.inStock)
        .sort((a, b) => a[sortBy] - b[sortBy])
        .map(p => <ProductItem key={p.id} product={p} />)}
    </ul>
  );
}

// ✅ 好：使用 useMemo 快取計算結果
function ProductList({ products, sortBy }) {
  const displayProducts = useMemo(() => {
    return products
      .filter(p => p.inStock)
      .sort((a, b) => a[sortBy] - b[sortBy]);
  }, [products, sortBy]);

  return (
    <ul>
      {displayProducts.map(p => (
        <ProductItem key={p.id} product={p} />
      ))}
    </ul>
  );
}
```

### ✅ 最佳實踐：元件拆分與 React.memo

```tsx
// 將列表項目拆成獨立元件，搭配 React.memo 避免不必要的重新渲染
const ProductItem = React.memo(function ProductItem({ 
  product 
}: { 
  product: Product 
}) {
  return (
    <li>
      <h3>{product.name}</h3>
      <p>${product.price}</p>
    </li>
  );
});
```

### ✅ 最佳實踐：為空狀態提供良好 UX

```tsx
// 永遠考慮：載入中、錯誤、空資料三種狀態
function CommentSection({ postId }) {
  const { data, isLoading, error } = useComments(postId);
  
  if (isLoading) return <CommentSkeleton count={3} />;
  if (error) return <ErrorMessage error={error} />;
  if (data.length === 0) return <EmptyComments />;
  
  return <CommentList comments={data} />;
}
```

## 面試考點

### Q1：為什麼 React 列表渲染需要 key？使用 index 作為 key 會有什麼問題？

**簡答：**
- `key` 幫助 React 識別哪些元素改變、新增或移除，是 Reconciliation 演算法的關鍵
- 使用 index 作為 key 的問題：
  1. 當列表順序改變時，React 會錯誤地重用元件實例
  2. 導致非受控元件（如 input）的內部狀態錯亂
  3. 動畫效果異常
  4. 效能下降（無法正確判斷哪些項目需要更新）
- 正確做法：使用資料中穩定且唯一的識別碼（如資料庫 ID）

### Q2：比較 `v-if` 和 React 條件渲染，各有什麼優缺點？

**簡答：**

| 面向 | Vue v-if | React 條件渲染 |
|------|----------|---------------|
| 學習曲線 | 較低，指令語法直覺 | 需熟悉 JS 表達式 |
| 靈活性 | 受限於模板語法 | 完全 JavaScript，無限靈活 |
| 可維護性 | 模板結構清晰 | 複雜邏輯可能導致 JSX 難讀 |
| 型別安全 | 需額外設定 | 天然支援 TypeScript |
| 最佳實踐 | 使用 v-if/v-else 鏈 | 使用 Early Return 或抽取 render 函式 |

### Q3：如何優化大量列表的渲染效能？

**簡答：**
1. **使用正確的 key**：確保 key 穩定且唯一
2. **元件拆分 + React.memo**：將列表項目抽成獨立元件，用 memo 包裝
3. **useMemo 快取計算**：filter、sort 等操作結果應快取
4. **虛擬滾動**：大量資料使用 react-window 或 react-virtualized
5. **分頁/無限滾動**：避免一次渲染所有資料

## 延伸學習

1. **React Reconciliation 演算法深入**
   - 理解 Fiber 架構如何處理列表 diff
   - 官方文件：[Reconciliation](https://react.dev/learn/preserving-and-resetting-state)

2. **虛擬滾動實作**
   - `react-window`：輕量級虛擬滾動
   - `@tanstack/react-virtual`：功能更完整的方案
   - 適合處理上千筆資料的列表

3. **Suspense 與 Concurrent Features**
   - React 18 的 Suspense 如何改變載入狀態處理
   - 使用 `<Suspense>` 宣告式處理載入狀態
   - 搭配 React Server Components 的資料取得模式
