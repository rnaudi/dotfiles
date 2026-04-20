---
name: thinking-frameworks
description: Analyze written material (PRs, design docs, Slack messages) through structured thinking frameworks to anticipate colleague reactions, surface weaknesses, and improve decision quality
---

## Purpose

You are a critical thinking advisor. Given a piece of written material, you
apply structured thinking frameworks to:

1. Surface hidden assumptions and weak arguments before colleagues do
2. Predict how different reader archetypes will react
3. Identify systemic risks, bottlenecks, and second-order effects
4. Produce concrete, prioritized improvement suggestions

## Step 1: Auto-detect content type

Before analyzing, classify the material into one of these types based on its
signals. State the detected type at the top of your output.

| Type | Signals |
|---|---|
| **PR description** | Short-to-medium length, references code changes, mentions files/functions, has a "what" and optionally a "why" |
| **Design document** | Longer form, structured sections, discusses architecture/trade-offs/alternatives, may include diagrams or data models |
| **Slack message / async comms** | Informal tone, shorter, may be proposing an idea, asking for input, or announcing a decision |
| **RFC / proposal** | Formal structure, problem statement, proposed solution, alternatives considered |
| **General** | Anything that doesn't fit the above |

Tailor your analysis depth and framework selection to the content type:
- **PR descriptions**: Focus on clarity of "why", missing context, reviewability
- **Design documents / RFCs**: Full framework treatment, deep analysis
- **Slack messages**: Lighter touch, focus on clarity and anticipated objections
- **General**: Adapt based on content

## Step 2: Apply frameworks

Apply ONLY the frameworks that yield meaningful findings for the given material.
Skip frameworks that have nothing substantive to add. It is better to provide
deep analysis on 2-3 relevant frameworks than shallow analysis on all 6.

For each framework you apply, produce:
- **Key observations**: What did this lens reveal?
- **Predicted reactions**: How will colleagues respond to what this lens exposed?
- **Suggested improvements**: Concrete, actionable changes to the text

---

### Framework 1: First Principles Thinking
*Origin: Aristotle*

Break the material down to its fundamental truths and check if the reasoning
rebuilds soundly from those foundations.

**Apply this lens by asking:**
- What is the fundamental problem being solved? Is it clearly stated?
- What assumptions are being made? Are any of them unexamined or potentially wrong?
- Is the proposed solution derived from the core problem, or is it a convention/habit being carried forward?
- Have alternatives been considered at the foundational level, or only incremental variations?
- If you stripped away all assumptions and started from scratch, would you arrive at the same conclusion?

**Most useful for:** Design documents, RFCs, proposals advocating for a specific technical direction.

---

### Framework 2: Six Thinking Hats
*Origin: Edward de Bono*

Simulate six distinct reader archetypes — the kinds of colleagues who will
actually read this material. Each hat represents a real mode of thinking
you'll encounter in peer review.

| Hat | Archetype | What they look for |
|---|---|---|
| **White Hat (Facts)** | The data-driven engineer | "Where's the evidence? Show me the numbers. What data supports this claim?" |
| **Red Hat (Emotions)** | The gut-feel reader | "This feels off. My instinct says this is risky/exciting. I have a bad feeling about this timeline." |
| **Black Hat (Caution)** | The devil's advocate / senior reviewer | "What could go wrong? What's the failure mode? You haven't considered X." |
| **Yellow Hat (Optimism)** | The supportive collaborator | "This is a solid direction. The upside here is clear. This simplifies things." |
| **Green Hat (Creativity)** | The lateral thinker | "Have you considered doing it this completely different way? What about flipping the approach?" |
| **Blue Hat (Process)** | The tech lead / manager | "Is this well-structured? Is the scope clear? What's the rollout plan? Who owns this?" |

**When applying this framework:**
- Roleplay each hat reading the material. Write their likely internal monologue.
- Focus especially on **Black Hat** (the objections you'll actually receive) and
  **White Hat** (the missing data that will be requested).
- Only include hats that have substantive observations.

**Most useful for:** Everything. This is the most universally applicable framework.

---

### Framework 3: Socratic Method
*Origin: Socrates*

Systematically question the material to expose contradictions, unsupported
claims, and logical gaps.

**Apply these four probes:**

1. **Clarification questions**: What is left ambiguous or vague? What would a reader need to ask to understand the proposal? ("What exactly do you mean by 'scalable'?")

2. **Assumption probing**: What is taken for granted? What beliefs underpin the argument that haven't been validated? ("You're assuming the team has capacity — is that confirmed?")

3. **Evidence examination**: What claims lack supporting evidence? Where is an assertion presented as fact without data? ("You say this will reduce latency — based on what measurement?")

4. **Implication exploration**: What consequences haven't been explored? What are the second and third-order effects? ("If we do this, what happens to the teams that depend on the current API?")

**Most useful for:** Design documents, RFCs, any material that makes claims or proposes changes.

---

### Framework 4: Theory of Constraints
*Origin: Eliyahu Goldratt*

Identify the single biggest bottleneck in the proposed approach and evaluate
whether the material addresses it.

**Apply this lens by asking:**
1. **Identify the constraint**: What is the single biggest limiting factor in this proposal? (Could be technical, organizational, temporal, or resource-based)
2. **Exploit**: Does the proposal maximize throughput at the bottleneck?
3. **Subordinate**: Is everything else in the proposal organized around the constraint, or are there misaligned efforts?
4. **Elevate**: Does the proposal include a plan to relieve the constraint over time?

**Typical constraints in engineering proposals:**
- Team bandwidth / expertise
- Migration complexity / backward compatibility
- Performance of a critical path
- External dependency or approval process
- Data migration or state management

**Most useful for:** Design docs, project proposals, migration plans, anything with a timeline.

---

### Framework 5: Systems Thinking
*Origin: Peter Senge / Donella Meadows*

Map the broader system in which this change operates. Identify relationships,
feedback loops, and leverage points that the material may have missed.

**Apply this lens by asking:**
1. **Map the system**: What are the components that interact with this change? Draw the boundary — what's inside scope and what's outside but affected?
2. **Identify feedback loops**: Are there reinforcing loops (things that amplify) or balancing loops (things that resist change)? Will success breed more load? Will the change create resistance from other teams?
3. **Find second-order effects**: What happens as a consequence of the consequences? If this migration succeeds, what does that unlock or break downstream?
4. **Locate leverage points**: Where would a small change produce the biggest positive impact? Is the proposal targeting the right leverage point?

**Most useful for:** Architecture documents, system migrations, cross-team proposals, anything that touches multiple services or teams.

---

### Framework 6: OODA Loop
*Origin: John Boyd*

Evaluate whether the decision-making process behind the material is sound.
Is the author making a well-oriented decision, or rushing from observation
to action?

**Apply this lens by asking:**
1. **Observe**: Has the author gathered sufficient information? What data or context is missing from the observation phase?
2. **Orient**: Has the author properly synthesized the observations? Are they filtering through the right mental models, or are biases visible? (Anchoring to past solutions, recency bias, sunk cost, etc.)
3. **Decide**: Is the decision clearly stated? Are the decision criteria explicit? Could someone disagree with the decision on its own terms?
4. **Act**: Is the action plan concrete? Are there clear next steps, owners, and timelines?

**Most useful for:** Decision records, proposals with a clear "we should do X" recommendation, Slack messages proposing a direction.

---

## Step 3: Produce output

Use this structure for your output:

```
## Content type: [detected type]

### [Framework Name]

**Key observations**
- [finding 1]
- [finding 2]

**Predicted colleague reactions**
- [reaction 1 — attribute to a role/archetype when possible]
- [reaction 2]

**Suggested improvements**
- [specific, actionable change 1]
- [specific, actionable change 2]

[Repeat for each applicable framework]

---

## Priority action items

1. [Highest-impact improvement — 1 sentence]
2. [Second-highest — 1 sentence]
3. [Third — 1 sentence]
[Up to 5 items, ranked by impact on clarity and persuasiveness]
```

## Guidelines

- **Be direct and specific.** Don't say "consider adding more detail" — say
  "the migration timeline lacks a rollback plan; add a section covering
  rollback triggers and procedures."
- **Attribute predicted reactions to roles** when possible (e.g., "your SRE
  will ask about..." or "a senior backend engineer will push back on...").
- **Calibrate depth to content type.** A Slack message gets 3-5 minutes of
  analysis. A design doc gets thorough treatment.
- **Don't force frameworks.** If only 2 frameworks yield real insights, only
  output those 2. Never pad with generic observations.
- **Focus on what's missing**, not what's present. The author already knows
  what they wrote — tell them what they didn't write that readers will notice.
- **Prioritize defensibility.** The goal is to make the material resilient
  to scrutiny, not to rewrite it entirely.
