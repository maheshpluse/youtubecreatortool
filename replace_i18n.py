import json
import os

with open('frontend/web/assets/i18n/en.json', 'r') as f:
    en_dict = json.load(f)

with open('frontend/lib/app.dart', 'r') as f:
    content = f.lines = f.read()

# Add import if missing
if "import 'services/i18n_service.dart';" not in content:
    content = content.replace("import 'components/adsense_ad.dart';", "import 'components/adsense_ad.dart';\nimport 'services/i18n_service.dart';")

# Sort keys by length of value descending to avoid partial matches
sorted_keys = sorted(en_dict.keys(), key=lambda k: len(en_dict[k]), reverse=True)

for key in sorted_keys:
    val = en_dict[key]
    
    # We want to replace text('Val') with text(t('key'))
    # Also replace text("Val") with text(t('key'))
    # We have to be careful about variables like {count}
    
    if "{count}" in val:
        # Specialized replacements
        if key == "tag_ext_result":
            content = content.replace("text('${extractedTags!.length} tags extracted')", "text(t('tag_ext_result', {'count': extractedTags!.length.toString()}))")
        elif key == "blog_view_all":
            content = content.replace("text('View all ${blogPosts.length} articles')", "text(t('blog_view_all', {'count': blogPosts.length.toString()}))")
        continue

    # Escape single quotes in val for matching
    val_esc = val.replace("'", "\\'")
    
    # Replace plain text nodes
    content = content.replace(f"text('{val}')", f"text(t('{key}'))")
    content = content.replace(f"text(\"{val}\")", f"text(t('{key}'))")
    
    # Replace placeholders
    content = content.replace(f"'placeholder': '{val}'", f"'placeholder': t('{key}')")
    content = content.replace(f"'placeholder': \"{val}\"", f"'placeholder': t('{key}')")

with open('frontend/lib/app.dart', 'w') as f:
    f.write(content)

print("Done replacing.")
