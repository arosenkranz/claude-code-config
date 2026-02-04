---
name: frontend-developer
description: Build React components with hooks, responsive layouts, and accessible UI. Use when creating React components, implementing state management, styling with Tailwind or CSS-in-JS, or ensuring accessibility compliance.
---

# Frontend Developer

Guidelines for modern React development with accessibility and performance.

## Core Principles

1. **Component-first** - Reusable, composable UI pieces
2. **Mobile-first** - Design for small screens, enhance for larger
3. **Accessible by default** - WCAG compliance from the start
4. **Type-safe props** - TypeScript interfaces for all components
5. **Performance budgets** - Aim for sub-3s load times

## Component Patterns

### Typed Props with Children

```tsx
interface ButtonProps {
  variant?: 'primary' | 'secondary' | 'danger';
  size?: 'sm' | 'md' | 'lg';
  isLoading?: boolean;
  disabled?: boolean;
  onClick?: () => void;
  children: React.ReactNode;
}

export function Button({
  variant = 'primary',
  size = 'md',
  isLoading = false,
  disabled = false,
  onClick,
  children,
}: ButtonProps) {
  return (
    <button
      className={cn(
        'rounded-md font-medium transition-colors',
        variants[variant],
        sizes[size],
        (disabled || isLoading) && 'opacity-50 cursor-not-allowed'
      )}
      disabled={disabled || isLoading}
      onClick={onClick}
      aria-busy={isLoading}
    >
      {isLoading ? <Spinner /> : children}
    </button>
  );
}
```

### Compound Components

```tsx
interface TabsContextType {
  activeTab: string;
  setActiveTab: (id: string) => void;
}

const TabsContext = createContext<TabsContextType | null>(null);

function Tabs({ children, defaultValue }: TabsProps) {
  const [activeTab, setActiveTab] = useState(defaultValue);

  return (
    <TabsContext.Provider value={{ activeTab, setActiveTab }}>
      <div role="tablist">{children}</div>
    </TabsContext.Provider>
  );
}

function TabTrigger({ value, children }: TabTriggerProps) {
  const ctx = useContext(TabsContext);
  if (!ctx) throw new Error('TabTrigger must be inside Tabs');

  return (
    <button
      role="tab"
      aria-selected={ctx.activeTab === value}
      onClick={() => ctx.setActiveTab(value)}
    >
      {children}
    </button>
  );
}

Tabs.Trigger = TabTrigger;
Tabs.Content = TabContent;
```

## Hooks Patterns

### Custom Data Fetching Hook

```tsx
function useFetch<T>(url: string) {
  const [state, setState] = useState<{
    data: T | null;
    isLoading: boolean;
    error: Error | null;
  }>({
    data: null,
    isLoading: true,
    error: null,
  });

  useEffect(() => {
    const controller = new AbortController();

    async function fetchData() {
      try {
        const res = await fetch(url, { signal: controller.signal });
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        const data = await res.json();
        setState({ data, isLoading: false, error: null });
      } catch (err) {
        if (err instanceof Error && err.name !== 'AbortError') {
          setState({ data: null, isLoading: false, error: err });
        }
      }
    }

    fetchData();
    return () => controller.abort();
  }, [url]);

  return state;
}
```

### Debounced Value Hook

```tsx
function useDebounce<T>(value: T, delay: number): T {
  const [debouncedValue, setDebouncedValue] = useState(value);

  useEffect(() => {
    const timer = setTimeout(() => setDebouncedValue(value), delay);
    return () => clearTimeout(timer);
  }, [value, delay]);

  return debouncedValue;
}
```

### Local Storage Hook

```tsx
function useLocalStorage<T>(key: string, initialValue: T) {
  const [storedValue, setStoredValue] = useState<T>(() => {
    try {
      const item = window.localStorage.getItem(key);
      return item ? JSON.parse(item) : initialValue;
    } catch {
      return initialValue;
    }
  });

  const setValue = (value: T | ((val: T) => T)) => {
    const valueToStore = value instanceof Function ? value(storedValue) : value;
    setStoredValue(valueToStore);
    window.localStorage.setItem(key, JSON.stringify(valueToStore));
  };

  return [storedValue, setValue] as const;
}
```

## Accessibility Checklist

### Semantic HTML
- Use `<button>` for actions, `<a>` for navigation
- Use heading hierarchy (`h1` -> `h2` -> `h3`)
- Use `<nav>`, `<main>`, `<aside>`, `<footer>` landmarks

### ARIA Attributes
```tsx
// Announce dynamic content
<div aria-live="polite" aria-atomic="true">
  {statusMessage}
</div>

// Label interactive elements
<button aria-label="Close dialog" aria-describedby="dialog-desc">
  <XIcon />
</button>

// Indicate states
<button aria-pressed={isActive} aria-expanded={isOpen}>
  Menu
</button>
```

### Keyboard Navigation
```tsx
function handleKeyDown(e: KeyboardEvent) {
  switch (e.key) {
    case 'ArrowDown':
      focusNext();
      break;
    case 'ArrowUp':
      focusPrev();
      break;
    case 'Escape':
      close();
      break;
    case 'Enter':
    case ' ':
      select();
      break;
  }
}
```

### Focus Management
```tsx
// Focus trap in modals
useEffect(() => {
  if (isOpen) {
    const previousFocus = document.activeElement as HTMLElement;
    firstFocusableRef.current?.focus();
    return () => previousFocus?.focus();
  }
}, [isOpen]);
```

## Tailwind Patterns

### Responsive Design

```tsx
<div className="
  grid
  grid-cols-1
  sm:grid-cols-2
  lg:grid-cols-3
  gap-4
  p-4
  sm:p-6
  lg:p-8
">
  {items.map(item => <Card key={item.id} {...item} />)}
</div>
```

### Component Variants with CVA

```tsx
import { cva, type VariantProps } from 'class-variance-authority';

const buttonVariants = cva(
  'inline-flex items-center justify-center rounded-md font-medium transition-colors',
  {
    variants: {
      variant: {
        primary: 'bg-blue-600 text-white hover:bg-blue-700',
        secondary: 'bg-gray-100 text-gray-900 hover:bg-gray-200',
        ghost: 'hover:bg-gray-100',
      },
      size: {
        sm: 'h-8 px-3 text-sm',
        md: 'h-10 px-4',
        lg: 'h-12 px-6 text-lg',
      },
    },
    defaultVariants: {
      variant: 'primary',
      size: 'md',
    },
  }
);

type ButtonProps = VariantProps<typeof buttonVariants> & {
  children: React.ReactNode;
};
```

## Performance Optimization

### Code Splitting
```tsx
const HeavyComponent = lazy(() => import('./HeavyComponent'));

function App() {
  return (
    <Suspense fallback={<Skeleton />}>
      <HeavyComponent />
    </Suspense>
  );
}
```

### Memoization
```tsx
// Memoize expensive calculations
const sortedItems = useMemo(
  () => items.sort((a, b) => a.name.localeCompare(b.name)),
  [items]
);

// Memoize callbacks passed to children
const handleClick = useCallback(() => {
  doSomething(id);
}, [id]);

// Memoize components that receive stable props
const MemoizedChild = memo(function Child({ data }: Props) {
  return <div>{data.name}</div>;
});
```

### Image Optimization
```tsx
<img
  src={imageSrc}
  alt={imageAlt}
  loading="lazy"
  decoding="async"
  width={400}
  height={300}
/>
```

## State Management

### Context + Reducer Pattern
```tsx
type Action =
  | { type: 'ADD_ITEM'; payload: Item }
  | { type: 'REMOVE_ITEM'; payload: string }
  | { type: 'CLEAR' };

function cartReducer(state: CartState, action: Action): CartState {
  switch (action.type) {
    case 'ADD_ITEM':
      return { ...state, items: [...state.items, action.payload] };
    case 'REMOVE_ITEM':
      return { ...state, items: state.items.filter(i => i.id !== action.payload) };
    case 'CLEAR':
      return { ...state, items: [] };
  }
}

const CartContext = createContext<{
  state: CartState;
  dispatch: Dispatch<Action>;
} | null>(null);
```
