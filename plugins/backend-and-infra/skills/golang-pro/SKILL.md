---
name: golang-pro
description: Write idiomatic Go code with goroutines, channels, and interfaces. Use when writing Go code, implementing concurrency patterns, designing Go interfaces, handling errors in Go, or optimizing Go performance.
---

# Go Pro

Guidelines for writing concurrent, performant, and idiomatic Go code.

## Core Principles

1. **Simplicity first** - Clear is better than clever
2. **Composition via interfaces** - Small interfaces, big flexibility
3. **Explicit error handling** - No hidden magic or exceptions
4. **Concurrent by design** - Goroutines and channels are cheap
5. **Benchmark before optimize** - Measure, don't guess

## Project Structure

```
project/
├── cmd/
│   └── myapp/
│       └── main.go          # Entry point
├── internal/                 # Private packages
│   ├── domain/              # Business logic
│   ├── service/             # Application services
│   └── repository/          # Data access
├── pkg/                     # Public packages
├── go.mod
├── go.sum
└── Makefile
```

## Interface Design

### Small Interfaces

```go
// Good: Single-method interfaces
type Reader interface {
    Read(p []byte) (n int, err error)
}

type Writer interface {
    Write(p []byte) (n int, err error)
}

// Compose larger interfaces
type ReadWriter interface {
    Reader
    Writer
}
```

### Accept Interfaces, Return Structs

```go
// Accept interface for flexibility
func Process(r io.Reader) error {
    // Can accept *os.File, *bytes.Buffer, net.Conn, etc.
}

// Return concrete type for clarity
func NewService(db *sql.DB) *Service {
    return &Service{db: db}
}
```

## Error Handling

### Wrapping Errors

```go
import "fmt"

func fetchUser(id string) (*User, error) {
    user, err := db.QueryUser(id)
    if err != nil {
        return nil, fmt.Errorf("fetchUser %s: %w", id, err)
    }
    return user, nil
}

// Check wrapped errors
if errors.Is(err, sql.ErrNoRows) {
    // Handle not found
}

var pathErr *os.PathError
if errors.As(err, &pathErr) {
    // Handle path error
}
```

### Custom Error Types

```go
type ValidationError struct {
    Field   string
    Message string
}

func (e *ValidationError) Error() string {
    return fmt.Sprintf("%s: %s", e.Field, e.Message)
}

func (e *ValidationError) Is(target error) bool {
    _, ok := target.(*ValidationError)
    return ok
}
```

### Sentinel Errors

```go
var (
    ErrNotFound     = errors.New("not found")
    ErrUnauthorized = errors.New("unauthorized")
)

func GetUser(id string) (*User, error) {
    if user == nil {
        return nil, ErrNotFound
    }
    return user, nil
}
```

## Concurrency Patterns

### Worker Pool

```go
func workerPool(jobs <-chan Job, results chan<- Result, numWorkers int) {
    var wg sync.WaitGroup

    for i := 0; i < numWorkers; i++ {
        wg.Add(1)
        go func() {
            defer wg.Done()
            for job := range jobs {
                results <- process(job)
            }
        }()
    }

    wg.Wait()
    close(results)
}
```

### Context for Cancellation

```go
func fetchWithTimeout(ctx context.Context, url string) ([]byte, error) {
    ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
    defer cancel()

    req, err := http.NewRequestWithContext(ctx, "GET", url, nil)
    if err != nil {
        return nil, err
    }

    resp, err := http.DefaultClient.Do(req)
    if err != nil {
        return nil, err
    }
    defer resp.Body.Close()

    return io.ReadAll(resp.Body)
}
```

### Select for Multiple Channels

```go
func processWithTimeout(data <-chan int, timeout time.Duration) {
    timer := time.NewTimer(timeout)
    defer timer.Stop()

    for {
        select {
        case v, ok := <-data:
            if !ok {
                return // Channel closed
            }
            process(v)
        case <-timer.C:
            log.Println("timeout")
            return
        }
    }
}
```

### Mutex vs Channel

```go
// Use mutex for protecting shared state
type SafeCounter struct {
    mu    sync.RWMutex
    count int
}

func (c *SafeCounter) Inc() {
    c.mu.Lock()
    defer c.mu.Unlock()
    c.count++
}

func (c *SafeCounter) Get() int {
    c.mu.RLock()
    defer c.mu.RUnlock()
    return c.count
}

// Use channels for communication/coordination
func producer(ch chan<- int) {
    for i := 0; i < 10; i++ {
        ch <- i
    }
    close(ch)
}
```

## Testing

### Table-Driven Tests

```go
func TestAdd(t *testing.T) {
    tests := []struct {
        name     string
        a, b     int
        expected int
    }{
        {"positive", 2, 3, 5},
        {"negative", -1, -2, -3},
        {"zero", 0, 0, 0},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            result := Add(tt.a, tt.b)
            if result != tt.expected {
                t.Errorf("Add(%d, %d) = %d; want %d",
                    tt.a, tt.b, result, tt.expected)
            }
        })
    }
}
```

### Benchmarks

```go
func BenchmarkFibonacci(b *testing.B) {
    for i := 0; i < b.N; i++ {
        Fibonacci(20)
    }
}

// Run: go test -bench=. -benchmem
```

### Test Helpers

```go
func setupTestDB(t *testing.T) *sql.DB {
    t.Helper()
    db, err := sql.Open("sqlite3", ":memory:")
    if err != nil {
        t.Fatal(err)
    }
    t.Cleanup(func() { db.Close() })
    return db
}
```

## Generics (Go 1.18+)

```go
// Generic function
func Map[T, U any](items []T, fn func(T) U) []U {
    result := make([]U, len(items))
    for i, item := range items {
        result[i] = fn(item)
    }
    return result
}

// Constrained generics
type Number interface {
    ~int | ~int64 | ~float64
}

func Sum[T Number](nums []T) T {
    var total T
    for _, n := range nums {
        total += n
    }
    return total
}
```

## Common Patterns

### Functional Options

```go
type Server struct {
    addr    string
    timeout time.Duration
}

type Option func(*Server)

func WithTimeout(d time.Duration) Option {
    return func(s *Server) {
        s.timeout = d
    }
}

func NewServer(addr string, opts ...Option) *Server {
    s := &Server{addr: addr, timeout: 30 * time.Second}
    for _, opt := range opts {
        opt(s)
    }
    return s
}

// Usage
server := NewServer(":8080", WithTimeout(60*time.Second))
```

### Defer for Cleanup

```go
func processFile(path string) error {
    f, err := os.Open(path)
    if err != nil {
        return err
    }
    defer f.Close() // Always runs, even on panic

    // Process file...
    return nil
}
```

## Performance Tips

- Preallocate slices: `make([]T, 0, expectedSize)`
- Use `strings.Builder` for string concatenation
- Use `sync.Pool` for frequently allocated objects
- Avoid interface{} when type is known
- Profile with `pprof` before optimizing
