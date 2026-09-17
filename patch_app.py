import re

with open('frontend/lib/app.dart', 'r') as f:
    content = f.read()

# 1. Update _buildHero to use dynamic H1
content = re.sub(
    r"\[text\('Free Video SEO & Growth Tools — VidSEOKit'\)\]",
    r"[text(kPageSeo[activeTab]?.h1 ?? 'Free Video SEO & Growth Tools — VidSEOKit')]",
    content
)

# 2. Update blog link
content = content.replace("if (tab == 'blog') return '/blog/index.html';", "if (tab == 'blog') return '/blog/';")

# 3. Add aria-hidden="true" to material symbols
content = re.sub(
    r"span\(classes: 'material-symbols-outlined(.*?)\",",
    r"span(classes: 'material-symbols-outlined\1\", attributes: {'aria-hidden': 'true'},",
    content
)

# 4. Update _getTabFromPath to return 'home' for '/'
content = content.replace(
    "if (path == '/youtube-seo-analyzer' || path == '/') return 'seo';",
    "if (path == '/youtube-seo-analyzer') return 'seo';\n    if (path == '/') return 'home';"
)

# 5. Add / route for _buildHomeHub
content = content.replace(
    "Route(path: '/', builder: (context, state) => _buildSeoAnalyzer()),",
    "Route(path: '/', builder: (context, state) => _buildHomeHub()),"
)

# 6. Author Byline in _buildSeoContent
# Add byline after sources
byline_html = """
    if (seo.sources.isNotEmpty) {
      children.add(
        div(classes: 'mt-12 pt-8 border-t border-slate-200 dark:border-slate-800', [
          h3(classes: 'text-sm font-semibold text-slate-900 dark:text-white uppercase tracking-wider mb-4', [text('Sources')]),
          ul(classes: 'space-y-3', [
            for (final source in seo.sources)
              li(classes: 'flex items-start', [
                span(classes: 'material-symbols-outlined text-slate-400 mt-0.5 mr-2 text-sm', attributes: {'aria-hidden': 'true'}, [text('article')]),
                a(href: source.url, target: Target.blank, rel: 'noopener noreferrer', classes: 'text-sm text-slate-600 dark:text-slate-400 hover:text-red-600 dark:hover:text-red-500 transition-colors', [text(source.title)]),
              ]),
          ]),
        ]),
      );
    }
    
    // Author Byline
    children.add(
      div(classes: 'mt-8 pt-8 border-t border-slate-200 dark:border-slate-800 flex items-center', [
        div(classes: 'w-12 h-12 rounded-full bg-slate-200 dark:bg-slate-700 flex items-center justify-center text-slate-500 dark:text-slate-400 mr-4', [
          span(classes: 'material-symbols-outlined', attributes: {'aria-hidden': 'true'}, [text('person')])
        ]),
        div([
          p(classes: 'text-sm font-semibold text-slate-900 dark:text-white', [text('Written by VidSEOKit Team')]),
          p(classes: 'text-xs text-slate-500 dark:text-slate-400', [text('Experts in YouTube growth and video SEO.')])
        ])
      ])
    );
"""
# find the existing sources block and replace
sources_pattern = re.compile(r"if \(seo\.sources\.isNotEmpty\) \{.*?\}\)", re.DOTALL)
content = re.sub(sources_pattern, byline_html.strip(), content)

with open('frontend/lib/app.dart', 'w') as f:
    f.write(content)

