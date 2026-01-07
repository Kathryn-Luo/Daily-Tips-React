# React useTransition：打造流暢的使用者體驗

> `useTransition` 讓你將狀態更新標記為「可中斷的低優先級任務」，確保 UI 在處理複雜計算時仍保持回應。

## 為什麼要學這個？

在現代 Web 應用中，使用者期待即時回饋。當你有一個搜尋功能需要過濾上千筆資料，或是複雜的表單驗證，傳統的同步更新會讓整個 UI 凍結。

`useTransition` 是 React 18 引入的 Concurrent Features 之一，它解決了一個關鍵問題：**如何在處理繁重任務時，仍讓使用者感覺應用是流暢的？**

常見應用場景：
- 搜尋過濾大量資料
- Tab 切換時載入複雜內容
- 導航時的頁面轉場
- 即時預覽功能

## 核心概念

想像你在餐廳點餐。服務生（React）收到你的訂單後，有兩種處理方式：

1. **傳統方式**：等廚房做完整道菜才回應你 → UI 凍結
2. **useTransition 方式**：先告訴你「正在準備中」，然後背景處理 → UI 保持回應

```typescript
const [isPending, startTransition] = useTransition();
```

- `isPending`：布林值，表示轉場是否正在進行
- `startTransition`：函數，用來包裝「可以延遲」的狀態更新

**關鍵概念：優先級**

React 18 將更新分為兩種優先級：
- **緊急更新（Urgent）**：打字、點擊、按鍵 → 需要立即回饋
- **轉場更新（Transition）**：畫面切換、資料過濾 → 可以稍微延遲

## Vue vs React 對比

| 面向 | Vue 3 | React 18 |
|------|-------|----------|
| 概念名稱 | 無直接對應 | useTransition |
| 類似實作 | `nextTick` + 手動 loading 狀態 | 內建優先級排程 |
| 非同步更新 | 預設批次更新 | Concurrent Rendering |

**Vue 的做法**（需要手動管理）：

```vue
<script setup lang="ts">
import { ref, nextTick } from 'vue'

const isLoading = ref(false)
const searchResults = ref<string[]>([])

async function handleSearch(query: string) {
  isLoading.value = true
  await nextTick() // 讓 loading 狀態先渲染
  
  // 模擬繁重計算
  const results = heavyComputation(query)
  searchResults.value = results
  isLoading.value = false
}
</script>
```

**React 的做法**（原生支援）：

```tsx
import { useState, useTransition } from 'react';

function SearchComponent() {
  const [isPending, startTransition] = useTransition();
  const [searchResults, setSearchResults] = useState<string[]>([]);

  function handleSearch(query: string) {
    startTransition(() => {
      // 這個更新會被標記為低優先級
      const results = heavyComputation(query);
      setSearchResults(results);
    });
  }

  return (
    <>
      {isPending && <Spinner />}
      <ResultList results={searchResults} />
    </>
  );
}
```

React 的優勢在於：框架層級的優先級排程，不需要手動管理 `nextTick` 時機。

## 實作範例

### 範例 1：基礎 Tab 切換

```tsx
import { useState, useTransition } from 'react';

type Tab = 'home' | 'posts' | 'settings';

function TabContainer() {
  const [activeTab, setActiveTab] = useState<Tab>('home');
  const [isPending, startTransition] = useTransition();

  function handleTabChange(tab: Tab) {
    // Tab 按鈕的視覺回饋是緊急的，不包在 startTransition 裡
    // 但內容渲染可以延遲
    startTransition(() => {
      setActiveTab(tab);
    });
  }

  return (
    <div>
      <nav>
        {(['home', 'posts', 'settings'] as Tab[]).map((tab) => (
          <button
            key={tab}
            onClick={() => handleTabChange(tab)}
            className={activeTab === tab ? 'active' : ''}
          >
            {tab}
          </button>
        ))}
      </nav>

      {/* isPending 時顯示過渡效果，而非完全阻擋互動 */}
      <div style={{ opacity: isPending ? 0.7 : 1 }}>
        <TabContent tab={activeTab} />
      </div>
    </div>
  );
}

// 假設這是一個渲染成本很高的元件
function TabContent({ tab }: { tab: Tab }) {
  // 模擬複雜渲染
  const items = Array.from({ length: 5000 }, (_, i) => (
    <div key={i}>{tab} - Item {i}</div>
  ));
  
  return <div>{items}</div>;
}
```

### 範例 2：搜尋過濾大量資料

```tsx
import { useState, useTransition, useMemo } from 'react';

interface Product {
  id: number;
  name: string;
  category: string;
}

// 假設有 10000 筆產品資料
const allProducts: Product[] = generateProducts(10000);

function ProductSearch() {
  // 輸入框的值 - 需要即時更新（緊急）
  const [inputValue, setInputValue] = useState('');
  // 過濾條件 - 可以延遲更新（轉場）
  const [filterQuery, setFilterQuery] = useState('');
  const [isPending, startTransition] = useTransition();

  // 根據 filterQuery 過濾產品（繁重計算）
  const filteredProducts = useMemo(() => {
    if (!filterQuery) return allProducts.slice(0, 100);
    
    return allProducts.filter((product) =>
      product.name.toLowerCase().includes(filterQuery.toLowerCase())
    );
  }, [filterQuery]);

  function handleInputChange(e: React.ChangeEvent<HTMLInputElement>) {
    const value = e.target.value;
    
    // 輸入框立即更新 - 使用者打字要有即時回饋
    setInputValue(value);
    
    // 過濾結果延遲更新 - 包在 startTransition 裡
    startTransition(() => {
      setFilterQuery(value);
    });
  }

  return (
    <div>
      <input
        type="text"
        value={inputValue}
        onChange={handleInputChange}
        placeholder="搜尋產品..."
      />
      
      {isPending && (
        <div className="searching-indicator">
          搜尋中...
        </div>
      )}

      <ul style={{ opacity: isPending ? 0.6 : 1 }}>
        {filteredProducts.map((product) => (
          <li key={product.id}>{product.name}</li>
        ))}
      </ul>
    </div>
  );
}
```

### 範例 3：搭配 Suspense 的頁面導航

```tsx
import { useState, useTransition, Suspense, lazy } from 'react';

// 動態載入的頁面元件
const HomePage = lazy(() => import('./pages/HomePage'));
const DashboardPage = lazy(() => import('./pages/DashboardPage'));
const SettingsPage = lazy(() => import('./pages/SettingsPage'));

type Route = 'home' | 'dashboard' | 'settings';

const routes: Record<Route, React.LazyExoticComponent<React.FC>> = {
  home: HomePage,
  dashboard: DashboardPage,
  settings: SettingsPage,
};

function App() {
  const [currentRoute, setCurrentRoute] = useState<Route>('home');
  const [isPending, startTransition] = useTransition();

  function navigate(route: Route) {
    startTransition(() => {
      setCurrentRoute(route);
    });
  }

  const CurrentPage = routes[currentRoute];

  return (
    <div>
      <nav>
        <button 
          onClick={() => navigate('home')}
          disabled={isPending}
        >
          首頁
        </button>
        <button 
          onClick={() => navigate('dashboard')}
          disabled={isPending}
        >
          儀表板
        </button>
        <button 
          onClick={() => navigate('settings')}
          disabled={isPending}
        >
          設定
        </button>
        
        {/* 導航時的 loading 指示器 */}
        {isPending && <span className="nav-spinner">🔄</span>}
      </nav>

      {/* Suspense 處理 lazy loading 的 fallback */}
      <Suspense fallback={<PageSkeleton />}>
        <CurrentPage />
      </Suspense>
    </div>
  );
}

function PageSkeleton() {
  return <div className="skeleton">載入頁面中...</div>;
}
```

## 常見錯誤與最佳實踐

### ❌ 錯誤 1：把緊急更新包在 startTransition 裡

```tsx
// 錯誤：輸入框的值也被延遲了，打字會卡頓
function BadExample() {
  const [value, setValue] = useState('');
  const [isPending, startTransition] = useTransition();

  return (
    <input
      value={value}
      onChange={(e) => {
        startTransition(() => {
          setValue(e.target.value); // ❌ 這會讓打字延遲
        });
      }}
    />
  );
}
```

### ✅ 正確：分離緊急與非緊急狀態

```tsx
function GoodExample() {
  const [inputValue, setInputValue] = useState('');
  const [deferredValue, setDeferredValue] = useState('');
  const [isPending, startTransition] = useTransition();

  return (
    <input
      value={inputValue}
      onChange={(e) => {
        setInputValue(e.target.value); // ✅ 立即更新
        startTransition(() => {
          setDeferredValue(e.target.value); // ✅ 延遲更新
        });
      }}
    />
  );
}
```

### ❌ 錯誤 2：在 startTransition 中執行非同步操作

```tsx
// 錯誤：startTransition 不支援 async/await
startTransition(async () => {
  const data = await fetchData(); // ❌ 這不會正確運作
  setData(data);
});
```

### ✅ 正確：非同步操作在外面，只有 setState 在裡面

```tsx
async function handleClick() {
  const data = await fetchData(); // ✅ 非同步在外面
  
  startTransition(() => {
    setData(data); // ✅ 只有同步的 setState
  });
}
```

### 最佳實踐：何時使用 useTransition vs useDeferredValue

```tsx
// useTransition：你控制狀態更新的來源
const [isPending, startTransition] = useTransition();
startTransition(() => setFilter(newFilter));

// useDeferredValue：你只能讀取值，無法控制更新來源
const deferredQuery = useDeferredValue(externalQuery);
```

## 面試考點

### Q1：useTransition 和 debounce 有什麼差別？

**簡答**：
- `debounce`：延遲執行，等使用者停止輸入後才更新，可能感覺「卡」
- `useTransition`：立即開始更新，但標記為可中斷；如果有新的更新進來，會放棄舊的計算

`useTransition` 的優勢是「不會延遲開始」，而是「允許被中斷」，體驗更流暢。

### Q2：startTransition 裡面可以放非同步函數嗎？

**簡答**：
不行。`startTransition` 的 callback 必須是同步的。如果需要處理非同步資料，應該先 `await` 完成後，再在 `startTransition` 裡設定狀態。

若需要在 data fetching 時使用類似功能，可以考慮 React 19 的 `useActionState` 或搭配 Suspense。

### Q3：什麼情況下不應該使用 useTransition？

**簡答**：
1. 更新本身就很快（< 100ms），沒必要增加複雜度
2. 需要即時回饋的互動（打字、拖曳、動畫）
3. 在不支援 Concurrent Features 的舊版 React（< 18）

## 延伸學習

1. **useDeferredValue**：當你無法控制狀態來源時的替代方案，常與第三方函式庫搭配

2. **Suspense for Data Fetching**：結合 `useTransition` 打造更完整的載入體驗

3. **React Server Components**：了解 Server/Client 邊界如何影響 Concurrent Features 的使用
