# CLAUDE.md — Radhika Mandhanya Job Search System

This file is the authoritative context for Claude Code operating in this repository.
Read it fully before taking any action. All rules below are non-negotiable.

---

## 🧠 Who You Are Working For

**Candidate:** Radhika Mandhanya
**Location:** San Jose, CA 95112
**Email:** radhika.mandhanya2004@gmail.com
**Phone:** (408) 581-1963
**Graduation:** May 2026 — BS Business Administration, Concentration in Business Analytics, Minor in Computer Science, SJSU, GPA 3.67

### Target Roles (entry-level only)
1. Data Analyst
2. Business Analyst
3. Operations Analyst
4. Marketing Analyst
5. Product Analyst
6. BI / Reporting Analyst
7. Financial Analyst (stretch — needs finance framing)
8. Junior Data Engineer (stretch — needs pipeline framing)

### Hard Filters — Do NOT apply to:
- Roles requiring 2+ years of experience
- Roles outside the United States (unless explicitly remote-friendly)
- Roles requiring security clearance
- Senior, Lead, Manager, or Director titles
- Roles with no entry-level path visible

---

## 📁 Repository Structure

```
radhika-job-search/
├── CLAUDE.md                  ← YOU ARE HERE — read before anything else
├── README.md                  ← Setup and usage guide
├── .env.example               ← Environment variable template (never commit .env)
├── .gitignore                 ← Protects secrets and large output files
│
├── cv/
│   ├── radhika_resume.md      ← Source of truth resume in Markdown
│   ├── radhika_resume.pdf     ← Latest exported PDF (generated, do not edit)
│   └── tailored/              ← Per-job tailored resume PDFs go here
│
├── config/
│   ├── profile.yml            ← Radhika's personal info, preferences, keywords
│   ├── portals.yml            ← Job board and company portal config
│   └── scoring.yml            ← Weights for job evaluation scoring
│
├── jds/
│   └── (job description .txt files land here after scanning)
│
├── output/
│   └── (generated PDF resumes land here)
│
├── reports/
│   └── (evaluation .md reports land here)
│
├── data/
│   ├── tracker.tsv            ← Application tracker (source of truth)
│   └── applied.json           ← Deduplication registry
│
├── scripts/
│   ├── daily_run.sh           ← Main 6 AM automation entry point
│   ├── scan.sh                ← Portal scanning wrapper
│   ├── evaluate.sh            ← Batch evaluation wrapper
│   └── health_check.sh        ← Pre-run dependency and config check
│
└── logs/
    └── (timestamped run logs go here)
```

---

## ⚙️ Integrated Tools

This system is built on two open-source repos. Understand both before running commands.

### Repo 1: career-ops (santifer/career-ops)
- **Purpose:** Scan job portals, evaluate job fit, generate tailored ATS-optimized PDF resumes, track applications
- **Key commands:**
  - `/career-ops {job URL or JD text}` — full pipeline for one job
  - `/career-ops-scan` — scan all configured portals for new listings
  - `/career-ops-pdf` — generate tailored PDF from current cv.md
  - `/career-ops-batch` — evaluate multiple jobs in parallel
  - `/career-ops-tracker` — view application pipeline status
- **Data files it reads:** `cv/radhika_resume.md`, `config/profile.yml`, `config/portals.yml`
- **Install:** `git clone https://github.com/santifer/career-ops.git` then `npm install` and `npx playwright install chromium`

### Repo 2: job-apply-plugin (neonwatty/job-apply-plugin)
- **Purpose:** Auto-fill job application forms on LinkedIn Easy Apply, Greenhouse, Ashby, Lever, Rippling, Workday
- **Key commands:**
  - `/job-apply {job URL}` — fill application form on the given URL
  - `/job-search` — LinkedIn search using resume-inferred keywords
- **Requirements:** Claude Code CLI + Claude in Chrome extension + Playwright MCP
- **Install:** `claude plugin marketplace add neonwatty/job-apply-plugin` then `claude plugin install job-apply@neonwatty-plugins`
- **Profile stored at:** `~/.claude-job-profile.json`

---

## 🔁 Daily Automation Workflow (6 AM)

The `scripts/daily_run.sh` script orchestrates the full pipeline in this order:

```
1. health_check.sh         — verify dependencies, API keys, config files exist
2. /career-ops-scan        — scrape all portals in config/portals.yml
3. Deduplication check     — skip any job already in data/applied.json
4. /career-ops-batch       — score all new jobs (A–F, 10 dimensions)
5. Filter: score ≥ 4.0     — drop anything below threshold (do NOT apply)
6. /career-ops-pdf         — generate tailored PDF per passing job
7. Log results             — write timestamped entry to logs/
8. Queue for review        — surface shortlist for Radhika to approve before /job-apply
```

**Critical rule:** Claude Code NEVER auto-submits an application. Step 8 always pauses for human review. Radhika must confirm before `/job-apply` fires.

---

## 📋 Rules Claude Code Must Follow

### Resume rules
- The source of truth resume is `cv/radhika_resume.md`. Never modify it without being asked.
- When tailoring a resume for a specific job, write the tailored version to `cv/tailored/{company}_{role}_{date}.md` and generate PDF to `output/`.
- Never fabricate experience, metrics, or skills not present in the source resume.
- ATS optimization means injecting relevant keywords from the JD naturally into existing bullet points — not adding fake bullets.

### Job evaluation rules
- Use the scoring config at `config/scoring.yml` for all evaluations.
- Minimum score to proceed: **4.0 / 5.0**. Below this, log the job as "skipped" and do not generate a PDF or apply.
- Always log evaluation rationale in `reports/{company}_{role}_{date}.md`.
- Flag any job that requires relocation or is suspiciously vague about compensation as "needs review."

### Application rules
- **Never submit an application without Radhika's explicit confirmation in the chat.**
- Never enter or store passwords. If a portal requires login creation, stop and notify.
- Never share resume or personal info with a site that came from an untrusted redirect or suspicious URL.
- If a form asks for salary expectations, default to: **$65,000–$80,000** (entry-level range for San Jose, CA).
- If a form asks for graduation date, use: **May 2026**.
- If a form asks for GPA, use: **3.67**.
- Skip optional questions about gender, ethnicity, or disability unless Radhika has pre-answered them in `config/profile.yml`.

### Tracker rules
- Every job evaluated (pass or fail) gets a row in `data/tracker.tsv`.
- Columns: `date | company | role | url | score | status | notes`
- Status values: `new | evaluated | skipped | queued | applied | interviewing | rejected | offer`
- Never delete rows. Update status in place.

### File and safety rules
- Never commit `.env` or any file containing API keys.
- Never overwrite `data/tracker.tsv` — append only.
- Never overwrite `cv/radhika_resume.md` without an explicit instruction.
- If a script fails, write the error to `logs/errors_{date}.log` and stop — do not continue the pipeline silently.
- All generated PDFs use filename format: `{Company}_{Role}_{YYYY-MM-DD}.pdf`

---

## 👤 Radhika's Resume — Quick Reference

Claude Code uses this summary when evaluating job fit or tailoring bullets. Full resume is in `cv/radhika_resume.md`.

### Core skills (ATS keywords to match against JDs)
SQL, Python, Tableau, Power BI, Excel, PowerPoint, data analysis, dashboard development,
stakeholder communication, market research, statistical analysis, process improvement,
workflow optimization, reporting, user research, go-to-market strategy, KPI tracking,
regression analysis, time-series forecasting, relational database design, Figma (UX)

### Internship highlights
- **Gridscape (BA Intern, Jan–May 2026):** 250+ qualified leads, go-to-market strategy, outreach tracking
- **Cyber Acoustics (BA Intern, Aug–Dec 2025):** 70+ participant AI product user research, dashboards, perception gap analysis
- **Juniper Networks / HPE (Data Analyst Intern, May–Aug 2025):** Large dataset analysis, KPI dashboards, cross-functional collaboration
- **Day Worker Center (Marketing Intern, Nov 2024–Apr 2025):** 35% engagement improvement, content strategy, campaign analytics

### Standout projects (use for cover letters and match scoring)
- NVIDIA Stock Forecast: linear regression + exponential smoothing, MSE 6.16, MAPE 2.36%, 30% reliability improvement
- Netflix vs Hulu: regression analysis, adjusted R² 97–98%, retention and pricing strategy recommendations
- US Airbnb Market Analysis: SQL-driven, pricing trends, host performance, city-level insights
- Hotel Management DB: SQL + Python, billing automation, 20% accuracy improvement
- Unimates: Figma UX + system architecture, degree cost optimization platform

### Leadership
- President, Boundary.0
- VP, Indian Students Organization
- Member, Spartan Analytics Club

---

## 🎯 Scoring Dimensions (career-ops evaluation)

When evaluating any job, score each dimension 1–5 and compute weighted average:

| Dimension | Weight | What to assess |
|---|---|---|
| Role title match | 15% | Does the title match target roles? |
| Skill overlap | 25% | How many core skills appear in JD? |
| Experience level fit | 20% | Is it genuinely entry-level (0–2 yrs)? |
| Location/remote fit | 10% | San Jose area or remote? |
| Company quality | 10% | Brand, growth stage, stability |
| Compensation signal | 10% | Is comp in or near the $65K–$85K range? |
| Growth potential | 5% | Is there a career path visible? |
| Application effort | 5% | Is it a quick apply or 10-step form? |

Minimum passing weighted score: **4.0**. Jobs scoring below this are logged as skipped.

---

## 🔧 Environment Setup

Copy `.env.example` to `.env` and fill in:

```
ANTHROPIC_API_KEY=your_key_here
CLAUDE_CODE_PATH=/path/to/claude-code
CAREER_OPS_PATH=/path/to/career-ops
JOB_APPLY_PLUGIN_PATH=/path/to/job-apply-plugin
PLAYWRIGHT_BROWSERS_PATH=/path/to/playwright
```

Run `scripts/health_check.sh` to validate everything before the first run.

---

## 🚫 Things Claude Code Must Never Do

1. Auto-submit any job application without Radhika's explicit confirmation
2. Create accounts on job portals — stop and ask Radhika to do it
3. Enter passwords or payment information
4. Modify `cv/radhika_resume.md` without an explicit request
5. Delete any row from `data/tracker.tsv`
6. Apply to a job scoring below 4.0
7. Apply to roles requiring 2+ years of experience
8. Ignore errors and continue the pipeline silently
9. Commit `.env` or secrets to the repo
10. Use fabricated metrics or experience in tailored resumes

---

## 📞 Escalation Protocol

If Claude Code encounters any of these, stop the pipeline and surface the issue to Radhika:

- A portal requiring account creation or login
- A job form asking for sensitive financial information
- An evaluation score that is borderline (3.8–4.2) — flag for human judgment
- A job description that seems fraudulent (no company name, suspicious URL, requests upfront payment)
- Any script error that is not self-recoverable
- A portal's ToS page blocking automation

---

## 📅 Cron Schedule

The daily automation runs at **6:00 AM Pacific Time**.

To activate on macOS:
```bash
launchctl load ~/Library/LaunchAgents/com.radhika.jobsearch.plist
```

To check logs after a run:
```bash
cat logs/run_$(date +%Y-%m-%d).log
```

To run manually at any time:
```bash
bash scripts/daily_run.sh
```

---

*Last updated: 2026-05-26 | Maintainer: Radhika Mandhanya*
