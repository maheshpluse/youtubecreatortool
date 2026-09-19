"""
Keyword-gap finder for VidSEOKit's own blog/landing pages.

Reuses the SEO Analyzer's DataForSEO keyword-research service
(services/keyword_api.fetch_keyword_ideas) to expand a set of niche seed
terms into real search-volume/competition data, then filters out anything
VidSEOKit's ~50 existing blog posts and landing pages already target.

This is a one-off/manual tool, not a scheduled job. Run it, review the
report, decide which keywords are worth a new blog post.

Usage:
    cd backend && python3 scripts/keyword_gap.py
Output:
    scripts/keyword_gap_report.json  (full ranked list)
    stdout                            (top 25, human-readable)
"""
import json
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from services.keyword_api import fetch_keyword_ideas

REPO_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
POSTS_JSON = os.path.join(REPO_ROOT, "frontend", "blog_src", "posts.json")
SEO_PAGES_DART = os.path.join(REPO_ROOT, "frontend", "lib", "data", "seo_pages.dart")
REPORT_PATH = os.path.join(os.path.dirname(__file__), "keyword_gap_report.json")

# Broad terms covering the site's niche (YouTube growth/SEO/monetization/
# tools for creators). Each one gets expanded into ~100 related long-tail
# ideas by DataForSEO — this list is deliberately short to keep the number
# of paid API calls modest; widen it once the pipeline proves useful.
SEED_KEYWORDS = [
    "youtube seo",
    "youtube monetization",
    "youtube algorithm",
    "youtube shorts",
    "youtube analytics",
    "youtube channel growth",
    "youtube thumbnail",
    "youtube tags",
    "youtube video ideas",
    "faceless youtube channel",
    "youtube live streaming",
    "content creator tools",
]

MIN_VOLUME = 200
MAX_COMPETITION_INDEX = 60  # skip highly-contested head terms


def load_covered_corpus() -> str:
    """Lowercased text of everything already published, for substring dedup."""
    chunks = []

    with open(POSTS_JSON) as f:
        posts = json.load(f)
    for post in posts:
        chunks.append(post.get("title", ""))
        chunks.append(post.get("seo_title", ""))
        chunks.append(post.get("description", ""))
        chunks.extend(post.get("keywords", []))

    if os.path.exists(SEO_PAGES_DART):
        with open(SEO_PAGES_DART) as f:
            chunks.append(f.read())

    return " \n ".join(chunks).lower()


def is_covered(keyword: str, corpus: str) -> bool:
    kw = keyword.lower().strip()
    if not kw:
        return True
    if kw in corpus:
        return True
    # Also reject if every significant word (len > 3) already co-occurs
    # somewhere in the corpus as a title/keyword fragment — catches near-
    # duplicates like "youtube algorithm changes" vs "youtube algorithm update".
    words = [w for w in re.findall(r"[a-z0-9]+", kw) if len(w) > 3]
    if words and all(w in corpus for w in words):
        return True
    return False


def opportunity_score(volume: int, competition_index: int) -> float:
    return round(volume / (competition_index + 5), 1)


def main():
    corpus = load_covered_corpus()
    print(f"Loaded coverage corpus from {len(SEED_KEYWORDS)} seeds' worth of context "
          f"({len(corpus)} chars from posts.json + seo_pages.dart).")

    seen_keywords = set()
    candidates = []

    for seed in SEED_KEYWORDS:
        print(f"Fetching ideas for seed: {seed!r} ...")
        ideas = fetch_keyword_ideas(seed, limit=100)
        print(f"  -> {len(ideas)} ideas returned")
        for idea in ideas:
            kw = idea["keyword"]
            key = kw.lower().strip()
            if not key or key in seen_keywords:
                continue
            seen_keywords.add(key)

            if idea["search_volume"] < MIN_VOLUME:
                continue
            if idea["competition_index"] > MAX_COMPETITION_INDEX:
                continue
            if is_covered(kw, corpus):
                continue

            idea["opportunity_score"] = opportunity_score(
                idea["search_volume"], idea["competition_index"]
            )
            candidates.append(idea)

    candidates.sort(key=lambda x: x["opportunity_score"], reverse=True)

    with open(REPORT_PATH, "w") as f:
        json.dump(candidates, f, indent=2)

    print(f"\n{len(candidates)} content-gap candidates (volume >= {MIN_VOLUME}, "
          f"competition_index <= {MAX_COMPETITION_INDEX}, not already covered).")
    print(f"Full report: {REPORT_PATH}\n")

    print(f"{'Keyword':<45} {'Volume':>8} {'Comp':>6} {'CPC':>6} {'Score':>8}  Seed")
    print("-" * 100)
    for c in candidates[:25]:
        print(f"{c['keyword']:<45} {c['search_volume']:>8} {c['competition_index']:>6} "
              f"${c['cpc']:>4.2f} {c['opportunity_score']:>8}  {c['seed']}")


if __name__ == "__main__":
    main()
