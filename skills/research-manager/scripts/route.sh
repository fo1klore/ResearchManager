#!/usr/bin/env bash
# route.sh — Route status transitions and listing
# Usage:
#   route.sh add <id> --title "..." --goals "..."
#   route.sh list [status]
#   route.sh status <id> <new-status> [--decision "..."]

set -euo pipefail

ROUTES=".research/routes.md"

ensure_routes() {
    if [ ! -f "$ROUTES" ]; then
        echo '---' > "$ROUTES"
        echo 'routes: []' >> "$ROUTES"
        echo '---' >> "$ROUTES"
        echo '' >> "$ROUTES"
        echo '# Research Routes' >> "$ROUTES"
    fi
}

case "${1:-help}" in
    add)
        ID="$2"
        shift 2
        TITLE=""; GOALS=""
        while [ $# -gt 0 ]; do
            case "$1" in
                --title) TITLE="$2"; shift 2 ;;
                --goals) GOALS="$2"; shift 2 ;;
                *) shift ;;
            esac
        done
        ensure_routes
        python3 -c "
import json, re, sys
with open('$ROUTES') as f:
    text = f.read()
m = re.match(r'^---\n(.*?)\n---\n?(.*)', text, re.DOTALL)
if not m:
    print('! bad routes.md format')
    sys.exit(1)
fm = m.group(1)
body = m.group(2)
routes = fm.split('\n')
routes.append(f'  - id: $ID')
routes.append(f'    title: \"$TITLE\"')
# parse goals array
goals_str = '[$GOALS]'
routes.append(f'    goal: {goals_str}')
routes.append(f'    status: proposed')
routes.append(f'    evaluated: $(date +%Y-%m-%d)')
routes.append(f'    decision: null')
routes.append(f'    related_lit: []')
out = '---\n' + '\n'.join(routes) + '\n---\n' + body
with open('$ROUTES', 'w') as f:
    f.write(out)
print(f'✓ Route $ID added as proposed')
"
        ;;
    list)
        ensure_routes
        FILTER="${2:-}"
        python3 -c "
import json, re, sys
with open('$ROUTES') as f:
    text = f.read()
m = re.search(r'---\n(.*?)\n---', text, re.DOTALL)
if not m:
    print('(no routes)')
    sys.exit(0)
lines = m.group(1).split('\n')
i = 0
while i < len(lines):
    l = lines[i].strip()
    if l.startswith('- id:'):
        rid = l.split(':')[1].strip()
        title = ''
        status = ''
        j = i + 1
        while j < len(lines) and (lines[j].startswith('    ') or lines[j] == ''):
            stripped = lines[j].strip()
            if stripped.startswith('title:'):
                title = stripped.split(':', 1)[1].strip().strip('\"')
            if stripped.startswith('status:'):
                status = stripped.split(':', 1)[1].strip()
            j += 1
        if not FILTER or status == FILTER:
            print(f'{rid:30} [{status:12}] {title}')
        i = j
    else:
        i += 1
"
        ;;
    status)
        ID="$2"
        NEWSTATUS="$3"
        shift 3
        DECISION=""
        while [ $# -gt 0 ]; do
            case "$1" in
                --decision) DECISION="$2"; shift 2 ;;
                *) shift ;;
            esac
        done
        ensure_routes
        python3 -c "
import json, re, sys
with open('$ROUTES') as f:
    text = f.read()
m = re.match(r'^---\n(.*?)\n---\n?(.*)', text, re.DOTALL)
if not m:
    print('! bad routes.md')
    sys.exit(1)
fm = m.group(1)
body = m.group(2)
# Find the route and update status
lines = fm.split('\n')
result = []
found = False
i = 0
while i < len(lines):
    l = lines[i]
    stripped = l.strip()
    if stripped.startswith('- id:') and stripped.split(':')[1].strip() == '$ID':
        found = True
        result.append(l)
        i += 1
        # copy/update indented lines until next route
        while i < len(lines) and (lines[i].startswith('    ') or lines[i] == ''):
            s = lines[i].strip()
            if s.startswith('status:'):
                result.append(f'    status: $NEWSTATUS')
            elif s.startswith('decision:') and '$DECISION' != '':
                result.append(f'    decision: \"$DECISION\"')
            else:
                result.append(lines[i])
            i += 1
    else:
        result.append(l)
        i += 1
if not found:
    print(f'! route $ID not found')
    sys.exit(1)
out = '---\n' + '\n'.join(result) + '\n---\n' + body
with open('$ROUTES', 'w') as f:
    f.write(out)
print(f'✓ Route $ID → $NEWSTATUS')
"
        ;;
    *)
        echo "Usage: route.sh add|list|status"
        exit 1
        ;;
esac
