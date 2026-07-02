# Writing & Submission Protocol

Managing paper writing, venue targeting, submission tracking, and
review response.

## Writing directory structure

Each paper at `.research/writing/<paper-name>/`:

```
writing/
├── index.json                         ← all papers overview
└── <paper-name>/
    ├── outline.md                     ← structure + assigned sections
    ├── drafts/
    │   ├── v1.md                      ← full draft (or most recent)
    │   └── v2.md                      ← revised version
    ├── submission.md                  ← venue + dates + status
    ├── reviews/
    │   ├── reviewer-1.md              ← raw review text
    │   ├── reviewer-2.md
    │   ├── reviewer-3.md
    │   └── response.md                ← point-by-point rebuttal
    └── talks/
        ├── slides-outline.md
        └── poster-outline.md
```

## Tracking papers

`writing/index.json` overview:

```json
{
  "papers": [
    {
      "name": "prm-math-reasoning",
      "title": "Improving Math Reasoning with Process Reward Models",
      "authors": "You, Coauthor1, Coauthor2",
      "status": "drafting",
      "target_venue": "NeurIPS 2026",
      "deadline": "2026-05-15",
      "submitted": null,
      "decision": null,
      "current_draft": "v2"
    }
  ]
}
```

**Status lifecycle:**
`planning → drafting → polishing → submitted → under-review → accepted / rejected → camera-ready`

### Venue tracking

When choosing a venue, consider:
- **Topic fit**: Does this venue publish similar work?
- **Deadline**: Is there enough time to prepare?
- **Tier**: Is the ambition level appropriate?
- **Review style**: Double-blind? Single-blind?

Track per-paper venue in `submission.md`:

```markdown
---
status: drafting
target: NeurIPS 2026
deadline: 2026-05-15
---

# Submission Plan

## Target: NeurIPS 2026
- Deadline: 2026-05-15
- Decision: 2026-08-15
- Style: Double-blind

## Fallback: ICML 2027
- Deadline: 2027-01-31
```

## Rebuttal workflow

When reviews arrive, the goal is a structured, point-by-point response
that clearly shows what was changed.

### Step 1: Log each review

Save each review to `reviews/reviewer-N.md`:
```markdown
---
reviewer: 1
confidence: 4/5
score: 3 (weak accept)
---

## Original review text

[Paste the full review here. Keep it verbatim.]
```

### Step 2: Build response structure

In `reviews/response.md`, structure as:

```markdown
---
status: drafting   # drafting → finalized
---

# Response to Reviewers

## Summary of changes
[List the major changes made in response to reviews]

---

## Reviewer 1

### Comment 1.1: [...]
**Original**: [quote]
**Response**: [your reply]
**Change**: [what you changed and where, e.g., "Added discussion to Section 4.2"]

### Comment 1.2: [...]
...

---

## Reviewer 2
...
```

### Response principles

- Be specific: "We added a paragraph to Section 3.2 analyzing X"
- Be respectful: assume good intent in every comment
- Acknowledge: if the reviewer is right, say so and fix it
- Push back sparingly: only when the reviewer clearly misunderstood
  and explaining would help
- Mark every change: the editor should be able to see what was changed
  without re-reading the entire paper

## Talk/poster preparation

Draft talk outlines in `talks/slides-outline.md`:

```markdown
# Talk: Improving Math Reasoning with PRM
- Venue: NeurIPS 2026
- Duration: 15 min + 5 min Q&A

## Slide outline
1. Title + Problem (1 min)
2. Background: Outcome vs Process Supervision (2 min)
3. Our approach (4 min)
4. Key results (4 min)
5. Ablations and analysis (3 min)
6. Conclusion + Future work (1 min)
```
