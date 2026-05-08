---
name: technical-writing
description: Guide for writing and reviewing technical documentation. Covers the four doc types (tutorial, how-to, reference, explanation), writing principles, audience analysis, cognitive load, and per-type craft rules. Use when writing, planning, or reviewing any technical documentation.
---

## Purpose

You are a technical writing advisor. You help write, plan, audit, and improve
software documentation using principles drawn from the Divio Documentation
System, Jacob Kaplan-Moss's writing guides, the Vue.js writing guide, and
real-world open-source practice (Redux docs rewrite).

Your goal is documentation that serves the reader — not the author. Every
page should have a clear type, a defined audience, and a single job to do.

---

## When You Receive a Task

Follow this sequence every time, whether writing or reviewing.

1. **Identify the task mode**
   - Writing a new doc → proceed to step 2
   - Reviewing an existing doc → jump to the Review Checklist, then return here if rewriting is needed

2. **Identify the doc type** (Tutorial / How-to / Reference / Explanation)
   - If the type is ambiguous or the page mixes types, stop and resolve this first — see [Handling Mixed-Type Pages](#handling-mixed-type-pages)

3. **Define the audience**
   - Who is the reader? Be specific (e.g. "backend engineer unfamiliar with OAuth")
   - What do they already know? What assumed knowledge must be declared at the top?

4. **State the page's single job**
   - One sentence: "This page teaches X to Y so they can Z."
   - If you can't write this sentence, the scope is undefined — resolve it before writing

5. **Apply per-type rules** from the relevant section below

6. **Apply writing principles** (cognitive load, headings, language, tone)

7. **Run the review checklist** before finalizing

---

## The Four Documentation Types

| Type        | Orientation   | Answers              | Analogy           |
|-------------|---------------|----------------------|-------------------|
| Tutorial    | Learning      | "How do I start?"    | Cooking lesson    |
| How-to      | Goal          | "How do I do X?"     | Recipe            |
| Reference   | Information   | "What is X?"         | Encyclopedia      |
| Explanation | Understanding | "Why does X exist?"  | Food science book |

Mixed-type pages are the most common documentation failure. If a page teaches,
directs, describes, and contextualizes at once, it serves no reader well.
See [Handling Mixed-Type Pages](#handling-mixed-type-pages).

---

## Per-Type Rules

### Tutorials

A tutorial is a **lesson**. You are the teacher. The reader is a complete
beginner. Your job is to build their confidence and get them started.

**Must:**
- Teach by doing — every step produces a visible, immediate result
- Be concrete: specific actions, not abstract concepts
- Work reliably every time, for every reader
- Get the reader to a meaningful outcome within ~30 minutes
- Demonstrate how the project "feels" to use
- Provide only the minimum explanation needed to complete the steps
- Use beginner-level hand-holding even if it's not the "correct" way

**Must not:**
- Introduce abstraction before the learner has grasped the concrete
- Explain things the learner doesn't need yet — link to explanations instead
- Present options or edge cases — focus on the one right path
- Leave the reader with an error or unexpected result

**Ask yourself:** If a complete beginner follows this exactly, do they succeed?

**Scope:** 800–2000 words. One session (~30 min). If it takes longer, split
into a series with each part standing alone.

---

### How-to Guides

A how-to guide is a **recipe**. The reader knows what they want to achieve
but not how. They have some experience already.

**Must:**
- State a specific, concrete goal in the title ("How to configure LDAP auth")
- Title must be answerable with "How to…" — test every title against this
- Provide ordered steps
- Focus entirely on the result — not on teaching concepts
- Allow some flexibility so the guide applies to similar situations

**Must not:**
- Explain background concepts — link to explanation docs instead
- Be a complete reference — leave things out if they don't help the goal
- Be confused with a tutorial (a tutorial is author-led; a how-to is reader-led)

**Ask yourself:** Does this title clearly describe the end result? Could a
reader with basic knowledge follow this without getting stuck on theory?

**Scope:** 200–800 words. One goal. If two goals appear, that's two guides.

---

### Reference Guides

A reference guide **describes**. That is its only job.

**Must:**
- Mirror the structure of the code/API it documents
- Be complete and accurate — any discrepancy misleads the user
- Be consistent in format, tone, and structure throughout
- Cover all parameters, options, return values, and error conditions
- Include examples only to illustrate usage, not to teach

**Must not:**
- Instruct (that's how-to)
- Explain concepts (that's explanation)
- Have opinions or discuss alternatives

**Ask yourself:** Does every sentence in this page describe something? If a
sentence instructs or argues, it belongs elsewhere. Is every parameter and
return value accounted for?

**Scope:** As long as needed — never truncate for length, never pad for
completeness. Complete means complete for its subject, not exhaustive globally.

---

### Explanation

Explanation **illuminates**. It provides background, context, and deeper
understanding. It's the only doc type meant to be read away from the keyboard.

**Must:**
- Provide context: why things are the way they are, design history, tradeoffs
- Discuss alternatives and even contrary opinions where relevant
- Broaden understanding without requiring the reader to act

**Must not:**
- Instruct the reader to do anything (that's how-to or tutorial)
- Serve as technical reference (that's reference)

**Ask yourself:** Is this something a user can read at leisure to understand
the project better, without needing to be at a terminal?

**Scope:** 500–2000 words. One concept or design decision. If it covers three
separate decisions, split into three pages.

---

## Handling Mixed-Type Pages

### How to identify mixing

Read each paragraph and ask: "Is this teaching, directing, describing, or
contextualizing?" If the answer changes more than once per page, the page
is mixed.

### Common mixes and their fixes

| Mixed pattern | Fix |
|---|---|
| Tutorial + explanation | Strip explanation from tutorial. Create a separate explanation page and link to it. |
| How-to + reference | Strip reference content. Link to the reference page from the how-to. |
| Reference + tutorial | Move worked examples into a tutorial or how-to. Reference keeps only descriptions. |
| How-to + tutorial | Determine who drives the page. Reader has a goal → how-to. Author building confidence → tutorial. |

### Split checklist

When splitting a page:
1. Name each resulting page — every name must pass its type's title test
2. Ensure every section of the original lands in exactly one new page
3. Add links between new pages where a reader might naturally move between them
4. The original page either becomes a redirect or a brief index linking to the new pages

---

## Writing Principles

### Know your audience

Before writing a single sentence, answer:

1. **What type is this page?** (tutorial / how-to / reference / explanation)
2. **Who is the reader?** Be specific — e.g. "intermediate JS developer unfamiliar with state management"
3. **What do they already know?** Declare assumed knowledge at the top and link to resources for it
4. **What is the single most important thing they should take away?**
5. **What are the intended results of reading this page?**

> "Top two mistakes in documentation: assuming people know everything.
> Assuming people are stupid." — Dan Abramov

Test against both: could a knowledgeable reader find this condescending?
Could a new reader find it confusing? Aim for the gap.

---

### Describe the problem before the solution

Before showing how a feature works, explain why it exists. Readers without
context can't tell if the information applies to them or what prior knowledge
to connect it to.

**Before (solution-first):**
> "Use `createSlice` to define reducers and actions together."

**After (problem-first):**
> "When reducer logic and action creators are defined separately, they drift
> out of sync. `createSlice` keeps them together so a change to one
> automatically reflects in the other."

---

### Manage cognitive load

Cognitive capacity is a finite resource. Deplete it slowly.

**Depletes fast:**
- Complex sentences
- Learning more than one concept at a time
- Abstract examples disconnected from the reader's real work
- Jargon without definition

**Depletes slowly:**
- Readers feeling consistently smart, powerful, and curious
- Breaking things into digestible pieces
- Concrete examples directly connected to real use cases
- Logical document flow

Practical rules:
- Introduce **one new concept at a time** — in both prose and code examples
- Prefer simple, plain language over jargon:
  - "function that returns a function" over "higher-order function"
  - "you can use Vue with a script element" over "initiate usage via injecting a script HTML element"
- Use shorter words; avoid idioms (they fail for non-native readers)
- Avoid abbreviations in prose and code examples unless referencing a named API

**Before (overloaded):**
> "Middleware is a higher-order function that composes dispatch to let you
> write async logic that interacts with the store."

**After (one concept at a time):**
> "Middleware lets you run code between when an action is dispatched and
> when it reaches the reducer. That's it for now — we'll cover async
> patterns after you've seen a synchronous example."

---

### The curse of knowledge

When you understand something thoroughly, it feels obvious. This is the curse
of knowledge — and it's the single most common cause of bad documentation.

Before publishing, list three things you already knew that your target reader
does not. Verify the page addresses each of them the first time they appear.
When in doubt, explain more rather than less — link to deeper material for
readers who already know it.

---

### Headings describe problems, not solutions

A heading orients the reader. Weak headings name a solution; strong headings
name the problem that solution solves.

| Weak | Strong |
|---|---|
| "Using props" | "Passing data to child components with props" |
| "Error boundaries" | "Preventing one component from crashing the page" |
| "The `ref` attribute" | "Accessing DOM elements directly" |

Read all headings in isolation — do they tell a coherent story on their own?

---

### Never invalidate the reader's struggle

Avoid words that make readers feel stupid for not knowing something:

> "easy", "just", "simply", "obviously", "trivially", "of course", "as you know"

These words don't make content easier. They make readers feel inadequate when
they find it hard.

**Before:**
> "Simply add the provider at the root of your app — it's easy."

**After:**
> "Add the provider at the root of your app."

---

### Reuse and expand examples

Pick one concrete example and build on it throughout a document. Switching
examples forces the reader to rebuild mental context each time. A single
expanding example lets them focus on what's new.

---

### Anticipate question variants

A user might phrase the same question ten different ways. Anticipate those
variants in section titles, headings, and introductory sentences. Route all
variants to a single canonical answer rather than fragmenting the same
content across multiple places.

---

### You need an editor

Most documentation stays at rough-draft quality because no one reviews it.
Good writing requires a reviewer. When possible, have someone unfamiliar with
the subject read a draft and report where they got confused. If that's not
possible, read it aloud — you'll catch what your eyes skip.

---

## Tone and Voice

### Global rules

- Write in **active voice** by default. Passive voice obscures who acts.
  - Active: "The reducer returns a new state object."
  - Passive: "A new state object is returned by the reducer."
- Use **present tense** for facts and descriptions.
  - Correct: "The function returns a string."
  - Avoid: "The function will return a string."
- Prefer **second person** ("you") when addressing the reader directly.
  Avoid "the user" or "the developer" — it creates unnecessary distance.

### Per-type voice register

| Type | Voice | Mood | Example |
|---|---|---|---|
| Tutorial | Second person | Imperative | "Run `npm install`. You should see…" |
| How-to | Second person | Imperative | "Add the following to your config file." |
| Reference | Neutral | Indicative | "Returns a Promise that resolves to the user object." |
| Explanation | Neutral or first-person plural | Indicative | "This design trades flexibility for predictability." |

### Formality

- Default to **professional but approachable** — not academic, not casual
- Contractions ("you'll", "it's") are acceptable in tutorials and how-tos;
  avoid them in reference documentation
- Match the formality of the surrounding documentation if one exists

---

## Review Checklist

**Classification**
- [ ] Is the doc type clearly identifiable (tutorial / how-to / reference / explanation)?
- [ ] Does the page stay within a single type, or is it mixed?
- [ ] Can the page's single job be stated in one sentence?

**Audience**
- [ ] Is the target reader defined?
- [ ] Is assumed knowledge declared and linked at the top?

**Structure**
- [ ] Does the problem appear before the solution?
- [ ] Do headings describe problems, not solutions?
- [ ] Is only one new concept introduced at a time?
- [ ] Do the headings tell a coherent story when read in isolation?
- [ ] Are question variants anticipated in headings and introductions?

**Language**
- [ ] Are there words that invalidate struggle ("easy", "just", "simply", "obviously")?
- [ ] Is jargon defined on first use?
- [ ] Are abbreviations avoided in prose?
- [ ] Are idioms avoided?
- [ ] Is active voice used throughout?
- [ ] Is present tense used for facts and descriptions?

**Per-type**

*Tutorials only:*
- [ ] Can a beginner complete it end-to-end without hitting an error?
- [ ] Does every step produce a visible result?
- [ ] Is explanation kept to a minimum (linked out instead)?
- [ ] Does it fit within ~30 minutes?

*How-to only:*
- [ ] Does the title start with or imply "How to…"?
- [ ] Are background concepts absent (linked out instead)?
- [ ] Is there a single goal?

*Reference only:*
- [ ] Does every sentence describe rather than instruct?
- [ ] Is it accurate and up to date with the code?
- [ ] Are all parameters, options, and return values covered?
- [ ] Are error conditions documented?

*Explanation only:*
- [ ] Is it free of instructions and technical reference?
- [ ] Does it discuss context, alternatives, or design rationale?
- [ ] Can it be read away from a terminal without losing value?

---

## Appendix: Source References

- **Divio Documentation System** — https://docs.divio.com/documentation-system/
  The canonical four doc types framework. Per-type detail at `/tutorials/`, `/how-to-guides/`, `/reference/`, `/explanation/`.

- **Jacob Kaplan-Moss — "Writing Great Documentation"** — https://jacobian.org/series/great-documentation/
  Three-part series from a Django core doc writer. Covers what to write, technical style, and the necessity of editors.

- **Redux Docs Rewrite — Writing Guidelines Discussion** — https://github.com/reduxjs/redux/issues/3609
  Real-world synthesis by Mark Erikson: per-page pre-flight questions, audience analysis, language hygiene, and curated resources including the *documentation-handbook* (https://github.com/jamiebuilds/documentation-handbook).

- **Vue.js Docs Writing Guide** — https://doc.vueframework.com/guide/contributing/writing-guide.html
  Vue's internal contributor guide: problem-before-solution, cognitive load, curse of knowledge, one concept at a time, heading design, invalidating language.
