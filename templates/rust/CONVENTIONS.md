## Rust Conventions

> Appended to CLAUDE.md during scaffold init. These are language-specific rules for Claude Code.

### Code Style

- **Run `cargo fmt`** before every commit — non-negotiable.
- **Run `cargo clippy`** and fix all warnings. Clippy is the primary linter.
- **Naming**:
  - Types and traits: `PascalCase`
  - Functions, methods, variables: `snake_case`
  - Constants: `SCREAMING_SNAKE_CASE`
  - Lifetimes: short lowercase (`'a`, `'b`), descriptive for complex cases (`'input`, `'conn`)
- **Keep functions short.** If a function exceeds ~40 lines, consider splitting.
- **Use `#[must_use]`** on functions where ignoring the return value is likely a bug.
- **Prefer iterators** over manual loops — `.map()`, `.filter()`, `.collect()` are idiomatic.

### Ownership & Borrowing

- **Prefer borrowing over ownership** when the function doesn't need to own the data. Use `&T` and `&mut T`.
- **Use `Clone` sparingly** — cloning to satisfy the borrow checker is a code smell. Restructure instead.
- **Prefer `&str` over `String`** in function parameters. Accept owned `String` only when the function needs ownership.
- **Use `Cow<'_, str>`** when a function might or might not need to allocate.
- **Minimize lifetime annotations** — let the compiler infer where possible. Add explicit lifetimes only when required.

### Error Handling

- **Use `Result<T, E>`** for recoverable errors. Never `panic!` in library code.
- **Use `thiserror`** for defining error types (derive macro for custom errors).
- **Use `anyhow`** for application-level error handling (when you don't need callers to match on error variants).
- **Use the `?` operator** for error propagation — don't `.unwrap()` in non-test code.
- **`.unwrap()` and `.expect()` are OK in**:
  - Tests
  - Cases where the invariant is provably true (with a comment explaining why)
  - Early startup/initialization (fail fast)
- **Never use `.unwrap()` on user input or I/O results.**

### Testing

- **Use `#[cfg(test)]` module** in the same file for unit tests:
  ```rust
  #[cfg(test)]
  mod tests {
      use super::*;

      #[test]
      fn test_name_describes_behavior() {
          // ...
      }
  }
  ```
- **Integration tests** go in `tests/` directory at the crate root.
- **Use `assert_eq!`** with descriptive messages: `assert_eq!(result, expected, "should return X when Y")`.
- **Use `#[should_panic]`** for testing panic behavior.
- **Property-based testing** with `proptest` for functions with wide input domains.

### Project Structure

```
project/
├── src/
│   ├── main.rs        # (binary crate)
│   ├── lib.rs         # (library crate)
│   └── ...
├── tests/
│   ├── unit/
│   ├── integration/
│   └── agent/
├── benches/            # Benchmarks
├── Cargo.toml
└── Cargo.lock          # Committed for binaries, not for libraries
```

### Dependencies

- **Minimize dependencies.** Each dependency is a supply chain risk and compile time cost.
- **Check `cargo audit`** periodically for known vulnerabilities.
- **Use feature flags** to keep optional dependencies optional.
- **Specify version ranges** in `Cargo.toml`: `serde = "1"` (compatible), not `serde = "=1.0.193"` (exact).
- **Commit `Cargo.lock`** for binaries and applications. Don't commit it for libraries.

### Unsafe

- **Avoid `unsafe` unless absolutely necessary.** Prefer safe abstractions.
- **If `unsafe` is used**: add a `// SAFETY:` comment explaining why it's sound.
- **Encapsulate `unsafe`** in a safe wrapper — don't expose unsafe APIs.
- **Document invariants** that callers must uphold for unsafe functions.

### Performance

- **Profile before optimizing** — use `cargo flamegraph` or `criterion` for benchmarks.
- **Use `&[T]` over `Vec<T>`** in function parameters when you don't need ownership.
- **Avoid allocations in hot paths** — reuse buffers, use `with_capacity`.
- **Use `rayon`** for data parallelism when processing large collections.
