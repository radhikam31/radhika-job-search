# Radhika Job Search System

AI-powered job search pipeline built on [career-ops](https://github.com/santifer/career-ops) and [job-apply-plugin](https://github.com/neonwatty/job-apply-plugin), orchestrated by Claude Code.

Runs daily at 6 AM — scans 45+ portals, scores jobs, generates tailored resumes, and queues top matches for one-click application review.

## Quick Start

```bash
# 1. Clone and enter repo
git clone <your-repo-url>
cd radhika-job-search

# 2. Set up environment
cp .env.example .env
# Fill in your ANTHROPIC_API_KEY and paths

# 3. Install career-ops
git clone https://github.com/santifer/career-ops.git
cd career-ops && npm install && npx playwright install chromium && cd ..

# 4. Install job-apply-plugin (requires Claude Code CLI)
claude plugin marketplace add neonwatty/job-apply-plugin
claude plugin install job-apply@neonwatty-plugins

# 5. Add your resume
# Edit cv/radhika_resume.md with your full resume in Markdown

# 6. Configure portals and profile
# Edit config/profile.yml and config/portals.yml

# 7. Run health check
bash scripts/health_check.sh

# 8. Run manually or activate cron
bash scripts/daily_run.sh
# OR
launchctl load ~/Library/LaunchAgents/com.radhika.jobsearch.plist
```

## How It Works

1. `daily_run.sh` triggers at 6 AM
2. career-ops scans all portals in `config/portals.yml`
3. New jobs are scored against your resume (minimum 4.0/5.0 to proceed)
4. Passing jobs get a tailored ATS-optimized PDF resume generated
5. You wake up to a shortlist — review and confirm before anything is submitted
6. `/job-apply` fills the form; you click submit

**Nothing is ever submitted automatically. You always have the final say.**

## Directory Guide

| Path | Purpose |
|---|---|
| `cv/radhika_resume.md` | Source of truth resume — edit this |
| `cv/tailored/` | Per-job tailored resume versions |
| `config/profile.yml` | Your info, salary expectations, preferences |
| `config/portals.yml` | Which companies/boards to scan |
| `config/scoring.yml` | Job scoring weights |
| `data/tracker.tsv` | Full application history |
| `reports/` | Evaluation reports per job |
| `output/` | Generated PDF resumes |
| `logs/` | Daily run logs |

## Maintenance

- Update `cv/radhika_resume.md` whenever you want to reflect new experience
- Add companies to `config/portals.yml` to expand your scan coverage
- Check `data/tracker.tsv` weekly to update application statuses
- Review `logs/` if a run produces unexpected results

## Rules

See `CLAUDE.md` for the full set of rules governing how Claude Code operates in this repo.
