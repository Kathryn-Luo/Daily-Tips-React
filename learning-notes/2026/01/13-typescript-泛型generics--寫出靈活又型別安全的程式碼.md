我來幫你產生今天的學習筆記。首先讓我查看一下已經寫過的主題，避免重複。

```bash
ls -la learning-notes/2026/01/ 2>/dev/null || echo "目錄可能不存在"
```

```bash
cat learning-notes/README.md | head -50
```

根據已有的筆記，我看到 React 相關的主題已經涵蓋了：
- useRef Hook
- useReducer Hook
- useLayoutEffect
- useCallback & useMemo

今天是 1/13，根據權重分配，這次可以寫一個 TypeScript 進階主題。讓我撰寫一篇關於 **TypeScript 泛型** 的學習筆記。

```markdown
# TypeScript 泛型（Generics）- 寫出靈活又型別安全的程式碼

> 泛型讓你的函式和元件能夠處理多種型別，同時保持完整的型別檢查。

## 為什麼要學這個？

在前端開發中，我們經常需要寫出「可重用」的程式碼。例如一個通用的 API 請求函式、一個可以處理各種資料型別的列表元件。如果沒有泛型，你只能：

1. 使用 `any` 放棄型別檢查（危險！）
2. 為每種型別寫一個重複的函式（累死！）

泛型（Generics）就是解決這個問題的利器。它讓你可以：
- 寫出適用於多種型別的函式或類別
- 保持完整的型別推導和檢查
- 在編譯時期就抓出型別錯誤

React 生態系中大量使用泛型，例如 `useState<T>`、`useReducer<S, A>`、React Query 的 `useQuery<TData, TError>`。掌握泛型是進入 TypeScript + React 專案的必備技能。

## 核心概念

### 什麼是泛型？

把泛型想像成「型別的參數」。就像函式可以接收值作為參數，泛型函式可以接收型別作為參數。

```typescript
// 一般函式：接收「值」作為參數
function identity(value: number): number {
  return value;
}

// 泛型函式：接收「型別」作為參數
function identity<T>(value: T): T {
  return value;
}
```

這裡的 `<T>` 就是型別參數，`T` 是慣例命名（代表 Type），你也可以用其他名字如 `<TData>`、`<U>` 等。

### 泛型的運作方式

```typescript
// 明確指定型別
const num = identity<number>(42);      // T = number
const str = identity<string>("hello"); // T = string

// 型別推導（TypeScript 自動推斷）
const num2 = identity(42);      // T 被推導為 number
const str2 = identity("hello"); // T 被推導為 string
```

## 實作範例

### 範例一：基礎泛型函式

```typescript
// ❌ 不好的做法：使用 any
function getFirstItem(arr: any[]): any {
  return arr[0];
}

const first = getFirstItem([1, 2, 3]); // first 的型別是 any，失去型別保護

// ✅ 好的做法：使用泛型
function getFirstItem<T>(arr: T[]): T | undefined {
  return arr[0];
}

const first = getFirstItem([1, 2, 3]);           // first: number | undefined
const firstStr = getFirstItem(["a", "b", "c"]); // firstStr: string | undefined

// 型別檢查正常運作
first.toFixed(2);     // ✅ number 方法
firstStr.toUpperCase(); // ✅ string 方法
```

### 範例二：多個型別參數與泛型約束

```typescript
// 多個型別參數
function createPair<K, V>(key: K, value: V): [K, V] {
  return [key, value];
}

const pair = createPair("age", 30); // [string, number]

// 泛型約束（extends）：限制 T 必須符合某個結構
interface HasLength {
  length: number;
}

// T 必須有 length 屬性
function logLength<T extends HasLength>(item: T): void {
  console.log(item.length);
}

logLength("hello");     // ✅ string 有 length
logLength([1, 2, 3]);   // ✅ array 有 length
logLength({ length: 10 }); // ✅ 物件有 length 屬性
logLength(123);         // ❌ 編譯錯誤：number 沒有 length

// 實用範例：從物件中取得屬性值
function getProperty<T, K extends keyof T>(obj: T, key: K): T[K] {
  return obj[key];
}

const user = { name: "Alice", age: 30 };
const name = getProperty(user, "name"); // string
const age = getProperty(user, "age");   // number
const foo = getProperty(user, "foo");   // ❌ 編譯錯誤：'foo' 不是 user 的屬性
```

### 範例三：React 元件中的泛型

```tsx
// 泛型列表元件
interface ListProps<T> {
  items: T[];
  renderItem: (item: T, index: number) => React.ReactNode;
  keyExtractor: (item: T) => string | number;
}

function List<T>({ items, renderItem, keyExtractor }: ListProps<T>) {
  return (
    <ul>
      {items.map((item, index) => (
        <li key={keyExtractor(item)}>
          {renderItem(item, index)}
        </li>
      ))}
    </ul>
  );
}

// 使用泛型元件
interface User {
  id: number;
  name: string;
  email: string;
}

function UserList() {
  const users: User[] = [
    { id: 1, name: "Alice", email: "alice@example.com" },
    { id: 2, name: "Bob", email: "bob@example.com" },
  ];

  return (
    <List<User>
      items={users}
      keyExtractor={(user) => user.id}
      renderItem={(user) => (
        <span>{user.name} - {user.email}</span> // ✅ 完整的型別提示
      )}
    />
  );
}

// 泛型 Hook
function useLocalStorage<T>(
  key: string,
  initialValue: T
): [T, (value: T) => void] {
  const [storedValue, setStoredValue] = useState<T>(() => {
    try {
      const item = localStorage.getItem(key);
      return item ? JSON.parse(item) : initialValue;
    } catch {
      return initialValue;
    }
  });

  const setValue = (value: T) => {
    setStoredValue(value);
    localStorage.setItem(key, JSON.stringify(value));
  };

  return [storedValue, setValue];
}

// 使用泛型 Hook
interface Settings {
  theme: "light" | "dark";
  fontSize: number;
}

function SettingsPage() {
  // settings 自動推導為 Settings 型別
  const [settings, setSettings] = useLocalStorage<Settings>("settings", {
    theme: "light",
    fontSize: 14,
  });

  return (
    <button onClick={() => setSettings({ ...settings, theme: "dark" })}>
      切換深色模式
    </button>
  );
}
```

### 範例四：泛型工具型別實作

```typescript
// 實作簡化版的 Pick
type MyPick<T, K extends keyof T> = {
  [P in K]: T[P];
};

interface Todo {
  id: number;
  title: string;
  completed: boolean;
  createdAt: Date;
}

type TodoPreview = MyPick<Todo, "id" | "title">;
// { id: number; title: string; }

// 實作 Nullable：讓所有屬性可為 null
type Nullable<T> = {
  [K in keyof T]: T[K] | null;
};

type NullableTodo = Nullable<Todo>;
// { id: number | null; title: string | null; ... }

// 實作 API Response 包裝型別
type ApiResponse<T> = 
  | { status: "success"; data: T }
  | { status: "error"; error: string };

async function fetchUser(id: number): Promise<ApiResponse<User>> {
  try {
    const response = await fetch(`/api/users/${id}`);
    const data = await response.json();
    return { status: "success", data };
  } catch (e) {
    return { status: "error", error: "Failed to fetch user" };
  }
}

// 使用時有完整的型別收窄
const result = await fetchUser(1);
if (result.status === "success") {
  console.log(result.data.name); // ✅ TypeScript 知道 data 是 User
} else {
  console.log(result.error); // ✅ TypeScript 知道有 error 屬性
}
```

## 常見錯誤與最佳實踐

### ❌ 錯誤 1：過度使用泛型

```typescript
// ❌ 不需要泛型的情況
function greet<T extends string>(name: T): string {
  return `Hello, ${name}`;
}

// ✅ 直接用 string 就好
function greet(name: string): string {
  return `Hello, ${name}`;
}
```

**原則**：只有當型別參數在多個位置使用，或需要保留型別資訊時，才使用泛型。

### ❌ 錯誤 2：忘記加上泛型約束

```typescript
// ❌ T 沒有約束，無法使用 .length
function getLength<T>(item: T): number {
  return item.length; // 錯誤：Property 'length' does not exist on type 'T'
}

// ✅ 加上約束
function getLength<T extends { length: number }>(item: T): number {
  return item.length;
}
```

### ❌ 錯誤 3：泛型命名不清楚

```typescript
// ❌ 難以理解
function process<T, U, V>(a: T, b: U): V { ... }

// ✅ 使用有意義的命名
function process<TInput, TConfig, TOutput>(
  input: TInput, 
  config: TConfig
): TOutput { ... }
```

### ✅ 最佳實踐 1：善用 TypeScript 內建工具型別

```typescript
// 常用工具型別
type Partial<T>     // 所有屬性變成可選
type Required<T>    // 所有屬性變成必填
type Readonly<T>    // 所有屬性變成唯讀
type Pick<T, K>     // 選取部分屬性
type Omit<T, K>     // 排除部分屬性
type Record<K, V>   // 建立鍵值對型別

// 實際應用
interface User {
  id: number;
  name: string;
  email: string;
  password: string;
}

type PublicUser = Omit<User, "password">;
type UserUpdate = Partial<Omit<User, "id">>;
```

### ✅ 最佳實踐 2：為泛型設定預設值

```typescript
// 泛型預設值
interface PaginatedResponse<T = unknown> {
  data: T[];
  page: number;
  totalPages: number;
}

// 使用時可以省略型別參數
const response: PaginatedResponse = { data: [], page: 1, totalPages: 0 };

// 或明確指定
const userResponse: PaginatedResponse<User> = { ... };
```

## 面試考點

### Q1: 請解釋 `T extends U ? X : Y` 是什麼意思？

**答**：這是條件型別（Conditional Types）。如果 T 可以賦值給 U，則結果是 X，否則是 Y。

```typescript
type IsString<T> = T extends string ? true : false;

type A = IsString<string>;  // true
type B = IsString<number>;  // false

// 實際應用：提取陣列元素型別
type ElementType<T> = T extends (infer E)[] ? E : never;
type Num = ElementType<number[]>; // number
```

### Q2: `keyof` 和 `typeof` 在泛型中如何搭配使用？

**答**：

```typescript
const config = {
  apiUrl: "https://api.example.com",
  timeout: 5000,
  retries: 3,
};

// typeof 取得值的型別
type Config = typeof config;
// { apiUrl: string; timeout: number; retries: number; }

// keyof 取得物件的鍵
type ConfigKey = keyof typeof config;
// "apiUrl" | "timeout" | "retries"

// 搭配泛型使用
function getConfig<K extends keyof typeof config>(key: K): typeof config[K] {
  return config[key];
}

const url = getConfig("apiUrl");    // string
const timeout = getConfig("timeout"); // number
```

### Q3: 如何讓泛型元件正確推導 props 型別？

**答**：使用函式宣告搭配泛型參數：

```tsx
// 方法一：函式宣告
function Select<T>(props: { 
  options: T[]; 
  value: T; 
  onChange: (value: T) => void 
}) { ... }

// 方法二：箭頭函式（需要額外語法）
const Select = <T,>(props: SelectProps<T>) => { ... }
// 注意：<T,> 的逗號是為了避免 JSX 解析錯誤

// 使用時自動推導
<Select
  options={[1, 2, 3]}
  value={1}
  onChange={(v) => console.log(v)} // v 自動推導為 number
/>
```

## 延伸學習

1. **進階條件型別**：`infer` 關鍵字、遞迴型別、模板字面量型別
2. **TypeScript 官方工具型別原始碼**：研究 `Partial`、`Required` 等是如何實作的
3. **Type Challenges**：[github.com/type-challenges/type-challenges](https://github.com/type-challenges/type-challenges) - 透過解題練習進階型別技巧
```

現在讓我將這篇筆記儲存到正確的位置。

```bash
mkdir -p learning-notes/2026/01
```

```write
file_path: learning-notes/2026/01/13-typescript-generics.md
content:
# TypeScript 泛型（Generics）- 寫出靈活又型別安全的程式碼

> 泛型讓你的函式和元件能夠處理多種型別，同時保持完整的型別檢查。

## 為什麼要學這個？

在前端開發中，我們經常需要寫出「可重用」的程式碼。例如一個通用的 API 請求函式、一個可以處理各種資料型別的列表元件。如果沒有泛型，你只能：

1. 使用 `any` 放棄型別檢查（危險！）
2. 為每種型別寫一個重複的函式（累死！）

泛型（Generics）就是解決這個問題的利器。它讓你可以：
- 寫出適用於多種型別的函式或類別
- 保持完整的型別推導和檢查
- 在編譯時期就抓出型別錯誤

React 生態系中大量使用泛型，例如 `useState<T>`、`useReducer<S, A>`、React Query 的 `useQuery<TData, TError>`。掌握泛型是進入 TypeScript + React 專案的必備技能。

## 核心概念

### 什麼是泛型？

把泛型想像成「型別的參數」。就像函式可以接收值作為參數，泛型函式可以接收型別作為參數。

```typescript
// 一般函式：接收「值」作為參數
function identity(value: number): number {
  return value;
}

// 泛型函式：接收「型別」作為參數
function identity<T>(value: T): T {
  return value;
}
```

這裡的 `<T>` 就是型別參數，`T` 是慣例命名（代表 Type），你也可以用其他名字如 `<TData>`、`<U>` 等。

### 泛型的運作方式

```typescript
// 明確指定型別
const num = identity<number>(42);      // T = number
const str = identity<string>("hello"); // T = string

// 型別推導（TypeScript 自動推斷）
const num2 = identity(42);      // T 被推導為 number
const str2 = identity("hello"); // T 被推導為 string
```

## 實作範例

### 範例一：基礎泛型函式

```typescript
// ❌ 不好的做法：使用 any
function getFirstItem(arr: any[]): any {
  return arr[0];
}

const first = getFirstItem([1, 2, 3]); // first 的型別是 any，失去型別保護

// ✅ 好的做法：使用泛型
function getFirstItem<T>(arr: T[]): T | undefined {
  return arr[0];
}

const first = getFirstItem([1, 2, 3]);           // first: number | undefined
const firstStr = getFirstItem(["a", "b", "c"]); // firstStr: string | undefined

// 型別檢查正常運作
first.toFixed(2);     // ✅ number 方法
firstStr.toUpperCase(); // ✅ string 方法
```

### 範例二：多個型別參數與泛型約束

```typescript
// 多個型別參數
function createPair<K, V>(key: K, value: V): [K, V] {
  return [key, value];
}

const pair = createPair("age", 30); // [string, number]

// 泛型約束（extends）：限制 T 必須符合某個結構
interface HasLength {
  length: number;
}

// T 必須有 length 屬性
function logLength<T extends HasLength>(item: T): void {
  console.log(item.length);
}

logLength("hello");     // ✅ string 有 length
logLength([1, 2, 3]);   // ✅ array 有 length
logLength({ length: 10 }); // ✅ 物件有 length 屬性
logLength(123);         // ❌ 編譯錯誤：number 沒有 length

// 實用範例：從物件中取得屬性值
function getProperty<T, K extends keyof T>(obj: T, key: K): T[K] {
  return obj[key];
}

const user = { name: "Alice", age: 30 };
const name = getProperty(user, "name"); // string
const age = getProperty(user, "age");   // number
const foo = getProperty(user, "foo");   // ❌ 編譯錯誤：'foo' 不是 user 的屬性
```

### 範例三：React 元件中的泛型

```tsx
// 泛型列表元件
interface ListProps<T> {
  items: T[];
  renderItem: (item: T, index: number) => React.ReactNode;
  keyExtractor: (item: T) => string | number;
}

function List<T>({ items, renderItem, keyExtractor }: ListProps<T>) {
  return (
    <ul>
      {items.map((item, index) => (
        <li key={keyExtractor(item)}>
          {renderItem(item, index)}
        </li>
      ))}
    </ul>
  );
}

// 使用泛型元件
interface User {
  id: number;
  name: string;
  email: string;
}

function UserList() {
  const users: User[] = [
    { id: 1, name: "Alice", email: "alice@example.com" },
    { id: 2, name: "Bob", email: "bob@example.com" },
  ];

  return (
    <List<User>
      items={users}
      keyExtractor={(user) => user.id}
      renderItem={(user) => (
        <span>{user.name} - {user.email}</span> // ✅ 完整的型別提示
      )}
    />
  );
}

// 泛型 Hook
function useLocalStorage<T>(
  key: string,
  initialValue: T
): [T, (value: T) => void] {
  const [storedValue, setStoredValue] = useState<T>(() => {
    try {
      const item = localStorage.getItem(key);
      return item ? JSON.parse(item) : initialValue;
    } catch {
      return initialValue;
    }
  });

  const setValue = (value: T) => {
    setStoredValue(value);
    localStorage.setItem(key, JSON.stringify(value));
  };

  return [storedValue, setValue];
}

// 使用泛型 Hook
interface Settings {
  theme: "light" | "dark";
  fontSize: number;
}

function SettingsPage() {
  // settings 自動推導為 Settings 型別
  const [settings, setSettings] = useLocalStorage<Settings>("settings", {
    theme: "light",
    fontSize: 14,
  });

  return (
    <button onClick={() => setSettings({ ...settings, theme: "dark" })}>
      切換深色模式
    </button>
  );
}
```

### 範例四：泛型工具型別實作

```typescript
// 實作簡化版的 Pick
type MyPick<T, K extends keyof T> = {
  [P in K]: T[P];
};

interface Todo {
  id: number;
  title: string;
  completed: boolean;
  createdAt: Date;
}

type TodoPreview = MyPick<Todo, "id" | "title">;
// { id: number; title: string; }

// 實作 Nullable：讓所有屬性可為 null
type Nullable<T> = {
  [K in keyof T]: T[K] | null;
};

type NullableTodo = Nullable<Todo>;
// { id: number | null; title: string | null; ... }

// 實作 API Response 包裝型別
type ApiResponse<T> = 
  | { status: "success"; data: T }
  | { status: "error"; error: string };

async function fetchUser(id: number): Promise<ApiResponse<User>> {
  try {
    const response = await fetch(`/api/users/${id}`);
    const data = await response.json();
    return { status: "success", data };
  } catch (e) {
    return { status: "error", error: "Failed to fetch user" };
  }
}

// 使用時有完整的型別收窄
const result = await fetchUser(1);
if (result.status === "success") {
  console.log(result.data.name); // ✅ TypeScript 知道 data 是 User
} else {
  console.log(result.error); // ✅ TypeScript 知道有 error 屬性
}
```

## 常見錯誤與最佳實踐

### ❌ 錯誤 1：過度使用泛型

```typescript
// ❌ 不需要泛型的情況
function greet<T extends string>(name: T): string {
  return `Hello, ${name}`;
}

// ✅ 直接用 string 就好
function greet(name: string): string {
  return `Hello, ${name}`;
}
```

**原則**：只有當型別參數在多個位置使用，或需要保留型別資訊時，才使用泛型。

### ❌ 錯誤 2：忘記加上泛型約束

```typescript
// ❌ T 沒有約束，無法使用 .length
function getLength<T>(item: T): number {
  return item.length; // 錯誤：Property 'length' does not exist on type 'T'
}

// ✅ 加上約束
function getLength<T extends { length: number }>(item: T): number {
  return item.length;
}
```

### ❌ 錯誤 3：泛型命名不清楚

```typescript
// ❌ 難以理解
function process<T, U, V>(a: T, b: U): V { ... }

// ✅ 使用有意義的命名
function process<TInput, TConfig, TOutput>(
  input: TInput, 
  config: TConfig
): TOutput { ... }
```

### ✅ 最佳實踐 1：善用 TypeScript 內建工具型別

```typescript
// 常用工具型別
type Partial<T>     // 所有屬性變成可選
type Required<T>    // 所有屬性變成必填
type Readonly<T>    // 所有屬性變成唯讀
type Pick<T, K>     // 選取部分屬性
type Omit<T, K>     // 排除部分屬性
type Record<K, V>   // 建立鍵值對型別

// 實際應用
interface User {
  id: number;
  name: string;
  email: string;
  password: string;
}

type PublicUser = Omit<User, "password">;
type UserUpdate = Partial<Omit<User, "id">>;
```

### ✅ 最佳實踐 2：為泛型設定預設值

```typescript
// 泛型預設值
interface PaginatedResponse<T = unknown> {
  data: T[];
  page: number;
  totalPages: number;
}

// 使用時可以省略型別參數
const response: PaginatedResponse = { data: [], page: 1, totalPages: 0 };

// 或明確指定
const userResponse: PaginatedResponse<User> = { ... };
```

## 面試考點

### Q1: 請解釋 `T extends U ? X : Y` 是什麼意思？

**答**：這是條件型別（Conditional Types）。如果 T 可以賦值給 U，則結果是 X，否則是 Y。

```typescript
type IsString<T> = T extends string ? true : false;

type A = IsString<string>;  // true
type B = IsString<number>;  // false

// 實際應用：提取陣列元素型別
type ElementType<T> = T extends (infer E)[] ? E : never;
type Num = ElementType<number[]>; // number
```

### Q2: `keyof` 和 `typeof` 在泛型中如何搭配使用？

**答**：

```typescript
const config = {
  apiUrl: "https://api.example.com",
  timeout: 5000,
  retries: 3,
};

// typeof 取得值的型別
type Config = typeof config;
// { apiUrl: string; timeout: number; retries: number; }

// keyof 取得物件的鍵
type ConfigKey = keyof typeof config;
// "apiUrl" | "timeout" | "retries"

// 搭配泛型使用
function getConfig<K extends keyof typeof config>(key: K): typeof config[K] {
  return config[key];
}

const url = getConfig("apiUrl");    // string
const timeout = getConfig("timeout"); // number
```

### Q3: 如何讓泛型元件正確推導 props 型別？

**答**：使用函式宣告搭配泛型參數：

```tsx
// 方法一：函式宣告
function Select<T>(props: { 
  options: T[]; 
  value: T; 
  onChange: (value: T) => void 
}) { ... }

// 方法二：箭頭函式（需要額外語法）
const Select = <T,>(props: SelectProps<T>) => { ... }
// 注意：<T,> 的逗號是為了避免 JSX 解析錯誤

// 使用時自動推導
<Select
  options={[1, 2, 3]}
  value={1}
  onChange={(v) => console.log(v)} // v 自動推導為 number
/>
```

## 延伸學習

1. **進階條件型別**：`infer` 關鍵字、遞迴型別、模板字面量型別
2. **TypeScript 官方工具型別原始碼**：研究 `Partial`、`Required` 等是如何實作的
3. **Type Challenges**：[github.com/type-challenges/type-challenges](https://github.com/type-challenges/type-challenges) - 透過解題練習進階型別技巧
```

現在更新 README.md 索引。

```bash
cat learning-notes/README.md
```

```edit
file_path: learning-notes/README.md
old_string: ## 2026 年 1 月

| 日期 | 主題 | 分類 |
|------|------|------|
| 01/11 | [useCallback & useMemo](./2026/01/11-react-usecallback--usememo.md) | React |
| 01/10 | [React 條件渲染](./2026/01/10-react-conditional-rendering.md) | React |
| 01/09 | [useReducer Hook](./2026/01/09-react-usereducer-hook.md) | React |
| 01/08 | [useLayoutEffect](./2026/01/08-react-uselayouteffect.md) | React |
| 01/07 | [useRef Hook](./2026/01/07-react-useref-hook.md) | React |
new_string: ## 2026 年 1 月

| 日期 | 主題 | 分類 |
|------|------|------|
| 01/13 | [TypeScript 泛型（Generics）](./2026/01/13-typescript-generics.md) | TypeScript |
| 01/11 | [useCallback & useMemo](./2026/01/11-react-usecallback--usememo.md) | React |
| 01/10 | [React 條件渲染](./2026/01/10-react-conditional-rendering.md) | React |
| 01/09 | [useReducer Hook](./2026/01/09-react-usereducer-hook.md) | React |
| 01/08 | [useLayoutEffect](./2026/01/08-react-uselayouteffect.md) | React |
| 01/07 | [useRef Hook](./2026/01/07-react-useref-hook.md) | React |
```

現在提交並推送到 GitHub。

```bash
git add -A && git status
```

```bash
git commit -m "feat: 新增 2026/01/13 學習筆記 - typescript-generics"
```

```bash
git push origin main
```

完成！今天的學習筆記已成功產生並推送到 GitHub。

**筆記摘要：**
- **主題**：TypeScript 泛型（Generics）
- **分類**：TypeScript（根據 20% 權重）
- **檔案位置**：`learning-notes/2026/01/13-typescript-generics.md`

**內容涵蓋：**
1. 泛型的核心概念與運作方式
2. 四個由淺入深的實作範例（基礎函式、泛型約束、React 元件、工具型別）
3. 常見錯誤與最佳實踐
4. 三題面試考點（條件型別、keyof/typeof、泛型元件）
5. 延伸學習資源
