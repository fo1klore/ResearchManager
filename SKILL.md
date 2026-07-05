---
name: research-manager
description: >
  Manage a graduate research project through its full lifecycle — ideas,
  goals, literature survey, routes, experiments, and writing/publishing.
  Trigger this skill when the user wants to track research progress,
  evaluate a research direction, survey literature, design experiments,
  manage writing milestones, or any research management task.
  ALWAYS offer to load or create .research/ state before starting.
  Use /research-manager for the menu interface.
---

# Research Manager

Manage one graduate research project: track progress, capture ideas, define goals,
survey literature, explore routes, run experiments, and manage writing.
Each project has its own `.research/` directory alongside the code.

## Table of Contents

- [Loading state](#loading-state)
- [Modules](#modules)
- [Wiki integration](#wiki-integration-cross-cutting)
- [When to escalate](#when-to-escalate)
- [Scripts reference](#scripts-reference)

---

## Loading state

Every invocation of this skill follows the same entry sequence:

1. **Detect project** — look for `.research/state.json` in the current working
   directory. If found, load it.
2. **Auto-detect wiki** — check `.research/config.json` for `wiki_path`. If unset,
   check `$LLM_WIKI_PATH` env var, then `~/LLM-Wiki/`.
3. **Show status summary** — extract from `state.json`:
   - active project name, progress %, current phase
   - counts: ideas, notes, goals, routes, literature, experiments
4. **Present the menu** — inline, not a big card:

   > Current: <project> (<progress>%) — <phase>
   > What would you like to do?
   > • view status / update progress
   > • capture an idea
   > • create / update a research note
   > • define or evaluate a goal
   > • survey literature / log a paper
   > • explore or log research routes
   > • design / log an experiment
   > • manage writing or submissions
   > • write to log

If `.research/` doesn't exist, ask: "This project doesn't have a research
manager yet. Initialize it?" If yes, run
`.claude/skills/research-manager/scripts/init.sh .` in the project
root, then show the menu.

At the end of each interaction, **persist changes** — write back
`state.json`, append to `log.md`, and save any new/updated files in the
relevant subdirectory. Summarize what changed as a one-liner.

### Integrity discipline

The `.research/` directory is the **source of truth** — never rely on
context memory for its state. Follow these rules:

1. **Read before write** — before modifying any file under `.research/`,
   re-read it from disk with the Read tool. Do NOT use a version cached
   in context from an earlier turn.

2. **View raw data on request** — when the user asks to see the actual
   content of any `.research/` file (log, ideas, literature index,
   state.json, etc.), read it from disk and display it.

3. **Scripts for mutations** — for state changes, prefer calling the
   deterministic scripts (`.claude/skills/research-manager/scripts/state.sh`,
   `lit.sh`, `exp.sh`, `route.sh`, `log.sh`) over manual file edits.
   Scripts are immune to hallucination. User-facing data (ideas, goals,
   writing) is still best handled via direct Read/Write/Edit.

4. **Re-read summary before presenting** — when showing the status
   summary or menu, always read `state.json` from disk fresh. Do not
   summarize from conversation memory.

---

## Modules

### ideas — Idea capture and triage

When the user has a raw research idea (a hunch, a paper they just read, a
conversation with their advisor):

1. **Wiki pre-check** — grep `~/LLM-Wiki/wiki/concepts/` and
   `~/LLM-Wiki/wiki/sources/` for related terms. If found, note what
   already exists so the user knows what's covered.
2. **Log the idea** — save to `.research/ideas/<date>-<short-slug>.md`.
   Template:
   ```markdown
   ---
   date: <YYYY-MM-DD>
   source: paper/conversation/reading/other
   status: captured   # captured → filtered → adopted/abandoned
   summary: <one-line of what the idea is and why it matters>
   # When abandoned, append "Why abandoned" section to file
   ---
   # <title>
   ## The idea
   ## Why it might matter
   ## Related work (wiki-found or known)
   ## Open questions
   ```
   **Also add an entry** to `.research/ideas/index.json` with slug,
   title, date, source, status, and summary for fast lookup.
3. **Ask about next step** — If the idea is promising and the user wants
   to investigate further:
   - "Do you want to create a research note for this idea? Research notes
     are where you investigate an idea—gather evidence, survey related
     work, assess feasibility—before it matures into a concrete
     contribution to your project's goal or a paper section."
   - Otherwise: "Keep it as an idea for now."
4. **When abandoning** — if the idea is deemed not worth pursuing (because
   it's been done before, infeasible, or superseded), update `status` to
   `abandoned` in the file frontmatter **and index**, and **append a
   "Why abandoned / Lessons learned" section** to the idea file recording
   the reason. Delete the `summary` field from the frontmatter (so the
   abandoned state is immediately visible without reading the file). This
   prevents re-exploration of the same dead end months later.
5. **When adopting** — update `status` to `adopted` in the file frontmatter
   and index, then create a research note as described above.

Ideas that are adopted become **research notes** (see the [notes](#notes--research-notes) module). The
project has a single goal; all ideas converge toward it through investigation.

---

### notes — Research notes

A research note is an intermediate investigation artifact. It serves two
purposes:

1. **Idea development**: When an idea is adopted, you create a note to
   investigate it — gather preliminary evidence, survey related work,
   assess feasibility. When sufficiently grounded, the findings feed into
   the project's single goal or a paper draft.
2. **Paper writing intermediates**: While writing a paper, you may survey a
   specific subtopic, analyze a method, or organize related work. These are
   also notes, linked to the relevant paper via `related_papers`.

**Status lifecycle:** `in-progress → solidified → archived`

- `in-progress`: actively investigating
- `solidified`: investigation has a conclusion (results feed into goal, paper, or route)
- `archived`: abandoned or superseded

**Types (as tags, not strict schema):**

| Type | Purpose |
|------|---------|
| `idea-development` | Exploring an adopted idea, connecting it to the project goal |
| `paper-writing` | Writing-related survey, analysis, or synthesis |
| `technical-analysis` | Deep dive on a method, algorithm, or phenomenon |
| `literature-digest` | Multi-paper synthesis comparing findings |

**Note file:** `.research/notes/<slug>.md`:
```markdown
---
id: <slug>
title: <title>
type: idea-development
created: <YYYY-MM-DD>
updated: <YYYY-MM-DD>
status: in-progress
related_ideas: []
related_papers: []
---
# <title>
## Overview / Motivation
## Key findings / Progress
## Open questions / Next steps
## Links
```

**When creating or updating a note:**
1. Check `.research/notes/index.json` for existing notes on the same topic — update instead of duplicate.
2. Link to source ideas (`related_ideas`) or papers (`related_papers`) as appropriate.
3. Use `scripts/notes.sh add` to create the index entry and template file.
4. Use `scripts/notes.sh status` to transition between states.

See `references/notes-protocol.md` for the full protocol.

---

### goals — Goal definition and evaluation

When the user wants to define a formal research goal or evaluate whether
a direction is worth pursuing:

1. **Read the framework** — load `references/goal-framework.md` for the
   full evaluation dimensions.
2. **Wiki pre-check** — search wiki for related concepts, prior surveys,
   and previously explored directions. Report what exists and flag
   potential overlap.
3. **Walk through the framework interactively** — don't dump all
   questions at once. Lead the conversation:

   - **Novelty**: "Does this direction overlap with known work in this
     area?" Let the user answer, then suggest a SOTA check if needed.
   - **Feasibility**: "Do you have the data, compute, and expertise to
     execute this?"
   - **Value**: "If it works, what's the contribution? A new method?
     Better results? A theoretical insight?"

4. **Save** to `.research/goals/current.md`. If there was already a goal,
   archive the old one and start fresh.

See `references/goal-framework.md` for the complete evaluation protocol.

---

### literature — Literature survey and tracking

When the user wants to find papers, log papers they've read, or check
reading status:

**Search papers:**
1. Wiki pre-check — search wiki for the query. If sufficient coverage
   exists, report it and offer to read existing notes instead.
2. Search using available tools:
   - WebSearch for broad coverage
   - arXiv API (`export.arxiv.org/api/query`) for structured metadata
   - If deep survey needed, consider fanning out multiple searches
   - **Always keep search queries in `.research/literature/searches/`**
     with date + query + results summary to avoid re-searching the same
     thing later.

**Log a paper:**
1. Query the user for: arxiv ID (preferred), title, authors, venue
2. Search wiki sources for existing note — if found, link instead of
   duplicating
3. Add to `.research/literature/index.json`:
   ```json
   {
     "arxiv:2402.03300": {
       "title": "Let's Verify Step by Step",
       "authors": "Lightman et al.",
       "venue": "arXiv 2023",
       "year": 2023,
       "status": "to-read",
       "linked_routes": [],
       "notes": null
     }
   }
   ```
4. If the user wants to take notes, create
   `.research/literature/readings/<arxiv-id>.md`.

**Status values:** `to-read` → `reading` → `reviewed` → `integrated`

Use `scripts/lit.sh` for efficient index operations.

See `references/literature-protocol.md` for the complete search
strategy and note-taking protocol.

---

### route — Research route exploration

When the user has a goal and wants to explore technical approaches, or
when they have a new direction to evaluate:

1. **Wiki pre-check** — search wiki for routes already explored in other
   projects. Flag re-evaluation risk.
2. **Load the route exploration framework** — read
   `references/route-exploration.md` for the structured process.
3. **Divergence phase** — propose 2-4 candidate routes. Order by
   plausibility. For each, note:
   - Core idea (one paragraph)
   - Why it might work
   - Key risk
   - Related literature (reference by arxiv ID)
4. **Convergence phase** — based on user feedback, eliminate or refine
   routes. Ask questions that help decision-making:
   - "Route X has high novelty but the compute cost is significant. Is
     that acceptable?"
   - "Route Y is well-trodden — the contribution would need to be in
     the evaluation, not the method."
5. **Log decision** — update `.research/routes.md`.

Routes are stored in `.research/routes.json` with a human-readable
`.research/routes.md` auto-generated from it.
See `scripts/route.sh` for status transitions.

```yaml
routes:
  - id: self-consistency-prm
    title: "Self-consistency + process reward"
    goals: ["improve-math-reasoning"]
    status: adopted
    evaluated: 2026-07-02
    decision: "Novel combination, limited prior work, feasible with existing infra"
    related_lit: ["2203.11171", "2305.20050"]
```

---

### experiment — Experiment design and tracking

When the user wants to design an experiment, log a run, or compare
results:

1. **Load the template** — read `references/experiment-templates.md` for
   AI/ML experiment design guidelines.
2. **Guide the design**:
   - **Motivation**: what question is this experiment answering?
   - **Baseline**: what are you comparing against?
   - **Setup**: model, dataset, hyperparameters, compute
   - **Metrics**: main and secondary
   - **Ablations**: what components will you isolate?
3. **Save** to `.research/experiments/<exp-name>/design.md`. Create the
   directory via `scripts/exp.sh add <exp-name>`.
4. **When results come in**, log them to `results.md`:
   - **Cross-run comparison table** (different seeds, configs)
   - **Ablation table**
   - **vs baseline table**
   - **Preliminary analysis**: what the results suggest, surprises,
     next steps

Use `scripts/exp.sh` for experiment CRUD and status transitions.

See `references/experiment-templates.md` for templates and analysis
protocol.

---

### writing — Paper writing and submission management

When the user is writing a paper, targeting a venue, or responding to
reviews:

1. **Show current writing status** from `.research/writing/index.json`.
   If no papers exist, offer to create one.
2. **Log a new paper** — each paper gets its own directory under
   `.research/writing/<paper-name>/`:
   ```
   writing/
   ├── index.json                    ← all papers overview
   └── <paper-name>/
       ├── outline.md
       ├── drafts/
       │   ├── v1.md
       │   └── v2.md
       ├── submission.md             ← target venue, status, dates
       ├── reviews/
       │   ├── reviewer-1.md          ← original review text
       │   ├── reviewer-2.md
       │   ├── reviewer-3.md
       │   └── response.md            ← point-by-point rebuttal
       └── talks/
           └── slides.md              ← talk/poster outline
   ```

3. **Track venues** — for each paper, track:
   - target venue(s) with deadlines
   - submission date, status (drafting → submitted → under-review →
     accepted/rejected)
   - review dates and decisions

See `references/writing-protocol.md` for the complete protocol
including the rebuttal workflow.

---

### status — Progress overview

Always show a compact summary after each interaction. The summary reads
the current `state.json` and renders:

```
📋 <project name>
Phase: <phase>  |  Progress: <progress>%
• ideas: <N>     • notes: <N> active / <N> solidified
   • goals: active <N> / archived <N>
• literature: <N> surveyed, <N> to-read
• routes: active <N> / abandoned <N>
• experiments: <N> completed, <N> planned
• writing: <N> paper(s)
Latest: <last log entry excerpt>
```

## Wiki integration (cross-cutting)

The skill interacts with `~/LLM-Wiki/` (auto-detected) as a shared
knowledge base across all research projects. This is a cross-cutting
concern — it applies to **ideas**, **goals**, **literature**, and
**routes** modules.

### Protocol

| Phase | Action | Permission |
|-------|--------|------------|
| **Pre-check** | Before expensive operations, grep wiki for existing content. Found → offer to read, skip duplicate. | Read-only |
| **Contribute** | After creating new knowledge (paper notes, route analysis, concept writeup), ask user: "Should this be recorded in LLM-Wiki for future reuse?" | Confirm first |
| **Correct** | If pre-check finds outdated or incorrect info, flag to user and offer to update wiki. | Confirm first |

### Pre-check scope

- **Literature pre-check**: before searching, grep
  `~/LLM-Wiki/wiki/sources/` and `~/LLM-Wiki/wiki/concepts/` for the
  paper title or key terms.
- **Route pre-check**: before evaluating a route, grep wiki concepts
  for related approaches. If another project already explored this
  direction, surface the decision log.
- **Goal pre-check**: search wiki for surveys and concept pages that
  cover the proposed direction.

### Wiki contribution rules

When writing to wiki, follow `~/LLM-Wiki/AGENTS.md`:
- Concepts go to `wiki/concepts/<slug>.md`
- Paper summaries go to `wiki/sources/<slug>.md`
- Always include frontmatter (type, status, created, updated)
- Use bidirection links to related pages
- Distinguish sourced claims from inference
- Update `wiki/index.md` after additions

### Path detection

```python
# Pseudocode for config resolution
if .research/config.json contains wiki_path:
    use it
elif $LLM_WIKI_PATH env var is set:
    use it
elif ~/LLM-Wiki/wiki/index.md exists:
    use ~/LLM-Wiki/
else:
    prompt user once, cache in config.json
```

---

## When to escalate

This skill defines protocols and frameworks. It does NOT hardcode calls
to specific agents or tools. However, when a task exceeds what the model
can do with basic Read/Write/Bash/WebSearch, consider escalating:

| Condition | Suggested approach |
|-----------|-------------------|
| Need to survey many sources on an unfamiliar topic | Fan out multiple parallel searches or deep research |
| Goal feasibility is uncertain; need independent perspectives | Spawn independent analysis agents to challenge the idea from different angles |
| Need to compare multiple route options systematically | Run independent route evaluations in parallel, then synthesize |
| Literature survey returns many candidates; need structured rankings | Use independent agents to score and rank papers against criteria |
| Experiment results need adversarial analysis | Spawn agents to stress-test the conclusions |

The key principle: define the **dimension to evaluate** (novelty,
feasibility, reproducibility, etc.), not the **agent to call**.

---

## Scripts reference

| Script | Purpose |
|--------|---------|
| `.claude/skills/research-manager/scripts/init.sh <project-dir>` | Scaffold study project (code dirs + data dirs + `.research/` metadata) |
| `.claude/skills/research-manager/scripts/lit.sh` | Literature index: `add <arxiv-id>`, `list [status]`, `update <arxiv-id> <field=value>` |
| `.claude/skills/research-manager/scripts/state.sh` | State read/write: `get <field>`, `set <field>=<value>`, `summary` |
| `.claude/skills/research-manager/scripts/exp.sh` | Experiment CRUD: `add <name>`, `list`, `status <name> <new-status>` |
| `.claude/skills/research-manager/scripts/route.sh` | Route transitions: `add`, `status <id> <new-status>`, `list` |
| `.claude/skills/research-manager/scripts/notes.sh` | Research notes CRUD: `add <slug> --title "..."`, `list [status]`, `status <slug> <new-status>`, `rm <slug>` |
| `.claude/skills/research-manager/scripts/log.sh` | Log append: `add <type> <message>`, `recent [N]` |

These scripts are **optional aids** — they save token cost by replacing
multi-step Read/Edit cycles with single commands. Use them when the
operation is mechanical (index updates, status transitions). For
open-ended tasks (designing an experiment, evaluating a goal), skipping
the script and working directly is fine.

---

## Reference files

Read these when their module is active:

- `references/goal-framework.md` — Evaluation dimensions for research
  goals (novelty, feasibility, value, timing)
- `references/notes-protocol.md` — Research notes lifecycle, types,
  creation and transition workflows
- `references/literature-protocol.md` — Search strategies, dedup rules,
  note-taking standards for literature
- `references/route-exploration.md` — Divergence → convergence process,
  evaluation criteria for research routes
- `references/experiment-templates.md` — Experiment design templates,
  results analysis and cross-experiment comparison protocol
- `references/writing-protocol.md` — Paper writing workflow, venue
  selection, submission tracking, and rebuttal handling
- `references/wiki-interaction.md` — Detailed wiki pre-check and
  contribution protocol
