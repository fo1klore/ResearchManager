#!/usr/bin/env bash
# notes.sh — Research notes CRUD and status transitions
# Usage:
#   notes.sh add <slug> --title "..." --type "idea-development" [--related-ideas "..."] [--related-papers "..."]
#   notes.sh list [status]
#   notes.sh status <slug> <new-status>
#   notes.sh rm <slug>
#
# Types: idea-development | paper-writing | technical-analysis | literature-digest
# Statuses: in-progress | solidified | archived

set -euo pipefail

INDEX=".research/notes/index.json"
NOTESDIR=".research/notes"
STATE=".research/state.json"
TODAY=$(date +%Y-%m-%d)

ensure_index() {
    mkdir -p "$NOTESDIR"
    if [ ! -f "$INDEX" ]; then
        echo '{"notes":[]}' > "$INDEX"
    fi
}

increment_state() {
    # Increment notes_active in state.json
    if [ -f "$STATE" ]; then
        python3 -c "
import json
d = json.load(open('$STATE'))
s = d.get('stats', {})
s['notes_active'] = s.get('notes_active', 0) + 1
d['stats'] = s
d['updated'] = '$TODAY'
json.dump(d, open('$STATE', 'w'), indent=2)
" 2>/dev/null || true
    fi
}

decrement_state() {
    if [ -f "$STATE" ]; then
        python3 -c "
import json
d = json.load(open('$STATE'))
s = d.get('stats', {})
s['notes_active'] = max(0, s.get('notes_active', 0) - 1)
d['stats'] = s
d['updated'] = '$TODAY'
json.dump(d, open('$STATE', 'w'), indent=2)
" 2>/dev/null || true
    fi
}

case "${1:-help}" in
    add)
        SLUG="$2"
        shift 2
        TITLE=""; NTYPE="idea-development"; RELATED_IDEAS="[]"; RELATED_PAPERS="[]"
        while [ $# -gt 0 ]; do
            case "$1" in
                --title) TITLE="$2"; shift 2 ;;
                --type) NTYPE="$2"; shift 2 ;;
                --related-ideas)
                    RELATED_IDEAS=$(echo "$2" | python3 -c "import sys, json; print(json.dumps([s.strip() for s in sys.stdin.read().strip().split(',') if s.strip()]))")
                    shift 2 ;;
                --related-papers)
                    RELATED_PAPERS=$(echo "$2" | python3 -c "import sys, json; print(json.dumps([s.strip() for s in sys.stdin.read().strip().split(',') if s.strip()]))")
                    shift 2 ;;
                *) shift ;;
            esac
        done

        if [ -z "$TITLE" ]; then
            echo "! usage: notes.sh add <slug> --title \"...\" [--type <type>] [--related-ideas \"a,b\"] [--related-papers \"x,y\"]"
            exit 1
        fi

        ensure_index
        python3 - "$INDEX" "$SLUG" "$TITLE" "$NTYPE" "$TODAY" "$RELATED_IDEAS" "$RELATED_PAPERS" <<'PYEOF'
import json, sys
index_file = sys.argv[1]
slug = sys.argv[2]
title = sys.argv[3]
ntype = sys.argv[4]
today = sys.argv[5]
related_ideas = json.loads(sys.argv[6]) if sys.argv[6] != "[]" else []
related_papers = json.loads(sys.argv[7]) if sys.argv[7] != "[]" else []

with open(index_file) as f:
    d = json.load(f)

for n in d["notes"]:
    if n["slug"] == slug:
        print(f"! Note {slug} already exists")
        sys.exit(0)

d["notes"].append({
    "slug": slug,
    "title": title,
    "type": ntype,
    "status": "in-progress",
    "created": today,
    "updated": today,
    "related_ideas": related_ideas,
    "related_papers": related_papers
})

with open(index_file, 'w') as f:
    json.dump(d, f, indent=2)
print(f"✓ Note {slug} added as in-progress")
PYEOF

        NOTE_FILE="$NOTESDIR/$SLUG.md"
        if [ ! -f "$NOTE_FILE" ]; then
            cat > "$NOTE_FILE" <<NOTE
---
id: $SLUG
title: $TITLE
type: $NTYPE
created: $TODAY
updated: $TODAY
status: in-progress
related_ideas: $RELATED_IDEAS
related_papers: $RELATED_PAPERS
---

# $TITLE

## Overview / Motivation

## Key findings / Progress

## Open questions / Next steps

## Links
NOTE
            echo "  Created $NOTE_FILE"
        fi
        increment_state
        ;;

    list)
        ensure_index
        python3 - "$INDEX" "${2:-}" <<'PYEOF'
import json, sys
index_file = sys.argv[1]
status_filter = sys.argv[2] if len(sys.argv) > 2 else ""

with open(index_file) as f:
    d = json.load(f)

found = False
for n in d.get("notes", []):
    s = n.get("status", "in-progress")
    if status_filter and s != status_filter:
        continue
    found = True
    title = n.get("title", "?")[:60]
    ntype = n.get("type", "?")
    print(f"{n['slug']:30} [{s:12}] [{ntype:20}] {title}")

if not found:
    print("(no notes)" if not status_filter else f"(no notes with status '{status_filter}')")
PYEOF
        ;;

    status)
        SLUG="$2"
        NEWSTATUS="$3"
        if [ -z "$SLUG" ] || [ -z "$NEWSTATUS" ]; then
            echo "! usage: notes.sh status <slug> <new-status>"
            exit 1
        fi
        if [ "$NEWSTATUS" != "in-progress" ] && [ "$NEWSTATUS" != "solidified" ] && [ "$NEWSTATUS" != "archived" ]; then
            echo "! Invalid status: $NEWSTATUS. Use: in-progress, solidified, archived"
            exit 1
        fi
        ensure_index
        python3 - "$INDEX" "$SLUG" "$NEWSTATUS" "$TODAY" <<'PYEOF'
import json, sys
index_file = sys.argv[1]
slug = sys.argv[2]
new_status = sys.argv[3]
today = sys.argv[4]

with open(index_file) as f:
    d = json.load(f)

for n in d["notes"]:
    if n["slug"] == slug:
        old_status = n.get("status", "?")
        n["status"] = new_status
        n["updated"] = today
        with open(index_file, 'w') as f:
            json.dump(d, f, indent=2)
        print(f"✓ Note '{slug}': {old_status} → {new_status}")
        sys.exit(0)

print(f"! Note '{slug}' not found")
PYEOF

        # Update .md file frontmatter if it exists
        NOTE_FILE="$NOTESDIR/$SLUG.md"
        if [ -f "$NOTE_FILE" ]; then
            python3 - "$NOTE_FILE" "$NEWSTATUS" "$TODAY" <<'PYEOF'
import re, sys
filepath = sys.argv[1]
new_status = sys.argv[2]
today = sys.argv[3]

with open(filepath) as f:
    content = f.read()

# Update status in frontmatter
content = re.sub(
    r'^(status:)\s*\S+',
    r'\1 ' + new_status,
    content,
    count=1,
    flags=re.MULTILINE
)
# Update updated date
content = re.sub(
    r'^(updated:)\s*\S+',
    r'\1 ' + today,
    content,
    count=1,
    flags=re.MULTILINE
)

with open(filepath, 'w') as f:
    f.write(content)

print(f"  Updated {filepath}")
PYEOF
        fi
        ;;

    rm)
        SLUG="$2"
        if [ -z "$SLUG" ]; then
            echo "! usage: notes.sh rm <slug>"
            exit 1
        fi
        ensure_index
        python3 - "$INDEX" "$SLUG" <<'PYEOF'
import json, sys
index_file = sys.argv[1]
slug = sys.argv[2]

with open(index_file) as f:
    d = json.load(f)

before = len(d["notes"])
d["notes"] = [n for n in d["notes"] if n["slug"] != slug]

if len(d["notes"]) < before:
    with open(index_file, 'w') as f:
        json.dump(d, f, indent=2)
    print(f"✓ Removed note {slug} from index (file kept at .research/notes/{slug}.md)")
else:
    print(f"! Note {slug} not found")
PYEOF
        decrement_state
        ;;

    *)
        echo "Usage: notes.sh add|list|status|rm"
        echo ""
        echo "  add <slug> --title \"...\" [--type <type>] [--related-ideas \"a,b\"] [--related-papers \"x,y\"]"
        echo "  list [status]"
        echo "  status <slug> <new-status>"
        echo "  rm <slug>"
        echo ""
        echo "Types:    idea-development | paper-writing | technical-analysis | literature-digest"
        echo "Statuses: in-progress | solidified | archived"
        exit 1
        ;;
esac
