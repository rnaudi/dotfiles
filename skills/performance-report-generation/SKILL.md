# Performance Report Generation

## Purpose

Generate monthly performance reports that demonstrate promotion-ready impact to directors and VPs.

---

## Generating Raw Data

Raw PR data is generated using [`gh-log`](https://github.com/rnaudi/gh-log):

```bash
gh-log print --month YYYY-MM --force > YYYY-MM.raw.md
```

This produces a text file with:
- Aggregate metrics such as total PRs, average lead time, frequency, and size distribution
- Top reviewers with PR counts
- Review activity ratios
- Weekly breakdowns with individual PRs: date, repo, PR number, title, lead time, size
- PR descriptions with context, decisions, and screenshots
- Repository summaries

---

## Tone & Style

- Humble but confident
- Friendly and collaborative
- Goal-oriented
- Quantified
- No emojis
- Avoid generic assistant filler or overly enthusiastic language

---

## Company Values Reference

Only tag items that strongly demonstrate a values-aligned behavior. Most work is good execution, so reserve tags for standout moments where the behavior is unmistakable. Not every row needs a tag.

| Value | Theme | Key Behaviors |
|-------|-------|---------------|
| **Teamwork** | Collaboration | Celebrates collective efforts and works across boundaries |
| **Excellence** | Ambition | Pursues bold goals, assesses performance honestly, changes circumstances |
| **Accountability** | Empathy & Ownership | Invests in others, holds self and others accountable, acts with care |
| **Customer Focus** | Passion & Creativity | Delivers meaningful user impact and earns trust through reliability |
| **Continuous Improvement** | Learning | Explores, iterates, and raises quality beyond the minimum |
| **Resilience** | Grit | Welcomes challenges, adapts, and sustains momentum in adversity |

---

## Report Structure

### 1. Executive Summary
- Two to three sentences
- Explain the month in business terms

### 1b. Context
- Optional
- Use short bullets only when framing matters

### 2. Business Impact
Format: `| Area | Impact |`

### 3. Key Achievements
- Three to five bullets
- Lead with outcome, then how, then quantified result
- Add a values tag only when it is clearly deserved

### 4. Leadership & Influence
Format: `| Category | Evidence |`

### 4b. Values Highlights
- Two to four items
- Concentrate only the strongest examples

### 5. Technical Excellence
Format: `| Area | Contribution |`

### 6. Metrics Snapshot
Include:
- PRs merged, average lead time, frequency
- PRs reviewed
- Incidents caused
- Repositories contributed to
- Size distribution
- Top collaborators

### 7. Alignment to Goals
Format: `| Team/Company Goal | My Contribution |`

### 8. What's Next
- Three to four bullets showing forward momentum

### 9. Appendix: Repository Breakdown
- Repository name
- PR count
- Average lead time
- Focus area description

---

## Writing Rules

1. Lead with business outcome.
2. Quantify everything.
3. Show scope expansion.
4. Demonstrate ownership.
5. Highlight multipliers such as tools and docs.
6. Call out zero incidents when true.
7. Thank collaborators by name.
8. Use tables for scanability.
9. Reserve values tags for standout moments.
10. Reference prior-month continuity when applicable.
11. Explain unusually high small-PR ratios when needed.
12. Classify discussion or exploratory work correctly.

---

## Input Format Expected

Raw data is the plain text output of `gh-log print`.

### PR Title Prefixes

- `feat:` / `fix:` / `refactor:` / `ci:` / `chore:`: shipped work
- `ignore:` / `discussion:`: alignment or design discussion, not shipped work
- `exclude:`: exploratory or experimental work
- `docs:`: documentation, often useful for both delivery and influence
- Ticket IDs: map to business objectives when possible

### PR Body Text

PR descriptions often contain the business context needed to explain impact. Read them closely.

### Private or Research Repos

These may include notes, research, teaching docs, and design discussions rather than production code. Use them mainly as evidence for leadership and influence.

---

## Output Checklist

- Executive summary is VP-readable
- Every achievement has a quantified outcome
- Collaborators are thanked by name
- Work is mapped to business or team goals
- Zero incidents are mentioned when applicable
- Next month's focus shows strategic thinking
- Tables are used for scanability
- Tone is humble, friendly, and confident
- Values highlights are selective and strong
- Prior-month continuity is referenced when relevant

---

## File Naming

- Reports: `YYYY-MM.md`
- Raw data: `YYYY-MM.raw.md`
