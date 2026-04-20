---
name: go-style
description: >-
  Reference for writing idiomatic Go code based on Google's Go Style Guide.
  Use when writing, reviewing, or refactoring Go code. Covers naming,
  error handling, documentation, interfaces, testing, and common patterns.
  Project-specific rules in AGENTS.md take precedence over this skill
  when they conflict.
---

# Go Style Guide (Google)

Apply these guidelines when writing or reviewing Go code. Based on Google's
[Go Style Guide](https://google.github.io/styleguide/go/).

## Precedence

This skill provides Google's Go style recommendations as a reference.
**Project AGENTS.md rules always take precedence when they conflict.**

Known divergences where AGENTS.md overrides Google's guide:

| Topic | Google says | AGENTS.md says | Follow |
|-------|------------|---------------|--------|
| Functional options | Valid pattern | Banned | AGENTS.md |
| Assertion libraries | Avoid; use `cmp` + `fmt` | Uses `testify/assert` | AGENTS.md |
| Table-driven tests | Endorsed as standard | Prefer `check` functions | AGENTS.md |
| `any` type | Acceptable in new code | Banned | AGENTS.md |
| Import groups | 4 groups | 3 groups | AGENTS.md |

When reviewing code, apply Google's guidance for topics AGENTS.md does not
cover. For topics AGENTS.md does cover, follow AGENTS.md.

## 1. Style Principles

Attributes of readable Go code, in order of importance:

1. **Clarity** -- purpose and rationale are clear to the reader, not the author.
2. **Simplicity** -- accomplishes its goal in the simplest way possible.
3. **Concision** -- high signal-to-noise ratio.
4. **Maintainability** -- easy to modify correctly.
5. **Consistency** -- consistent with surrounding code, then the broader codebase.

### Least mechanism

Prefer the most standard tool that is sufficient:

1. Core language constructs (channels, slices, maps, loops, structs).
2. Standard library (HTTP client, template engine, etc.).
3. Well-known third-party libraries only when the above are insufficient.

Do not introduce complex machinery without a demonstrated need.

## 2. Naming

### MixedCaps always

Go uses `MixedCaps` or `mixedCaps`, never `snake_case`. Constants are
`MaxLength` (not `MAX_LENGTH`), unexported constants are `maxLength`
(not `max_length`). No `k` prefix (`kMaxBuffer` is wrong).

### Package names

- Lowercase only, no underscores, no mixed caps: `tabwriter` not `tabWriter`.
- Avoid uninformative names: `util`, `helper`, `common`, `model`.
- The package name qualifies its exports: `widget.New` not `widget.NewWidget`.

```go
// Good: package name provides context
package yamlconfig
func Parse(input string) (*Config, error)

// Bad: repeats the package name
func ParseYAMLConfig(input string) (*Config, error)
```

### Receivers

Short (1-2 letters), abbreviation of the type, consistent across all methods:

```go
func (t Tray) Push(item Item)      // not func (tray Tray)
func (ri *ResearchInfo) Summary()   // not func (info *ResearchInfo)
```

Never use `this` or `self`.

### Initialisms

`URL`, `ID`, `DB`, `HTTP` -- all caps when exported, all lower when unexported.
Never `Url`, `Id`, `Db`.

| English | Exported | Unexported |
|---------|----------|------------|
| URL     | `URL`    | `url`      |
| ID      | `ID`     | `id`       |
| gRPC    | `GRPC`   | `gRPC`     |
| DDoS    | `DDoS`   | `ddos`     |

### No Get prefix

Use `Counts()` not `GetCounts()`. Use `Compute` or `Fetch` when the
operation is expensive or involves IO.

### Variable name length proportional to scope

- Small scope (1-7 lines): single letter or short abbreviation is fine (`c`, `n`, `r`).
- Medium scope (8-15 lines): single descriptive word (`count`, `users`).
- Large scope (15-25 lines): more descriptive (`userCount`, `projectName`).
- Very large scope (25+ lines): multiple words if needed.

Familiar single-letter names for common types: `r` for `io.Reader` or
`*http.Request`, `w` for `io.Writer` or `http.ResponseWriter`, `i` for
loop indices.

### Avoid repetition

- **Package vs. symbol**: `db.Load` not `db.LoadFromDatabase`.
- **Variable vs. type**: `var users int` not `var numUsers int`; `var name string` not `var nameString string`.
- **Context vs. local**: in method `UserCount()`, use `count` not `userCount`.
- **Method vs. receiver**: `func (c *Config) WriteTo(w)` not `WriteConfigTo(w)`.

```go
// Bad: redundant everywhere
func (db *DB) UserCount() (userCount int, err error) {
    var userCountInt64 int64
    if dbLoadError := db.LoadFromDatabase("count(distinct users)", &userCountInt64); dbLoadError != nil {
        return 0, fmt.Errorf("failed to load user count: %s", dbLoadError)
    }
    userCount = int(userCountInt64)
    return userCount, nil
}

// Good: context makes names clear
func (db *DB) UserCount() (int, error) {
    var count int64
    if err := db.Load("count(distinct users)", &count); err != nil {
        return 0, fmt.Errorf("failed to load user count: %s", err)
    }
    return int(count), nil
}
```

## 3. Error Handling

### Return the `error` type

Always return `error`, not a concrete error type. A concrete `nil` pointer
can become a non-nil interface value.

```go
// Good
func Open(path string) (*File, error)

// Bad: concrete return can cause nil-interface bugs
func Open(path string) (*File, *PathError)
```

### Error strings

Lowercase, no trailing punctuation. They appear within other context.

```go
// Good
fmt.Errorf("something bad happened")

// Bad
fmt.Errorf("Something bad happened.")
```

### Handle errors immediately

Handle the error or return it. Never discard with `_` unless the function
is documented to never fail (and add a comment explaining why).

```go
// Good: handle first, happy path unindented
if err != nil {
    return fmt.Errorf("create proxy: %w", err)
}
// normal code continues here

// Bad: happy path inside else
if err != nil {
    // error handling
} else {
    // normal code indented unnecessarily
}
```

### No in-band errors

Don't return -1, "", or nil to signal errors. Use multiple return values.

```go
// Good: explicit ok signal
func Lookup(key string) (value string, ok bool)

// Bad: in-band error
func Lookup(key string) int  // returns -1 on error
```

### Wrapping: %v vs %w

Use `%w` when callers need to inspect the error chain with `errors.Is` or
`errors.As`. Use `%v` to create a new error that hides the original
(especially at system boundaries like RPC, IPC, storage).

```go
// %w: preserve error chain for callers
return fmt.Errorf("open config: %w", err)

// %v: at system boundary, hide internal details
return fmt.Errorf("couldn't find fortune database: %v", err)
```

### %w placement

Place `%w` at the end of the error string to mirror the error chain structure:

```go
// Good: newest context first, original error last
return fmt.Errorf("create proxy: %w", err)
```

**Exception**: sentinel errors go at the beginning for quick categorization:

```go
var ErrParse = fmt.Errorf("parse error")
var ErrParseInvalidHeader = fmt.Errorf("%w: invalid header", ErrParse)
```

### Structured errors

Use sentinel values for errors callers need to distinguish programmatically.
Use custom types when errors carry extra data. Always check with `errors.Is`
and `errors.As`, never with string matching.

```go
// Good: sentinel + errors.Is
var ErrNotFound = errors.New("not found")

if errors.Is(err, ErrNotFound) {
    // handle not found
}

// Bad: string matching
if regexp.MatchString(`not found`, err.Error()) { ... }
```

## 4. Documentation and Comments

### Doc comments on all exports

Every exported type and function gets a doc comment starting with the name.
Use articles ("A", "An", "The") to read naturally.

```go
// A Request represents a request to run a command.
type Request struct { ... }

// Encode writes the JSON encoding of req to w.
func Encode(w io.Writer, req *Request) { ... }
```

### Comment sentences

Doc comments are full sentences: capitalize and punctuate. End-of-line
comments on struct fields can be simple phrases.

```go
type Server struct {
    // BaseDir points to the base directory for Shakespeare's works.
    BaseDir string

    WelcomeMessage  string // displayed when user logs in
    ProtocolVersion string // checked against incoming requests
    PageLength      int    // lines per page (optional; default: 20)
}
```

### Package comments

Immediately above the `package` clause, no blank line between.

```go
// Package math provides basic constants and mathematical functions.
package math
```

### Don't restate the obvious

- **Context cancellation**: don't document that `ctx` cancellation stops the
  function. Do document if behavior differs (e.g., returns nil on cancel).
- **Concurrency**: don't document that read-only ops are safe or that mutating
  ops are not. Do document surprising cases (e.g., `Lookup` that mutates an
  LRU cache internally).
- **Parameters**: don't enumerate every parameter. Document only what is
  non-obvious or error-prone.

### Always document cleanup

If the caller must close, cancel, flush, or free something, say so explicitly.

```go
// NewTicker returns a new Ticker. The caller must call Stop when done
// to release associated resources.
func NewTicker(d time.Duration) *Ticker
```

### Signal boost unusual patterns

When code looks like a common pattern but does something subtly different,
add a comment to call attention to it:

```go
if err := doSomething(); err == nil { // if NO error
    // ...
}
```

## 5. Interfaces

### Consumer defines the interface

The package that uses the interface should define it, not the package that
implements it. Don't export an interface from a producer package "for mocking."

### Accept interfaces, return concrete types

Functions should accept interface parameters when flexibility is needed,
but return concrete types so callers have full access to the implementation.

### Don't create interfaces prematurely

Wait until you have a real need (testing, multiple implementations). A
concrete type is fine until proven otherwise.

### Keep interfaces small

One or two methods is ideal. The larger the interface, the weaker the
abstraction.

### Document thoroughly

Because an interface hides the implementation, its documentation must
compensate. Document behavior, contracts, and edge cases.

## 6. Language Patterns

### Struct literals: use field names

Always use field names for types from other packages. Position-based
literals break when fields are added or reordered.

```go
// Good
r := csv.Reader{
    Comma:   ',',
    Comment: '#',
}

// Bad
r := csv.Reader{',', '#', 4, false, false, false, false}
```

### Nil slices

Prefer `var s []T` (nil) over `s := []T{}` (empty). Both behave the same
for `len`, `cap`, `append`, and `range`. Use `len(s) == 0` to check
emptiness, not `s == nil`.

```go
// Good
var t []string

// Bad
t := []string{}
```

### Zero-value fields

Omit zero-value fields in struct literals when clarity allows. This draws
attention to the fields that matter.

```go
// Good: only non-default fields visible
ldb := leveldb.Open("/my/table", &db.Options{
    BlockSize:       1 << 16,
    ErrorIfDBExists: true,
})
```

### Don't panic

Reserve `panic` for invariant violations that indicate a programming error
(like the standard library's `reflect` package). Never let panics escape
package boundaries. At package boundaries, recover and convert to an error.

### Goroutine lifetimes

Always know when and how a goroutine exits. Document the exit conditions.
Use `sync.WaitGroup`, `context.Context`, or channels to manage lifetimes.
A goroutine leak is a resource leak.

### Synchronous functions preferred

Prefer synchronous functions that return results directly. Let the caller
manage concurrency with goroutines if needed. Callbacks and channels in
return values force specific concurrency patterns on the caller.

### Pass values for small types

Don't pointer-ify everything. Small structs, basic types, and slices (which
are already reference types) can be passed by value. Use pointers for large
types, mutation, or when nil is a meaningful signal.

### Function signatures on one line

Keep the full signature on one line. If it's too long, shorten by extracting
local variables at the call site, not by splitting the signature.

```go
// Good: extract locals to shorten the call
local := helper(some, parameters, here)
good := foo.Call(list, of, parameters, local)

// Bad: arbitrary line breaks in arguments
bad := foo.Call(long, list, of, parameters,
    with, arbitrary, line, breaks)
```

### Conditionals: no multi-line if

Don't break `if` conditions across lines (causes indentation confusion).
Extract boolean operands into local variables instead.

```go
// Good
inTransaction := db.CurrentStatusIs(db.InTransaction)
keysMatch := db.ValuesEqual(db.TransactionKey(), row.Key())
if inTransaction && keysMatch {
    return db.Error(db.TransactionError, "...")
}

// Bad: second line looks like the if body
if db.CurrentStatusIs(db.InTransaction) &&
    db.ValuesEqual(db.TransactionKey(), row.Key()) {
    return db.Error(db.TransactionError, "...")
}
```

## 7. Imports

### Grouping

Separate imports into groups with blank lines. Within each group, sort
alphabetically. See AGENTS.md for this project's specific group ordering.

### Renaming

Only rename imports to avoid collisions or to clarify uninformative names.
Prefer the `pkg` suffix for shadowed standard packages (e.g., `urlpkg`).
Use consistent local names across files.

### No dot imports

Never use `import . "package"`. It obscures where identifiers come from.

### Blank imports only in main

`import _ "package"` belongs in `main` packages or test files that need
side effects, not in library code.

## 8. Testing

### Failure messages: got before want

Include the function name, input, got, and want in failure messages.
A developer should be able to find the failing code from the message alone.

```go
if got, want := UserCount(tc.input), tc.want; got != want {
    t.Errorf("UserCount(%v) = %d, want %d", tc.input, got, want)
}
```

### Compare full structures

Don't assert field-by-field. When a struct gains a new field, full-value
comparison catches it immediately.

```go
// Good: one comparison, all fields visible
assert.Equal(t, expected, got)

// Bad: five separate assertions, easy to forget a field
assert.Equal(t, "abc", got.ID)
assert.Equal(t, 200, got.Status)
```

### Subtests

- Each subtest must be independent and runnable in isolation.
- Use descriptive names that work as identifiers (avoid spaces and slashes).

### t.Error vs t.Fatal

Prefer `t.Error` (continue) over `t.Fatal` (stop) when subsequent checks
provide useful diagnostic information. Use `t.Fatal` only when the test
cannot proceed meaningfully.

### Test helpers

- Always call `t.Helper()` so failures report the caller's line.
- Accept `testing.TB` to work with both `*testing.T` and `*testing.B`.
- Helpers validate inputs; they don't make correctness assertions on the SUT.
- Never call `t.Fatal` from a goroutine other than the test goroutine.

### Scope setup to tests that need it

Don't use package-level `init()` or `TestMain` for test setup unless every
test in the package truly needs it. Prefer per-test setup with `t.Cleanup`.

## 9. Global State

### Avoid package-level mutable state

Libraries should provide instance-based APIs. Global registries, singletons,
and service locators make tests interfere with each other and create hidden
dependencies.

### Litmus tests

Global state is problematic when:
- Two tests using it cannot run in parallel.
- The result depends on the order tests run.
- A test cannot clean up after itself.

Global state is acceptable when:
- It is logically constant (set once at init, never mutated).
- It is stateless (a pure function, a stateless codec).
- It does not leak side effects.

### Default instances

When convenience requires a "default," make it a thin proxy that delegates
to an instance-based API. The instance-based API must remain the primary
public surface.

## 10. Function Design

### Option structs for complex configuration

When a function needs many optional parameters, use an options struct
as the last argument. Zero values should be safe defaults.

```go
// Good
type Options struct {
    Port    int    // optional; default: 8080
    Timeout time.Duration // optional; default: 30s
}

func NewServer(addr string, opts Options) (*Server, error)
```

### Long string literals

Don't break string literals for line length. Break at format boundaries
and group arguments semantically.

```go
// Good: break after format string, group by semantic meaning
log.Warningf("Database key (%q, %d, %q) incompatible in transaction started by (%q, %d, %q)",
    currentCustomer, currentOffset, currentKey,
    txCustomer, txOffset, txKey)

// Bad: broken mid-string
log.Warningf("Database key (%q, %d, %q) incompatible in"+
    " transaction started by (%q, %d, %q)",
    currentCustomer, currentOffset, currentKey, txCustomer,
    txOffset, txKey)
```
