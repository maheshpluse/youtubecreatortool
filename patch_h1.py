import re

with open('frontend/lib/data/seo_pages.dart', 'r') as f:
    content = f.read()

# Add h1 field
content = content.replace('final String title;', 'final String title;\n  final String h1;')
content = content.replace('required this.title,', 'required this.title,\n    this.h1 = \'\',')

# Set H1s for each route
h1s = {
    "'seo'": "'Free YouTube SEO Analyzer'",
    "'home'": "'Free Video SEO & Growth Tools — VidSEOKit'", # We will add home later
    "'titles'": "'YouTube Title Generator'",
    "'thumbnails'": "'YouTube Thumbnail Ideas Generator'",
    "'tags'": "'YouTube Tag Extractor'",
    "'earnings'": "'YouTube Earnings Calculator'",
    "'blog'": "'YouTube Growth Blog'",
    "'youtube-rpm-by-country'": "'YouTube RPM by Country'",
    "'about'": "'About VidSEOKit'",
    "'contact'": "'Contact VidSEOKit'",
    "'privacy'": "'Privacy Policy'",
    "'terms'": "'Terms of Service'"
}

for key, h1 in h1s.items():
    pattern = rf"({key}: PageSeo\(\s*title: '.*?',\s*)"
    replacement = rf"\1h1: {h1},\n    "
    content = re.sub(pattern, replacement, content)

with open('frontend/lib/data/seo_pages.dart', 'w') as f:
    f.write(content)

