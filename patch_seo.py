import re

with open('frontend/lib/data/seo_pages.dart', 'r') as f:
    content = f.read()

# Add 'home' route right before 'seo'
home_route = """
  'home': PageSeo(
    title: 'VidSEOKit \u2014 Free Video SEO Tools for YouTube Creators',
    h1: 'Free Video SEO & Growth Tools — VidSEOKit',
    description: 'Free video SEO tools for YouTube creators. Score your title, description and tags, generate titles and thumbnail ideas, extract competitor tags and estimate AdSense earnings. No sign-up.',
    canonical: 'https://vidseokit.com/',
    definition: 'VidSEOKit is a free suite of YouTube SEO and analytics tools - SEO scoring, title generation, thumbnail concepts, tag extraction and earnings estimation - that requires no account to use.',
    sections: [
      ContentSection('Free YouTube Tools for Creators', [
        'Welcome to VidSEOKit. We build free tools to help you optimize your metadata, research competitors, and calculate earnings. Get started with our YouTube SEO Analyzer or explore our other tools below.'
      ])
    ],
  ),
"""

content = content.replace("  'seo': PageSeo(", home_route + "\  'seo': PageSeo(")

# Update SEO route canonical to /youtube-seo-analyzer
content = re.sub(
    r"('seo': PageSeo\([\s\S]*?canonical:\s*)'\$kSiteUrl/'",
    r"\1'$kSiteUrl/youtube-seo-analyzer'",
    content
)

# Update SEO route definition and sections
seo_bait_pattern = re.compile(r"ContentSection\('What metadata can and cannot do', \[.*?\]\),", re.DOTALL)
new_seo_section = """ContentSection('YouTube SEO Score: A Worked Example', [
        'A good score requires balancing keywords and readability. For example, a title like "My Vlog #12" will score poorly. Changing it to "Vlog 12: Exploring the Best Coffee Shops in London" adds targeted keywords. A description that simply says "Subscribe!" misses an opportunity. A good description will weave the keyword "Best Coffee Shops in London" naturally into the first 150 characters, alongside a clear call to action and helpful timestamps.',
        'By testing different combinations of title, description, and tags in the analyzer above, you can often push a video from a 45/100 to an 85/100 in minutes, giving it a much stronger foundation for search and discovery.'
      ]),"""

content = re.sub(seo_bait_pattern, new_seo_section, content)

with open('frontend/lib/data/seo_pages.dart', 'w') as f:
    f.write(content)

