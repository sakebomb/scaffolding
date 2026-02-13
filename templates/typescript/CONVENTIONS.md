## TypeScript Conventions

> Appended to CLAUDE.md during scaffold init. These are language-specific rules for Claude Code.

### Code Style

- **Strict mode always.** `tsconfig.json` must have `"strict": true` — no exceptions.
- **Explicit types at function boundaries** — parameter types and return types. Infer within function bodies.
- **Prefer `const` over `let`.** Never use `var`.
- **Prefer `interface` over `type`** for object shapes (better error messages, extendable). Use `type` for unions, intersections, and mapped types.
- **Use `readonly` properties** where mutation isn't needed.
- **ESM modules** (`import`/`export`) — no CommonJS (`require`) unless forced by a dependency.
- **Prefer `unknown` over `any`.** If `any` is truly needed, add a `// eslint-disable` comment with justification.
- **Use template literals** over string concatenation.

### Error Handling

- **Throw `Error` instances** (or subclasses) — never throw strings or plain objects.
- **Use discriminated unions** for result types when errors are expected:
  ```typescript
  type Result<T> = { ok: true; value: T } | { ok: false; error: Error };
  ```
- **Handle Promise rejections** — every `.then()` needs a `.catch()`, or use `async/await` with `try/catch`.
- **Use `satisfies` operator** for type narrowing when appropriate.

### Testing

- **Framework**: Vitest (preferred) or Jest. Configuration in `vitest.config.ts` or `jest.config.ts`.
- **Use `describe`/`it` blocks** with behavior-focused names.
- **Mock with `vi.mock()`** (Vitest) or `jest.mock()`. Prefer dependency injection over module mocking when possible.
- **Test file naming**: `<module>.test.ts` co-located or in `tests/` subdirectory.
- **Use `expectTypeOf`** (Vitest) for compile-time type testing.

### Project Structure

```
project/
├── src/
│   ├── index.ts
│   └── ...
├── tests/
│   ├── unit/
│   ├── integration/
│   └── agent/
├── package.json
├── tsconfig.json
├── eslint.config.mjs
└── vitest.config.ts
```

### Dependencies

- **Pin exact versions** in `package.json` for applications. Use ranges for libraries.
- **Separate `devDependencies`** from `dependencies` — type packages, test tools, and linters are dev-only.
- **Prefer smaller packages** over kitchen-sink frameworks. Check bundle size before adding.
- **Use `npm ci`** in CI — not `npm install` (ensures deterministic builds from lockfile).

### Async Patterns

- **Prefer `async/await`** over `.then()` chains.
- **Use `Promise.all()`** for independent async operations — parallelize where possible.
- **Use `AbortController`** for cancellable operations (fetch, long-running tasks).
- **Never use `setTimeout` for control flow** — use proper async patterns or event-driven approaches.

### Performance

- **Avoid unnecessary object spread** in hot paths — spread creates new objects.
- **Use `Map` and `Set`** over plain objects for dynamic key collections.
- **Lazy import** heavy modules with `await import()` when they're not always needed.
