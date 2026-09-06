import re
import os

keys = {
  'nav_logo_text': 'VidSEOKit',
  'hero_grow_channel': 'Grow your channel with ',
  'hero_description': 'The all-in-one suite for YouTube creators. Optimize your SEO, generate perfect titles, and estimate your earnings.',
  'tab_seo': 'SEO Analyzer',
  'tab_titles': 'Titles',
  'tab_thumbnails': 'Thumbnails',
  'tab_tags': 'Tags',
  'tab_earnings': 'Earnings',
  'tab_blog': 'Blog',
  'mobile_seo': 'SEO',
  'mobile_titles': 'Titles',
  'mobile_thumb': 'Thumb',
  'mobile_tags': 'Tags',
  'mobile_earn': 'Earn',
  'mobile_blog': 'Blog',
  'btn_analyzing': 'Analyzing...',
  'btn_analyze': 'Analyze',
  'btn_working': 'Working...',
  'btn_generate': 'Generate',
  'btn_extracting': 'Extracting...',
  'btn_extract': 'Extract',
  'btn_calculating': 'Calculating...',
  'btn_calculate': 'Calculate',
  'error_title': 'Something went wrong',
  'error_fill_fields': 'Please fill in all fields (Target Keyword, Title, Description) before analyzing.',
  'error_enter_topic': 'Please enter a video topic.',
  'error_enter_url': 'Please enter a YouTube video URL.',
  'error_invalid_url': 'Please enter a valid YouTube URL (e.g., https://youtube.com/...).',
  'seo_title': 'SEO Analyzer',
  'seo_placeholder_keyword': 'Target Keyword (e.g. how to code)',
  'seo_placeholder_title': 'Video Title',
  'seo_placeholder_desc': 'Video Description...',
  'seo_score_label': 'SEO Score',
  'seo_empty_state': 'Enter details to see your score',
  'title_gen_title': 'Title Generator',
  'title_gen_placeholder': 'Enter video topic...',
  'thumb_gen_title': 'Thumbnail Idea Generator',
  'thumb_gen_placeholder': 'Enter video topic...',
  'thumb_visual_concept': 'Visual Concept',
  'thumb_text_on_screen': 'Text on Screen',
  'tag_ext_title': 'Tag Extractor',
  'tag_ext_placeholder': 'e.g. https://youtube.com/watch?v=dQw4w9WgXcQ',
  'earn_calc_title': 'Earnings Calculator',
  'earn_daily_views': 'Daily Views',
  'earn_niche': 'Niche',
  'earn_monthly_rev': 'Estimated Monthly Revenue',
  'earn_disclaimer': 'Based on US/UK tier-1 CPM rates',
  'earn_empty_state': 'Select your parameters',
  'blog_latest': 'Latest from the Creator Blog',
  'blog_read_min': 'min read',
  'footer_privacy': 'Privacy',
  'footer_terms': 'Terms',
  'footer_about': 'About',
  'footer_contact': 'Contact',
  'footer_privacy_policy': 'Privacy Policy',
  'footer_terms_service': 'Terms of Service',
  'footer_cookies': 'Cookie Settings',
  'footer_copyright': '© 2026 VidSEOKit',
}

def replace_in_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    for key, text in keys.items():
        # Component.text('Text') -> Component.text(t('key'))
        # Needs to match exact string
        escaped_text = re.escape(text)
        
        # Replace Component.text('...')
        content = re.sub(
            r"Component\.text\('" + escaped_text + r"'\)",
            f"Component.text(t('{key}'))",
            content
        )
        
        # Replace placeholders: placeholder: '...' -> placeholder: t('...')
        content = re.sub(
            r"placeholder: '" + escaped_text + r"'",
            f"placeholder: t('{key}')",
            content
        )

    # Some special cases like `text_on_screen`
    content = content.replace(
        "Component.text(isLoading ? 'Analyzing...' : 'Analyze')",
        "Component.text(isLoading ? t('btn_analyzing') : t('btn_analyze'))"
    )
    content = content.replace(
        "Component.text(isLoading ? 'Working...' : 'Generate')",
        "Component.text(isLoading ? t('btn_working') : t('btn_generate'))"
    )
    content = content.replace(
        "Component.text(isLoading ? 'Calculating...' : 'Calculate')",
        "Component.text(isLoading ? t('btn_calculating') : t('btn_calculate'))"
    )

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

replace_in_file('frontend/lib/app.dart')
print("Done")
