import re

with open('frontend/lib/data/seo_pages.dart', 'r') as f:
    content = f.read()

# 1. Update 'home' page
content = content.replace(
    "title: 'VidSEOKit — Free Video SEO Tools for YouTube Creators',",
    "title: 'VidSEOKit — Free YouTube SEO Toolkit & Creator Tools',"
)
content = content.replace(
    "description: 'Free video SEO tools for YouTube creators.",
    "description: 'Free YouTube SEO toolkit for creators."
)

# 2. Update 'seo' page
content = content.replace(
    "title: 'VidSEOKit \u2014 Free Video SEO Tools for YouTube Creators',\n    h1: 'Free YouTube SEO Analyzer',",
    "title: 'Free YouTube SEO Toolkit — VidSEOKit',\n    h1: 'Free YouTube SEO Toolkit',"
)

# 3. Update 'titles' page
content = content.replace(
    "title: 'YouTube Title Generator - Free AI Titles That Get Clicks',\n    h1: 'YouTube Title Generator',",
    "title: 'AI YouTube Title and Tag Generator — VidSEOKit',\n    h1: 'AI YouTube Title & Tag Generator',"
)

titles_section_old = "ContentSection('Choosing between the options', ["
titles_section_new = """ContentSection('Choosing between the options', [
        'Pick for search intent first. If people find the video by typing a question, the title should contain something close to that question. If they find it in suggested video or on the home feed, the title is competing on curiosity against everything else on screen, and specificity beats cleverness.',
        'Read each candidate at mobile width, where titles are cut after roughly 40 characters. If the first half stops making sense on its own, rewrite it so the meaning survives truncation. Avoid all-caps and manufactured shock - they raise click-through rate briefly and damage the channel over time, because viewers who feel misled leave early and that is the signal YouTube actually measures.',
      ]),
      ContentSection('Automated Video Description Writer for Creators', [
        'While the title grabs attention, the description provides the context that search algorithms need. A good title generator works best when paired with an automated video description writer that seamlessly weaves in the same target keywords.',
        'Always ensure the first 150 characters of your description complement the generated title. This snippet appears in search results and acts as a secondary hook for viewers deciding whether to click.'
      ]),
"""
content = content.replace(titles_section_old + "\n        'Pick for search intent first.", titles_section_new.strip() + "XXYYZZ")
content = re.sub(r"XXYYZZ.*?'Read each candidate at mobile width,.*?\]\),", "", content, flags=re.DOTALL) # A bit hacky, let's fix below

# A safer way to replace titles sections:
titles_sections_pattern = re.compile(r"ContentSection\('Choosing between the options', \[.*?\]\),", re.DOTALL)
new_titles_section = """ContentSection('Choosing between the options', [
        'Pick for search intent first. If people find the video by typing a question, the title should contain something close to that question. If they find it in suggested video or on the home feed, the title is competing on curiosity against everything else on screen, and specificity beats cleverness.',
        'Read each candidate at mobile width, where titles are cut after roughly 40 characters. If the first half stops making sense on its own, rewrite it so the meaning survives truncation.'
      ]),
      ContentSection('Automated Video Description Writer for Creators', [
        'While the title grabs attention, the description provides the context that search algorithms need. A good title generator works best when paired with an automated video description writer that seamlessly weaves in the same target keywords.',
        'Always ensure the first 150 characters of your description complement the generated title. This snippet appears in search results and acts as a secondary hook for viewers deciding whether to click.'
      ]),"""
content = re.sub(titles_sections_pattern, new_titles_section, content)

# 4. Update 'tags' page
content = content.replace(
    "title: 'YouTube Tag Extractor - See Any Video Tags Free',\n    h1: 'YouTube Tag Extractor',",
    "title: 'Automated Video Hashtag Categorizer Tool — VidSEOKit',\n    h1: 'Automated Video Hashtag Categorizer Tool',"
)


# 5. Add 'vidiq-alternative-free' page
vidiq_page = """
  'vidiq-alternative-free': PageSeo(
    title: 'VidIQ Alternative Free: VidSEOKit vs VidIQ (2026)',
    h1: 'The Best Free VidIQ Alternative',
    description: 'Looking for a free VidIQ alternative? VidSEOKit offers YouTube SEO scoring, AI titles, and tag extraction with zero paywalls and no sign-ups required.',
    canonical: '$kSiteUrl/vidiq-alternative-free',
    definition: 'VidSEOKit is a 100% free alternative to VidIQ, providing essential YouTube SEO tools without subscriptions, paywalled features, or mandatory account creation.',
    breadcrumbName: 'VidIQ Alternative',
    sections: [
      ContentSection('Why Choose a Free VidIQ Alternative?', [
        'VidIQ is a powerful tool, but its best features are locked behind expensive monthly subscriptions. For small to medium creators, paying for keyword research and AI title generation eats into production budgets.',
        'VidSEOKit was built as a VidIQ alternative free of paywalls. You get unrestricted access to our YouTube SEO Analyzer, AI Title Generator, and Tag Extractor immediately, without even needing to create an account.'
      ]),
      ContentSection('Feature Comparison', [
        'Both platforms offer SEO scoring. However, VidSEOKit transparently shows you exactly how the score is calculated (based on keyword placement and length) rather than relying on a proprietary black-box metric.',
        'Our suite includes an automated video hashtag categorizer tool and AI thumbnail concepts, designed specifically to help you optimize metadata before you hit publish, entirely for free.'
      ]),
    ],
    faqs: [
      FaqItem('Is VidSEOKit completely free compared to VidIQ?', 'Yes. While VidIQ limits features on its free tier, VidSEOKit offers its entire suite of tools 100% free with no hidden costs.'),
      FaqItem('Do I need to install a browser extension?', 'No. VidSEOKit operates entirely in your browser, meaning you don\'t need to install any extensions that might slow down your computer or require intrusive permissions.')
    ]
  ),
"""

# Insert vidiq-alternative-free right before 'about'
content = content.replace("  'about': PageSeo(", vidiq_page + "  'about': PageSeo(")

with open('frontend/lib/data/seo_pages.dart', 'w') as f:
    f.write(content)

