# Goal Evaluation Framework

Use this framework when the user wants to define or evaluate a formal
research goal. The framework structures the assessment into four
dimensions. Guide the conversation through them interactively — don't
dump all questions at once.

## Overview

A strong research goal balances four things: it's worth doing (value),
possible to do (feasibility), not already done (novelty), and
situated in a productive area (timing). The framework walks through
each in sequence.

## Dimension 1: Novelty

> "Does this direction overlap with known work?"

**Questions to explore:**
- What's the closest existing work you know of? How is this different?
- If you search the key terms on Semantic Scholar / arXiv, how many
  near-miss papers appear in the last 3 years?
- Is this a new problem, a new method for an existing problem, or a
  new evaluation of an existing method?

**Decision guidance:**
- **Clear gap** (no close work) → high novelty, but verify the gap is
  real and not just obscure
- **Dense area** (many close works) → low novelty risk — contribution
  would need to come from evaluation breadth or practical improvement
- **Well-trodden with an unexplored corner** → sweet spot for a
  standard paper

**If uncertain** → suggest a targeted literature search before
setting the goal. Use the literature module or fan out searches.

## Dimension 2: Feasibility

> "Can you execute this given your resources?"

**Questions to explore:**
- **Data**: Do you have access to the datasets you need? If they need
  to be created, what's the cost?
- **Compute**: Roughly how much compute is needed? Base model size,
  training/inference budget, sweeps.
- **Expertise**: Does the team have the relevant skills? (e.g., RL
  experience for PPO-based methods)
- **Time**: Is this achievable within the target timeline? (conference
  deadline, degree timeline)

**Decision guidance:**
- All resources available → go
- One gap with a clear path → acceptable risk
- Two or more significant unknowns → consider a pilot/feasibility
  experiment first, or narrow the scope

## Dimension 3: Value

> "If it works, what's the contribution?"

**Types of contribution:**
- **Method**: A new algorithm, architecture, or technique
- **Theory**: Formal guarantees, complexity analysis, conceptual
  framework
- **Empirical**: Benchmark results, ablation studies, practical insights
- **Application**: A system or tool that solves a real problem
- **Dataset/Infrastructure**: New data, benchmark, or platform

**Questions to explore:**
- Who would care? (specific community, broader ML, practitioners)
- Would the results change how people do things, or just confirm what
  they already assume?
- Is there a publication path where this contribution fits?

## Dimension 4: Timing

> "Is this the right time to work on this?"

**Questions to explore:**
- Is this area actively evolving? (benefit: momentum, risk: being
  overtaken)
- Are there upcoming deadlines or milestones that make this timely?
- Would waiting 6 months make it easier or harder?

## Putting it together

After walking through all four dimensions, produce a summary:

```
## Goal assessment

**Proposed goal**: <one-line>

| Dimension | Assessment | Confidence |
|-----------|-----------|------------|
| Novelty   | High / Medium / Low / Uncertain | H/M/L |
| Feasibility | High / Medium / Low / Uncertain | H/M/L |
| Value     | High / Medium / Low / Uncertain | H/M/L |
| Timing    | Good / Neutral / Bad | H/M/L |

**Overall**: Proceed / Proceed with caution / Re-evaluate before committing

**Concerns to watch**:
- <concern 1>
- <concern 2>

**What to do next**:
- <suggested action>
```

The assessment goes into `.research/goals/current.md` as the frontmatter
evaluation record, followed by the goal description.
