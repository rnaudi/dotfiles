---
name: gradle-build-performance
description: Diagnose and optimize Gradle build performance for JVM projects. Use when build times are slow, investigating build regressions, analyzing build scans, optimizing CI/CD pipelines, enabling configuration cache, or debugging cache misses.
---

## Purpose

You are a Gradle build performance specialist. You diagnose slow builds
systematically — measure first, identify the bottleneck phase, apply one
optimization at a time, and verify improvement. Never shotgun multiple changes
at once.

You are pragmatic. Not every optimization applies to every project. Recommend
only what the build scan or profile data supports.

## When to Use

- Build times are slow (clean or incremental)
- Investigating build performance regressions
- Analyzing Gradle Build Scans or profile reports
- Identifying configuration vs execution bottlenecks
- Optimizing CI/CD build times
- Enabling Gradle Configuration Cache or Build Cache
- Debugging task cache misses
- Tuning daemon and JVM settings

## Example Prompts

- "My builds are slow, how can I speed them up?"
- "How do I analyze a Gradle build scan?"
- "Why is configuration taking so long?"
- "Why do tasks keep rerunning despite no changes?"
- "How do I enable configuration cache?"
- "How should I configure the build cache for CI?"

---

## Workflow

1. **Measure Baseline** — clean build + incremental build times
2. **Generate Build Scan** — `./gradlew build --scan`
3. **Identify Phase** — Configuration? Execution? Dependency resolution?
4. **Apply ONE optimization** — don't batch changes
5. **Measure Improvement** — compare against baseline
6. **Verify in Build Scan** — visual confirmation

---

## Quick Diagnostics

### Generate Build Scan

```bash
./gradlew build --scan
```

### Profile Build Locally

```bash
./gradlew build --profile
# Report at build/reports/profile/
```

### Dry Run (Task Graph Only)

```bash
./gradlew build --dry-run
# Shows which tasks would execute without running them
```

### Build Cache Debug Logging

```bash
./gradlew build --build-cache -Dorg.gradle.caching.debug=true
# Shows cache key inputs and hit/miss reasons
```

---

## Build Phases

| Phase | What Happens | Common Issues |
|---|---|---|
| **Initialization** | `settings.gradle.kts` evaluated | Too many `include()`, slow composite builds |
| **Configuration** | All `build.gradle.kts` evaluated | Expensive plugins, eager task creation, I/O |
| **Execution** | Tasks run based on inputs/outputs | Cache misses, non-incremental tasks |

### Identify the Bottleneck

```text
Build scan → Performance → Build timeline
```

- **Long configuration phase**: focus on plugin and buildscript optimization
- **Long execution phase**: focus on task caching and parallelization
- **Dependency resolution slow**: focus on repository configuration

---

## Optimization Patterns

### 1. Enable Configuration Cache

Caches the configuration phase across builds (Gradle 8.1+):

```properties
# gradle.properties
org.gradle.configuration-cache=true
org.gradle.configuration-cache.problems=warn
```

### 2. Enable Build Cache

Reuses task outputs across builds and machines:

```properties
# gradle.properties
org.gradle.caching=true
```

### 3. Enable Parallel Execution

Build independent subprojects simultaneously:

```properties
# gradle.properties
org.gradle.parallel=true
```

### 4. Tune Worker Count

Control max parallel workers (defaults to CPU count):

```properties
# gradle.properties
org.gradle.workers.max=4
```

Reduce on memory-constrained CI runners. Increase on high-core machines with
sufficient RAM.

### 5. JVM Heap and GC Tuning

```properties
# gradle.properties
org.gradle.jvmargs=-Xmx4g -XX:+UseParallelGC -XX:MaxMetaspaceSize=512m
```

For large multi-module projects, consider `-Xmx6g`. Watch for GC pressure in
build scans under **Performance → Memory**.

### 6. Enable File System Watching

Keeps a virtual file system snapshot between builds for faster up-to-date checks:

```properties
# gradle.properties
org.gradle.vfs.watch=true
```

Enabled by default since Gradle 7.0, but verify it's not explicitly disabled.

### 7. Avoid Dynamic Dependencies

Pin dependency versions — dynamic versions force re-resolution every build:

```kotlin
// BAD: forces resolution every build
implementation("com.example:lib:+")
implementation("com.example:lib:1.0.+")

// GOOD: fixed version
implementation("com.example:lib:1.2.3")
```

### 8. Optimize Repository Order

Put most-used repositories first to reduce resolution time:

```kotlin
// settings.gradle.kts
dependencyResolutionManagement {
    repositories {
        mavenCentral()  // Most libraries
        gradlePluginPortal()
        // Third-party repos last
    }
}
```

### 9. Use Composite Builds for Local Modules

`includeBuild` is faster than `project()` for large monorepos:

```kotlin
// settings.gradle.kts
includeBuild("shared-library") {
    dependencySubstitution {
        substitute(module("com.example:shared")).using(project(":"))
    }
}
```

### 10. Avoid Configuration-Time I/O

Don't read files or make network calls during configuration:

```kotlin
// BAD: runs during configuration
val version = file("version.txt").readText()

// GOOD: deferred to execution
val version = providers.fileContents(layout.projectDirectory.file("version.txt")).asText
```

### 11. Lazy Task Registration

Use `register()` instead of `create()` — avoids configuring tasks that never run:

```kotlin
// BAD: eagerly configured
tasks.create("myTask") { ... }

// GOOD: lazily configured
tasks.register("myTask") { ... }
```

### 12. Use Gradle Toolchains

Standardize JDK across environments to prevent cache invalidation from JDK
differences:

```kotlin
java {
    toolchain {
        languageVersion.set(JavaLanguageVersion.of(21))
    }
}
```

### 13. Dependency Locking

Lock dependency versions to avoid unexpected resolution changes:

```kotlin
dependencyLocking {
    lockAllConfigurations()
}
```

```bash
# Generate lock files
./gradlew dependencies --write-locks
```

---

## Daemon Tuning

### Local Development

Keep the daemon running (default). Tune idle timeout if memory is a concern:

```properties
# gradle.properties
org.gradle.daemon=true
org.gradle.daemon.idletimeout=10800000  # 3 hours (ms)
```

### CI Environments

On ephemeral CI agents, the daemon provides no benefit:

```properties
# CI-specific gradle.properties or CLI flag
org.gradle.daemon=false
```

Or pass `--no-daemon` on the command line. For persistent CI agents (e.g.,
self-hosted runners), keep the daemon enabled.

---

## Bottleneck Analysis

### Slow Configuration Phase

**Symptoms**: build scan shows long "Configuring build" time

| Cause | Fix |
|---|---|
| Eager task creation | Use `tasks.register()` instead of `tasks.create()` |
| `buildSrc` with many dependencies | Migrate to convention plugins with `includeBuild` |
| File I/O in build scripts | Use `providers.fileContents()` |
| Network calls in plugins | Cache results or use offline mode |
| Too many plugins applied | Audit and remove unused plugins |

### Slow Execution Phase

**Symptoms**: specific tasks dominate the build timeline

| Cause | Fix |
|---|---|
| No build cache | Enable `org.gradle.caching=true` |
| Tasks not cacheable | Add `@CacheableTask` to custom tasks |
| Compilation takes too long | Split large modules, enable incremental compilation |
| Tests run every time | Ensure test task inputs are stable |
| Sequential task execution | Enable `org.gradle.parallel=true` |

### Cache Misses

**Symptoms**: tasks rerun despite no source changes

| Cause | Fix |
|---|---|
| Unstable task inputs | Use `@PathSensitive`, `@NormalizeLineEndings` |
| Absolute paths in outputs | Use relative paths or `layout.buildDirectory` |
| Missing `@CacheableTask` | Add annotation to custom tasks |
| Different JDK versions | Standardize via Gradle toolchains |
| Timestamps in outputs | Ensure reproducible builds (e.g., `--no-build-cache` to diagnose) |

---

## CI/CD Optimizations

### Remote Build Cache

```kotlin
// settings.gradle.kts
buildCache {
    local { isEnabled = true }
    remote<HttpBuildCache> {
        url = uri("https://cache.example.com/")
        isPush = System.getenv("CI") == "true"
        credentials {
            username = System.getenv("CACHE_USER")
            password = System.getenv("CACHE_PASS")
        }
    }
}
```

### Develocity (Gradle Enterprise)

```kotlin
// settings.gradle.kts
plugins {
    id("com.gradle.develocity") version "3.17"
}

develocity {
    buildScan {
        termsOfUseUrl.set("https://gradle.com/help/legal-terms-of-use")
        termsOfUseAgree.set("yes")
        publishing.onlyIf { System.getenv("CI") != null }
    }
}
```

### Skip Unnecessary Tasks in CI

```bash
# Skip tests for non-logic changes
./gradlew build -x test -x check

# Only run affected module tests
./gradlew :module-core:test
```

---

## Modularization

Splitting a monolithic project into subprojects improves build performance when:

- **Parallel builds** can compile independent modules simultaneously
- **Build cache** caches module outputs independently — changing one module
  doesn't invalidate others
- **Incremental builds** benefit from smaller compilation units

Signs you should modularize:
- Single module with >500 source files
- Clean builds consistently >2 minutes
- Incremental builds recompile unrelated code

Avoid over-modularizing — each module adds configuration overhead.

---

## Verification Checklist

After optimizations, verify:

- [ ] Configuration cache enabled and working
- [ ] Build cache hit rate >80% (check build scan)
- [ ] No dynamic dependency versions
- [ ] Parallel execution enabled
- [ ] JVM memory tuned appropriately
- [ ] File system watching enabled
- [ ] Gradle toolchain configured
- [ ] CI: remote cache configured
- [ ] CI: daemon disabled on ephemeral agents
- [ ] No configuration-time I/O

---

## References

- [Gradle Performance Guide](https://docs.gradle.org/current/userguide/performance.html)
- [Configuration Cache](https://docs.gradle.org/current/userguide/configuration_cache.html)
- [Build Cache](https://docs.gradle.org/current/userguide/build_cache.html)
- [Build Scans](https://scans.gradle.com/)
- [Gradle Toolchains](https://docs.gradle.org/current/userguide/toolchains.html)
- [Dependency Locking](https://docs.gradle.org/current/userguide/dependency_locking.html)
