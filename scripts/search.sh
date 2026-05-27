#!/usr/bin/env python3
"""
search.sh — Pre-filter job candidates before fetching full JDs.

Usage:
  python3 scripts/search.sh --title "Data Analyst" --company "Google"
  python3 scripts/search.sh --batch results.json

Pre-filter logic (zero API cost):
  1. Title check  — reject if title contains hard-reject keywords
  2. Sponsor check — pass/uncertain/skip based on config/portals.yml whitelist
  3. Output: PASS / UNCERTAIN (fetch JD) | SKIP (do not fetch)

PASS or UNCERTAIN => caller should fetch the full JD and score it.
SKIP              => log as skipped, do not spend an API call.
"""

import sys
import json
import yaml
import argparse
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
PORTALS = REPO / "config" / "portals.yml"
TRACKER = REPO / "data" / "tracker.tsv"
APPLIED = REPO / "data" / "applied.json"


def load_config():
    with open(PORTALS) as f:
        return yaml.safe_load(f)


def load_applied_urls():
    try:
        with open(APPLIED) as f:
            data = json.load(f)
            return set(data) if isinstance(data, list) else set(data.keys())
    except (FileNotFoundError, json.JSONDecodeError):
        return set()


def check_title(title: str, config: dict) -> tuple[str, str]:
    """Returns (result, reason). result: PASS | SKIP"""
    title_lower = title.lower()
    for kw in config.get("reject_title_keywords", []):
        if kw.lower() in title_lower:
            return "SKIP", f"Title contains rejected keyword: '{kw}'"
    return "PASS", "Title OK"


def check_sponsor(company: str, config: dict) -> tuple[str, str]:
    """Returns (result, reason). result: PASS | UNCERTAIN"""
    whitelist = config.get("sponsor_whitelist", {})
    company_lower = company.lower().strip()

    for tier, companies in whitelist.items():
        for known in companies:
            if known.lower() in company_lower or company_lower in known.lower():
                return "PASS", f"Confirmed H-1B sponsor ({tier}): {known}"

    return "UNCERTAIN", "Company not in sponsor whitelist — fetch JD to check sponsorship"


def check_duplicate(url: str, applied_urls: set) -> tuple[str, str]:
    """Returns (result, reason). result: SKIP | PASS"""
    if url and url in applied_urls:
        return "SKIP", "Already in applied.json (duplicate)"
    return "PASS", "Not a duplicate"


def pre_filter(title: str, company: str, url: str = "", config: dict = None, applied: set = None):
    """Run all pre-filters. Returns dict with result and reasons."""
    if config is None:
        config = load_config()
    if applied is None:
        applied = load_applied_urls()

    checks = {}

    # Duplicate check (cheapest — do first)
    checks["duplicate"] = check_duplicate(url, applied)
    if checks["duplicate"][0] == "SKIP":
        return {"result": "SKIP", "reason": checks["duplicate"][1], "checks": checks}

    # Title check
    checks["title"] = check_title(title, config)
    if checks["title"][0] == "SKIP":
        return {"result": "SKIP", "reason": checks["title"][1], "checks": checks}

    # Sponsor check
    checks["sponsor"] = check_sponsor(company, config)
    sponsor_result = checks["sponsor"][0]  # PASS or UNCERTAIN

    # Final verdict
    if sponsor_result == "PASS":
        result = "PASS"
        reason = f"Confirmed sponsor. {checks['sponsor'][1]}"
    else:
        result = "UNCERTAIN"
        reason = f"Fetch JD to verify sponsorship. {checks['sponsor'][1]}"

    return {"result": result, "reason": reason, "company": company, "title": title, "url": url, "checks": checks}


def main():
    parser = argparse.ArgumentParser(description="Pre-filter job candidates")
    parser.add_argument("--title", help="Job title")
    parser.add_argument("--company", help="Company name")
    parser.add_argument("--url", default="", help="Job URL (for dedup check)")
    parser.add_argument("--batch", help="JSON file with list of {title, company, url} objects")
    parser.add_argument("--json", action="store_true", help="Output as JSON")
    args = parser.parse_args()

    config = load_config()
    applied = load_applied_urls()

    if args.batch:
        with open(args.batch) as f:
            candidates = json.load(f)
        results = [
            pre_filter(c.get("title", ""), c.get("company", ""), c.get("url", ""), config, applied)
            for c in candidates
        ]
        to_fetch = [r for r in results if r["result"] in ("PASS", "UNCERTAIN")]
        to_skip  = [r for r in results if r["result"] == "SKIP"]

        if args.json:
            print(json.dumps({"fetch": to_fetch, "skip": to_skip}, indent=2))
        else:
            print(f"\n{'='*60}")
            print(f"Pre-filter results: {len(to_fetch)} to fetch, {len(to_skip)} skipped")
            print(f"{'='*60}")
            for r in to_fetch:
                tag = "✓ PASS" if r["result"] == "PASS" else "? UNCERTAIN"
                print(f"  {tag}  |  {r['company']} — {r['title']}")
                print(f"         {r['reason']}")
            if to_skip:
                print(f"\n  Skipped ({len(to_skip)}):")
                for r in to_skip:
                    print(f"    ✗ {r.get('company','?')} — {r.get('title','?')}: {r['reason']}")
        return

    if not args.title or not args.company:
        parser.print_help()
        sys.exit(1)

    result = pre_filter(args.title, args.company, args.url, config, applied)

    if args.json:
        print(json.dumps(result, indent=2))
    else:
        tag = {"PASS": "✓ PASS", "UNCERTAIN": "? UNCERTAIN", "SKIP": "✗ SKIP"}[result["result"]]
        print(f"\n{tag}  |  {args.company} — {args.title}")
        print(f"  {result['reason']}")
        for check, (res, msg) in result.get("checks", {}).items():
            print(f"  [{check}] {res}: {msg}")


if __name__ == "__main__":
    main()
