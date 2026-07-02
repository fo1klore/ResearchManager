#!/usr/bin/env bash
# route.sh — Route status transitions (JSON-backed)
# Usage:
#   route.sh add <id> --title "..." --goals "..."
#   route.sh list [status]
#   route.sh status <id> <new-status> [--decision "..."]
#   route.sh rm <id>

set -euo pipefail

ROUTES_JSON=".research/routes.json"
ROUTES_MD=".research/routes.md"

ensure_json() {
    mkdir -p "$(dirname "$ROUTES_JSON")"
    if [ ! -f "$ROUTES_JSON" ]; then
        echo '{"routes": []}' > "$ROUTES_JSON"
    fi
}

# Rebuild routes.md from routes.json (human-readable summary)
rebuild_md() {
    python3 - "$ROUTES_JSON" "$ROUTES_MD" <<'PYEOF'
import json, sys
routes_file = sys.argv[1]
md_file = sys.argv[2]

with open(routes_file) as f:
    d = json.load(f)

routes = d.get("routes", [])
grouped = {"proposed": [], "evaluating": [], "adopted": [], "abandoned": []}
for r in routes:
    grouped.setdefault(r.get("status", "proposed"), []).append(r)

lines = ["# Research Routes", ""]
for status in ["adopted", "evaluating", "proposed", "abandoned"]:
    items = grouped.get(status, [])
    if not items:
        continue
    lines.append(f"## {status}")
    lines.append("")
    for r in items:
        title = r.get("title", r["id"])
        goal = ", ".join(r.get("goal", [])) if r.get("goal") else "—"
        decision = r.get("decision") or "pending"
        lines.append(f"- **{r['id']}**: {title}")
        lines.append(f"  - Goal: {goal}")
        lines.append(f"  - Decision: {decision}")
        lines.append("")

with open(md_file, 'w') as f:
    f.write("\n".join(lines) + "\n")
PYEOF
}

case "${1:-help}" in
    add)
        ID="$2"
        shift 2
        TITLE=""; GOALS_JSON="[]"
        while [ $# -gt 0 ]; do
            case "$1" in
                --title) TITLE="$2"; shift 2 ;;
                --goals)
                    # Goals is comma-separated, convert to JSON array
                    GOALS_JSON=$(echo "$2" | python3 -c "import sys, json; print(json.dumps([g.strip() for g in sys.stdin.read().strip().split(',') if g.strip()]))")
                    shift 2 ;;
                *) shift ;;
            esac
        done

        ensure_json
        python3 - "$ROUTES_JSON" "$ID" "$TITLE" "$GOALS_JSON" <<'PYEOF'
import json, sys
routes_file = sys.argv[1]
rid = sys.argv[2]
title = sys.argv[3]
goals = json.loads(sys.argv[4]) if sys.argv[4] != "[]" else []

import subprocess
today = subprocess.check_output(["date", "+%Y-%m-%d"]).decode().strip()

with open(routes_file) as f:
    d = json.load(f)

for r in d["routes"]:
    if r["id"] == rid:
        print(f"! Route {rid} already exists")
        sys.exit(0)

d["routes"].append({
    "id": rid,
    "title": title,
    "goal": goals,
    "status": "proposed",
    "evaluated": today,
    "decision": None,
    "related_lit": []
})
with open(routes_file, 'w') as f:
    json.dump(d, f, indent=2)
print(f"✓ Route {rid} added as proposed")
PYEOF
        rebuild_md
        ;;
    list)
        ensure_json
        python3 - "$ROUTES_JSON" "${2:-}" <<'PYEOF'
import json, sys
routes_file = sys.argv[1]
status_filter = sys.argv[2] if len(sys.argv) > 2 else ""

with open(routes_file) as f:
    d = json.load(f)

found = False
for r in d.get("routes", []):
    s = r.get("status", "proposed")
    if status_filter and s != status_filter:
        continue
    found = True
    title = r.get("title", "?")[:50]
    print(f"{r['id']:30} [{s:12}] {title}")

if not found:
    print("(no routes)" if not status_filter else f"(no routes with status '{status_filter}')")
PYEOF
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

        ensure_json
        python3 - "$ROUTES_JSON" "$ID" "$NEWSTATUS" "$DECISION" <<'PYEOF'
import json, sys
routes_file = sys.argv[1]
rid = sys.argv[2]
new_status = sys.argv[3]
decision = sys.argv[4] if len(sys.argv) > 4 else ""

with open(routes_file) as f:
    d = json.load(f)

for r in d["routes"]:
    if r["id"] == rid:
        r["status"] = new_status
        if decision:
            r["decision"] = decision
        with open(routes_file, 'w') as f:
            json.dump(d, f, indent=2)
        print(f"✓ Route {rid} → {new_status}")
        sys.exit(0)

print(f"! Route {rid} not found")
PYEOF
        rebuild_md
        ;;
    rm)
        ID="$2"
        ensure_json
        python3 - "$ROUTES_JSON" "$ID" <<'PYEOF'
import json, sys
routes_file = sys.argv[1]
rid = sys.argv[2]

with open(routes_file) as f:
    d = json.load(f)

before = len(d["routes"])
d["routes"] = [r for r in d["routes"] if r["id"] != rid]

if len(d["routes"]) < before:
    with open(routes_file, 'w') as f:
        json.dump(d, f, indent=2)
    print(f"✓ Removed route {rid}")
else:
    print(f"! Route {rid} not found")
PYEOF
        rebuild_md
        ;;
    *)
        echo "Usage: route.sh add|list|status|rm"
        exit 1
        ;;
esac
