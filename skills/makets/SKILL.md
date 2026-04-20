---
name: makets
description: Create and evolve make.ts scripts — ad-hoc shell commands captured as reproducible Deno+dax scripts following matklad's pattern
---

## What is make.ts

matklad's pattern: instead of typing ad-hoc commands into the shell and relying
on Up-arrow history, capture them into a `make.ts` file and run `./make.ts`.
Even one-off commands benefit because they take several tries to get right.
The file evolves incrementally from throwaway to proper script.

## Stack

- **Runtime**: Deno (single binary, no setup, built-in TypeScript, `deno fmt`, `deno lsp`)
- **Subprocess**: `@david/dax` — tagged template `$` for safe process spawning, no shell middleman
- **Args**: `@std/cli/parse-args` — only when flags are needed
- **Typed errors**: `neverthrow` (`Result<T, E>`) — only when error handling matters
- **All imports use inline jsr:/npm: specifiers** — no deno.json needed

## Scaffold (new file)

When creating a new make.ts, start with this minimal template:

```ts
#!/usr/bin/env -S deno run --allow-all
import $ from "jsr:@david/dax@0.44.2";

async function main() {
  // ad-hoc commands go here
}

if (import.meta.main) {
  await main();
}
```

Add imports only as needed. Don't front-load neverthrow or parseArgs
unless the user's request requires them.

## Evolving an existing file

If make.ts already exists:
1. Read and understand it first
2. Add new functions, commands, or flags alongside existing ones
3. Don't rewrite or remove existing logic unless explicitly asked
4. Keep the same import style and structure

## Reproducibility rules

These are non-negotiable:

1. **Cleanup created resources**: If the script creates temp files, containers,
   helm releases, API resources, etc. — clean them up. Use `try/finally` blocks.
   Use `.noThrow()` on cleanup commands (the resource may not exist yet).

2. **Idempotent by default**: Re-running must be safe. Kill old processes before
   starting new ones. Delete old output before creating new output.
   Use `.noThrow()` on cleanup-before-create patterns:
   ```ts
   await $`rm -f output.json`.noThrow();
   await $`curl ... -o output.json`;
   ```

3. **Caching**: If the script caches results (downloaded files, API responses,
   compiled artifacts), add a `--fresh` flag via parseArgs to bypass the cache.
   Document what is cached and where.

4. **Temp files**: Use `Deno.makeTempFile()` or `Deno.makeTempDir()`.
   Always clean up in `finally`. Never leave temp files behind.

## SIGINT and AbortController

Only add when the script does long-running parallel work, background processes,
or manages a server lifecycle. Don't add it for simple sequential scripts.

When needed, use this pattern:

```ts
const abort = new AbortController();
let interrupted = false;

Deno.addSignalListener("SIGINT", () => {
  if (interrupted) Deno.exit(130);
  interrupted = true;
  console.error("\nInterrupted, cleaning up...");
  abort.abort();
});

// Pass abort.signal to long-running commands:
await $`long-running-cmd`.signal(abort.signal).noThrow();
```

## dax patterns reference

- `` await $`cmd arg1 arg2` `` — run command, throw on non-zero exit
- `` await $`cmd`.text() `` — capture stdout as string
- `` await $`cmd`.json() `` — capture stdout as parsed JSON
- `` await $`cmd`.noThrow() `` — don't throw on non-zero exit
- `` await $`cmd`.quiet() `` — suppress all output
- `` await $`cmd`.quiet("stdout") `` — suppress only stdout
- `` await $`cmd`.env({ KEY: "val" }) `` — pass environment variables
- `` await $`cmd`.signal(abort.signal) `` — propagate cancellation
- `` $`cmd`.spawn() `` — spawn without awaiting (for background processes)
- `` await $.sleep("5s") `` — sleep with human-readable duration
- `$.log()`, `$.logStep()`, `$.logLight()`, `$.logWarn()`, `$.logError()` — structured logging

## Concurrency

Use `Promise.all` for parallel work:

```ts
await Promise.all([
  $`curl https://api.example.com/endpoint-1`,
  $`curl https://api.example.com/endpoint-2`,
]);
```

Use `.spawn()` for background processes that outlive a single await:

```ts
const server = $`./serve`.spawn();
try {
  await $`curl http://localhost:8080/health`;
  // ... do work ...
} finally {
  server.kill();
  await server;
}
```

## CLI flags (when needed)

```ts
import { parseArgs } from "jsr:@std/cli@1.0.27/parse-args";

const flags = parseArgs(Deno.args, {
  boolean: ["fresh", "verbose"],
  string: ["target"],
  default: { fresh: false, verbose: false },
});
```

## After writing the file

1. `chmod a+x make.ts`
2. Add `make.ts` to `.git/info/exclude` if in a git repo and not already excluded
3. Show the user the result and suggest: `./make.ts`

## Style

- Single file. This is a scratchpad, not production code.
- Top-level functions. `async function main()` as entry.
- `if (import.meta.main)` guard at the bottom.
- Keep it readable. Comments for non-obvious things.
- Grow incrementally — start minimal, add complexity only when needed.
