# React useReducer Hook：複雜狀態邏輯的優雅解決方案

> 當 useState 不再足夠，useReducer 讓你用 Redux 的思維管理元件內的複雜狀態。

## 為什麼要學這個？

在實際專案中，你會經常遇到這些情況：
- 表單有多個欄位且彼此有關聯驗證
- 狀態更新邏輯變得複雜，充滿 if-else
- 多個 useState 開始互相依賴，難以追蹤

`useReducer` 是 React 內建的 Hook，它提供了一種更結構化的方式來管理複雜狀態。如果你未來要學 Redux，這更是必備的前置知識——兩者的核心概念幾乎一致。

## 核心概念

### Reducer 模式的本質

想像你是一家餐廳的廚房：
- **State（狀態）**：目前廚房的所有食材和半成品
- **Action（動作）**：服務生送來的點餐單（包含餐點類型和細節）
- **Reducer（處理器）**：廚師根據點餐單和現有食材，產出新的餐點狀態
- **Dispatch（派發）**：服務生送單的動作

```
新狀態 = reducer(當前狀態, 動作)
```

這是一個**純函式**：相同的輸入永遠產生相同的輸出，不會有副作用。

### 基本語法結構

```typescript
const [state, dispatch] = useReducer(reducer, initialState);
```

## Vue vs React 對比

| 面向 | Vue 3 (Pinia/Vuex) | React (useReducer) |
|------|-------------------|-------------------|
| 定義狀態 | `state: () => ({...})` | `initialState` 物件 |
| 修改方式 | `actions` + 直接修改 | `dispatch(action)` + reducer 純函式 |
| 異步處理 | 直接在 actions 中處理 | 需搭配 useEffect 或 middleware |
| 可變性 | Proxy 響應式（可變） | 不可變更新（immutable） |

### Vue 的做法（Pinia）

```typescript
// Vue + Pinia
export const useCounterStore = defineStore('counter', {
  state: () => ({ count: 0, history: [] }),
  actions: {
    increment() {
      this.count++  // 直接修改
      this.history.push('increment')
    }
  }
})
```

### React 的做法（useReducer）

```typescript
// React + useReducer
function reducer(state, action) {
  switch (action.type) {
    case 'increment':
      return {  // 回傳新物件
        count: state.count + 1,
        history: [...state.history, 'increment']
      }
    default:
      return state
  }
}
```

**關鍵差異**：Vue 允許直接修改狀態（靠 Proxy 追蹤），React 強制回傳新狀態物件（靠引用比較觸發更新）。

## 實作範例

### 範例一：基礎計數器

```tsx
import { useReducer } from 'react';

// 1. 定義狀態型別
type CounterState = {
  count: number;
};

// 2. 定義 Action 型別（使用 Discriminated Union）
type CounterAction = 
  | { type: 'increment' }
  | { type: 'decrement' }
  | { type: 'reset' }
  | { type: 'set'; payload: number };

// 3. 初始狀態
const initialState: CounterState = { count: 0 };

// 4. Reducer 函式：根據 action 類型決定如何更新狀態
function counterReducer(state: CounterState, action: CounterAction): CounterState {
  switch (action.type) {
    case 'increment':
      return { count: state.count + 1 };
    case 'decrement':
      return { count: state.count - 1 };
    case 'reset':
      return initialState;
    case 'set':
      return { count: action.payload };
    default:
      // TypeScript 會確保所有 case 都被處理
      const _exhaustive: never = action;
      return state;
  }
}

function Counter() {
  const [state, dispatch] = useReducer(counterReducer, initialState);

  return (
    <div>
      <p>Count: {state.count}</p>
      <button onClick={() => dispatch({ type: 'increment' })}>+1</button>
      <button onClick={() => dispatch({ type: 'decrement' })}>-1</button>
      <button onClick={() => dispatch({ type: 'reset' })}>重置</button>
      <button onClick={() => dispatch({ type: 'set', payload: 100 })}>設為 100</button>
    </div>
  );
}
```

### 範例二：表單狀態管理

```tsx
import { useReducer, FormEvent } from 'react';

// 表單狀態型別
type FormState = {
  values: {
    email: string;
    password: string;
    confirmPassword: string;
  };
  errors: {
    email?: string;
    password?: string;
    confirmPassword?: string;
  };
  isSubmitting: boolean;
  isValid: boolean;
};

// Action 型別
type FormAction =
  | { type: 'SET_FIELD'; field: keyof FormState['values']; value: string }
  | { type: 'SET_ERROR'; field: keyof FormState['errors']; error: string }
  | { type: 'CLEAR_ERRORS' }
  | { type: 'SUBMIT_START' }
  | { type: 'SUBMIT_SUCCESS' }
  | { type: 'SUBMIT_ERROR' }
  | { type: 'RESET' };

const initialFormState: FormState = {
  values: { email: '', password: '', confirmPassword: '' },
  errors: {},
  isSubmitting: false,
  isValid: false,
};

// 驗證邏輯抽離為純函式
function validateForm(values: FormState['values']): FormState['errors'] {
  const errors: FormState['errors'] = {};
  
  if (!values.email.includes('@')) {
    errors.email = '請輸入有效的 Email';
  }
  if (values.password.length < 8) {
    errors.password = '密碼至少需要 8 個字元';
  }
  if (values.password !== values.confirmPassword) {
    errors.confirmPassword = '密碼確認不一致';
  }
  
  return errors;
}

function formReducer(state: FormState, action: FormAction): FormState {
  switch (action.type) {
    case 'SET_FIELD': {
      const newValues = {
        ...state.values,
        [action.field]: action.value,
      };
      const errors = validateForm(newValues);
      return {
        ...state,
        values: newValues,
        errors,
        isValid: Object.keys(errors).length === 0,
      };
    }
    case 'SET_ERROR':
      return {
        ...state,
        errors: { ...state.errors, [action.field]: action.error },
        isValid: false,
      };
    case 'CLEAR_ERRORS':
      return { ...state, errors: {}, isValid: true };
    case 'SUBMIT_START':
      return { ...state, isSubmitting: true };
    case 'SUBMIT_SUCCESS':
      return { ...initialFormState }; // 重置表單
    case 'SUBMIT_ERROR':
      return { ...state, isSubmitting: false };
    case 'RESET':
      return initialFormState;
    default:
      return state;
  }
}

function RegistrationForm() {
  const [state, dispatch] = useReducer(formReducer, initialFormState);

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    if (!state.isValid) return;

    dispatch({ type: 'SUBMIT_START' });
    
    try {
      await fakeApiCall(state.values);
      dispatch({ type: 'SUBMIT_SUCCESS' });
    } catch {
      dispatch({ type: 'SUBMIT_ERROR' });
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <div>
        <input
          type="email"
          value={state.values.email}
          onChange={(e) => dispatch({
            type: 'SET_FIELD',
            field: 'email',
            value: e.target.value,
          })}
          placeholder="Email"
        />
        {state.errors.email && <span className="error">{state.errors.email}</span>}
      </div>
      
      <div>
        <input
          type="password"
          value={state.values.password}
          onChange={(e) => dispatch({
            type: 'SET_FIELD',
            field: 'password',
            value: e.target.value,
          })}
          placeholder="密碼"
        />
        {state.errors.password && <span className="error">{state.errors.password}</span>}
      </div>
      
      <div>
        <input
          type="password"
          value={state.values.confirmPassword}
          onChange={(e) => dispatch({
            type: 'SET_FIELD',
            field: 'confirmPassword',
            value: e.target.value,
          })}
          placeholder="確認密碼"
        />
        {state.errors.confirmPassword && (
          <span className="error">{state.errors.confirmPassword}</span>
        )}
      </div>

      <button type="submit" disabled={!state.isValid || state.isSubmitting}>
        {state.isSubmitting ? '提交中...' : '註冊'}
      </button>
    </form>
  );
}
```

### 範例三：搭配 Context 實現跨元件狀態共享

```tsx
import { createContext, useContext, useReducer, ReactNode, Dispatch } from 'react';

// 購物車狀態
type CartItem = {
  id: string;
  name: string;
  price: number;
  quantity: number;
};

type CartState = {
  items: CartItem[];
  total: number;
};

type CartAction =
  | { type: 'ADD_ITEM'; item: Omit<CartItem, 'quantity'> }
  | { type: 'REMOVE_ITEM'; id: string }
  | { type: 'UPDATE_QUANTITY'; id: string; quantity: number }
  | { type: 'CLEAR_CART' };

const initialCartState: CartState = {
  items: [],
  total: 0,
};

// 計算總價的輔助函式
function calculateTotal(items: CartItem[]): number {
  return items.reduce((sum, item) => sum + item.price * item.quantity, 0);
}

function cartReducer(state: CartState, action: CartAction): CartState {
  switch (action.type) {
    case 'ADD_ITEM': {
      const existingIndex = state.items.findIndex(
        (item) => item.id === action.item.id
      );

      let newItems: CartItem[];
      
      if (existingIndex >= 0) {
        // 已存在，增加數量
        newItems = state.items.map((item, index) =>
          index === existingIndex
            ? { ...item, quantity: item.quantity + 1 }
            : item
        );
      } else {
        // 新增商品
        newItems = [...state.items, { ...action.item, quantity: 1 }];
      }

      return {
        items: newItems,
        total: calculateTotal(newItems),
      };
    }

    case 'REMOVE_ITEM': {
      const newItems = state.items.filter((item) => item.id !== action.id);
      return {
        items: newItems,
        total: calculateTotal(newItems),
      };
    }

    case 'UPDATE_QUANTITY': {
      if (action.quantity <= 0) {
        // 數量為 0 時移除商品
        return cartReducer(state, { type: 'REMOVE_ITEM', id: action.id });
      }

      const newItems = state.items.map((item) =>
        item.id === action.id ? { ...item, quantity: action.quantity } : item
      );

      return {
        items: newItems,
        total: calculateTotal(newItems),
      };
    }

    case 'CLEAR_CART':
      return initialCartState;

    default:
      return state;
  }
}

// 建立 Context
const CartContext = createContext<{
  state: CartState;
  dispatch: Dispatch<CartAction>;
} | null>(null);

// Provider 元件
export function CartProvider({ children }: { children: ReactNode }) {
  const [state, dispatch] = useReducer(cartReducer, initialCartState);

  return (
    <CartContext.Provider value={{ state, dispatch }}>
      {children}
    </CartContext.Provider>
  );
}

// 自定義 Hook：封裝 Context 使用邏輯
export function useCart() {
  const context = useContext(CartContext);
  if (!context) {
    throw new Error('useCart 必須在 CartProvider 內使用');
  }

  const { state, dispatch } = context;

  // 封裝常用操作，提供更友善的 API
  return {
    items: state.items,
    total: state.total,
    itemCount: state.items.reduce((sum, item) => sum + item.quantity, 0),
    addItem: (item: Omit<CartItem, 'quantity'>) =>
      dispatch({ type: 'ADD_ITEM', item }),
    removeItem: (id: string) =>
      dispatch({ type: 'REMOVE_ITEM', id }),
    updateQuantity: (id: string, quantity: number) =>
      dispatch({ type: 'UPDATE_QUANTITY', id, quantity }),
    clearCart: () =>
      dispatch({ type: 'CLEAR_CART' }),
  };
}

// 使用範例
function ProductCard({ product }: { product: { id: string; name: string; price: number } }) {
  const { addItem } = useCart();

  return (
    <div className="product-card">
      <h3>{product.name}</h3>
      <p>${product.price}</p>
      <button onClick={() => addItem(product)}>加入購物車</button>
    </div>
  );
}

function CartSummary() {
  const { items, total, updateQuantity, removeItem, clearCart } = useCart();

  if (items.length === 0) {
    return <p>購物車是空的</p>;
  }

  return (
    <div>
      {items.map((item) => (
        <div key={item.id}>
          <span>{item.name}</span>
          <input
            type="number"
            value={item.quantity}
            onChange={(e) => updateQuantity(item.id, parseInt(e.target.value, 10))}
            min="0"
          />
          <button onClick={() => removeItem(item.id)}>刪除</button>
        </div>
      ))}
      <p>總計：${total}</p>
      <button onClick={clearCart}>清空購物車</button>
    </div>
  );
}
```

## 常見錯誤與最佳實踐

### ❌ 錯誤 1：直接修改 state

```tsx
// 錯誤：直接修改原物件
function reducer(state, action) {
  state.count++; // ❌ React 偵測不到變化
  return state;
}

// 正確：回傳新物件
function reducer(state, action) {
  return { ...state, count: state.count + 1 }; // ✅
}
```

### ❌ 錯誤 2：在 Reducer 中執行副作用

```tsx
// 錯誤：在 reducer 中呼叫 API
function reducer(state, action) {
  if (action.type === 'FETCH') {
    fetch('/api/data'); // ❌ Reducer 應該是純函式
  }
  return state;
}

// 正確：副作用放在 useEffect 或事件處理
function Component() {
  const [state, dispatch] = useReducer(reducer, initialState);

  useEffect(() => {
    fetch('/api/data')
      .then(res => res.json())
      .then(data => dispatch({ type: 'SET_DATA', payload: data }));
  }, []);
}
```

### ❌ 錯誤 3：Action type 使用字串字面值

```tsx
// 不推薦：容易打錯字
dispatch({ type: 'ICREMENT' }); // typo 不會報錯

// 推薦：使用常數或 TypeScript 列舉
const ActionTypes = {
  INCREMENT: 'INCREMENT',
  DECREMENT: 'DECREMENT',
} as const;

// 或使用 Discriminated Union（TypeScript 會檢查）
type Action = { type: 'INCREMENT' } | { type: 'DECREMENT' };
```

### ✅ 最佳實踐 1：使用 Immer 簡化不可變更新

```tsx
import { useImmerReducer } from 'use-immer';

function reducer(draft, action) {
  switch (action.type) {
    case 'ADD_TODO':
      // 可以「直接修改」，Immer 會處理不可變性
      draft.todos.push(action.payload);
      break;
    case 'TOGGLE_TODO':
      const todo = draft.todos.find(t => t.id === action.id);
      if (todo) todo.completed = !todo.completed;
      break;
  }
}
```

### ✅ 最佳實踐 2：狀態初始化函式（Lazy Initialization）

```tsx
// 當初始狀態需要複雜計算時
function init(initialCount: number): CounterState {
  // 這個函式只在首次渲染時執行
  return { count: initialCount };
}

function Counter({ initialCount }: { initialCount: number }) {
  // 第三個參數是初始化函式
  const [state, dispatch] = useReducer(reducer, initialCount, init);
}
```

## 面試考點

### Q1：什麼時候該用 useState，什麼時候該用 useReducer？

**簡答**：

| 使用 useState | 使用 useReducer |
|--------------|----------------|
| 狀態簡單（布林、數字、字串） | 狀態是物件或陣列且邏輯複雜 |
| 狀態更新邏輯簡單 | 多個狀態更新有關聯 |
| 狀態更新不依賴前一個狀態 | 需要根據不同動作做不同處理 |

經驗法則：當你發現 `useState` 的 setter 開始寫一堆 if-else，就該考慮 `useReducer`。

### Q2：useReducer 的 dispatch 是否穩定？可以放進 dependency array 嗎？

**簡答**：`dispatch` 函式的引用是**穩定的**（類似 `useRef`），在元件的整個生命週期中不會改變。因此：
- 不需要放入 `useEffect` 的 dependency array
- 可以安全地傳遞給子元件，不會造成不必要的 re-render

### Q3：如何讓 useReducer 處理非同步操作？

**簡答**：Reducer 本身必須是純函式，非同步操作有以下處理方式：

1. **在元件中使用 useEffect**：dispatch 同步 action，在 effect 中處理非同步
2. **自定義 middleware 模式**：包裝 dispatch 函式
3. **使用第三方方案**：如 `useReducer` + `useEffect` 封裝成自定義 Hook

```tsx
// 常見模式
const fetchData = async () => {
  dispatch({ type: 'FETCH_START' });
  try {
    const data = await api.getData();
    dispatch({ type: 'FETCH_SUCCESS', payload: data });
  } catch (error) {
    dispatch({ type: 'FETCH_ERROR', error });
  }
};
```

## 延伸學習

1. **Redux Toolkit**
   - 當 useReducer + Context 無法滿足需求時，Redux 是下一步
   - RTK 大幅簡化了樣板程式碼，內建 Immer

2. **XState（狀態機）**
   - 當狀態轉換有嚴格規則時（如：只能從 A → B → C）
   - 視覺化狀態圖，適合複雜的 UI 流程

3. **React Query / SWR（伺服器狀態）**
   - 專門處理「伺服器狀態」的快取、同步、更新
   - 讓 useReducer 專注於「客戶端狀態」

---

*撰寫日期：2026-01-09*
