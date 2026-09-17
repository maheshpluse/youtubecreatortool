import re

with open('frontend/lib/app.dart', 'r') as f:
    content = f.read()

# Fix script tag
script_pattern = re.compile(r"head\.add\(script\(\s*type:\s*'application/ld\+json',\s*\[RawText\(r'''(.*?)'''\)\]\s*\)\);", re.DOTALL)
content = re.sub(script_pattern, r"head.add(script(content: r'''\1''', attributes: {'type': 'application/ld+json'}));", content)

# Fix text() -> Component.text()
# I'll just blindly replace "text(" with "Component.text(" but only when it is inside my _buildHomeHub or Author byline
# Actually, global replace of "\btext\(" with "Component.text(" except for RawText
content = re.sub(r'(?<!\w)text\(', 'Component.text(', content)

with open('frontend/lib/app.dart', 'w') as f:
    f.write(content)

