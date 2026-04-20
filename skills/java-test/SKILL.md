---
name: java-test
description: >
  Principles and coding practices for writing Java tests.
  Use when writing, reviewing, or refactoring Java tests.
  Applies to unit and integration tests. Framework-agnostic principles,
  examples use JUnit 5 + AssertJ syntax.
---

# Java Test Skill

## 1. Philosophy

Three principles drive every decision.

**CI = change detection.**
The purpose of a test is: if something changes, a test must fail.
Coverage is a change-detection gate, not a quality metric.
Linting and formatting are tests too — they detect change.

**One harness, one entry point.**
Tests don't know where they run — local, CI, staging.
One test suite, one way to run it. No environment-specific test paths.
The same suite runs against fakes and against real implementations.

**Resource-driven boundaries.**
Boundaries follow resources: CPU, RAM, disk, network.
Pure domain logic has no IO — it's fast to test.
IO lives at the edges. Push it there. Test the edges with integration tests.
This gives you the testing split for free: pure domain = unit tests, IO boundaries = integration tests.

## 2. Writing a Test

### The pattern

A test is: arrange an input, call the SUT's public API, compare the result to an expected value.

```java
@Test
void parse_validJson_returnsOrder() {
    var parser = new OrderParser();

    var order = parser.parse("""
        {"id": "abc", "amount": 42}
        """);

    assertThat(order).isEqualTo(new Order("abc", 42));
}
```

### Rules

**Black-box the SUT.**
Test the public API. Never test private methods. Never reach into internals.
The test is a caller — it knows what the SUT promises, nothing more.

**Whole-object comparison.**
When the SUT returns a value object, construct the expected instance and compare directly with `isEqualTo`.
Never assert field-by-field. Field-by-field assertions silently pass when a new field is added — defeating change detection.

```java
// BAD — adding a new field won't break this test
assertThat(order.id()).isEqualTo("abc");
assertThat(order.amount()).isEqualTo(42);

// GOOD — any structural change forces a test update
assertThat(order).isEqualTo(new Order("abc", 42));
```

**Visible test data.**
Inline the values. A reader must understand the test without scrolling or jumping to a setup method.
If data construction is complex, use a factory method in the same test class — not a shared fixture in another file.

**One logical assertion per test.**
Each test proves one behavior. One `isEqualTo(expected)` is one logical assertion.
Multiple assertions on different behaviors belong in separate tests.

**Naming: `method_scenario_expectedResult`.**
The test name is documentation. It tells you what broke without reading the body.
`parse_validJson_returnsOrder`, `withdraw_insufficientFunds_throwsException`.

### Java idioms for tests

- Use `var` for local variables — reduces noise.
- Use records for expected values — they give you `equals` for free.
- Use text blocks for inline JSON, XML, SQL — keeps data visible.
- Use sealed types to make illegal states unrepresentable — fewer error-path tests needed.

## 3. Fakes and Contracts

**Fakes over mocks.**
A fake implements the real interface with a simple in-memory implementation.
A mock asserts on method calls — interactions the real system never promised.
Fakes test behavior. Mocks test wiring.

```java
// Fake: implements the real interface
class InMemoryOrderRepository implements OrderRepository {
    private final Map<String, Order> store = new HashMap<>();

    @Override
    public void save(Order order) { store.put(order.id(), order); }

    @Override
    public Optional<Order> findById(String id) { return Optional.ofNullable(store.get(id)); }
}
```

**Contract testing.**
The same test suite runs against the fake and against the real implementation.
This is how you prevent fake drift. If the fake passes and the real fails, the fake is lying.

```java
abstract class OrderRepositoryContract {
    abstract OrderRepository createRepository();

    @Test
    void save_thenFindById_returnsSameOrder() {
        var repo = createRepository();
        var order = new Order("abc", 42);

        repo.save(order);

        assertThat(repo.findById("abc")).contains(order);
    }
}

class InMemoryOrderRepositoryTest extends OrderRepositoryContract {
    @Override OrderRepository createRepository() { return new InMemoryOrderRepository(); }
}

class PostgresOrderRepositoryTest extends OrderRepositoryContract {
    @Override OrderRepository createRepository() { return new PostgresOrderRepository(dataSource); }
}
```

**Dirty database.**
Never assume an empty database. Another test, a parallel run, or leftover data from a previous run may have inserted rows.
Query by what you just created — filter by the known ID, not by "the only row in the table."

```java
// BAD — assumes empty table
assertThat(repo.findAll()).hasSize(1);

// GOOD — queries by what we created
assertThat(repo.findById(order.id())).contains(order);
```

## 4. Test Sizes — A Thinking Tool

Use Google's test size definitions as a reference for understanding what your test touches.
This is a thinking tool for design decisions, not a tagging scheme.

| Property    | Small        | Medium          | Large          |
|-------------|--------------|-----------------|----------------|
| Network     | No           | localhost only   | Yes            |
| Database    | No           | Yes              | Yes            |
| Filesystem  | No           | Yes              | Yes            |
| Threads     | No           | Yes              | Yes            |
| Sleep       | No           | Yes              | Yes            |
| System time | No           | Yes              | Yes            |
| Duration    | Milliseconds | Seconds          | Minutes        |
| Hermetic    | Yes          | Mostly           | Not guaranteed |

If a test touches network or database, it's not small. Knowing that tells you where it belongs in your resource-driven boundary model and how to think about its failure modes.

## 5. Anti-patterns

**Field-by-field assertions.** Compare the whole expected object. Field-by-field silently passes when new fields are added.

**Hidden setup in `@BeforeEach`.** If the setup changes what the test means, inline it. A test should be self-contained.

**`Thread.sleep()`.** Never. Use `Awaitility` or a `CountDownLatch` or redesign the contract to be synchronous.

**Mocks that assert on interactions.** `verify(repo).save(order)` asserts the SUT called a method — an implementation detail. Assert on observable behavior: the order exists after the operation.

**Testing private methods.** If you feel the need, the class is doing too much. Extract a new class with a public API and test that.

**Mock drift.** A mock returns whatever you tell it. Without contract tests, the mock and the real implementation diverge silently.

**TODOs without linked issues.** A `// TODO` in test code is a broken test you haven't written. Link it to an issue or delete it.
