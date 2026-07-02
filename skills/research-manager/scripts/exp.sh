#!/usr/bin/env bash
# exp.sh — Experiment CRUD and status transitions
# Usage:
#   exp.sh add <name> [--route <id>] [--desc "..."]
#   exp.sh list [status]
#   exp.sh status <name> <new-status>
#   exp.sh rm <name>

set -euo pipefail

INDEX=".research/experiments/index.json"
EXPDIR=".research/experiments"

ensure_index() {
    mkdir -p "$EXPDIR"
    if [ ! -f "$INDEX" ]; then
        echo '{"experiments":[]}' > "$INDEX"
    fi
}

case "${1:-help}" in
    add)
        NAME="$2"
        shift 2
        ROUTE=""; DESC=""
        while [ $# -gt 0 ]; do
            case "$1" in
                --route) ROUTE="$2"; shift 2 ;;
                --desc) DESC="$2"; shift 2 ;;
                *) shift ;;
            esac
        done
        ensure_index
        python3 -c "
import json
d = json.load(open('$INDEX'))
for e in d['experiments']:
    if e['name'] == '$NAME':
        print(f'! exp $NAME already exists')
        exit(0)
d['experiments'].append({'name': '$NAME', 'route': '$ROUTE', 'status': 'planned', 'primary_metric': None, 'baseline_metric': None, 'key_finding': None, 'conclusion': None})
json.dump(d, open('$INDEX', 'w'), indent=2)
"
        mkdir -p "$EXPDIR/$NAME"
        if [ ! -f "$EXPDIR/$NAME/design.md" ]; then
            cat > "$EXPDIR/$NAME/design.md" <<DESC
# $NAME

## Motivation

## Baseline

## Setup

## Metrics
DESC
        fi
        echo "✓ Added experiment $NAME"
        ;;
    list)
        ensure_index
        python3 -c "
import json, sys
d = json.load(open('$INDEX'))
flt = '${2:-}'
for e in d['experiments']:
    if flt and e.get('status') != flt:
        continue
    s = e.get('status', '?')
    m = e.get('primary_metric', '—')
    print(f\"{e['name']:30} [{s:12}] metric={m}\")
" 2>/dev/null || echo "(no experiments)"
        ;;
    status)
        NAME="$2"
        NEWSTATUS="$3"
        ensure_index
        python3 -c "
import json, sys
d = json.load(open('$INDEX'))
for e in d['experiments']:
    if e['name'] == '$NAME':
        e['status'] = '$NEWSTATUS'
        json.dump(d, open('$INDEX', 'w'), indent=2)
        print(f'✓ $NAME → $NEWSTATUS')
        sys.exit(0)
print(f'! experiment $NAME not found')
" 2>/dev/null
        ;;
    rm)
        NAME="$2"
        ensure_index
        python3 -c "
import json, sys
d = json.load(open('$INDEX'))
before = len(d['experiments'])
d['experiments'] = [e for e in d['experiments'] if e['name'] != '$NAME']
if len(d['experiments']) < before:
    json.dump(d, open('$INDEX', 'w'), indent=2)
    print(f'✓ Removed $NAME from index (dir kept at $EXPDIR/$NAME)')
else:
    print(f'! experiment $NAME not found')
" 2>/dev/null
        ;;
    *)
        echo "Usage: exp.sh add|list|status|rm"
        exit 1
        ;;
esac
