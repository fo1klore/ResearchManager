#!/usr/bin/env bash
# lit.sh — Literature index operations
# Usage:
#   lit.sh add <arxiv-id> [--title "..." --authors "..." --venue "..."]
#   lit.sh list [status]
#   lit.sh update <arxiv-id> <field=value> [<field=value> ...]
#   lit.sh rm <arxiv-id>

set -euo pipefail

INDEX=".research/literature/index.json"

case "${1:-help}" in
    add)
        ID="$2"
        shift 2
        # Collect metadata into env vars to avoid shell quoting issues
        LIT_TITLE=""; LIT_AUTHORS=""; LIT_VENUE=""
        while [ $# -gt 0 ]; do
            case "$1" in
                --title) LIT_TITLE="$2"; shift 2 ;;
                --authors) LIT_AUTHORS="$2"; shift 2 ;;
                --venue) LIT_VENUE="$2"; shift 2 ;;
                *) shift ;;
            esac
        done
        mkdir -p "$(dirname "$INDEX")"
        [ -f "$INDEX" ] || echo '{}' > "$INDEX"
        # Check if exists, then add/update
        python3 - "$ID" "$LIT_TITLE" "$LIT_AUTHORS" "$LIT_VENUE" <<'PYEOF'
import json, sys, os
idx_file = ".research/literature/index.json"
paper_id = sys.argv[1]
title = sys.argv[2]
authors = sys.argv[3]
venue = sys.argv[4]

with open(idx_file) as f:
    d = json.load(f)

existing = paper_id in d
d[paper_id] = {
    "title": title,
    "authors": authors,
    "venue": venue,
    "status": "to-read",
    "linked_routes": [],
    "notes": None
}
with open(idx_file, 'w') as f:
    json.dump(d, f, indent=2)

if existing:
    print(f"✓ Updated {paper_id} in literature index")
else:
    print(f"✓ Added {paper_id} to literature index")
PYEOF
        ;;
    list)
        mkdir -p "$(dirname "$INDEX")"
        [ -f "$INDEX" ] || echo '{}' > "$INDEX"
        STATUS_FILTER="${2:-}"
        python3 - "$STATUS_FILTER" <<'PYEOF'
import json, sys
idx_file = ".research/literature/index.json"
status_filter = sys.argv[1]

with open(idx_file) as f:
    d = json.load(f)

if not d:
    print("(empty)")
    sys.exit(0)

found = False
for k, v in sorted(d.items()):
    s = v.get("status", "unknown")
    if status_filter and s != status_filter:
        continue
    found = True
    title = v.get("title", "?")[:60]
    print(f"{k:20} [{s:12}] {title}")

if not found and status_filter:
    print(f"(no papers with status '{status_filter}')")
elif not found:
    print("(empty)")
PYEOF
        ;;
    update)
        ID="$2"
        shift 2
        [ -f "$INDEX" ] || echo '{}' > "$INDEX"
        # Pass field=value pairs as remaining args
        python3 - "$ID" "$@" <<'PYEOF'
import json, sys
idx_file = ".research/literature/index.json"
paper_id = sys.argv[1]
pairs = sys.argv[2:]

with open(idx_file) as f:
    d = json.load(f)

if paper_id not in d:
    print(f"! {paper_id} not found in index")
    sys.exit(1)

entry = d[paper_id]
for pair in pairs:
    if "=" not in pair:
        continue
    field, val = pair.split("=", 1)
    # Try numeric
    try:
        val = int(val)
    except ValueError:
        pass
    entry[field] = val

with open(idx_file, 'w') as f:
    json.dump(d, f, indent=2)

print(f"✓ Updated {paper_id}")
PYEOF
        ;;
    rm)
        ID="$2"
        [ -f "$INDEX" ] || echo '{}' > "$INDEX"
        python3 - "$ID" <<'PYEOF'
import json, sys
idx_file = ".research/literature/index.json"
paper_id = sys.argv[1]

with open(idx_file) as f:
    d = json.load(f)

if paper_id in d:
    del d[paper_id]
    with open(idx_file, 'w') as f:
        json.dump(d, f, indent=2)
    print(f"✓ Removed {paper_id}")
else:
    print(f"! {paper_id} not found")
PYEOF
        ;;
    *)
        echo "Usage: lit.sh add|list|update|rm"
        exit 1
        ;;
esac
