# React useLayoutEffect：解決畫面閃爍的秘密武器

> `useLayoutEffect` 是 `useEffect` 的同步版本，在瀏覽器繪製前執行，用於需要同步讀取 DOM 或防止視覺閃爍的場景。

## 為什麼要學這個？

在開發 React 應用時，你可能遇過這種情況：元素先以錯誤的位置或樣式出現，然後「跳」到正確的位置。這種視覺閃爍（visual flicker）嚴重影響使用者體驗。

`useLayoutEffect` 正是解決這類問題的關鍵工具。它在瀏覽器實際繪製畫面之前同步執行，讓你能在使用者看到任何內容前完成 DOM 的測量與調整。

**常見應用場景：**
- 測量 DOM 元素尺寸後調整位置（tooltip、popover）
- 動畫起始位置的設定
- 需要同步讀取 DOM 屬性的操作
- 防止初始渲染閃爍

## 核心概念

### 執行時機差異

把瀏覽器渲染想像成拍電影：

```
React 渲染 → DOM 更新 → useLayoutEffect → 瀏覽器繪製 → useEffect
              (劇本寫好)   (燈光調整)      (開拍！)      (後製)
```

- **useEffect**：在瀏覽器繪製「之後」非同步執行（後製階段）
- **useLayoutEffect**：在瀏覽器繪製「之前」同步執行（開拍前的最後調整）

### 為什麼這很重要？

```tsx
// 使用 useEffect 可能產生閃爍
function TooltipWithFlicker({ targetRef }) {
  const [position, setPosition] = useState({ top: 0, left: 0 });
  
  useEffect(() => {
    // 瀏覽器已經繪製了 top:0, left:0 的 tooltip
    // 現在才計算正確位置，導致「跳動」
    const rect = targetRef.current.getBoundingClientRect();
    setPosition({ top: rect.bottom, left: rect.left });
  }, []);
  
  return <div style={{ position: 'absolute', ...position }}>Tooltip</div>;
}

// 使用 useLayoutEffect 無閃爍
function TooltipSmooth({ targetRef }) {
  const [position, setPosition] = useState({ top: 0, left: 0 });
  
  useLayoutEffect(() => {
    // 在瀏覽器繪製前就計算好位置
    // 使用者只會看到正確位置的 tooltip
    const rect = targetRef.current.getBoundingClientRect();
    setPosition({ top: rect.bottom, left: rect.left });
  }, []);
  
  return <div style={{ position: 'absolute', ...position }}>Tooltip</div>;
}
```

## Vue vs React 對比

| 概念 | Vue 3 | React |
|------|-------|-------|
| 非同步副作用 | `onMounted` / `watchEffect` | `useEffect` |
| 同步 DOM 操作 | `onMounted` (同步執行) | `useLayoutEffect` |
| 更新前操作 | `onBeforeUpdate` | 無直接對應 |

### Vue 的 onMounted 行為

```vue
<script setup>
import { ref, onMounted } from 'vue'

const tooltipRef = ref(null)
const position = ref({ top: 0, left: 0 })

// Vue 的 onMounted 本身就是同步執行的
// 在 DOM 掛載後、瀏覽器繪製前執行
onMounted(() => {
  const rect = tooltipRef.value.getBoundingClientRect()
  position.value = { top: rect.bottom, left: rect.left }
})
</script>
```

### React 的選擇

```tsx
// React 需要明確選擇同步或非同步
import { useEffect, useLayoutEffect } from 'react';

function Component() {
  // 大多數情況用這個（非同步，不阻塞繪製）
  useEffect(() => {
    // 資料獲取、訂閱、日誌等
  }, []);

  // 需要同步 DOM 操作時用這個
  useLayoutEffect(() => {
    // DOM 測量、位置調整等
  }, []);
}
```

**關鍵差異**：Vue 的 lifecycle hooks 預設行為比較像 `useLayoutEffect`，而 React 預設推薦使用 `useEffect`，只在必要時才用 `useLayoutEffect`。

## 實作範例

### 範例一：自動調整的 Tooltip

```tsx
import { useState, useRef, useLayoutEffect } from 'react';

interface TooltipProps {
  targetRef: React.RefObject<HTMLElement>;
  children: React.ReactNode;
}

function Tooltip({ targetRef, children }: TooltipProps) {
  const tooltipRef = useRef<HTMLDivElement>(null);
  const [coords, setCoords] = useState({ top: 0, left: 0 });
  const [isPositioned, setIsPositioned] = useState(false);

  useLayoutEffect(() => {
    if (!targetRef.current || !tooltipRef.current) return;

    const targetRect = targetRef.current.getBoundingClientRect();
    const tooltipRect = tooltipRef.current.getBoundingClientRect();
    
    // 計算 tooltip 位置，確保不超出視窗
    let top = targetRect.bottom + 8;
    let left = targetRect.left + (targetRect.width - tooltipRect.width) / 2;
    
    // 如果超出右邊界，向左調整
    if (left + tooltipRect.width > window.innerWidth) {
      left = window.innerWidth - tooltipRect.width - 8;
    }
    
    // 如果超出下邊界，改顯示在上方
    if (top + tooltipRect.height > window.innerHeight) {
      top = targetRect.top - tooltipRect.height - 8;
    }

    setCoords({ top, left });
    setIsPositioned(true);
  }, [targetRef]);

  return (
    <div
      ref={tooltipRef}
      style={{
        position: 'fixed',
        top: coords.top,
        left: coords.left,
        // 定位完成前隱藏，避免閃爍
        opacity: isPositioned ? 1 : 0,
        transition: 'opacity 0.2s',
      }}
    >
      {children}
    </div>
  );
}
```

### 範例二：測量後的動畫起點

```tsx
import { useRef, useLayoutEffect, useState } from 'react';

function AnimatedList({ items }: { items: string[] }) {
  const containerRef = useRef<HTMLUListElement>(null);
  const [heights, setHeights] = useState<Map<string, number>>(new Map());

  useLayoutEffect(() => {
    if (!containerRef.current) return;

    const newHeights = new Map<string, number>();
    
    // 在繪製前測量所有子元素的高度
    Array.from(containerRef.current.children).forEach((child, index) => {
      const key = items[index];
      newHeights.set(key, child.getBoundingClientRect().height);
    });

    setHeights(newHeights);
  }, [items]);

  return (
    <ul ref={containerRef}>
      {items.map((item, index) => (
        <li
          key={item}
          style={{
            // 使用測量到的高度來設定動畫
            '--item-height': `${heights.get(item) || 0}px`,
            animation: 'slideIn 0.3s ease-out',
            animationDelay: `${index * 50}ms`,
          } as React.CSSProperties}
        >
          {item}
        </li>
      ))}
    </ul>
  );
}
```

### 範例三：同步滾動位置恢復

```tsx
import { useLayoutEffect, useRef } from 'react';

interface ScrollRestorationProps {
  scrollKey: string;
  children: React.ReactNode;
}

// 儲存滾動位置的 Map
const scrollPositions = new Map<string, number>();

function ScrollRestoration({ scrollKey, children }: ScrollRestorationProps) {
  const containerRef = useRef<HTMLDivElement>(null);

  // 使用 useLayoutEffect 確保在繪製前恢復滾動位置
  // 如果用 useEffect，使用者會先看到頂部，再跳到正確位置
  useLayoutEffect(() => {
    const container = containerRef.current;
    if (!container) return;

    // 恢復之前的滾動位置
    const savedPosition = scrollPositions.get(scrollKey);
    if (savedPosition !== undefined) {
      container.scrollTop = savedPosition;
    }

    // 離開時儲存滾動位置
    return () => {
      scrollPositions.set(scrollKey, container.scrollTop);
    };
  }, [scrollKey]);

  return (
    <div ref={containerRef} style={{ overflow: 'auto', height: '100vh' }}>
      {children}
    </div>
  );
}
```

## 常見錯誤與最佳實踐

### 1. 過度使用 useLayoutEffect

```tsx
// ❌ 錯誤：不需要同步執行的操作
useLayoutEffect(() => {
  fetch('/api/data').then(setData); // 網路請求不需要阻塞繪製
  console.log('Component mounted');  // 日誌不需要阻塞繪製
}, []);

// ✅ 正確：使用 useEffect
useEffect(() => {
  fetch('/api/data').then(setData);
  console.log('Component mounted');
}, []);
```

### 2. 忽略 SSR 相容性

```tsx
// ❌ 錯誤：在 SSR 環境會產生警告
function Component() {
  useLayoutEffect(() => {
    // Server 端沒有 DOM，這會產生警告
  }, []);
}

// ✅ 正確：使用 useIsomorphicLayoutEffect
import { useEffect, useLayoutEffect } from 'react';

const useIsomorphicLayoutEffect = 
  typeof window !== 'undefined' ? useLayoutEffect : useEffect;

function Component() {
  useIsomorphicLayoutEffect(() => {
    // 在 client 端使用 useLayoutEffect
    // 在 server 端使用 useEffect（會被忽略）
  }, []);
}
```

### 3. 在 useLayoutEffect 中執行耗時操作

```tsx
// ❌ 錯誤：長時間計算會阻塞繪製
useLayoutEffect(() => {
  const result = heavyComputation(); // 可能花費 100ms+
  setData(result);
}, []);

// ✅ 正確：只做必要的 DOM 操作
useLayoutEffect(() => {
  const rect = ref.current.getBoundingClientRect(); // 快速 DOM 讀取
  setPosition({ x: rect.left, y: rect.top });
}, []);
```

### 4. 正確的使用時機判斷

```tsx
// 使用 useLayoutEffect 的情況：
// 1. 需要測量 DOM 後立即更新
// 2. 需要防止視覺閃爍
// 3. 需要在繪製前同步修改 DOM

// 使用 useEffect 的情況（大多數情況）：
// 1. 資料獲取
// 2. 事件訂閱
// 3. 日誌記錄
// 4. 不影響視覺呈現的操作
```

### 5. 搭配 flushSync 強制同步更新

```tsx
import { flushSync } from 'react-dom';

function Component() {
  useLayoutEffect(() => {
    // 有時需要強制 React 同步處理多個更新
    flushSync(() => {
      setWidth(ref.current.offsetWidth);
    });
    flushSync(() => {
      setHeight(ref.current.offsetHeight);
    });
  }, []);
}
```

## 面試考點

### Q1: useEffect 和 useLayoutEffect 的差異是什麼？何時該用哪個？

**簡答**：
- **執行時機**：`useEffect` 在瀏覽器繪製後非同步執行；`useLayoutEffect` 在繪製前同步執行
- **使用場景**：`useLayoutEffect` 用於需要同步讀取 DOM 或防止視覺閃爍的情況；其他情況用 `useEffect`
- **效能考量**：`useLayoutEffect` 會阻塞瀏覽器繪製，應只在必要時使用

### Q2: 在 Next.js 或其他 SSR 框架中使用 useLayoutEffect 會有什麼問題？如何解決？

**簡答**：
- **問題**：Server 端沒有 DOM，`useLayoutEffect` 會產生警告
- **解決方案**：使用條件判斷建立 `useIsomorphicLayoutEffect`，在 server 端降級為 `useEffect`
- **原理**：SSR 時 effect 不會執行，警告只是提醒開發者注意 hydration 可能的不一致

### Q3: 描述一個你會使用 useLayoutEffect 的實際場景

**簡答範例**：
「實作一個自動定位的 dropdown menu。需要先渲染 menu 取得其尺寸，再根據觸發按鈕位置和視窗邊界計算最終位置。使用 `useLayoutEffect` 可以在使用者看到任何畫面前完成定位，避免 menu 先出現在錯誤位置再跳到正確位置的閃爍問題。」

## 延伸學習

1. **React 渲染流程深入**
   - 了解 React Fiber 架構與 reconciliation 過程
   - 研究 `useInsertionEffect`（React 18 新增，比 `useLayoutEffect` 更早執行，專供 CSS-in-JS 使用）

2. **效能最佳化**
   - 學習 `flushSync` 的使用時機
   - 研究如何用 `requestAnimationFrame` 搭配 effect 優化動畫

3. **相關 Hooks 比較**
   - `useSyncExternalStore`：用於訂閱外部資料來源
   - `useDeferredValue`：延遲更新非緊急的 UI
   - 理解 React 18 concurrent features 如何影響 effect 執行
