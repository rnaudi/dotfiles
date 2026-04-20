---
name: jj-workflow
description: >-
  Parallel task development using jj workspaces. Activate when the user asks
  to create a workspace, is working from a non-default jj workspace directory,
  or mentions jj workspace workflow. Covers setup, working, handoff, and cleanup.
---

## 1. Context Detection

Run this **before every other section**. Do not skip it.

```bash
jj workspace root          # are we in a jj repo?
jj workspace list          # which workspaces exist? which one are we in?
jj log -r 'heads(bookmarks())' --no-graph --limit 5   # what branches exist?
```

Derive these values and carry them through the rest of the skill:

| Variable       | How to derive                                                        |
|----------------|----------------------------------------------------------------------|
| `PROJECT`      | `basename $(jj workspace root)` from the **default** workspace       |
| `BASE`         | Look for `main`, then `master`, then `develop` bookmarks, in order. If ambiguous or none found, **ask the user**. |
| `TASK_NAME`    | From the user's request, normalized to kebab-case. **Propose it and ask the user to confirm.** Never guess silently. |
| `WORKSPACE`    | Which workspace the cwd belongs to (from `jj workspace list`)        |

**Routing:**

- If we are in the **default** workspace and the user wants to start a task -> go to **Setup**.
- If we are in a **non-default** workspace -> go to **Resume**.
- If the user asks to clean up -> go to **Cleanup**.

If `jj workspace root` fails, stop. This is not a jj repository.

## 2. Setup

### Directory convention

Default: create the workspace as a **sibling** to the project root.

```
../<PROJECT>-<TASK_NAME>
```

Before defaulting, check for an existing convention:
1. Does `.workspaces/` or `workspaces/` exist in the project root? If yes, use it.
2. Does project documentation (`AGENTS.md`, `README.md`, or `docs/`) specify a preference? If yes, follow it.
3. Otherwise, use the sibling directory default above.

If using a **project-local** directory (`.workspaces/`, `workspaces/`):
- Check `.gitignore` and `.jjignore` for the directory pattern.
- If missing, add it and describe the change: `jj describe -m "chore: gitignore workspace directory"`.

### Steps

Run each command and **verify it succeeded** before continuing. If any step
fails, report the error to the user and stop.

**Step 1** -- Create the workspace (from the project root):

```bash
jj workspace add ../<PROJECT>-<TASK_NAME>
```

**Step 2** -- All subsequent commands use `workdir` set to the new workspace
path. Never use `cd` in bash -- it does not persist between tool calls.

```bash
# workdir = ../<PROJECT>-<TASK_NAME>
jj new <BASE> -m "<TASK_NAME>: <description>"
```

**Step 3** -- Create a bookmark to track the work:

```bash
# workdir = ../<PROJECT>-<TASK_NAME>
jj bookmark create <TASK_NAME> -r @
```

**Step 4** -- Baseline verification. If the project has a fast check command
(type check, lint, or build -- not a full test suite), run it to verify the
workspace starts clean. If it fails, report the failure and let the user
decide whether to proceed.

**Step 5** -- Report status:

```
Workspace created: ../<PROJECT>-<TASK_NAME>
Bookmark:          <TASK_NAME>
Base:              <BASE>
Status:            ready

All commands in this workspace use workdir=../<PROJECT>-<TASK_NAME>
```

## 3. Resume

When the agent is activated inside an existing non-default workspace, it
needs to understand current state before doing anything.

Read the workspace state:

```bash
jj status                  # working copy state
jj log -r @ --no-graph     # current commit
jj bookmark list           # find the task bookmark
jj log -r ':@' --limit 10  # recent history to identify base
```

From this, derive:
- `TASK_NAME`: the bookmark pointing at or near `@`.
- `BASE`: the ancestor branch the work diverged from.
- Current state of the working copy (clean, modified files, etc.).

Report this to the user before proceeding:

```
Workspace:  <workspace-name>
Bookmark:   <TASK_NAME> -> <change-id>
Base:       <BASE>
Working copy: <clean | N files modified>
```

Then continue to the **Working** phase.

## 4. Working

All commands use `workdir=<workspace-path>`.

- **Single-commit work**: write code, then update the commit message with
  `jj describe -m "<TASK_NAME>: <updated description>"` after meaningful
  units of work. Not after every file -- after logical milestones.

- **Multi-commit work**: when the current commit is a complete unit and new
  work should be a separate commit:
  ```bash
  jj new -m "<TASK_NAME>: <next unit description>"
  jj bookmark set <TASK_NAME> -r @
  ```
  These two commands are **always paired**. `jj new` does not move bookmarks.
  Forgetting `bookmark set` is the most common mistake.

- Review changes periodically:
  ```bash
  jj diff                        # working copy changes
  jj log -r '<BASE>..@'          # full change stack
  ```

- **Boundaries**: never touch commits outside this workspace's change stack.
  Never modify another workspace's working-copy commit.

## 5. Handoff

Before the user takes over for push and PR:

**Step 1** -- Ensure the bookmark is at the tip:

```bash
jj bookmark set <TASK_NAME> -r @
```

**Step 2** -- Show the change stack and full diff:

```bash
jj log -r '<BASE>..@'
jj diff --from <BASE>
```

**Step 3** -- Report a summary:

```
Bookmark:   <TASK_NAME> (at tip)
Commits:    N commits on top of <BASE>
Changed:    <brief summary of what changed and why>

Next steps (from the main workspace):
  jj git push -b <TASK_NAME>
  gh pr create ...
```

## 6. Cleanup

Run from the **main/default workspace**, not from the workspace being removed.

```bash
jj workspace forget <workspace-name>
rm -rf ../<PROJECT>-<TASK_NAME>
jj bookmark delete <TASK_NAME>
```

Verify the workspace exists (`jj workspace list`) before running `forget`.

## 7. Recovery

**Stale working copy**: another workspace modified shared history.
```bash
jj workspace update-stale
```

**Bookmark not advancing**: `jj new` was run without `jj bookmark set`.
Fix by pointing the bookmark at the current tip:
```bash
jj bookmark set <TASK_NAME> -r @
```

**Colocated `.git/` missing**: additional workspaces only get `.jj/`, not
`.git/`. Tools that need `.git/` (IDEs, `gh`, etc.) require:
```bash
GIT_DIR=<main-workspace>/.git <command>
```

## 8. Reference

**Mental model**: all workspaces share one commit graph and repo store. Each
workspace has its own working-copy commit (`@`) and its own files on disk.
Bookmarks are shared. There is no staging area -- jj auto-snapshots on every
command.

**Commands**:

| Command                          | What it does                        |
|----------------------------------|-------------------------------------|
| `jj workspace add <path>`       | Create a new workspace              |
| `jj workspace list`             | List all workspaces                 |
| `jj workspace forget <name>`    | Remove workspace (keeps files)      |
| `jj workspace root`             | Show workspace root path            |
| `jj workspace update-stale`     | Sync stale workspace                |
| `jj new <rev> -m "msg"`         | Create child commit                 |
| `jj bookmark create <name> -r @`| Create bookmark at working copy     |
| `jj bookmark set <name> -r @`   | Move bookmark to working copy       |
| `jj describe -m "msg"`          | Update current commit message       |
| `jj diff --from <rev>`          | Diff against a revision             |
| `jj log -r '<base>..@'`         | Show commits from base to here      |

## 9. Example

Task: `auth-module`, base: `develop`, project: `player-authx`.

```bash
# setup (from project root, workdir = .)
jj workspace add ../player-authx-auth-module

# all subsequent commands: workdir = ../player-authx-auth-module
jj new develop -m "auth-module: implement OAuth2 flow"
jj bookmark create auth-module -r @
# ... work ...
jj describe -m "auth-module: implement OAuth2 token exchange"

# second commit
jj new -m "auth-module: add integration tests"
jj bookmark set auth-module -r @

# handoff
jj bookmark set auth-module -r @
jj log -r 'develop..@'
jj diff --from develop
```
