import urllib.request
import json
import os
import ssl

ssl._create_default_https_context = ssl._create_unverified_context

slugs_and_keywords = {
    "rank-higher-youtube-search": "Search_engine_optimization",
    "improve-youtube-click-through-rate": "Click-through_rate",
    "youtube-monetization-requirements-guide": "Monetization",
    "how-to-increase-youtube-rpm": "Finance",
    "youtube-keyword-research-tools": "Index_term",
    "high-cpc-keywords-youtube-niches": "Advertising",
    "youtube-analytics-metrics-that-matter": "Data_analysis",
    "how-youtube-algorithm-works": "Algorithm",
    "youtube-competitor-analysis-guide": "Competitor_analysis",
    "youtube-engagement-rate-calculation": "Engagement_(marketing)",
    "find-target-audience-youtube": "Target_audience",
    "adsense-revenue-per-1000-views": "Google_AdSense",
    "passive-income-streams-youtube-creators": "Passive_income",
    "youtube-affiliate-marketing-strategies": "Affiliate_marketing",
    "youtube-sponsored-content-brand-deals": "Sponsor",
    "content-creation-tools-youtube-creators": "Content_creation",
    "organic-traffic-growth-strategy": "Organic_search",
    "digital-marketing-funnel-creators": "Purchase_funnel",
    "youtube-channel-online-business": "Electronic_business",
    "youtube-seo-checklist-small-channels": "Checklist"
}

out_dir = "frontend/web/images/blog"
os.makedirs(out_dir, exist_ok=True)
for slug, _ in slugs_and_keywords.items():
    url = f"https://picsum.photos/seed/{slug}/400/300"
    try:
        print(f"Downloading image for {slug}")
        img_data = urllib.request.urlopen(url).read()
        with open(f"{out_dir}/{slug}.jpg", "wb") as f:
            f.write(img_data)
    except Exception as e:
        print(f"Error {slug}: {e}")
