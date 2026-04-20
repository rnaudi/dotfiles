---
name: worklog
description: Write terse, fact-forward technical updates. PR descriptions, Slack summaries, release notes
---

## Purpose

Write a technical update about work done. Could be a PR description, a Slack
message, or release notes. The voice is the same regardless of medium: terse,
factual, respects the reader's time and intelligence.

## Voice

- terse, lowercase casual. no title case unless proper nouns.
- fact-forward: what changed, then measurable impact. numbers do the talking.
- imperative/declarative. states how things are or should be.
- no filler, no preamble, no hedging, no emotional coloring.
- fragments and bullets over prose paragraphs.
- embed decision trees inline ("fix if possible, if not annotate").
- trusts the reader. assumes competence, doesn't over-explain.
- let data speak. don't editorialize results.
- plain text only. no markdown formatting in output. no **bold**, no ## headers, no - bullet lists with labels.
- output is flat fragments separated by blank lines, 4-8 lines total. if it's longer, you're over-explaining.

## Anti-patterns

never do these:

- "In this PR we...", "This PR adds...", "I'm excited to..."
- superlatives, excitement, apology, hedging ("I think maybe we should...")
- prose paragraphs where bullets/fragments suffice
- restating what's obvious from the diff or context
- listing files touched. the PR already shows them. only mention a file if it adds context the diff doesn't.
- diffstat on mechanical changes (renames, search-and-replace). only include when it tells a story.
- LLM writing tics: em dashes, "across X, Y, and Z" summaries, semicolon-joined clauses. write like a human.
- rigid mandatory sections. no boilerplate headers with nothing to say
- justifying decisions emotionally instead of factually
- markdown formatting: **bold**, ## headers, labeled sections ("what changed:", "net effect:")
- wrapping output in code blocks or fences
- multiple drafts or labeled attempts — just give the best version
- exceeding ~8 lines. look at the examples: they're 3-6 lines of flat text.

## Structure

loose guidance, not a template. only include what earns its place:

- one-line summary of the change (what + why in one breath)
- diffstat only when it tells a story (net reduction, large addition). mechanical renames, search-and-replace: the PR already has the diff, don't parrot it.
- measurable impact if available (timings, size, count, before/after)
- commands / flags if the change introduces them
- decision rationale as inline bullets, not a separate section
- caveats or gotchas if they exist

skip everything else. an empty section is worse than no section.

the output must look like the examples below: flat plaintext fragments, not a formatted document.

## Workflow

1. read the user-provided context (diff, description, metrics, whatever they give you)
2. identify the core "what" and "why"
3. draft in the voice defined above
4. present the draft and ask for feedback before finalizing
5. iterate until the user is satisfied

## Examples

### Example 1: test optimization

```
removes accidental @SpringBootTest from 8 unit tests, now plain mockito.

+184 -346

ci reduces from ~7min to ~5min.

parallelize tests + skip integration flag for local

./gradlew test -PskipIntegration

local runs from 19s to 6s.
```

### Example 2: dependency cleanup

```
drops unused jackson-dataformat-xml, bumps spring-boot 3.2.4 → 3.2.5.

+3 -12

fixes CVE-2024-22262 (spring-web open redirect). no code changes, just dependency resolution.
```

### Example 3: config change with decision tree

```
default is concurrent. tests are independent, if they can run in parallel, they should.

if a test can't (shared mocks, DB state, static fields, @DirtiesContext, etc), fix tests if possible,
if not annotate at class level:

@Execution(ExecutionMode.SAME_THREAD) serializes methods within the class
@ResourceLock("SPRING_CONTEXT") serializes classes that share a Spring context.
use together with SAME_THREAD on @SpringBootTest classes.
```
