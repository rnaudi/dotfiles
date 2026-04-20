---
name: project-context
description: Gather project architecture and codebase context to bootstrap a session
---

## Steps

1. Find and read any high-level project documentation at or near the project
   root. Look for files like: architecture.md, AGENTS.md, README.md,
   CONTRIBUTING.md, docs/architecture.md, docs/overview.md, or similar.
   Skip files that don't exist — don't error on missing docs.

2. Explore the top-level directory structure to understand the project layout.
   Identify key directories, their purposes, and the tech stack.

3. If the user provided additional instructions (e.g. "read src/api",
   "focus on the auth layer"), follow those instructions — read the specified
   files/folders and incorporate them into the context.

4. Produce a concise context summary covering:
   - Project overview and tech stack
   - Directory structure and key modules
   - Important patterns or conventions
   - Anything from the user's extra instructions

## Guidelines

- Keep the summary concise — this is meant to bootstrap a session, not
  document everything
- Read files directly in the main session so the raw context is available
  for follow-up work
- If no extra instructions are provided, just do steps 1-2 and summarize
