# Wiki Interaction Protocol

How the skill interacts with the shared LLM-Wiki knowledge base.

## Purpose

The wiki (`~/LLM-Wiki/` by default) serves as a **cross-project shared
knowledge base**. Using it avoids re-surveying literature,
re-evaluating routes, and re-creating concept notes across different
research projects.

## Pre-check (read-only)

Before every expensive operation — literature search, route evaluation,
goal assessment — check the wiki for existing coverage.

### What to search

| Before this operation | Search these wiki paths |
|-----------------------|------------------------|
| Literature search | `wiki/sources/` (paper summaries), `wiki/concepts/` (related concepts) |
| Route evaluation | `wiki/concepts/` (approaches), wiki index for project history |
| Goal setting | `wiki/concepts/` (surveys, area overview) |

### Search method

```bash
grep -ril "<keyword>" ~/LLM-Wiki/wiki/concepts/ ~/LLM-Wiki/wiki/sources/ 2>/dev/null
```

For better coverage, try 2-3 keyword variations (e.g., "process reward",
"PRM", "process supervision").

### Handling matches

- **1-2 highly relevant matches** → load those pages and summarize for
  the user: "Wiki already has notes on X. Here's what's covered..."
- **Many loosely relevant matches** → read the index and ask user which
  pages to load
- **No matches** → proceed with the operation normally

### What not to do

Do NOT load every matching wiki page to check for relevance — that's
expensive. Use grep first, then load only promising hits.

## Contribution (write, with confirmation)

After creating new knowledge, offer to record it in the wiki.

### When to offer

| You just created... | Ask if user wants to add to wiki... |
|--------------------|------------------------------------|
| A detailed literature note | `wiki/sources/<arxiv-id>.md` |
| A new concept explanation | `wiki/concepts/<slug>.md` |
| An insightful route analysis | As a section in an existing concept page |
| A key experiment finding | In relevant concept page's note section |

### How to propose

Compact, not pushy — don't list everything:

> "This paper note is detailed enough to be useful across projects.
> Should I add it to ~/LLM-Wiki/wiki/sources/? (Y/n)"

If yes, follow `~/LLM-Wiki/AGENTS.md`:
- Write to correct directory
- Include frontmatter: `type`, `status`, `created`, `updated`
- Use bidirectional links to related pages
- Update `wiki/index.md`

## Correction (write, with confirmation)

If pre-check identifies wiki content that is outdated or incorrect:

> "I noticed the wiki page on X references a 2022 study, but your
> project has more recent findings. Would you like me to update the
> wiki? (Y/n)"

Updates are additive — append new sections, don't rewrite existing
ones unless the user explicitly asks.

## Path detection

```
Priority 1: .research/config.json  → wiki_path field
Priority 2: $LLM_WIKI_PATH         → environment variable
Priority 3: ~/LLM-Wiki/            → default
Priority 4: none                   → prompt user once, cache in config
```

Detection happens once at session start. Cache the result in
`.research/config.json`.
