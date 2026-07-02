#!/usr/bin/env bash
# log.sh — Append and view research log entries
# Usage:
#   log.sh add <type> <message>       — append an entry
#   log.sh recent [N]                 — show last N entries (default 10)
#   log.sh grep <pattern>             — search log

set -euo pipefail

LOG=".research/log.md"
TODAY=$(date +%Y-%m-%d)
NOW=$(date +%H:%M)

case "${1:-help}" in
    add)
        TYPE="$2"
        shift 2
        MESSAGE="$*"
        if [ -z "$MESSAGE" ]; then
            echo "! usage: log.sh add <type> <message>"
            exit 1
        fi
        ENTRY="- [$TODAY $NOW] **[$TYPE]** $MESSAGE"
        echo "$ENTRY" >> "$LOG"
        echo "✓ logged: $ENTRY"
        ;;
    recent)
        N="${2:-10}"
        if [ ! -f "$LOG" ]; then
            echo "(empty)"
            exit 0
        fi
        grep -v '^\s*$' "$LOG" | tail -n "$N"
        ;;
    grep)
        PATTERN="${2:-}"
        if [ -z "$PATTERN" ]; then
            echo "! usage: log.sh grep <pattern>"
            exit 1
        fi
        if [ ! -f "$LOG" ]; then
            echo "(empty)"
            exit 0
        fi
        grep -i "$PATTERN" "$LOG" || echo "(no matches)"
        ;;
    *)
        echo "Usage: log.sh add|recent|grep"
        exit 1
        ;;
esac
