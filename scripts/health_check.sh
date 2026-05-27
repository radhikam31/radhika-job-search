#!/bin/bash
# health_check.sh — validates all dependencies before daily pipeline runs

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PASS=true

# Load env if not already set
if [ -f "$REPO_DIR/.env" ]; then
  set -a && source "$REPO_DIR/.env" && set +a
fi

check() {
  local label="$1"
  local condition="$2"
  if eval "$condition" &>/dev/null; then
    echo "  ✓ $label"
  else
    echo "  ✗ $label — FAILED"
    PASS=false
  fi
}

echo "Running health check..."

# Environment
check ".env file exists"           "[ -f '$REPO_DIR/.env' ]"
check "ANTHROPIC_API_KEY set"      "[ -n '${ANTHROPIC_API_KEY:-}' ]"
check "CAREER_OPS_PATH set"        "[ -n '${CAREER_OPS_PATH:-}' ]"

# Files
check "cv/radhika_resume.md exists" "[ -f '$REPO_DIR/cv/radhika_resume.md' ]"
check "config/profile.yml exists"   "[ -f '$REPO_DIR/config/profile.yml' ]"
check "config/portals.yml exists"   "[ -f '$REPO_DIR/config/portals.yml' ]"
check "config/scoring.yml exists"   "[ -f '$REPO_DIR/config/scoring.yml' ]"
check "data/tracker.tsv exists"     "[ -f '$REPO_DIR/data/tracker.tsv' ]"

# Directories
check "output/ directory exists"    "[ -d '$REPO_DIR/output' ]"
check "reports/ directory exists"   "[ -d '$REPO_DIR/reports' ]"
check "logs/ directory exists"      "[ -d '$REPO_DIR/logs' ]"
check "jds/ directory exists"       "[ -d '$REPO_DIR/jds' ]"

# Tools
check "Node.js installed"          "command -v node"
check "npm installed"              "command -v npm"
check "claude CLI installed"       "command -v claude"
check "career-ops directory"       "[ -d '${CAREER_OPS_PATH:-/nonexistent}' ]"

if [ "$PASS" = true ]; then
  echo "All checks passed."
  exit 0
else
  echo "One or more checks failed. Fix issues before running daily_run.sh."
  exit 1
fi
