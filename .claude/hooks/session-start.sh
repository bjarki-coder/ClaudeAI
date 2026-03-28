#!/usr/bin/env bash
set -euo pipefail

INPUT=$(cat)
CWD=$(printf '%s' "$INPUT" | jq -r '.cwd // empty' 2>/dev/null || true)
SOURCE=$(printf '%s' "$INPUT" | jq -r '.source // empty' 2>/dev/null || true)
PROJECT_DIR="${CWD:-${CLAUDE_PROJECT_DIR:-$(pwd)}}"
MEMORY_DIR="$PROJECT_DIR/docs/claude-memory"

# ── Customize this section for your project ──
MODE_PROMPT='Welcome. What are we working on today?'

CURRENT_STATE=""
if [ -f "$MEMORY_DIR/CURRENT_STATE.md" ]; then
  CURRENT_STATE=$(head -60 "$MEMORY_DIR/CURRENT_STATE.md")
fi

OPEN_QUESTIONS=""
if [ -f "$MEMORY_DIR/OPEN_QUESTIONS.md" ]; then
  OPEN_QUESTIONS=$(head -30 "$MEMORY_DIR/OPEN_QUESTIONS.md")
fi

CONTEXT="$MODE_PROMPT"

if [ -n "$CURRENT_STATE" ]; then
  CONTEXT="$CONTEXT

Current project state:
$CURRENT_STATE"
fi

if [ -n "$OPEN_QUESTIONS" ]; then
  CONTEXT="$CONTEXT

Open questions:
$OPEN_QUESTIONS"
fi

# Output as JSON for Claude to inject
jq -n --arg ctx "$CONTEXT" \
  '{hookSpecificOutput:{hookEventName:"SessionStart",additionalContext:$ctx}}'
