# Literature Survey Protocol

Search strategies, dedup rules, and note-taking standards for
literature management in a research project.

## Search strategy

### Tool selection

| Need | Recommended tool |
|------|-----------------|
| Quick check for known paper | arXiv API (`export.arxiv.org/api/query?id_list=...`) |
| Broad keyword search | WebSearch or arXiv API |
| Finding related work | Semantic Scholar API (recommended: `api.semanticscholar.org/graph/v1/paper/search`) |
| Checking venue reputation | DBLP (`dblp.org/search/publ/api`) |
| Prior art / patent search | Google Scholar |
| In-depth survey | Fan out multiple searches covering different sub-topics |

### Search dedup

**Before searching**, check:
1. `.research/literature/index.json` — have we already logged this?
2. `~/LLM-Wiki/wiki/sources/` — does the wiki already cover this paper?
3. `.research/literature/searches/` — did we already run this query?

**Save every search** to `.research/literature/searches/`:
```markdown
---
date: 2026-07-02
query: "process reward model math reasoning"
tool: arxiv-api
---

## Results
- [2402.03300] Let's Verify Step by Step — Lightman et al. (2023)
- [2305.20050] Process Reward Model — Wang et al. (2024)
- [2108.05341] Self-Consistency — Wang et al. (2022)

## Filtered out
- [2201.00000] unrelated topic — doesn't address reward modeling

## Next steps
- Read 2402.03300 first (most cited)
- Check citations of 2305.20050 for more recent work
```

## Note-taking standard

A good paper note answers:
1. **What problem does it solve?**
2. **What's the key method/idea?**
3. **What's the main result?**
4. **How does it relate to my work?** (baseline, extension, motivation, orthogonal)
5. **Key figures/tables to remember**

Template for `.research/literature/readings/<arxiv-id>.md`:
```markdown
---
arxiv: 2402.03300
title: Let's Verify Step by Step
status: reviewed    # to-read → reading → reviewed → integrated
read: 2026-07-02
relevance: 5        # 1-5
---

# Let's Verify Step by Step

## Problem
[1-2 sentences]

## Method
[Brief technical description. Include key formulas if relevant.]

## Results
[Quantitative highlights]

## Relevance to my work
| Aspect | Connection |
|--------|-----------|
| Baseline | {direct baseline / orthogonal / inspiration} |
| Method | {similar / different approach} |
| Not used | {why it's not directly applicable} |

## Key takeaways
- Point 1
- Point 2

## Follow-up questions
- What if we modify X?
- Does this extend to Y?
```

## Index management

The index at `.research/literature/index.json` is a flat JSON object
keyed by arxiv ID. Use `scripts/lit.sh` for CRUD operations.

**Status lifecycle:** `to-read` → `reading` → `reviewed` → `integrated`

- `to-read`: in reading list, not started
- `reading`: currently reading
- `reviewed`: read and noted
- `integrated`: findings have been incorporated into the project's
  direction, experiments, or writing

## When to search vs. when to stop

- Search until you've found 1-2 papers that directly address the same
  sub-problem, or until 3 consecutive searches yield no new relevant
  results
- For survey purposes (understanding a new area), 5-10 key papers with
  one survey paper is sufficient to start
- Depth-first beats breadth-first: read the most relevant paper fully
  before searching more
