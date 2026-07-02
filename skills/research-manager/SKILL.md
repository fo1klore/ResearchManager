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
   - counts: ideas, goals, routes, literature, experiments
4. **Present the menu** — inline, not a big card:

   > Current: <project> (<progress>%) — <phase>
   > What would you like to do?
   > • view status / update progress
   > • capture an idea
   > • define or evaluate a goal
   > • survey literature / log a paper
   > • explore or log research routes
   > • design / log an experiment
   > • manage writing or submissions
   > • write to log

If `.research/` doesn't exist, ask: "This project doesn't have a research
manager yet. Initialize it?" If yes, run `scripts/init.sh` in the project
root, then show the menu.

At the end of each interaction, **persist changes** — write back
`state.json`, append to `log.md`, and save any new/updated files in the
relevant subdirectory. Summarize what changed as a one-liner.

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
   ---
   # <title>
   ## The idea
   ## Why it might matter
   ## Related work (wiki-found or known)
   ## Open questions
   ```
3. **Ask about next step** — "Do you want to turn this into a formal
   research goal? Or keep it as an idea for now?"

Ideas don't need an elaborate triage system. The user decides when to
promote one to a goal.

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

Routes are stored in a single flat file with frontmatter for machine
readability. See `scripts/route.sh` for status transitions.

```yaml
---
routes:
  - id: self-consistency-prm
    title: "Self-consistency + process reward"
    goal: [improve-math-reasoning]    # references goal(s)
    status: adopted     # proposed → evaluating → adopted / abandoned
    evaluated: 2026-07-02
    decision: "Novel combination, limited prior work, feasible with existing infra"
    related_lit: [2203.11171, 2305.20050]
---
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
• ideas: <N>     • goals: active <N> / archived <N>
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
| `scripts/init.sh <project-dir>` | Create `.research/` skeleton with default state.json |
| `scripts/lit.sh` | Literature index: `add <arxiv-id>`, `list [status]`, `update <arxiv-id> <field=value>` |
| `scripts/state.sh` | State read/write: `get <field>`, `set <field>=<value>`, `summary` |
| `scripts/exp.sh` | Experiment CRUD: `add <name>`, `list`, `status <name> <new-status>` |
| `scripts/route.sh` | Route transitions: `add`, `status <id> <new-status>`, `list` |
| `scripts/log.sh` | Log append: `add <type> <message>`, `recent [N]` |

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
