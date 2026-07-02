#!/usr/bin/env bash
# init.sh — Scaffold a complete research project
# Usage: scripts/init.sh <project-directory>
# Creates the full project skeleton:
#   .research/    — Research metadata system (managed by skill)
#   src/          — Experiment code
#   configs/      — Experiment configurations
#   data/         — Datasets (gitignored)
#   results/      — Experiment outputs (gitignored)
#   notebooks/    — Analysis notebooks
#   paper/        — Paper LaTeX source
#   slides/       — Presentations
#   scripts/      — Project-specific utilities
#   .gitignore    — Sensible defaults for research projects

set -euo pipefail

PROJECT_DIR="${1:-}"
TODAY=$(date +%Y-%m-%d)

if [ -z "$PROJECT_DIR" ]; then
    echo "Usage: $0 <project-directory>"
    echo "Example: $0 ~/my-research-project"
    exit 1
fi

# Create project root if it doesn't exist
mkdir -p "$PROJECT_DIR"

RESEARCH_DIR="$PROJECT_DIR/.research"

if [ -f "$RESEARCH_DIR/state.json" ]; then
    echo "! .research/ already exists in $PROJECT_DIR"
    echo "  Run with OVERWRITE=1 to reinitialize (preserves existing state files)"
    exit 0
fi

# ── .research/ directories ──
mkdir -p "$RESEARCH_DIR"/ideas
mkdir -p "$RESEARCH_DIR"/goals
mkdir -p "$RESEARCH_DIR"/literature/readings
mkdir -p "$RESEARCH_DIR"/literature/searches
mkdir -p "$RESEARCH_DIR"/experiments
mkdir -p "$RESEARCH_DIR"/writing
mkdir -p "$RESEARCH_DIR"/talks

# ── .research/ data files ──
echo '{"routes":[]}' > "$RESEARCH_DIR/routes.json"
touch "$RESEARCH_DIR/log.md"

cat > "$RESEARCH_DIR/config.json" <<CONFIG
{
  "wiki_path": null,
  "wiki_last_synced": null,
  "created": "$TODAY"
}
CONFIG

echo '{}' > "$RESEARCH_DIR/literature/index.json"

cat > "$RESEARCH_DIR/experiments/index.json" <<'EXPINDEX'
{
  "experiments": []
}
EXPINDEX

cat > "$RESEARCH_DIR/writing/index.json" <<'WRIINDEX'
{
  "papers": []
}
WRIINDEX

cat > "$RESEARCH_DIR/state.json" <<STATE
{
  "project_name": "",
  "status": "active",
  "progress": 0,
  "phase": "initializing",
  "current_goal": null,
  "stats": {
    "ideas": 0,
    "goals_active": 0,
    "literature_surveyed": 0,
    "routes_active": 0,
    "experiments_completed": 0,
    "papers_active": 0
  },
  "updated": "$TODAY"
}
STATE

# ── Project-level directories ──
mkdir -p "$PROJECT_DIR"/src
mkdir -p "$PROJECT_DIR"/configs
mkdir -p "$PROJECT_DIR"/data
mkdir -p "$PROJECT_DIR"/results
mkdir -p "$PROJECT_DIR"/notebooks
mkdir -p "$PROJECT_DIR"/paper
mkdir -p "$PROJECT_DIR"/slides
mkdir -p "$PROJECT_DIR"/scripts

# Keep empty directories in git
for dir in src configs data results notebooks paper slides scripts; do
    touch "$PROJECT_DIR/$dir/.gitkeep"
done

# ── .gitignore ──
cat > "$PROJECT_DIR/.gitignore" <<'GITIGNORE'
# OS files
.DS_Store
Thumbs.db

# Python
__pycache__/
*.pyc
*.pyo
*.egg-info/
dist/
build/

# Research generated files (large or auto-generated)
data/
results/
checkpoints/
runs/
wandb/

# Notebook checkpoints
.ipynb_checkpoints/

# Environment
.env
venv/
.venv/

# Editor
.vscode/
.idea/
*.swp
*.swo
*~
GITIGNORE


echo ""
echo "✓ Research project scaffolded in $(cd "$PROJECT_DIR" && pwd)"
echo ""
echo "  ┌──────────────────────────────────────────────────────────┐"
echo "  │ Next steps:                                              │"
echo "  │                                                          │"
echo "  │ 1. Set project name in .research/state.json              │"
echo "  │                                                          │"
echo "  │ 2. Install the skill (one-time):                         │"
echo "  │    mkdir -p .claude/skills/research-manager               │"
echo "  │    cp -r /path/to/ResearchManager/* .claude/skills/      │"
echo "  │        research-manager/                                 │"
echo "  │                                                          │"
echo "  │ 3. Start managing:                                       │"
echo "  │    cd . && claude → /research-manager                    │"
echo "  └──────────────────────────────────────────────────────────┘"
