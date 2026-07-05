#!/usr/bin/env bash
# state.sh — Read/write .research/state.json
# Usage:
#   state.sh get <field>
#   state.sh set <field>=<value>
#   state.sh stats <field>=<val>
#   state.sh increment <field>
#   state.sh summary

set -euo pipefail

STATE=".research/state.json"
TODAY=$(date +%Y-%m-%d)

ensure_state() {
    if [ ! -f "$STATE" ]; then
        echo "{}"
        return
    fi
}

case "${1:-help}" in
    get)
        python3 -c "
import json, sys
d = json.load(open('$STATE'))
keys = '${2}'.split('.')
v = d
for k in keys:
    if isinstance(v, dict):
        v = v.get(k, '')
    else:
        v = ''
print(v)
" 2>/dev/null || echo ""
        ;;
    set)
        python3 -c "
import json
d = json.load(open('$STATE'))
pair = '${2}'
if '=' not in pair:
    print('! use: set field=value')
    sys.exit(1)
field, val = pair.split('=', 1)
keys = field.split('.')
target = d
for k in keys[:-1]:
    target = target[k]
# try int first
try:
    target[keys[-1]] = int(val)
except ValueError:
    target[keys[-1]] = val
d['updated'] = '$TODAY'
json.dump(d, open('$STATE', 'w'), indent=2)
print(f'✓ {field} = {val}')
" 2>/dev/null || echo "! failed to set $2"
        ;;
    stats)
        python3 -c "
import json, sys
d = json.load(open('$STATE'))
pair = '${2}'
if '=' not in pair:
    print('! use: stats field=value')
    sys.exit(1)
field, val = pair.split('=', 1)
try:
    d['stats'][field] = int(val)
except ValueError:
    d['stats'][field] = val
d['updated'] = '$TODAY'
json.dump(d, open('$STATE', 'w'), indent=2)
print(f'✓ stats.{field} = {val}')
" 2>/dev/null || echo "! failed to set stats.$2"
        ;;
    increment)
        python3 -c "
import json, sys
d = json.load(open('$STATE'))
keys = '${2}'.split('.')
target = d
for k in keys[:-1]:
    target = target[k]
target[keys[-1]] = target.get(keys[-1], 0) + 1
d['updated'] = '$TODAY'
json.dump(d, open('$STATE', 'w'), indent=2)
print(f'✓ {keys[-1]} incremented')
" 2>/dev/null || echo "! failed to increment $2"
        ;;
    summary)
        python3 -c "
import json, sys
try:
    d = json.load(open('$STATE'))
except:
    print('(no .research/state.json found)')
    sys.exit(0)
s = d.get('stats', {})
print(f\"Project: {d.get('project_name', '(unnamed)')}\")
print(f\"Phase:   {d.get('phase', '—')}  |  Progress: {d.get('progress', 0)}%\")
print(f\"Ideas:   {s.get('ideas', 0)}  |  Goals: {s.get('goals_active', 0)} active\")
print(f\"Notes:   {s.get('notes_active', 0)} active\")
print(f\"Lit:     {s.get('literature_surveyed', 0)} surveyed\")
print(f\"Routes:  {s.get('routes_active', 0)} active\")
print(f\"Exp:     {s.get('experiments_completed', 0)} completed\")
print(f\"Papers:  {s.get('papers_active', 0)} active\")
print(f\"Updated: {d.get('updated', '—')}\")
"
        ;;
    *)
        echo "Usage: state.sh get|set|stats|increment|summary"
        exit 1
        ;;
esac
