#!/usr/bin/env bash
# lit.sh — Literature index operations
# Usage:
#   lit.sh add <arxiv-id> [--title "..." --authors "..." --venue "..."]
#   lit.sh list [status]
#   lit.sh update <arxiv-id> <field=value> [<field=value> ...]
#   lit.sh rm <arxiv-id>

set -euo pipefail

INDEX=".research/literature/index.json"

ensure_index() {
    if [ ! -f "$INDEX" ]; then
        echo '{}' > "$INDEX"
    fi
}

case "${1:-help}" in
    add)
        ID="$2"
        shift 2
        ensure_index
        # Build JSON entry from remaining args
        TITLE=""; AUTHORS=""; VENUE=""
        while [ $# -gt 0 ]; do
            case "$1" in
                --title) TITLE="$2"; shift 2 ;;
                --authors) AUTHORS="$2"; shift 2 ;;
                --venue) VENUE="$2"; shift 2 ;;
                *) shift ;;
            esac
        done
        # Check if exists
        if python3 -c "import json; d=json.load(open('$INDEX')); exit(0 if '$ID' not in d else 1)" 2>/dev/null; then
            python3 -c "
import json, sys
d = json.load(open('$INDEX'))
d['$ID'] = {'title': '$TITLE', 'authors': '$AUTHORS', 'venue': '$VENUE', 'status': 'to-read', 'linked_routes': [], 'notes': None}
json.dump(d, open('$INDEX', 'w'), indent=2)
"
            echo "✓ Added $ID to literature index"
        else
            echo "! $ID already in index (use 'update' to modify)"
        fi
        ;;
    list)
        ensure_index
        STATUS_FILTER="${2:-}"
        python3 -c "
import json, sys
d = json.load(open('$INDEX'))
if not d:
    print('(empty)')
    sys.exit(0)
for k, v in sorted(d.items()):
    s = v.get('status', 'unknown')
    if '$STATUS_FILTER' and s != '$STATUS_FILTER':
        continue
    print(f\"{k} [{s:12}] {v.get('title', '?')[:60]}\")
"
        ;;
    update)
        ID="$2"
        shift 2
        ensure_index
        FIELDS=""
        for kv in "$@"; do
            FIELD="${kv%%=*}"
            VALUE="${kv#*=}"
            FIELDS="$FIELDS --arg $FIELD \"$VALUE\""
        done
        python3 -c "
import json, sys
d = json.load(open('$INDEX'))
if '$ID' not in d:
    print(f'! $ID not found in index')
    sys.exit(1)
entry = d['$ID']
$(for kv in "$@"; do
    FIELD="${kv%%=*}"
    VALUE="${kv#*=}"
    echo "entry['$FIELD'] = '$VALUE'"
done)
json.dump(d, open('$INDEX', 'w'), indent=2)
print(f'✓ Updated $ID')
"
        ;;
    rm)
        ID="$2"
        ensure_index
        python3 -c "
import json
d = json.load(open('$INDEX'))
if d.pop('$ID', None):
    json.dump(d, open('$INDEX', 'w'), indent=2)
    print(f'✓ Removed $ID')
else:
    print(f'! $ID not found')
"
        ;;
    *)
        echo "Usage: lit.sh add|list|update|rm"
        exit 1
        ;;
esac
