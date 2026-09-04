import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:js_util' as js_util;

import 'config.dart';
import 'data/blog_posts.dart';
import 'pages/legal.dart';
import 'components/adsense_ad.dart';

class App extends StatefulComponent {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  String _activeTab = 'seo';
  bool isDark = true;

  // SEO Analyzer State
  String seoTargetKeyword = '';
  String seoTitle = '';
  String seoDescription = '';
  Map<String, dynamic>? seoResult;

  // Title Generator State
  String titleTopic = '';
  List<dynamic>? generatedTitles;

  // Thumbnail Generator State
  String thumbnailTopic = '';
  List<dynamic>? generatedThumbnails;

  // Tag Extractor State
  String tagUrl = '';
  List<dynamic>? extractedTags;

  // Earnings Calculator State
  int dailyViews = 10000;
  String selectedNiche = 'Finance';
  Map<String, dynamic>? earningsResult;

  bool isLoading = false;

  /// Last request failure, shown to the user. Null when the last call succeeded.
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    // Let web/consent.js open the Privacy Policy tab from its banner link.
    // The Jaspr app owns routing, so the banner cannot navigate on its own.
    js_util.setProperty(
      js_util.globalThis,
      'ctOpenPrivacy',
      js_util.allowInterop(() => switchTab('privacy')),
    );
  }

  void switchTab(String tab) {
    setState(() => _activeTab = tab);
  }

  void toggleTheme() {
    setState(() => isDark = !isDark);
  }

  /// Reopens the cookie preferences panel owned by web/consent.js.
  /// No-op if that script failed to load, so the footer link can never throw.
  void openConsentPreferences() {
    final fn = js_util.getProperty(js_util.globalThis, 'showConsentPreferences');
    if (fn != null) {
      js_util.callMethod(js_util.globalThis, 'showConsentPreferences', []);
    }
  }

  /// POSTs [body] to [path] on the API with a fresh reCAPTCHA token and returns
  /// the decoded JSON. Throws on any non-200 so the caller can surface it.
  Future<dynamic> _postJson(String path, Map<String, dynamic> body) async {
    final token = await js_util.promiseToFuture(
        js_util.callMethod(js_util.globalThis, 'executeRecaptcha', []));
    final response = await http.post(
      Uri.parse('$apiBaseUrl$path'),
      headers: {
        'Content-Type': 'application/json',
        'X-Recaptcha-Token': token.toString(),
      },
      body: jsonEncode(body),
    );
    if (response.statusCode != 200) {
      throw Exception('Request failed (${response.statusCode}). ${response.body}');
    }
    return jsonDecode(response.body);
  }

  /// Wraps a tool request in the loading + error handling every tool shares.
  /// Previously each caller swallowed its exception, so a failed request left
  /// the UI looking idle with no explanation.
  Future<void> _run(Future<void> Function() request) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      await request();
    } catch (e) {
      setState(() => errorMessage = e.toString());
    }
    setState(() => isLoading = false);
  }

  Future<void> calculateSeo() => _run(() async {
        final data = await _postJson('/api/calculate-seo', {
          'target_keyword': seoTargetKeyword,
          'title': seoTitle,
          'description': seoDescription,
          'tags': [],
        });
        setState(() => seoResult = data as Map<String, dynamic>);
      });

  Future<void> generateTitles() => _run(() async {
        final data = await _postJson('/api/generate-titles', {'topic': titleTopic});
        setState(() => generatedTitles = data as List<dynamic>);
      });

  Future<void> generateThumbnails() => _run(() async {
        final data =
            await _postJson('/api/generate-thumbnails', {'topic': thumbnailTopic});
        setState(() => generatedThumbnails = data as List<dynamic>);
      });

  Future<void> extractTags() => _run(() async {
        final data = await _postJson('/api/extract-tags', {'url': tagUrl});
        setState(() => extractedTags = data['tags'] as List<dynamic>);
      });

  Future<void> calculateEarnings() => _run(() async {
        final data = await _postJson('/api/calculate-earnings', {
          'daily_views': dailyViews,
          'niche': selectedNiche,
        });
        setState(() => earningsResult = data as Map<String, dynamic>);
      });

  // ═══════════════════════════════════════════
  //  LOGO SVG
  // ═══════════════════════════════════════════
  Component _buildLogoIcon(String extraClasses) {
    return svg(
      classes: 'text-yt-red transition-transform duration-300 hover:scale-110 animate-flip-x $extraClasses',
      attributes: {'viewBox': '0 0 24 24', 'fill': 'currentColor', 'xmlns': 'http://www.w3.org/2000/svg'},
      [
        path(
          attributes: {
            'd': 'M6.5 6.25v11.5a2.25 2.25 0 003.36 1.95l10.07-5.75a2.25 2.25 0 000-3.9L9.86 4.3A2.25 2.25 0 006.5 6.25z'
          },
          []
        )
      ]
    );
  }

  @override
  Component build(BuildContext context) {
    return div(classes: 'min-h-screen font-sans transition-colors duration-300', [
      _buildNavbar(),
      _buildHero(),
      div(classes: 'max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 pb-32 md:pb-16', [
        _buildDesktopTabs(),
        if (errorMessage != null) _buildErrorBanner(errorMessage!),
        div(classes: 'animate-fade-in-up animate-delay-100', [
          if (_activeTab == 'seo') _buildSeoAnalyzer(),
          if (_activeTab == 'titles') _buildTitleGenerator(),
          if (_activeTab == 'thumbnails') _buildThumbnailGenerator(),
          if (_activeTab == 'tags') _buildTagExtractor(),
          if (_activeTab == 'earnings') _buildEarningsCalculator(),
          if (_activeTab == 'blog') _buildBlogSection(),
          if (_activeTab == 'privacy') _buildPrivacyPolicy(),
          if (_activeTab == 'terms') _buildTerms(),
          if (_activeTab == 'about') _buildAbout(),
          if (_activeTab == 'contact') _buildContact(),
        ]),
        _buildSeoArticle(),
      ]),
      _buildFooter(),
      _buildMobileNav(),
    ]);
  }

  // ═══════════════════════════════════════════
  //  NAVBAR
  // ═══════════════════════════════════════════
  Component _buildNavbar() {
    return div(classes: 'glass fixed top-0 left-0 right-0 z-50 animate-slide-in-top animate-duration-500', [
      div(classes: 'max-w-6xl mx-auto px-4 sm:px-6 lg:px-8', [
        div(classes: 'flex items-center justify-between h-14', [
          // Logo
          div(classes: 'flex items-center gap-2 cursor-pointer', [
            _buildLogoIcon('w-8 h-8'),
            span(classes: 'text-xl font-bold tracking-tighter', [text('CreatorTools')]),
          ]),
          // Right Actions
          div(classes: 'flex items-center gap-3', [
            button(
              classes: 'theme-toggle',
              attributes: {'data-theme-toggle': 'true'},
              onClick: () => toggleTheme(),
              [span(classes: 'material-symbols-rounded text-2xl', [text(isDark ? 'light_mode' : 'dark_mode')])]
            ),
          ]),
        ])
      ])
    ]);
  }

  // ═══════════════════════════════════════════
  //  HERO
  // ═══════════════════════════════════════════
  Component _buildHero() {
    return div(classes: 'pt-24 pb-8 md:pt-28 md:pb-8 text-center px-4 relative overflow-hidden', [
      div(classes: 'relative z-10', [
        h1(classes: 'text-3xl sm:text-4xl md:text-5xl font-bold tracking-tight animate-fade-in-up animate-delay-200', [
          text('Grow your channel with '),
          span(classes: 'text-yt-red', [text('CreatorTools')])
        ]),
        p(classes: 'mt-4 text-yt-gray-600 dark:text-yt-gray-400 text-base max-w-xl mx-auto leading-relaxed animate-fade-in-up animate-delay-400', [
          text('The all-in-one suite for YouTube creators. Optimize your SEO, generate perfect titles, and estimate your earnings.')
        ]),
      ])
    ]);
  }

  // ═══════════════════════════════════════════
  //  DESKTOP TABS
  // ═══════════════════════════════════════════
  Component _buildDesktopTabs() {
    return div(classes: 'hidden md:flex items-center gap-3 mb-8 animate-fade-in-up animate-delay-500 overflow-x-auto pb-2', [
      _buildTabChip('SEO Analyzer', 'seo'),
      _buildTabChip('Titles', 'titles'),
      _buildTabChip('Thumbnails', 'thumbnails'),
      _buildTabChip('Tags', 'tags'),
      _buildTabChip('Earnings', 'earnings'),
      _buildTabChip('Blog', 'blog'),
    ]);
  }

  /// Inline banner for a failed request, dismissible so it never blocks the UI.
  Component _buildErrorBanner(String message) {
    return div(
      classes: 'mb-6 flex items-start gap-3 rounded-lg border border-yt-red/30 '
          'bg-yt-red/10 p-4 animate-fade-in-up',
      [
        span(classes: 'material-symbols-rounded text-yt-red text-xl', [text('error')]),
        div(classes: 'flex-1', [
          p(classes: 'text-sm font-medium text-yt-red', [text('Something went wrong')]),
          p(classes: 'mt-1 text-xs text-yt-gray-600 dark:text-yt-gray-400 break-words',
              [text(message)]),
        ]),
        button(
          classes: 'material-symbols-rounded text-yt-gray-500 hover:text-yt-gray-900 '
              'dark:hover:text-white text-lg',
          attributes: {'aria-label': 'Dismiss error'},
          onClick: () => setState(() => errorMessage = null),
          [text('close')],
        ),
      ],
    );
  }

  Component _buildTabChip(String label, String id) {
    bool isActive = _activeTab == id;
    return button(
      classes: 'px-4 py-1.5 text-sm font-medium rounded-lg transition-colors whitespace-nowrap ' +
          (isActive
              ? 'bg-yt-gray-900 text-white dark:bg-white dark:text-yt-gray-900'
              : 'bg-yt-gray-100 text-yt-gray-900 dark:bg-yt-gray-800 dark:text-white hover:bg-yt-gray-200 dark:hover:bg-yt-gray-700'),
      onClick: () => switchTab(id),
      [
        text(label),
      ]
    );
  }

  // ═══════════════════════════════════════════
  //  MOBILE BOTTOM NAV
  // ═══════════════════════════════════════════
  Component _buildMobileNav() {
    return div(classes: 'mobile-nav md:hidden', [
      div(classes: 'flex items-center justify-around px-2', [
        _mobileNavItem('search', 'SEO', 'seo'),
        _mobileNavItem('title', 'Titles', 'titles'),
        _mobileNavItem('image', 'Thumb', 'thumbnails'),
        _mobileNavItem('sell', 'Tags', 'tags'),
        _mobileNavItem('payments', 'Earn', 'earnings'),
        _mobileNavItem('article', 'Blog', 'blog'),
      ])
    ]);
  }

  Component _mobileNavItem(String icon, String label, String tab) {
    bool isActive = _activeTab == tab;
    return button(
      classes: 'flex flex-col items-center gap-1 py-1 px-3 transition-all duration-300 ' +
          (isActive ? 'text-yt-gray-900 dark:text-white' : 'text-yt-gray-600 dark:text-yt-gray-400'),
      onClick: () => switchTab(tab),
      [
        span(classes: 'material-symbols-rounded text-2xl ' + (isActive ? 'filled' : ''), [text(icon)]),
        span(classes: 'text-[10px] font-medium', [text(label)]),
      ]
    );
  }

  // ═══════════════════════════════════════════
  //  SEO ANALYZER
  // ═══════════════════════════════════════════
  Component _buildSeoAnalyzer() {
    return div(classes: 'grid grid-cols-1 lg:grid-cols-3 gap-6', [
      div(classes: 'lg:col-span-2 space-y-4 animate-fade-in-left animate-delay-100', [
        div(classes: 'flex items-center gap-2 mb-4', [
          span(classes: 'material-symbols-rounded text-2xl', [text('analytics')]),
          h2(classes: 'text-xl font-bold', [text('SEO Analyzer')]),
        ]),
        div([
          input(
            classes: 'input-field',
            attributes: {'placeholder': 'Target Keyword (e.g. how to code)'},
            onInput: (e) => setState(() => seoTargetKeyword = e.toString()),
          ),
        ]),
        div([
          input(
            classes: 'input-field',
            attributes: {'placeholder': 'Video Title'},
            onInput: (e) => setState(() => seoTitle = e.toString()),
          ),
        ]),
        div([
          textarea(
            classes: 'input-field resize-none',
            attributes: {'placeholder': 'Video Description...', 'rows': '5'},
            onInput: (e) => setState(() => seoDescription = e.toString()),
            [],
          ),
        ]),
        div(classes: 'flex justify-end', [
          button(
            classes: 'btn-primary font-medium px-6 py-2 text-sm flex items-center justify-center gap-2 w-full md:w-auto',
            onClick: () => calculateSeo(),
            [
              text(isLoading ? 'Analyzing...' : 'Analyze'),
            ]
          ),
        ])
      ]),
      div(classes: 'card p-6 flex flex-col items-center justify-center min-h-[300px] animate-fade-in-right animate-delay-200', [
        if (seoResult != null) ...[
          div(classes: 'score-ring mb-6', [
            div(classes: 'text-center', [
              span(classes: 'text-4xl font-bold ' + ((seoResult!['score'] as int) > 75 ? 'text-[#2BA640]' : 'text-yt-red'), [
                text(seoResult!['score'].toString())
              ]),
              p(classes: 'text-sm font-medium text-yt-gray-500 mt-1', [text('SEO Score')])
            ])
          ]),
          div(classes: 'w-full space-y-2', [
            for (var fb in seoResult!['feedback'])
              div(classes: 'flex items-start gap-2', [
                span(classes: 'material-symbols-rounded text-sm mt-0.5 ' +
                    (fb.toString().startsWith('Pass') ? 'text-[#2BA640]' : 'text-yt-red'),
                    [text(fb.toString().startsWith('Pass') ? 'check_circle' : 'cancel')]),
                span(classes: 'text-sm text-yt-gray-700 dark:text-yt-gray-300', [text(fb.toString())])
              ])
          ]),
        ] else ...[
          span(classes: 'material-symbols-rounded text-5xl text-yt-gray-300 dark:text-yt-gray-700 mb-4', [text('troubleshoot')]),
          p(classes: 'text-yt-gray-500 text-sm font-medium text-center', [text('Enter details to see your score')]),
        ]
      ])
    ]);
  }

  // ═══════════════════════════════════════════
  //  TITLE GENERATOR
  // ═══════════════════════════════════════════
  Component _buildTitleGenerator() {
    return div(classes: 'space-y-6 max-w-4xl', [
      div(classes: 'animate-fade-in-up animate-delay-100', [
        div(classes: 'flex items-center gap-2 mb-4', [
          span(classes: 'material-symbols-rounded text-2xl', [text('title')]),
          h2(classes: 'text-xl font-bold', [text('Title Generator')]),
        ]),
        div(classes: 'flex flex-col sm:flex-row gap-3', [
          div(classes: 'flex-1', [
            input(
              classes: 'input-field',
              attributes: {'placeholder': 'Enter video topic...'},
              onInput: (e) => setState(() => titleTopic = e.toString()),
            ),
          ]),
          button(
            classes: 'btn-primary font-medium px-6 py-2 text-sm flex items-center justify-center whitespace-nowrap',
            onClick: () => generateTitles(),
            [text(isLoading ? 'Working...' : 'Generate')]
          ),
        ]),
      ]),
      if (generatedTitles != null) div(classes: 'grid grid-cols-1 md:grid-cols-2 gap-4 animate-fade-in-up animate-delay-200', [
        for (var i = 0; i < generatedTitles!.length; i++)
          div(classes: 'card p-4 hover:bg-yt-gray-50 dark:hover:bg-yt-gray-800 cursor-pointer', [
            div(classes: 'flex gap-3', [
              span(classes: 'text-sm font-medium text-yt-gray-500 mt-0.5', [
                text((i + 1).toString() + '.')
              ]),
              div(classes: 'flex-1', [
                p(classes: 'font-medium text-sm text-yt-gray-900 dark:text-white', [
                  text(generatedTitles![i]['title'].toString())
                ]),
                div(classes: 'flex items-center gap-2 mt-2', [
                  span(classes: 'text-xs text-[#2BA640] font-medium', [
                    text('CTR: ' + generatedTitles![i]['ctr_score'].toString() + '%')
                  ]),
                ]),
              ]),
            ])
          ])
      ])
    ]);
  }

  // ═══════════════════════════════════════════
  //  TAG EXTRACTOR
  // ═══════════════════════════════════════════
  //  THUMBNAIL GENERATOR
  // ═══════════════════════════════════════════
  Component _buildThumbnailGenerator() {
    return div(classes: 'space-y-6 max-w-4xl', [
      div(classes: 'animate-fade-in-up animate-delay-100', [
        div(classes: 'flex items-center gap-2 mb-4', [
          span(classes: 'material-symbols-rounded text-2xl', [text('image')]),
          h2(classes: 'text-xl font-bold', [text('Thumbnail Idea Generator')]),
        ]),
        div(classes: 'flex flex-col sm:flex-row gap-3', [
          div(classes: 'flex-1', [
            input(
              classes: 'input-field',
              attributes: {'placeholder': 'Enter video topic...'},
              onInput: (e) => setState(() => thumbnailTopic = e.toString()),
            ),
          ]),
          button(
            classes: 'btn-primary font-medium px-6 py-2 text-sm flex items-center justify-center whitespace-nowrap',
            onClick: () => generateThumbnails(),
            [text(isLoading ? 'Working...' : 'Generate')]
          ),
        ]),
      ]),
      if (generatedThumbnails != null) div(classes: 'space-y-4 animate-fade-in-up animate-delay-200', [
        for (var i = 0; i < generatedThumbnails!.length; i++)
          div(classes: 'card p-5 hover:bg-yt-gray-50 dark:hover:bg-yt-gray-800 transition-colors', [
            div(classes: 'flex items-start gap-3', [
              span(classes: 'flex items-center justify-center w-8 h-8 rounded-full bg-yt-gray-100 dark:bg-yt-gray-700 font-bold text-yt-red shrink-0 mt-1', [
                text((i + 1).toString())
              ]),
              div(classes: 'flex-1', [
                h3(classes: 'font-bold text-lg text-yt-gray-900 dark:text-white mb-2', [
                  text(generatedThumbnails![i]['concept_name'].toString())
                ]),
                div(classes: 'mb-3', [
                  span(classes: 'text-xs font-bold text-yt-gray-500 uppercase tracking-wider', [text('Visual Concept')]),
                  p(classes: 'text-sm text-yt-gray-600 dark:text-yt-gray-400 mt-1', [
                    text(generatedThumbnails![i]['visual_description'].toString())
                  ]),
                ]),
                div(classes: 'bg-yt-gray-100 dark:bg-yt-gray-900 rounded p-3 border border-yt-gray-200 dark:border-yt-gray-700', [
                  span(classes: 'text-xs font-bold text-yt-gray-500 uppercase tracking-wider', [text('Text on Screen')]),
                  p(classes: 'text-sm font-bold text-yt-gray-900 dark:text-white mt-1 text-xl italic', [
                    text('"' + generatedThumbnails![i]['text_on_screen'].toString() + '"')
                  ]),
                ]),
              ])
            ])
          ])
      ])
    ]);
  }

  // ═══════════════════════════════════════════
  Component _buildTagExtractor() {
    return div(classes: 'space-y-6 max-w-4xl', [
      div(classes: 'animate-fade-in-up animate-delay-100', [
        div(classes: 'flex items-center gap-2 mb-4', [
          span(classes: 'material-symbols-rounded text-2xl', [text('sell')]),
          h2(classes: 'text-xl font-bold', [text('Tag Extractor')]),
        ]),
        div(classes: 'flex flex-col sm:flex-row gap-3', [
          div(classes: 'flex-1', [
            input(
              classes: 'input-field',
              attributes: {
                'placeholder': 'e.g. https://youtube.com/watch?v=dQw4w9WgXcQ',
                'value': tagUrl
              },
              onInput: (e) => setState(() => tagUrl = e.toString()),
            ),
          ]),
          button(
            classes: 'btn-primary font-medium px-6 py-2 text-sm flex items-center justify-center whitespace-nowrap',
            onClick: () => extractTags(),
            [text(isLoading ? 'Extracting...' : 'Extract')]
          ),
        ]),
      ]),
      if (extractedTags != null) div(classes: 'card p-6 animate-fade-in-up animate-delay-200', [
        div(classes: 'flex items-center gap-2 mb-4', [
          span(classes: 'text-sm font-medium text-yt-gray-600 dark:text-yt-gray-400', [
            text(extractedTags!.length.toString() + ' tags extracted')
          ])
        ]),
        div(classes: 'flex flex-wrap gap-2', [
          for (var tag in extractedTags!)
            span(classes: 'bg-yt-gray-100 dark:bg-yt-gray-800 text-yt-gray-900 dark:text-white px-3 py-1.5 rounded-full text-sm hover:bg-yt-gray-200 dark:hover:bg-yt-gray-700 cursor-pointer transition-colors', [
              text(tag.toString())
            ])
        ])
      ])
    ]);
  }

  // ═══════════════════════════════════════════
  //  EARNINGS CALCULATOR
  // ═══════════════════════════════════════════
  Component _buildEarningsCalculator() {
    return div(classes: 'grid grid-cols-1 lg:grid-cols-3 gap-6', [
      div(classes: 'lg:col-span-2 space-y-6 animate-fade-in-left animate-delay-100', [
        div(classes: 'flex items-center gap-2 mb-4', [
          span(classes: 'material-symbols-rounded text-2xl', [text('payments')]),
          h2(classes: 'text-xl font-bold', [text('Earnings Calculator')]),
        ]),
        div(classes: 'card p-6 space-y-6', [
          div([
            div(classes: 'flex items-center justify-between mb-2', [
              label(classes: 'text-sm font-medium text-yt-gray-900 dark:text-white', [text('Daily Views')]),
              span(classes: 'text-sm font-bold', [text(dailyViews.toString())]),
            ]),
            input(
              classes: 'w-full h-1 rounded-full appearance-none cursor-pointer bg-yt-gray-200 dark:bg-yt-gray-700 accent-yt-red',
              attributes: {'type': 'range', 'min': '1000', 'max': '100000', 'step': '1000'},
              onChange: (e) => setState(() => dailyViews = int.parse(e.toString())),
            ),
          ]),
          div([
            label(classes: 'block text-sm font-medium text-yt-gray-900 dark:text-white mb-3', [text('Niche')]),
            div(classes: 'grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-2', [
              _nicheButton('Finance', 'Finance'),
              _nicheButton('Tech', 'Tech'),
              _nicheButton('Gaming', 'Gaming'),
              _nicheButton('Vlog', 'Vlog'),
              _nicheButton('Education', 'Education'),
              _nicheButton('Entertainment', 'Entertainment'),
              _nicheButton('Health', 'Health'),
              _nicheButton('Beauty', 'Beauty'),
              _nicheButton('Cooking', 'Cooking'),
            ])
          ]),
          div(classes: 'flex justify-end pt-2', [
             button(
              classes: 'btn-primary font-medium px-6 py-2 text-sm flex items-center justify-center gap-2 w-full sm:w-auto',
              onClick: () => calculateEarnings(),
              [text(isLoading ? 'Calculating...' : 'Calculate')]
            ),
          ])
        ]),
      ]),
      div(classes: 'card p-6 flex flex-col items-center justify-center min-h-[300px] animate-fade-in-right animate-delay-200', [
        if (earningsResult != null) ...[
          div(classes: 'text-center animate-bounce-in', [
            span(classes: 'text-sm text-yt-gray-500 font-medium mb-1', [text('Estimated Monthly Revenue')]),
            p(classes: 'text-4xl font-bold text-yt-gray-900 dark:text-white mt-2', [
              text('\$' + earningsResult!['min_monthly'].toString() + ' - \$' + earningsResult!['max_monthly'].toString())
            ]),
            p(classes: 'text-xs text-yt-gray-500 mt-4', [text('Based on US/UK tier-1 CPM rates')]),
          ])
        ] else ...[
          span(classes: 'material-symbols-rounded text-5xl text-yt-gray-300 dark:text-yt-gray-700 mb-4', [text('monetization_on')]),
          p(classes: 'text-yt-gray-500 text-sm font-medium text-center', [text('Select your parameters')]),
        ]
      ])
    ]);
  }

  Component _nicheButton(String label, String value) {
    bool isActive = selectedNiche == value;
    return button(
      classes: 'px-3 py-2 rounded-lg text-sm font-medium transition-all duration-200 ' +
          (isActive
              ? 'bg-yt-gray-900 text-white dark:bg-white dark:text-yt-gray-900'
              : 'bg-yt-gray-100 text-yt-gray-900 dark:bg-yt-gray-800 dark:text-white hover:bg-yt-gray-200 dark:hover:bg-yt-gray-700'),
      onClick: () => setState(() => selectedNiche = value),
      [
        text(label),
      ]
    );
  }

  // ═══════════════════════════════════════════
  //  BLOG SECTION
  // ═══════════════════════════════════════════
  Component _buildBlogSection() {
    return div(classes: 'space-y-6', [
      div(classes: 'flex items-center justify-between gap-3 mb-4 animate-fade-in-down animate-delay-100', [
        div(classes: 'flex items-center gap-2', [
          span(classes: 'material-symbols-rounded text-2xl', [text('article')]),
          h2(classes: 'text-xl font-bold', [text('Latest from the Creator Blog')]),
        ]),
        a(
          href: 'blog/index.html',
          classes: 'text-sm font-medium text-yt-blue-dark dark:text-yt-blue-light hover:underline whitespace-nowrap',
          [text('View all ' + blogPosts.length.toString() + ' articles')]
        ),
      ]),

      div(
        classes: 'grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 animate-fade-in-up animate-delay-200',
        [for (final post in blogPosts) _blogCard(post)]
      ),
      AdSenseAd(slotId: '1234567890'),
    ]);
  }

  Component _blogCard(BlogPost post) {
    return a(
      href: post.url,
      classes: 'flex flex-col gap-2 group',
      [
        div(classes: 'aspect-video bg-yt-gray-200 dark:bg-yt-gray-800 rounded-xl flex items-center justify-center overflow-hidden', [
          img(src: post.imageUrl, classes: 'w-full h-full object-cover group-hover:scale-105 transition-transform duration-500', alt: post.title)
        ]),
        div(classes: 'flex items-start gap-3 mt-1', [
          div(classes: 'w-9 h-9 rounded-full bg-yt-gray-200 dark:bg-yt-gray-800 shrink-0 flex items-center justify-center', [
            _buildLogoIcon('w-4 h-4')
          ]),
          div(classes: 'flex flex-col', [
            h3(classes: 'text-sm font-medium text-yt-gray-900 dark:text-white line-clamp-2 leading-tight group-hover:text-yt-red transition-colors', [text(post.title)]),
            p(classes: 'text-xs text-yt-gray-600 dark:text-yt-gray-400 mt-1', [
              text(post.category + ' \u2022 ' + post.date + ' \u2022 ' + post.readMinutes.toString() + ' min read')
            ]),
          ])
        ])
      ]
    );
  }

  // ═══════════════════════════════════════════
  //  SEO ARTICLE
  // ═══════════════════════════════════════════
  Component _buildSeoArticle() {
    String title = '';
    List<Component> content = [];

    switch (_activeTab) {
      case 'seo':
        title = 'About YouTube SEO Analyzer';
        content = [
          p([text('To succeed on YouTube today, mastering Search Engine Optimization (SEO) is critical. Whether your goal is to boost your AdSense revenue or reach a highly targeted audience, leveraging tools for video analytics and calculating your Click-Through Rate (CTR) can significantly improve your video engagement rate.')]),
          p([text('Using a robust keyword research tool helps you conduct in-depth competitor analysis to find high CPC keywords. These High RPM keywords are essential when building passive income streams or diversifying with affiliate marketing strategies and sponsored content.')]),
        ];
        break;
      case 'titles':
        title = 'Generating Viral YouTube Titles';
        content = [
          p([text('The title is the most important metadata for your video. A highly clickable, viral YouTube title can drastically improve your CTR (Click-Through Rate) and help the YouTube algorithm recommend your content to a wider audience.')]),
          p([text('Our AI-powered title generator analyzes current trends and proven formulas to suggest titles that grab attention without being misleading clickbait. Perfect for increasing views and maximizing AdSense earnings.')]),
        ];
        break;
      case 'thumbnails':
        title = 'Designing Clickable Thumbnails';
        content = [
          p([text('A great thumbnail is just as important as a great title. It is the visual hook that makes someone stop scrolling and click on your video.')]),
          p([text('Our AI generates proven visual concepts focusing on strong contrast, clear emotions, and minimal text to ensure your thumbnail stands out, especially on mobile devices where most views happen.')]),
        ];
        break;
      case 'tags':
        title = 'Extracting High-Performing Tags';
        content = [
          p([text('Tags play a supportive role in YouTube SEO, helping the algorithm understand the context of your video. By extracting tags from top-performing competitor videos, you can discover hidden keywords and ranking opportunities.')]),
          p([text('Use our Tag Extractor to quickly grab the exact tags used by viral videos in your niche, saving you hours of manual research and helping you optimize your video metadata for better search rankings.')]),
        ];
        break;
      case 'earnings':
        title = 'Estimating YouTube AdSense Earnings';
        content = [
          p([text('Understanding your potential revenue is key to treating your YouTube channel like a business. Our Earnings Calculator uses average CPM (Cost Per Mille) and RPM (Revenue Per Mille) rates across different niches to give you a realistic estimate.')]),
          p([text('Keep in mind that finance and tech niches typically have higher RPMs compared to gaming or vlogs, meaning you can earn more with fewer views. Always focus on audience retention to maximize ad placements.')]),
        ];
        break;
      case 'blog':
        title = 'Creator Insights & Strategies';
        content = [
          p([text('Stay ahead of the curve with the latest strategies, algorithm updates, and monetization tips on our Creator Blog. We break down complex topics into actionable advice for YouTubers of all sizes.')]),
          p([text('From improving your thumbnail designs to understanding audience psychology, our blog is your go-to resource for sustainable channel growth and community building.')]),
        ];
        break;
      default:
        // Hide article on legal pages
        return div([]);
    }

    return div(classes: 'mt-12 pt-8 border-t border-yt-gray-200 dark:border-yt-gray-800 animate-fade-in animate-duration-300 max-w-3xl', [
      h2(classes: 'text-lg font-bold text-yt-gray-900 dark:text-white mb-4', [text(title)]),
      div(classes: 'space-y-4 text-yt-gray-600 dark:text-yt-gray-400 text-sm leading-relaxed', content)
    ]);
  }

  // ═══════════════════════════════════════════
  //  FOOTER
  // ═══════════════════════════════════════════
  Component _buildFooter() {
    return div(classes: 'border-t border-yt-gray-200 dark:border-yt-gray-800 mt-16 mb-20 md:mb-0 pb-8 animate-fade-in animate-delay-500', [
      div(classes: 'max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-6', [
        div(classes: 'flex flex-col md:flex-row items-center justify-between gap-4', [
           div(classes: 'flex items-center gap-2', [
            _buildLogoIcon('w-5 h-5'),
            span(classes: 'font-bold text-sm text-yt-gray-900 dark:text-white tracking-tight', [text('CreatorTools')]),
          ]),
          div(classes: 'flex flex-wrap justify-center gap-4', [
            button(classes: 'text-xs text-yt-gray-500 hover:text-yt-gray-900 dark:hover:text-white transition-colors', onClick: () => switchTab('about'), [text('About')]),
            button(classes: 'text-xs text-yt-gray-500 hover:text-yt-gray-900 dark:hover:text-white transition-colors', onClick: () => switchTab('contact'), [text('Contact')]),
            button(classes: 'text-xs text-yt-gray-500 hover:text-yt-gray-900 dark:hover:text-white transition-colors', onClick: () => switchTab('privacy'), [text('Privacy Policy')]),
            button(classes: 'text-xs text-yt-gray-500 hover:text-yt-gray-900 dark:hover:text-white transition-colors', onClick: () => switchTab('terms'), [text('Terms of Service')]),
            button(classes: 'text-xs text-yt-gray-500 hover:text-yt-gray-900 dark:hover:text-white transition-colors', onClick: openConsentPreferences, [text('Cookie Settings')]),
          ]),
          p(classes: 'text-xs text-yt-gray-500', [text('\u00a9 2026 CreatorTools')]),
        ])
      ])
    ]);
  }

  // ═══════════════════════════════════════════
  //  STATIC PAGES
  // ═══════════════════════════════════════════
  Component _buildPrivacyPolicy() {
    return _buildStaticPage('Privacy Policy', privacyPolicyContent());
  }

  Component _buildTerms() {
    return _buildStaticPage('Terms of Service', termsOfServiceContent());
  }

  Component _buildAbout() {
    return _buildStaticPage('About Us', [
      p([text('CreatorTools.io was built by creators, for creators. Our mission is to democratize access to advanced YouTube analytics and SEO tools, helping channels of all sizes maximize their reach and revenue.')]),
      p(classes: 'mt-4', [text('Whether you are a new vlogger or a seasoned tech reviewer, our suite of tools is designed to save you time and boost your Click-Through Rates (CTR).')]),
    ]);
  }

  Component _buildContact() {
    return _buildStaticPage('Contact Us', [
      p([text('We would love to hear from you! If you have feature requests, bug reports, or business inquiries, please reach out to us.')]),
      div(classes: 'mt-6 p-4 bg-yt-gray-100 dark:bg-yt-gray-800 rounded-lg flex items-center gap-3', [
        span(classes: 'material-symbols-rounded', [text('mail')]),
        a(href: 'mailto:support@creatortools.io', classes: 'font-medium text-yt-red hover:underline', [text('support@creatortools.io')])
      ])
    ]);
  }

  Component _buildStaticPage(String title, List<Component> content) {
    return div(classes: 'max-w-3xl mx-auto px-4 py-12 animate-fade-in-up', [
      h1(classes: 'text-3xl font-bold mb-6 text-yt-gray-900 dark:text-white', [text(title)]),
      div(classes: 'prose dark:prose-invert max-w-none text-yt-gray-600 dark:text-yt-gray-400 space-y-4 leading-relaxed', content)
    ]);
  }
}
