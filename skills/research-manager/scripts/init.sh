#!/usr/bin/env bash
# init.sh — Initialize .research/ skeleton for a research project
# Usage: scripts/init.sh <project-directory>
# Creates .research/ with all subdirectories and default state files

set -euo pipefail

PROJECT_DIR="${1:-.}"
RESEARCH_DIR="$PROJECT_DIR/.research"
TODAY=$(date +%Y-%m-%d)

if [ -f "$RESEARCH_DIR/state.json" ]; then
    echo "! .research/ already exists in $PROJECT_DIR"
    echo "  Run with OVERWRITE=1 to reinitialize (preserves existing files)"
    exit 0
fi

# Create directory structure
mkdir -p "$RESEARCH_DIR"/ideas
mkdir -p "$RESEARCH_DIR"/goals
mkdir -p "$RESEARCH_DIR"/literature/readings
mkdir -p "$RESEARCH_DIR"/literature/searches
mkdir -p "$RESEARCH_DIR"/experiments
mkdir -p "$RESEARCH_DIR"/writing
mkdir -p "$RESEARCH_DIR"/talks

# Create empty files
touch "$RESEARCH_DIR/routes.md"
touch "$RESEARCH_DIR/log.md"

# config.json
cat > "$RESEARCH_DIR/config.json" <<CONFIG
{
  "wiki_path": null,
  "wiki_last_synced": null,
  "created": "$TODAY"
}
CONFIG

# literature index
echo '{}' > "$RESEARCH_DIR/literature/index.json"

# experiment index
cat > "$RESEARCH_DIR/experiments/index.json" <<'EXPINDEX'
{
  "experiments": []
}
EXPINDEX

# writing index
cat > "$RESEARCH_DIR/writing/index.json" <<'WRIINDEX'
{
  "papers": []
}
WRIINDEX

# state.json
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

echo "✓ Initialized .research/ in $PROJECT_DIR"
echo "  Edit .research/state.json to set project name, then run /research-manager"
