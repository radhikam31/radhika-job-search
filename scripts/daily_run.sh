#!/bin/bash
# daily_run.sh — Radhika Job Search Daily Pipeline
# Runs at 6 AM via launchd/cron. Orchestrates scan → evaluate → PDF → queue.

set -euo pipefail

# ─── Config ────────────────────────────────────────────────────────────────────
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR="$REPO_DIR/logs"
DATE=$(date +%Y-%m-%d)
TIME=$(date +%H-%M-%S)
LOG_FILE="$LOG_DIR/run_${DATE}.log"
ERROR_LOG="$LOG_DIR/errors_${DATE}.log"

# Load environment
if [ -f "$REPO_DIR/.env" ]; then
  set -a && source "$REPO_DIR/.env" && set +a
else
  echo "ERROR: .env file not found. Run: cp .env.example .env and fill in values." | tee "$ERROR_LOG"
  exit 1
fi

# ─── Logging helper ────────────────────────────────────────────────────────────
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

error() {
  echo "[ERROR $(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE" | tee -a "$ERROR_LOG"
}

# ─── Start ─────────────────────────────────────────────────────────────────────
mkdir -p "$LOG_DIR"
log "=========================================="
log "Daily job search pipeline starting"
log "Date: $DATE | Time: $TIME"
log "=========================================="

# ─── Step 1: Health check ──────────────────────────────────────────────────────
log "Step 1/5: Running health check..."
if ! bash "$REPO_DIR/scripts/health_check.sh" >> "$LOG_FILE" 2>&1; then
  error "Health check failed. Aborting pipeline. Check $ERROR_LOG for details."
  exit 1
fi
log "Health check passed."

# ─── Step 2: Scan portals ──────────────────────────────────────────────────────
log "Step 2/5: Scanning job portals..."
cd "$CAREER_OPS_PATH" || { error "career-ops path not found: $CAREER_OPS_PATH"; exit 1; }

if ! claude -p "/career-ops-scan" >> "$LOG_FILE" 2>&1; then
  error "Portal scan failed. Check career-ops configuration."
  exit 1
fi
log "Portal scan complete."

# ─── Step 3: Deduplication ─────────────────────────────────────────────────────
log "Step 3/5: Deduplicating against applied.json..."
cd "$REPO_DIR"
# career-ops handles dedup internally via its tracker; this is a secondary check
NEW_JDS=$(find "$REPO_DIR/jds" -name "*.txt" -newer "$REPO_DIR/data/applied.json" 2>/dev/null | wc -l)
log "Found $NEW_JDS new job descriptions to evaluate."

if [ "$NEW_JDS" -eq 0 ]; then
  log "No new jobs found. Pipeline complete for today."
  exit 0
fi

# ─── Step 4: Evaluate + generate PDFs ─────────────────────────────────────────
log "Step 4/5: Running batch evaluation and PDF generation..."
cd "$CAREER_OPS_PATH"

if ! claude -p "/career-ops-batch" >> "$LOG_FILE" 2>&1; then
  error "Batch evaluation failed. Check individual job reports in $REPO_DIR/reports/"
  # Non-fatal — continue to surfacing results
fi
log "Evaluation complete. PDFs generated for jobs scoring >= 4.0."

# ─── Step 5: Surface shortlist ─────────────────────────────────────────────────
log "Step 5/5: Preparing shortlist for review..."

SHORTLIST=$(grep -E "^[0-9]{4}-[0-9]{2}-[0-9]{2}.*queued" "$REPO_DIR/data/tracker.tsv" 2>/dev/null | tail -20)

if [ -z "$SHORTLIST" ]; then
  log "No jobs queued for application today."
else
  log "Jobs queued for your review:"
  echo "$SHORTLIST" | tee -a "$LOG_FILE"
  log ""
  log "ACTION REQUIRED: Review the jobs above and run:"
  log "  claude '/job-apply {job URL}' for each one you want to apply to."
  log "  Nothing has been submitted. You must confirm each application."
fi

log "=========================================="
log "Pipeline complete. Duration: $((SECONDS))s"
log "Review $LOG_FILE for full details."
log "=========================================="
