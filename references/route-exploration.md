# Route Exploration Framework

A structured process for generating, evaluating, and converging on
research routes for a given goal.

## Process overview

```
Divergence                     Convergence                    Decision
     │                             │                             │
     ▼                             ▼                             ▼
Propose 2-4           →  User feedback →            →  Adopt 1-2 routes
candidate routes         eliminate/refine               Archive the rest
```

## Divergence phase

Given a research goal, propose 2-4 candidate routes. Each should be a
distinct technical approach — not variations on the same idea.

### Route template

For each route, write a brief analysis:

```markdown
## Route: <name>

**Core idea**: [One paragraph]

**Why it might work**:
- [Positive evidence, e.g., related work shows promise]
- [Key hypothesis]

**Key risk**:
- [The main thing that could fail]
- [How to mitigate]

**Related literature**: [arxiv IDs]

**Compute estimate**: [rough estimate, e.g., "4×A100 for 1 week"]

**Novelty assessment**: [known approach / novel combination /
  genuinely new / exploratory]
```

### Generating diverse routes

Push for **mechanistic diversity** — routes should differ in their
core assumption or bottleneck:

- **Existing method applied to new domain** (low novelty, lower risk)
- **New combination of existing ideas** (medium novelty, medium risk)
- **Modified/improved version of known approach** (medium novelty,
  controlled risk)
- **Genuinely new idea** (high novelty, high risk — treat as a
  moonshot unless the user is confident)

If the user already has a route in mind, start from there and propose
alternatives. Don't ignore their existing direction.

## Convergence phase

Present each route briefly. After the user responds to each one:

1. **Eliminate** routes that are clearly infeasible or uninteresting to
   the user
2. **Refine** remaining routes with user feedback — adjust the
   approach, identify sub-problems, note open questions
3. **If uncertain**, suggest concrete next steps to resolve
   uncertainty:
   - "Read paper X to check feasibility of route A"
   - "Run a small-scale pilot to test route B's core hypothesis"
   - "Search for more related work to confirm novelty of route C"

### Decision criteria

Guide the user with questions, not declarations:

| Ask | When |
|-----|------|
| "Route X has the highest novelty but the compute cost is significant. Is that acceptable?" | Trade-off between novelty and feasibility |
| "Route Y shares core assumptions with an existing paper — the contribution would need to be in the evaluation, not the method." | Low novelty risk, need clearer differentiation |
| "Route Z is the safest option but may not be enough for a top-venue paper. How ambitious do you want to be?" | Ambition vs publishability |
| "These two routes could be explored partially in parallel — they share the baseline setup." | Parallel execution opportunity |

## Outcome

Route data lives in `.research/routes.json` (machine-readable) and
`.research/routes.md` (human-readable, auto-generated).

```yaml
---
routes:
  - id: route-a
    title: "..."
    goal: [goal-id]
    status: adopted       # proposed → evaluating → adopted / abandoned
    evaluated: 2026-07-02
    decision: "..."
    related_lit: [arxiv-id1, arxiv-id2]
---
```

For abandoned routes, always record the decision rationale. This
prevents re-exploring the same dead end months later.
