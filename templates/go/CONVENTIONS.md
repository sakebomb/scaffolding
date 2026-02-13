## Go Conventions

> Appended to CLAUDE.md during scaffold init. These are language-specific rules for Claude Code.

### Code Style

- **Follow `gofmt` and `goimports`** — non-negotiable. Code must be formatted before commit.
- **Use `golangci-lint`** with the project's `.golangci.yml` config. It aggregates multiple linters.
- **Naming**:
  - Exported names: `PascalCase`. Unexported: `camelCase`.
  - Acronyms stay uppercase: `HTTPClient`, `userID`, not `HttpClient`, `userId`.
  - Interface names: single-method interfaces use the method name + `er` suffix (`Reader`, `Writer`, `Stringer`).
  - Avoid stutter: `http.Server`, not `http.HTTPServer`.
- **Keep packages small and focused.** One package = one responsibility.
- **Use `context.Context`** as the first parameter for functions that do I/O or may be cancelled.

### Error Handling

- **Check every error.** Never use `_` to discard errors unless there's a documented reason.
- **Wrap errors with context** using `fmt.Errorf("doing X: %w", err)` — the `%w` verb enables `errors.Is()` and `errors.As()`.
- **Don't panic** in library code. Reserve `panic` for truly unrecoverable situations (and even then, prefer returning an error).
- **Use sentinel errors** (`var ErrNotFound = errors.New("not found")`) for errors callers need to check.
- **Custom error types** when callers need structured error data:
  ```go
  type ValidationError struct {
      Field   string
      Message string
  }
  func (e *ValidationError) Error() string { return fmt.Sprintf("%s: %s", e.Field, e.Message) }
  ```

### Testing

- **Framework**: stdlib `testing` package. No external test frameworks needed.
- **Table-driven tests** are the default pattern:
  ```go
  tests := []struct {
      name    string
      input   string
      want    string
      wantErr bool
  }{...}
  for _, tt := range tests {
      t.Run(tt.name, func(t *testing.T) { ... })
  }
  ```
- **Use `testify/assert`** or `testify/require` if the project already uses it — don't add it for new projects.
- **Test file naming**: `<file>_test.go` in the same package.
- **Use `t.Helper()`** in test helper functions for better error location reporting.
- **Use `t.Parallel()`** for tests that can run concurrently.

### Project Structure

```
project/
├── cmd/
│   └── {{PROJECT_NAME}}/
│       └── main.go
├── internal/           # Private packages
│   └── ...
├── pkg/                # Public packages (if library)
│   └── ...
├── tests/
│   ├── unit/
│   ├── integration/
│   └── agent/
├── go.mod
└── go.sum
```

### Concurrency

- **Don't communicate by sharing memory; share memory by communicating.** Use channels.
- **Use `sync.WaitGroup`** for fan-out/fan-in patterns.
- **Use `sync.Mutex`** only when channels are overkill (protecting simple shared state).
- **Always call `defer cancel()`** after `context.WithCancel()` or `context.WithTimeout()`.
- **Use `errgroup`** (`golang.org/x/sync/errgroup`) for managing groups of goroutines with error propagation.

### Dependencies

- **Minimize external dependencies.** Go's stdlib is extensive — use it first.
- **Use `go mod tidy`** to clean up unused dependencies.
- **Vendor dependencies** (`go mod vendor`) for reproducible builds in CI if needed.

### Performance

- **Pre-allocate slices** when the size is known: `make([]T, 0, expectedSize)`.
- **Use `strings.Builder`** for string concatenation in loops — not `+` or `fmt.Sprintf`.
- **Benchmark before optimizing** — use `func BenchmarkX(b *testing.B)`.
- **Avoid premature use of goroutines** — they have overhead. Profile first.
