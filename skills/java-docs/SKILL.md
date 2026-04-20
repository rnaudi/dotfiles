---
name: java-docs
description: >-
  Write and review Java documentation comments. Use when adding or editing
  Javadoc, package docs, module docs, or inline comments in Java code. Prefer
  minimal, human-sounding docs: explain intent, constraints, and usage without
  boilerplate or trivia.
---

# Java Docs

Write docs the way a teammate would explain the code in review: short, direct,
and only when they add information the code does not already carry.

## Default stance

- Prefer less Javadoc, written better.
- Document public APIs and non-obvious behavior. Skip boilerplate.
- Start with a plain-English summary sentence.
- Explain why, constraints, invariants, edge cases, or call patterns.
- Add examples only when usage is easier to learn from a snippet.
- Delete comments that only restate names, types, or control flow.

If the local codebase already has stronger documentation rules, follow those.

## Where to use Javadoc

- Public classes, interfaces, records, enums, and methods that form an API.
- Package docs in `package-info.java` when the package needs an overview.
- Module docs in `module-info.java` when dependencies or boundaries need context.

Usually skip Javadoc for:

- Private helpers with obvious behavior.
- Getters, setters, constructors, and builders whose names already say enough.
- Overrides that add no contract beyond the parent type.

## How to write it

Keep Javadoc compact. A good default shape is:

1. One summary sentence.
2. One short paragraph for rationale or constraints, if needed.
3. `@param`, `@return`, `@throws` only when they add information that the signature does not.
4. `<pre>{@code ...}</pre>` example only when it genuinely teaches usage.

Write like this:

```java
/**
 * Refreshes the cached signing keys for the tenant.
 *
 * Call this after a key rotation event. The method replaces the full cache in
 * one swap so readers never observe a partial update.
 */
void refreshKeys(TenantId tenantId);
```

Not like this:

```java
/**
 * Refreshes keys.
 *
 * @param tenantId the tenant id
 */
void refreshKeys(TenantId tenantId);
```

## Comment taxonomy

### API comments

Use Javadoc for the contract: what the caller can rely on, when to call it, and
what matters operationally.

Good topics:

- lifecycle expectations
- ordering requirements
- thread-safety or transaction assumptions
- external API quirks
- nullability or validation rules

### Why comments

Use inline `//` or a short Javadoc paragraph to explain a decision the code
cannot justify by itself.

```java
// Remove the old token first so retries never leave two active records.
repository.delete(tokenId);
repository.insert(newToken);
```

### Teacher comments

Teach the math, protocol, or domain rule behind a block when that knowledge is
not obvious from the code.

```java
// Okta sends event times in seconds, while our audit model stores milliseconds.
long eventTimeMillis = eventTimeSeconds * 1000;
```

### Guide comments

Break a long method into a few local steps when extraction would hurt clarity.
If many guide comments are needed, extract helpers instead.

```java
// Step 1: validate the external token before we touch local state.
// Step 2: map claims into our account model.
// Step 3: persist and emit the login event.
```

### Checklist comments

Use short maintenance reminders only when tooling cannot enforce them yet.
Prefer linking the related test, validation path, or issue.

```java
// If you add another grant type, update OAuthRequestValidator and its tests.
```

### Debt comments

Mark temporary shortcuts with an exit condition. Prefer `TODO(issue)` or
`FIXME(issue)` over vague notes.

```java
// TODO(PLAT-182): remove the fallback once all clients send region headers.
```

## Trivial comments to remove

Delete comments like these:

- `// Increment i`
- `/** Returns the user. */`
- `@param userId the user id`
- `@return the result`

Replace them only if there is real context to add.

## Review checklist

- Does the comment teach something the code does not?
- Is the first sentence a clean summary instead of boilerplate?
- Are tags present only when they add useful contract details?
- Would a maintainer learn the reason, constraint, or usage quickly?
- Can any comment be deleted with no loss of understanding?
