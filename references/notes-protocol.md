# Research Notes Protocol

Research notes are intermediate investigation artifacts that bridge ideas to the project's single goal, and also host paper-writing intermediates. They capture work-in-progress that is too concrete to remain an idea but not yet a formal result.

## Purpose

Research notes serve two scenarios:

1. **Idea development**: When an idea is adopted, you create a note to investigate it — gather preliminary evidence, survey related work, assess feasibility. When sufficiently grounded, the findings feed into the project's single goal (or inform a paper).

2. **Paper writing intermediates**: While writing a paper, you may survey a specific subtopic, analyze a method, or organize related work. These are also notes, linked to the relevant paper via `related_papers`.

## Note types

Types are tags for organization, not strict schema enforcement:

| Type | Purpose |
|------|---------|
| `idea-development` | Exploring an adopted idea, connecting it to the project goal |
| `paper-writing` | Writing-related survey, analysis, or synthesis for a specific paper |
| `technical-analysis` | Deep dive on a method, algorithm, or phenomenon |
| `literature-digest` | Multi-paper synthesis comparing findings across several works |

## Status lifecycle

```
in-progress → solidified → archived
```

- **in-progress**: Actively investigating. Questions are open, findings are accumulating.
- **solidified**: Investigation has reached a conclusion. Results have been fed into:
  - The project's single goal (for `idea-development` notes), often informing goal refinement
  - A paper draft section (for `paper-writing` notes)
  - A route decision (for `technical-analysis` notes)
- **archived**: No longer relevant. Superseded by a more recent note, or the direction was abandoned. Decision rationale should be noted so re-exploration is avoided.

## Template

Save each note to `.research/notes/<slug>.md`. The slug should be short, kebab-case, and descriptive.

```markdown
---
id: <slug>
title: <full descriptive title>
type: idea-development    # idea-development | paper-writing | technical-analysis | literature-digest
created: <YYYY-MM-DD>
updated: <YYYY-MM-DD>
status: in-progress       # in-progress → solidified → archived
related_ideas: ["<idea-slug>", ...]
related_papers: ["<paper-name>", ...]
---

# <title>

## Overview / Motivation
Why this note exists. What question is it investigating.

## Key findings / Progress
What has been learned so far. Key results, observations, or conclusions.
For paper-writing notes, this may become a section in the draft.

## Open questions / Next steps
What remains unclear. What to do next.

## Links
- Related literature by arxiv ID
- Related experiments
- Related writing
```

## Creation workflow

When creating a research note:

1. **Check existing notes** — grep `.research/notes/index.json` for similar slugs/titles. If an existing note already covers the topic, update it instead.
2. **Link to sources** — if the note is exploring an adopted idea, set `related_ideas` to the idea slug(s). If it's for a paper, set `related_papers` to the paper name.
3. **Create the file** — save to `.research/notes/<slug>.md` with the template above.
4. **Update index** — add entry to `.research/notes/index.json` via `scripts/notes.sh add`.
5. **Update state** — increment `stats.notes_active` via `state.sh stats notes_active=<new-count>` (or let `notes.sh add` handle this).

## Status transitions

- **in-progress → solidified**: When the investigation has a clear conclusion. Add a summary of findings in the note body. The findings should inform the project goal or paper draft.
- **solidified → archived**: When the direction is abandoned or superseded. Add a brief rationale in the note body.
- **Any state → archived**: Direct archival is allowed (e.g., a note that never got beyond in-progress but is no longer relevant).

## Index management

The index at `.research/notes/index.json`:

```json
{
  "notes": [
    {
      "slug": "self-consistency-analysis",
      "title": "Analysis of self-consistency methods for LLM reasoning",
      "type": "idea-development",
      "status": "in-progress",
      "created": "2026-07-05",
      "updated": "2026-07-05",
      "related_ideas": ["2026-07-05-math-reasoning"],
      "related_papers": []
    }
  ]
}
```

Use `scripts/notes.sh` for index CRUD and status transitions.
