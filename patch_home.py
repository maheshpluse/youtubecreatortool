import re

with open('frontend/lib/app.dart', 'r') as f:
    content = f.read()

home_hub = """
  Component _buildHomeHub() {
    final seo = kPageSeo['home'];
    return div(classes: 'max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-12', [
      if (seo != null)
        div(classes: 'mb-12 text-center max-w-3xl mx-auto', [
          p(classes: 'text-xl text-slate-600 dark:text-slate-300', [text(seo.definition)]),
        ]),
      div(classes: 'grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8', [
        _buildToolCard(
            title: 'YouTube SEO Analyzer',
            description: 'Analyze your video SEO score against a target keyword. Get actionable feedback on your title, description, and tags.',
            icon: 'analytics',
            link: '/youtube-seo-analyzer'),
        _buildToolCard(
            title: 'YouTube Title Generator',
            description: 'Generate viral, click-worthy titles from any topic using AI. Get multiple angles like curiosity, listicle, and how-to.',
            icon: 'title',
            link: '/youtube-title-generator'),
        _buildToolCard(
            title: 'Thumbnail Ideas Generator',
            description: 'Get AI thumbnail concepts for any video topic. We provide the subject, expression, text overlay, and color direction.',
            icon: 'image',
            link: '/youtube-thumbnail-ideas'),
        _buildToolCard(
            title: 'YouTube Tag Extractor',
            description: 'Extract tags from any YouTube video. See how ranking videos in your niche describe themselves.',
            icon: 'sell',
            link: '/youtube-tag-extractor'),
        _buildToolCard(
            title: 'Earnings Calculator',
            description: 'Estimate YouTube AdSense income from your daily views and niche. See how CPM and RPM differ by category.',
            icon: 'payments',
            link: '/youtube-earnings-calculator'),
      ]),
      if (seo != null) _buildSeoContent('home')
    ]);
  }

  Component _buildToolCard({required String title, required String description, required String icon, required String link}) {
    return a(
      href: link,
      classes: 'block p-6 bg-white dark:bg-slate-800 rounded-2xl shadow-sm hover:shadow-md transition-shadow border border-slate-200 dark:border-slate-700',
      [
        div(classes: 'flex items-center mb-4', [
          div(classes: 'w-12 h-12 bg-red-100 dark:bg-red-900/30 text-red-600 dark:text-red-500 rounded-xl flex items-center justify-center mr-4', [
            span(classes: 'material-symbols-outlined', attributes: {'aria-hidden': 'true'}, [text(icon)]),
          ]),
          h3(classes: 'text-lg font-bold text-slate-900 dark:text-white', [text(title)]),
        ]),
        p(classes: 'text-slate-600 dark:text-slate-400', [text(description)]),
      ]
    );
  }
"""

# Insert _buildHomeHub before _buildSeoAnalyzer
content = content.replace("  Component _buildSeoAnalyzer() {", home_hub + "\n  Component _buildSeoAnalyzer() {")

with open('frontend/lib/app.dart', 'w') as f:
    f.write(content)

