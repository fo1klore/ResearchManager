# Experiment Templates

Design templates and results analysis protocol for AI/ML experiments.

## Experiment design template

Use this when designing a new experiment. Save to
`.research/experiments/<exp-name>/design.md`.

```markdown
---
name: <exp-name>
status: planned       # planned → running → completed → abandoned
route: <route-id>
created: 2026-07-02
---

# Experiment: <title>

## Motivation
[What question is this experiment answering? What hypothesis is being
tested? One paragraph.]

## Baseline
[What are you comparing against? Include paper citations (arxiv IDs)
and expected performance numbers if available.]

## Setup

| Component | Value |
|-----------|-------|
| Base model | e.g., Llama-3-8B |
| Dataset | e.g., GSM8K, MATH |
| Compute | e.g., 4× A100, 2 days |
| Framework | e.g., TRL, vLLM |

## Hyperparameters

```
batch_size: 32
learning_rate: 5e-6
optimizer: AdamW
warmup_steps: 100
max_steps: 1000
...
```

## Metrics

- **Primary**: [e.g., accuracy on test set]
- **Secondary**: [e.g., latency, memory, sample efficiency]
- **Ablation**: [components to isolate and test individually]

## Ablations planned

1. [Ablation 1: what? why?]
2. [Ablation 2: what? why?]
```

## Results analysis protocol

When experimental results are available, log them to
`.research/experiments/<exp-name>/results.md`.

### Run log

```markdown
## Runs

| Run ID | Config | Seed | Primary | Secondary | Notes |
|--------|--------|------|---------|-----------|-------|
| run-1  | default | 42   | 72.3    | —         | initial |
| run-2  | default | 123  | 71.8    | —         | seed variation |
| run-3  | lr=1e-5 | 42   | 74.1    | —         | higher LR |
```

### vs Baseline

| Method | Accuracy | vs Baseline | Note |
|--------|----------|-------------|------|
| Baseline (paper X) | 70.0 | — | from paper |
| Our method (default) | 72.3 | +2.3 | matching setup |
| Our method (tuned) | 74.1 | +4.1 | best config |

### Ablation analysis

| Ablation | Accuracy | Delta from full | Note |
|----------|----------|-----------------|------|
| Full | 74.1 | — | — |
| w/o component A | 71.2 | -2.9 | A is critical |
| w/o component B | 73.5 | -0.6 | B has marginal effect |

### Preliminary analysis

[What do the results suggest?]

- **[Positive]**: [What worked as expected?]
- **[Surprise]**: [What was unexpected?]
- **[Inconclusive]**: [Where is the signal still unclear?]

### Next steps

- [Immediate next experiment]
- [What to try if results hold]
- [What to try if results don't replicate]
```

## Cross-experiment comparison

Maintain a comparison table in
`.research/experiments/index.json`:

```json
{
  "experiments": [
    {
      "name": "prm-baseline",
      "route": "self-consistency-prm",
      "status": "completed",
      "primary_metric": 72.3,
      "baseline_metric": 70.0,
      "key_finding": "PRM improves over outcome-only by 2.3 points",
      "conclusion": "Promising, needs scaling study"
    }
  ]
}
```

Use `scripts/exp.sh` to update experiment status and key metrics.
