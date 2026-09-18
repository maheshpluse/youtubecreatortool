import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';
import 'data/blog_posts.dart';
import 'data/seo_pages.dart';
import 'data/country_rpm.dart';
import 'data/social_profiles.dart';
import 'pages/legal.dart';
import 'components/adsense_ad.dart';
import 'services/i18n_service.dart';
import 'services/client_interop.dart' as client_interop;
import 'package:jaspr_router/jaspr_router.dart';

class App extends StatefulComponent {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool isDark = true;

  // SEO Analyzer State
  String seoTargetKeyword = '';
  String seoTitle = '';
  String seoDescription = '';
  String seoTags = '';
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

  // Loading & Error States per tab
  Map<String, bool> tabIsLoading = {};
  Map<String, String> tabErrorMessage = {};

  @override
  void initState() {
    super.initState();
    // Let web/consent.js open the Privacy Policy tab from its banner link.
    // The Jaspr app owns routing, so the banner cannot navigate on its own.
    client_interop.setupPrivacyCallback(() => switchTab('privacy'));
  }

  String _getPathForTab(String tab) {
    if (tab == 'seo') return '/youtube-seo-analyzer';
    if (tab == 'titles') return '/youtube-title-generator';
    if (tab == 'thumbnails') return '/youtube-thumbnail-ideas';
    if (tab == 'tags') return '/youtube-tag-extractor';
    if (tab == 'earnings') return '/youtube-earnings-calculator';
    if (tab == 'blog') return '/blog/';
    return '/$tab';
  }

  void switchTab(String tab) {
    if (tab == 'blog') {
      client_interop.navigateTo('/blog/');
      return;
    }
    Router.of(context).push(_getPathForTab(tab));
  }

  void toggleTheme() {
    setState(() => isDark = !isDark);
  }

  /// Reopens the cookie preferences panel owned by web/consent.js.
  /// No-op if that script failed to load, so the footer link can never throw.
  void openConsentPreferences() {
    client_interop.openConsentPreferences();
  }

  /// POSTs [body] to [path] on the API with a fresh reCAPTCHA token and returns
  /// the decoded JSON. Throws on any non-200 so the caller can surface it.
  Future<dynamic> _postJson(String path, Map<String, dynamic> body) async {
    // Belt and braces: if the token bridge ever hangs again rather than
    // throwing, this bounds the wait so the UI reports a failure instead of
    // spinning forever.
    final token = await client_interop.getRecaptchaToken().timeout(
      const Duration(seconds: 20),
      onTimeout: () => throw Exception(
          'Verification timed out. Please check your connection and try again.'),
    );
    final response = await http.post(
      Uri.parse('$apiBaseUrl$path'),
      headers: {
        'Content-Type': 'application/json',
        'X-Recaptcha-Token': token,
      },
      body: jsonEncode(body),
    );
    if (response.statusCode != 200) {
      throw Exception('Request failed (${response.statusCode}). ${response.body}');
    }
    return jsonDecode(response.body);
  }

  /// Wraps a tool request in the loading + error handling for a specific tab.
  Future<void> _run(String tab, Future<void> Function() request) async {
    setState(() {
      tabIsLoading[tab] = true;
      tabErrorMessage.remove(tab);
    });
    try {
      await request();
    } catch (e) {
      setState(() => tabErrorMessage[tab] = e.toString());
    }
    setState(() => tabIsLoading[tab] = false);
  }

  Future<void> calculateSeo() => _run('seo', () async {
        if (seoTargetKeyword.trim().isEmpty || seoTitle.trim().isEmpty || seoDescription.trim().isEmpty) {
          throw Exception('Please fill in all fields: keyword, title, and description.');
        }
        final tagList = seoTags.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
        final data = await _postJson('/api/calculate-seo', {
          'target_keyword': seoTargetKeyword,
          'title': seoTitle,
          'description': seoDescription,
          'tags': tagList,
        });
        setState(() => seoResult = data as Map<String, dynamic>);
      });

  Future<void> generateTitles() => _run('titles', () async {
        if (titleTopic.trim().isEmpty) {
          throw Exception('Please enter a topic for title generation.');
        }
        final data = await _postJson('/api/generate-titles', {
          'topic': titleTopic,
          'lang': I18nService().currentLanguage,
        });
        setState(() => generatedTitles = data['titles'] as List<dynamic>);
      });

  Future<void> generateThumbnails() => _run('thumbnails', () async {
        if (thumbnailTopic.trim().isEmpty) {
          throw Exception('Please enter a topic for thumbnail ideas.');
        }
        final data = await _postJson('/api/generate-thumbnails', {
          'topic': thumbnailTopic,
          'lang': I18nService().currentLanguage,
        });
        setState(() => generatedThumbnails = data['thumbnails'] as List<dynamic>);
      });

  Future<void> extractTags() => _run('tags', () async {
        if (tagUrl.trim().isEmpty) {
          throw Exception('Please enter a URL or topic to extract tags.');
        }
        final data = await _postJson('/api/extract-tags', {'url': tagUrl});
        setState(() => extractedTags = data['tags'] as List<dynamic>);
      });

  Future<void> calculateEarnings() => _run('earnings', () async {
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
    return Router(
      routes: [
        ShellRoute(
          builder: (context, state, child) {
            // ShellRoute has no path of its own, so RouteState.path is '' here
            // (empty, not null) — reading it blanked activeTab and hid every
            // per-tool article. location carries the real URI.
            String activeTab = _getTabFromPath(Uri.parse(state.location).path);
            // The page was built entirely from <div>. That cost the landmark
            // regions screen readers navigate by, and left answer engines with
            // no structural cue about which part of the page is the content.
            return div(classes: 'min-h-screen font-sans transition-colors duration-300', [
              _buildSeoHead(activeTab),
              _buildSkipLink(),
              _buildNavbar(),
              Component.element(tag: 'main', attributes: const {'id': 'main-content'}, children: [
                _buildHero(),
                div(classes: 'max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 pb-32 md:pb-16', [
                  _buildDesktopTabs(activeTab),
                  if (tabErrorMessage[activeTab] != null) _buildErrorBanner(activeTab, tabErrorMessage[activeTab]!),
                  _buildDefinition(activeTab),
                  div(classes: 'animate-fade-in-up animate-delay-100', [
                    child,
                  ]),
                  _buildSeoArticle(activeTab),
                  _buildPageContent(activeTab),
                ]),
              ]),
              _buildFooter(),
              _buildMobileNav(activeTab),
            ]);
          },
          routes: [
            Route(path: '/', builder: (context, state) => _buildHomeHub()),
            Route(path: '/youtube-seo-analyzer', builder: (context, state) => _buildSeoAnalyzer()),
            Route(path: '/youtube-title-generator', builder: (context, state) => _buildTitleGenerator()),
            Route(path: '/youtube-thumbnail-ideas', builder: (context, state) => _buildThumbnailGenerator()),
            Route(path: '/youtube-tag-extractor', builder: (context, state) => _buildTagExtractor()),
            Route(path: '/youtube-earnings-calculator', builder: (context, state) => _buildEarningsCalculator()),
            Route(path: '/youtube-rpm-by-country', builder: (context, state) => _buildRpmByCountry()),
            Route(path: '/privacy', builder: (context, state) => _buildPrivacyPolicy()),
            Route(path: '/terms', builder: (context, state) => _buildTerms()),
            Route(path: '/vidiq-alternative-free', builder: (context, state) => _buildComparisonPage('vidiq-alternative-free')),
            Route(path: '/about', builder: (context, state) => _buildAbout()),
            Route(path: '/contact', builder: (context, state) => _buildContact()),
            Route(path: '/youtube-description-generator', builder: (context, state) => _buildDescriptionGenerator()),
            Route(path: '/youtube-hashtag-generator', builder: (context, state) => _buildHashtagGenerator()),
            Route(path: '/youtube-channel-name-generator', builder: (context, state) => _buildChannelNameGenerator()),
            Route(path: '/youtube-video-ideas', builder: (context, state) => _buildVideoIdeasGenerator()),
            Route(path: '/youtube-script-generator', builder: (context, state) => _buildScriptGenerator()),
            Route(path: '/tubebuddy-alternative', builder: (context, state) => _buildComparisonPage('tubebuddy-alternative')),
            Route(path: '/youtube-keyword-tool', builder: (context, state) => _buildKeywordTool()),
            Route(path: '/vidiq-vs-tubebuddy', builder: (context, state) => _buildComparisonPage('vidiq-vs-tubebuddy')),
          ]
        )
      ]
    );
  }

  String _getTabFromPath(String rawPath) {
    // Normalise '' and '/foo/' so the static build and the client router
    // resolve to the same tab.
    String path = rawPath.isEmpty ? '/' : rawPath;
    if (path.length > 1 && path.endsWith('/')) path = path.substring(0, path.length - 1);
    if (path == '/youtube-seo-analyzer') return 'seo';
    if (path == '/') return 'home';
    if (path == '/youtube-title-generator') return 'titles';
    if (path == '/youtube-thumbnail-ideas') return 'thumbnails';
    if (path == '/youtube-tag-extractor') return 'tags';
    if (path == '/youtube-earnings-calculator') return 'earnings';
    if (path.startsWith('/')) return path.substring(1);
    return path;
  }

  /// Lets keyboard users jump past the nav straight to the content.
  ///
  /// Off-screen until focused, which is the standard pattern — it must stay in
  /// the DOM (not display:none) or it cannot receive focus at all.
  Component _buildSkipLink() {
    return a(
      href: '#main-content',
      classes: 'sr-only focus:not-sr-only focus:absolute focus:z-[100] focus:top-2 focus:left-2 '
          'focus:px-4 focus:py-2 focus:rounded-lg focus:bg-yt-gray-900 focus:text-white',
      [Component.text('Skip to content')],
    );
  }

  // ═══════════════════════════════════════════
  //  NAVBAR
  // ═══════════════════════════════════════════
  Component _buildNavbar() {
    return header(classes: 'glass fixed top-0 left-0 right-0 z-50 animate-slide-in-top animate-duration-500', [
      div(classes: 'max-w-6xl mx-auto px-4 sm:px-6 lg:px-8', [
        div(classes: 'flex items-center justify-between h-14', [
          // Logo
          div(classes: 'flex items-center gap-2 cursor-pointer', [
            _buildLogoIcon('w-8 h-8'),
            span(classes: 'text-xl font-bold tracking-tighter', [Component.text(t('nav_logo_text'))]),
          ]),
          // Right Actions
          div(classes: 'flex items-center gap-3', [
            div(classes: 'relative flex items-center bg-gray-100 dark:bg-gray-800 rounded-lg px-2 py-1', [
              span(classes: 'material-symbols-rounded text-lg mr-1 text-gray-600 dark:text-gray-400', attributes: const {'aria-hidden': 'true'}, [Component.text('language')]),
              select(
                classes: 'bg-transparent text-sm font-medium text-gray-700 dark:text-gray-300 focus:outline-none cursor-pointer outline-none border-none',
                attributes: const {'id': 'language-select', 'name': 'language-select', 'aria-label': 'Language'},
                onChange: (values) {
                  // jaspr's <select> onChange reports the selected values as a
                  // List<String> (to support multi-select); this control only
                  // ever has one selected, so take the first.
                  if (values.isEmpty) return;
                  I18nService().setLanguage(values.first).then((_) {
                    setState(() {});
                  });
                },
                [
                  // Server-render only the selected language. The full list is
                  // 71 <option> elements — about 100 words of language names
                  // ahead of any real content on every page, and the first
                  // thing an answer engine reads top-down. The client bundle
                  // renders the complete list, so the picker is unchanged for
                  // anyone actually using it.
                  if (kIsWeb)
                    for (var lang in kSupportedLanguages)
                      option(
                        value: lang.code,
                        attributes: I18nService().currentLanguage == lang.code ? {'selected': 'true'} : {},
                        [Component.text(lang.nativeName)]
                      )
                  else
                    option(
                      value: I18nService().currentOption.code,
                      attributes: const {'selected': 'true'},
                      [Component.text(I18nService().currentOption.nativeName)]
                    ),
                ]
              ),
            ]),
            button(
              classes: 'theme-toggle',
              attributes: {'data-theme-toggle': 'true', 'aria-label': 'Toggle dark mode'},
              onClick: () => toggleTheme(),
              [span(classes: 'material-symbols-rounded text-2xl', [Component.text(isDark ? 'light_mode' : 'dark_mode')])]
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
          Component.text(t('hero_grow_channel')),
          span(classes: 'text-yt-red', [Component.text(t('nav_logo_text'))])
        ]),
        p(classes: 'mt-4 text-yt-gray-600 dark:text-yt-gray-400 text-base max-w-xl mx-auto leading-relaxed animate-fade-in-up animate-delay-400', [
          Component.text(t('hero_description'))
        ]),
      ])
    ]);
  }

  // ═══════════════════════════════════════════
  //  DESKTOP TABS
  // ═══════════════════════════════════════════
  Component _buildDesktopTabs(String activeTab) {
    return nav(
        classes: 'hidden md:flex items-center gap-3 mb-8 animate-fade-in-up animate-delay-500 overflow-x-auto pb-2',
        attributes: const {'aria-label': 'Tools'},
        [
      _buildTabChip(t('tab_seo'), 'seo', activeTab),
      _buildTabChip(t('tab_titles'), 'titles', activeTab),
      _buildTabChip(t('tab_thumbnails'), 'thumbnails', activeTab),
      _buildTabChip(t('tab_tags'), 'tags', activeTab),
      _buildTabChip(t('tab_earnings'), 'earnings', activeTab),
      _buildTabChip(t('tab_blog'), 'blog', activeTab),
    ]);
  }

  /// Inline banner for a failed request, dismissible so it never blocks the UI.
  Component _buildErrorBanner(String tab, String message) {
    return div(
      classes: 'mb-6 flex items-start gap-3 rounded-lg border border-yt-red/30 '
          'bg-yt-red/10 p-4 animate-fade-in-up',
      [
        span(classes: 'material-symbols-rounded text-yt-red text-xl', [Component.text('error')]),
        div(classes: 'flex-1', [
          p(classes: 'text-sm font-medium text-yt-red', [Component.text(t('error_title'))]),
          p(classes: 'mt-1 text-xs text-yt-gray-600 dark:text-yt-gray-400 break-words',
              [Component.text(message)]),
        ]),
        button(
          classes: 'material-symbols-rounded text-yt-gray-500 hover:text-yt-gray-900 '
              'dark:hover:text-white text-lg',
          attributes: {'aria-label': 'Dismiss error'},
          onClick: () => setState(() => tabErrorMessage.remove(tab)),
          [Component.text('close')],
        ),
      ],
    );
  }

  Component _buildTabChip(String label, String id, String activeTab) {
    bool isActive = activeTab == id;
    final classes = 'px-4 py-1.5 text-sm font-medium rounded-lg transition-colors whitespace-nowrap ${isActive
            ? 'bg-yt-gray-900 text-white dark:bg-white dark:text-yt-gray-900'
            : 'bg-yt-gray-100 text-yt-gray-900 dark:bg-yt-gray-800 dark:text-white hover:bg-yt-gray-200 dark:hover:bg-yt-gray-700'}';
    
    if (id == 'blog') {
      return a(
        href: '/blog/', 
        classes: classes, 
        events: {'click': (e) { e.preventDefault(); client_interop.navigateTo('/blog/'); }},
        [Component.text(label)]
      );
    }
    
    return Link(
      to: _getPathForTab(id),
      classes: classes,
      child: Component.text(label),
    );
  }

  // ═══════════════════════════════════════════
  //  MOBILE BOTTOM NAV
  // ═══════════════════════════════════════════
  Component _buildMobileNav(String activeTab) {
    return nav(classes: 'mobile-nav md:hidden', attributes: const {'aria-label': 'Primary'}, [
      div(classes: 'flex items-center justify-around px-2', [
        _mobileNavItem('search', t('mobile_seo'), 'seo', activeTab),
        _mobileNavItem('title', t('mobile_titles'), 'titles', activeTab),
        _mobileNavItem('image', t('mobile_thumb'), 'thumbnails', activeTab),
        _mobileNavItem('sell', t('mobile_tags'), 'tags', activeTab),
        _mobileNavItem('payments', t('mobile_earn'), 'earnings', activeTab),
        _mobileNavItem('article', t('mobile_blog'), 'blog', activeTab),
      ])
    ]);
  }

  Component _mobileNavItem(String icon, String label, String tab, String activeTab) {
    bool isActive = activeTab == tab;
    
    final child = div(classes: 'flex flex-col items-center gap-1', [
      span(classes: 'material-symbols-rounded text-2xl ${isActive ? 'filled' : ''}', [Component.text(icon)]),
      span(classes: 'text-[10px] font-medium', [Component.text(label)]),
    ]);
    final classes = 'flex flex-col items-center gap-1 py-1 px-3 transition-all duration-300 ${isActive ? 'text-yt-gray-900 dark:text-white' : 'text-yt-gray-600 dark:text-yt-gray-400'}';

    if (tab == 'blog') {
      return a(
        href: '/blog/',
        classes: classes,
        events: {'click': (e) { e.preventDefault(); client_interop.navigateTo('/blog/'); }},
        [child],
      );
    }

    return Link(
      to: _getPathForTab(tab),
      classes: classes,
      child: child,
    );
  }

  // ═══════════════════════════════════════════
  //  SEO ANALYZER
  // ═══════════════════════════════════════════

  Component _buildHomeHub() {
    final seo = kPageSeo['home'];
    return div(classes: 'max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-12', [
      if (seo != null)
        div(classes: 'mb-12 text-center max-w-3xl mx-auto', [
          p(classes: 'text-xl text-yt-gray-600 dark:text-yt-gray-300', [Component.text(seo.definition)]),
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
        _buildToolCard(
            title: 'YouTube Description Generator',
            description: 'Automatically write SEO-optimized YouTube descriptions with timestamps, social links, and targeted keywords.',
            icon: 'description',
            link: '/youtube-description-generator'),
        _buildToolCard(
            title: 'YouTube Hashtag Generator',
            description: 'Find the most relevant and trending hashtags for your YouTube video to maximize reach and discoverability.',
            icon: 'tag',
            link: '/youtube-hashtag-generator'),
        _buildToolCard(
            title: 'Channel Name Generator',
            description: 'Generate catchy, memorable YouTube channel names tailored to your specific niche and target audience.',
            icon: 'badge',
            link: '/youtube-channel-name-generator'),
        _buildToolCard(
            title: 'YouTube Video Ideas',
            description: 'Overcome creator block with AI-generated video concepts, including hook ideas, formats, and target demographics.',
            icon: 'lightbulb',
            link: '/youtube-video-ideas'),
        _buildToolCard(
            title: 'YouTube Script Generator',
            description: 'Draft complete, engaging YouTube scripts from a simple prompt. Includes hooks, main points, and calls to action.',
            icon: 'draw',
            link: '/youtube-script-generator'),
        _buildToolCard(
            title: 'YouTube Keyword Tool',
            description: 'Discover high-volume, low-competition keywords for your YouTube channel to rank higher in search results.',
            icon: 'manage_search',
            link: '/youtube-keyword-tool'),
      ])
    ]);
  }

  Component _buildToolCard({required String title, required String description, required String icon, required String link}) {
    return a(
      href: link,
      classes: 'block p-6 bg-white dark:bg-yt-gray-800 rounded-2xl shadow-sm hover:shadow-md transition-shadow border border-yt-gray-200 dark:border-yt-gray-700',
      [
        div(classes: 'flex items-center mb-4', [
          div(classes: 'w-12 h-12 bg-red-100 dark:bg-red-900/30 text-red-600 dark:text-red-500 rounded-xl flex items-center justify-center mr-4', [
            span(classes: 'material-symbols-outlined', attributes: {'aria-hidden': 'true'}, [Component.text(icon)]),
          ]),
          h3(classes: 'text-lg font-bold text-yt-gray-900 dark:text-white', [Component.text(title)]),
        ]),
        p(classes: 'text-yt-gray-600 dark:text-yt-gray-400', [Component.text(description)]),
      ]
    );
  }

  Component _buildSeoAnalyzer() {
    return div(classes: 'grid grid-cols-1 lg:grid-cols-3 gap-6', [
      div(classes: 'lg:col-span-2 space-y-4 animate-fade-in-left animate-delay-100', [
        div(classes: 'flex items-center gap-2 mb-4', [
          span(classes: 'material-symbols-rounded text-2xl', [Component.text('analytics')]),
          h2(classes: 'text-xl font-bold', [Component.text(t('tab_seo'))]),
        ]),
        div([
          input(
            classes: 'input-field',
            attributes: {'id': 'seo-target-keyword', 'name': 'seo-target-keyword', 'placeholder': t('seo_placeholder_keyword'), 'aria-label': t('seo_placeholder_keyword'), 'value': seoTargetKeyword},
            onInput: (e) => setState(() => seoTargetKeyword = e.toString()),
          ),
        ]),
        div([
          input(
            classes: 'input-field',
            attributes: {'id': 'seo-title', 'name': 'seo-title', 'placeholder': t('seo_placeholder_title'), 'aria-label': t('seo_placeholder_title'), 'value': seoTitle},
            onInput: (e) => setState(() => seoTitle = e.toString()),
          ),
        ]),
        div([
          textarea(
            classes: 'input-field resize-none',
            attributes: {'id': 'seo-description', 'name': 'seo-description', 'placeholder': t('seo_placeholder_desc'), 'aria-label': t('seo_placeholder_desc'), 'rows': '5', 'value': seoDescription},
            onInput: (e) => setState(() => seoDescription = e.toString()),
            [],
          ),
        ]),
        div([
          input(
            classes: 'input-field',
            attributes: {'id': 'seo-tags', 'name': 'seo-tags', 'placeholder': t('seo_placeholder_tags'), 'aria-label': t('seo_placeholder_tags'), 'value': seoTags},
            onInput: (e) => setState(() => seoTags = e.toString()),
          ),
        ]),
        div(classes: 'flex justify-end', [
          button(
            classes: 'btn-primary font-medium px-6 py-2 text-sm flex items-center justify-center gap-2 w-full md:w-auto pr-10 ${(tabIsLoading['seo'] ?? false) ? 'btn-loading' : ''}',
            onClick: () => calculateSeo(),
            [
              Component.text((tabIsLoading['seo'] ?? false) ? t('btn_analyzing') : t('btn_analyze')),
            ]
          ),
        ])
      ]),
      div(classes: 'card p-6 flex flex-col items-center justify-center min-h-[300px] animate-fade-in-right animate-delay-200', [
        if (tabIsLoading['seo'] ?? false) ...[
          // SEO Analysis loading — progress steps + skeleton
          div(classes: 'w-full space-y-5 animate-fade-in', [
            div(classes: 'flex items-center gap-3', [
              div(classes: 'loading-spinner', []),
              p(classes: 'text-sm font-medium text-yt-gray-600 dark:text-yt-gray-400', [Component.text(t('btn_analyzing'))]),
            ]),
            div(classes: 'progress-step-bar', []),
            div(classes: 'space-y-3 mt-4', [
              for (var w in [100, 85, 70, 90, 60])
                div(classes: 'flex items-center gap-3', [
                  div(classes: 'skeleton w-5 h-5 rounded-full shrink-0', []),
                  div(classes: 'skeleton h-4 flex-1', attributes: {'style': 'max-width: $w%'}, []),
                ]),
            ]),
          ]),
        ] else if (seoResult != null) ...[
          div(classes: 'score-ring score-ring-animate mb-6', [
            div(classes: 'text-center', [
              span(classes: 'text-4xl font-bold ${(seoResult!['score'] as int) > 75 ? 'text-[#2BA640]' : 'text-yt-red'}', [
                Component.text(seoResult!['score'].toString())
              ]),
              p(classes: 'text-sm font-medium text-yt-gray-500 mt-1', [Component.text(t('seo_score_label'))])
            ])
          ]),
          div(classes: 'w-full space-y-2', [
            for (var i = 0; i < (seoResult!['feedback'] as List).length; i++)
              div(classes: 'card-stagger', attributes: {'style': 'animation-delay: ${i * 80}ms'}, [
                _buildSeoFeedbackRow(seoResult!['feedback'][i] as Map<String, dynamic>)
              ])
          ]),
        ] else ...[
          span(classes: 'material-symbols-rounded text-5xl text-yt-gray-300 dark:text-yt-gray-700 mb-4', [Component.text('troubleshoot')]),
          p(classes: 'text-yt-gray-500 text-sm font-medium text-center', [Component.text(t('seo_empty_state'))]),
        ]
      ])
    ]);
  }

  /// Renders one backend feedback entry. The backend sends a translation `key`
  /// (+ `params`) rather than pre-formatted English text, so this row reads
  /// correctly no matter which language is selected.
  Component _buildSeoFeedbackRow(Map<String, dynamic> fb) {
    final isPass = fb['status'] == 'pass';
    final params = (fb['params'] as Map?)?.map((k, v) => MapEntry(k.toString(), v.toString()));
    return div(classes: 'flex items-start gap-2', [
      span(classes: 'material-symbols-rounded text-sm mt-0.5 ${isPass ? 'text-[#2BA640]' : 'text-yt-red'}',
          [Component.text(isPass ? 'check_circle' : 'cancel')]),
      span(classes: 'text-sm text-yt-gray-700 dark:text-yt-gray-300',
          [Component.text(t(fb['key'].toString(), params))])
    ]);
  }

  // ═══════════════════════════════════════════
  //  TITLE GENERATOR
  // ═══════════════════════════════════════════
  Component _buildTitleGenerator() {
    return div(classes: 'space-y-6 max-w-4xl', [
      div(classes: 'animate-fade-in-up animate-delay-100', [
        div(classes: 'flex items-center gap-2 mb-4', [
          span(classes: 'material-symbols-rounded text-2xl', [Component.text('title')]),
          h2(classes: 'text-xl font-bold', [Component.text(t('title_gen_title'))]),
        ]),
        div(classes: 'flex flex-col sm:flex-row gap-3', [
          div(classes: 'flex-1', [
            input(
              classes: 'input-field',
              attributes: {'id': 'title-topic', 'name': 'title-topic', 'placeholder': t('title_gen_placeholder'), 'aria-label': t('title_gen_placeholder'), 'value': titleTopic},
              onInput: (e) => setState(() => titleTopic = e.toString()),
            ),
          ]),
          button(
            classes: 'btn-primary font-medium px-6 py-2 text-sm flex items-center justify-center whitespace-nowrap pr-10 ${(tabIsLoading['titles'] ?? false) ? 'btn-loading' : ''}',
            onClick: () => generateTitles(),
            [Component.text((tabIsLoading['titles'] ?? false) ? t('btn_working') : t('btn_generate'))]
          ),
        ]),
      ]),
      // Title loading skeleton
      if (tabIsLoading['titles'] ?? false) div(classes: 'grid grid-cols-1 md:grid-cols-2 gap-4 animate-fade-in', [
        for (var i = 0; i < 5; i++)
          div(classes: 'card p-4', [
            div(classes: 'flex gap-3', [
              div(classes: 'skeleton w-6 h-6 rounded-full shrink-0', []),
              div(classes: 'flex-1 space-y-2', [
                div(classes: 'skeleton h-4 w-full', []),
                div(classes: 'skeleton h-3', attributes: {'style': 'width: 30%'}, []),
              ]),
            ]),
          ]),
        div(classes: 'md:col-span-2 flex items-center justify-center gap-2 py-2', [
          div(classes: 'typing-dots', [span([]), span([]), span([])]),
          p(classes: 'text-sm text-yt-gray-500 ml-2', [Component.text(t('btn_working'))]),
        ]),
      ]),
      if (generatedTitles != null && !(tabIsLoading['titles'] ?? false)) div(classes: 'grid grid-cols-1 md:grid-cols-2 gap-4', [
        for (var i = 0; i < generatedTitles!.length; i++)
          div(classes: 'card p-4 hover:bg-yt-gray-50 dark:hover:bg-yt-gray-800 cursor-pointer card-stagger', attributes: {'style': 'animation-delay: ${i * 100}ms'}, [
            div(classes: 'flex gap-3', [
              span(classes: 'text-sm font-medium text-yt-gray-500 mt-0.5', [
                Component.text('${i + 1}.')
              ]),
              div(classes: 'flex-1', [
                p(classes: 'font-medium text-sm text-yt-gray-900 dark:text-white', [
                  Component.text(generatedTitles![i]['title'].toString())
                ]),
                div(classes: 'flex items-center gap-2 mt-2', [
                  span(classes: 'text-xs text-[#2BA640] font-medium', [
                    Component.text('CTR: ${generatedTitles![i]['ctr_score']}%')
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
          span(classes: 'material-symbols-rounded text-2xl', [Component.text('image')]),
          h2(classes: 'text-xl font-bold', [Component.text(t('thumb_gen_title'))]),
        ]),
        div(classes: 'flex flex-col sm:flex-row gap-3', [
          div(classes: 'flex-1', [
            input(
              classes: 'input-field',
              attributes: {'id': 'thumbnail-topic', 'name': 'thumbnail-topic', 'placeholder': t('thumb_gen_placeholder'), 'aria-label': t('thumb_gen_placeholder'), 'value': thumbnailTopic},
              onInput: (e) => setState(() => thumbnailTopic = e.toString()),
            ),
          ]),
          button(
            classes: 'btn-primary font-medium px-6 py-2 text-sm flex items-center justify-center whitespace-nowrap pr-10 ${(tabIsLoading['thumbnails'] ?? false) ? 'btn-loading' : ''}',
            onClick: () => generateThumbnails(),
            [Component.text((tabIsLoading['thumbnails'] ?? false) ? t('btn_working') : t('btn_generate'))]
          ),
        ]),
      ]),
      // Thumbnail loading skeleton
      if (tabIsLoading['thumbnails'] ?? false) div(classes: 'space-y-4 animate-fade-in', [
        for (var i = 0; i < 3; i++)
          div(classes: 'card p-5', [
            div(classes: 'flex items-start gap-3', [
              div(classes: 'skeleton w-8 h-8 rounded-full shrink-0', []),
              div(classes: 'flex-1 space-y-3', [
                div(classes: 'skeleton h-5', attributes: {'style': 'width: 40%'}, []),
                div(classes: 'skeleton h-4 w-full', []),
                div(classes: 'skeleton h-4', attributes: {'style': 'width: 75%'}, []),
                div(classes: 'skeleton h-12 w-full rounded', []),
              ]),
            ]),
          ]),
        div(classes: 'flex items-center justify-center gap-2 py-2', [
          div(classes: 'typing-dots', [span([]), span([]), span([])]),
          p(classes: 'text-sm text-yt-gray-500 ml-2', [Component.text(t('btn_working'))]),
        ]),
      ]),
      if (generatedThumbnails != null && !(tabIsLoading['thumbnails'] ?? false)) div(classes: 'space-y-4', [
        for (var i = 0; i < generatedThumbnails!.length; i++)
          div(classes: 'card p-5 hover:bg-yt-gray-50 dark:hover:bg-yt-gray-800 transition-colors card-stagger', attributes: {'style': 'animation-delay: ${i * 120}ms'}, [
            div(classes: 'flex items-start gap-3', [
              span(classes: 'flex items-center justify-center w-8 h-8 rounded-full bg-yt-gray-100 dark:bg-yt-gray-700 font-bold text-yt-red shrink-0 mt-1', [
                Component.text((i + 1).toString())
              ]),
              div(classes: 'flex-1', [
                h3(classes: 'font-bold text-lg text-yt-gray-900 dark:text-white mb-2', [
                  Component.text(generatedThumbnails![i]['concept_name'].toString())
                ]),
                div(classes: 'mb-3', [
                  span(classes: 'text-xs font-bold text-yt-gray-500 uppercase tracking-wider', [Component.text(t('thumb_visual_concept'))]),
                  p(classes: 'text-sm text-yt-gray-600 dark:text-yt-gray-400 mt-1', [
                    Component.text(generatedThumbnails![i]['visual_description'].toString())
                  ]),
                ]),
                div(classes: 'bg-yt-gray-100 dark:bg-yt-gray-900 rounded p-3 border border-yt-gray-200 dark:border-yt-gray-700', [
                  span(classes: 'text-xs font-bold text-yt-gray-500 uppercase tracking-wider', [Component.text(t('thumb_text_on_screen'))]),
                  p(classes: 'text-sm font-bold text-yt-gray-900 dark:text-white mt-1 text-xl italic', [
                    Component.text('"${generatedThumbnails![i]['text_on_screen']}"')
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
          span(classes: 'material-symbols-rounded text-2xl', [Component.text('sell')]),
          h2(classes: 'text-xl font-bold', [Component.text(t('tag_ext_title'))]),
        ]),
        div(classes: 'flex flex-col sm:flex-row gap-3', [
          div(classes: 'flex-1', [
            input(
              classes: 'input-field',
              attributes: {
                'id': 'tag-url', 'name': 'tag-url',
                'placeholder': t('tag_ext_placeholder'), 'aria-label': t('tag_ext_placeholder'),
                'value': tagUrl
              },
              onInput: (e) => setState(() => tagUrl = e.toString()),
            ),
          ]),
          button(
            classes: 'btn-primary font-medium px-6 py-2 text-sm flex items-center justify-center whitespace-nowrap pr-10 ${(tabIsLoading['tags'] ?? false) ? 'btn-loading' : ''}',
            onClick: () => extractTags(),
            [Component.text((tabIsLoading['tags'] ?? false) ? t('btn_extracting') : t('btn_extract'))]
          ),
        ]),
      ]),
      // Tag extraction loading skeleton
      if (tabIsLoading['tags'] ?? false) div(classes: 'card p-6 animate-fade-in', [
        div(classes: 'flex items-center gap-3 mb-4', [
          div(classes: 'loading-spinner', attributes: {'style': 'width:24px;height:24px;border-width:2px'}, []),
          p(classes: 'text-sm text-yt-gray-500', [Component.text(t('btn_extracting'))]),
        ]),
        div(classes: 'flex flex-wrap gap-2', [
          for (var w in [80, 100, 60, 90, 70, 110, 75, 95, 65, 85])
            div(classes: 'tag-skeleton skeleton', attributes: {'style': 'width: ${w}px'}, []),
        ]),
      ]),
      if (extractedTags != null && !(tabIsLoading['tags'] ?? false)) div(classes: 'card p-6 animate-fade-in', [
        div(classes: 'flex items-center gap-2 mb-4', [
          span(classes: 'text-sm font-medium text-yt-gray-600 dark:text-yt-gray-400', [
            Component.text(t('tag_ext_result', {'count': extractedTags!.length.toString()}))
          ])
        ]),
        div(classes: 'flex flex-wrap gap-2', [
          for (var i = 0; i < extractedTags!.length; i++)
            span(classes: 'bg-yt-gray-100 dark:bg-yt-gray-800 text-yt-gray-900 dark:text-white px-3 py-1.5 rounded-full text-sm hover:bg-yt-gray-200 dark:hover:bg-yt-gray-700 cursor-pointer transition-colors card-stagger', attributes: {'style': 'animation-delay: ${i * 50}ms'}, [
              Component.text(extractedTags![i].toString())
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
          span(classes: 'material-symbols-rounded text-2xl', [Component.text('payments')]),
          h2(classes: 'text-xl font-bold', [Component.text(t('earn_calc_title'))]),
        ]),
        div(classes: 'card p-6 space-y-6', [
          div([
            div(classes: 'flex items-center justify-between mb-2', [
              label(classes: 'text-sm font-medium text-yt-gray-900 dark:text-white', [Component.text(t('earn_daily_views'))]),
              span(classes: 'text-sm font-bold', [Component.text(dailyViews.toString())]),
            ]),
            input(
              classes: 'w-full h-1 rounded-full appearance-none cursor-pointer bg-yt-gray-200 dark:bg-yt-gray-700 accent-yt-red',
              attributes: {'id': 'daily-views', 'name': 'daily-views', 'type': 'range', 'min': '1000', 'max': '100000', 'step': '1000', 'aria-label': t('earn_daily_views'), 'value': dailyViews.toString()},
              onChange: (e) => setState(() => dailyViews = int.parse(e.toString())),
            ),
          ]),
          div([
            label(classes: 'block text-sm font-medium text-yt-gray-900 dark:text-white mb-3', [Component.text(t('earn_niche'))]),
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
              classes: 'btn-primary font-medium px-6 py-2 text-sm flex items-center justify-center gap-2 w-full sm:w-auto pr-10 ${(tabIsLoading['earnings'] ?? false) ? 'btn-loading' : ''}',
              onClick: () => calculateEarnings(),
              [Component.text((tabIsLoading['earnings'] ?? false) ? t('btn_calculating') : t('btn_calculate'))]
            ),
          ])
        ]),
      ]),
      div(classes: 'card p-6 flex flex-col items-center justify-center min-h-[300px] animate-fade-in-right animate-delay-200', [
        if (tabIsLoading['earnings'] ?? false) ...[
          div(classes: 'flex flex-col items-center gap-4 animate-fade-in', [
            div(classes: 'loading-spinner', []),
            p(classes: 'text-sm text-yt-gray-500 font-medium', [Component.text(t('btn_calculating'))]),
            div(classes: 'w-3/4 progress-step-bar', []),
          ])
        ] else if (earningsResult != null) ...[
          div(classes: 'text-center animate-bounce-in', [
            span(classes: 'text-sm text-yt-gray-500 font-medium mb-1', [Component.text(t('earn_monthly_rev'))]),
            p(classes: 'text-4xl font-bold text-yt-gray-900 dark:text-white mt-2', [
              Component.text('\$${earningsResult!['min_monthly']} - \$${earningsResult!['max_monthly']}')
            ]),
            p(classes: 'text-xs text-yt-gray-500 mt-4', [Component.text(t('earn_disclaimer'))]),
          ])
        ] else ...[
          span(classes: 'material-symbols-rounded text-5xl text-yt-gray-300 dark:text-yt-gray-700 mb-4', [Component.text('monetization_on')]),
          p(classes: 'text-yt-gray-500 text-sm font-medium text-center', [Component.text(t('earn_empty_state'))]),
        ],
        div(classes: 'mt-6 pt-4 border-t border-yt-gray-200 dark:border-yt-gray-800 w-full text-center', [
          a(
            href: '/youtube-rpm-by-country',
            classes: 'text-sm font-medium text-yt-blue-dark dark:text-yt-blue-light hover:underline',
            [Component.text('See typical RPM by country: US, UK, Canada & Europe')],
          ),
        ]),
      ])
    ]);
  }

  Component _nicheButton(String label, String value) {
    bool isActive = selectedNiche == value;
    return button(
      classes: 'px-3 py-2 rounded-lg text-sm font-medium transition-all duration-200 ${isActive
              ? 'bg-yt-gray-900 text-white dark:bg-white dark:text-yt-gray-900'
              : 'bg-yt-gray-100 text-yt-gray-900 dark:bg-yt-gray-800 dark:text-white hover:bg-yt-gray-200 dark:hover:bg-yt-gray-700'}',
      onClick: () => setState(() => selectedNiche = value),
      [
        Component.text(label),
      ]
    );
  }

  // ═══════════════════════════════════════════
  //  BLOG SECTION
  // ═══════════════════════════════════════════
  // ═══════════════════════════════════════════
  //  RPM BY COUNTRY
  // ═══════════════════════════════════════════

  /// Reference table of typical RPM per market.
  ///
  /// A real <table> rather than a grid of divs: the rows are tabular data, and
  /// search engines extract them far more reliably this way.
  Component _buildRpmByCountry() {
    return div(classes: 'space-y-6', [
      div(classes: 'flex items-center gap-2 mb-4', [
        span(classes: 'material-symbols-rounded text-2xl', [Component.text('public')]),
        h2(classes: 'text-xl font-bold', [Component.text('YouTube RPM by country')]),
      ]),
      p(classes: 'text-sm text-yt-gray-600 dark:text-yt-gray-400 max-w-3xl', [
        Component.text(
            'Typical revenue per 1,000 views across the markets that pay the most. These are commonly '
            'reported ranges across all niches, not a measurement of any one channel - finance and '
            'business sit at the top of every range below, entertainment and vlogs at the bottom.')
      ]),
      // Wide tables must scroll inside their own container rather than pushing
      // the page sideways on mobile.
      div(classes: 'overflow-x-auto -mx-4 px-4', [
        table(classes: 'w-full min-w-[640px] text-sm border-collapse', [
          thead([
            tr(classes: 'border-b border-yt-gray-300 dark:border-yt-gray-700', [
              th(classes: 'text-left py-3 pr-4 font-semibold', scope: 'col', [Component.text('Country')]),
              th(classes: 'text-left py-3 pr-4 font-semibold', scope: 'col', [Component.text('Currency')]),
              th(classes: 'text-left py-3 pr-4 font-semibold', scope: 'col', [Component.text('Typical RPM (USD)')]),
              th(classes: 'text-left py-3 font-semibold', scope: 'col', [Component.text('Notes')]),
            ])
          ]),
          tbody([
            for (final c in kCountryRpm)
              tr(classes: 'border-b border-yt-gray-200 dark:border-yt-gray-800 align-top', [
                th(classes: 'text-left py-3 pr-4 font-medium text-yt-gray-900 dark:text-white whitespace-nowrap',
                    scope: 'row', [Component.text(c.country)]),
                td(classes: 'py-3 pr-4 text-yt-gray-600 dark:text-yt-gray-400', [Component.text(c.currency)]),
                td(classes: 'py-3 pr-4 font-medium text-yt-gray-900 dark:text-white whitespace-nowrap', [
                  Component.text('\$${c.minRpm.toStringAsFixed(2)} - \$${c.maxRpm.toStringAsFixed(2)}')
                ]),
                td(classes: 'py-3 text-yt-gray-600 dark:text-yt-gray-400', [Component.text(c.note)]),
              ])
          ])
        ])
      ]),
      p(classes: 'text-xs text-yt-gray-500', [Component.text(kTierOneShareNote)]),
      p(classes: 'text-sm', [
        a(
          href: '/youtube-earnings-calculator',
          classes: 'font-medium text-yt-blue-dark dark:text-yt-blue-light hover:underline',
          [Component.text('Estimate your own earnings with the YouTube earnings calculator')],
        ),
      ]),
      AdSenseAd(slotId: '1234567890'),
    ]);
  }

  // ═══════════════════════════════════════════
  //  SEO ARTICLE
  // ═══════════════════════════════════════════
  // ═══════════════════════════════════════════
  //  PER-ROUTE <head>
  // ═══════════════════════════════════════════

  Component _jsonLd(Map<String, Object?> data) => script(
        content: jsonEncode(data),
        attributes: {'type': 'application/ld+json'},
      );

  /// Emits the title, description, canonical and social tags for the current
  /// route.
  ///
  /// web/index.template.html deliberately omits these: the static build renders
  /// one file per route from a single template, so anything page-specific left
  /// in the template would be copied verbatim onto all eleven pages and every
  /// tool would look like a duplicate of the homepage.
  Component _buildSeoHead(String activeTab) {
    final PageSeo? seo = kPageSeo[activeTab];
    if (seo == null) return div([]);

    final List<Component> head = [
      link(href: seo.canonical, rel: 'canonical'),
      meta(content: seo.title, attributes: {'property': 'og:title'}),
      meta(content: seo.description, attributes: {'property': 'og:description'}),
      meta(content: seo.canonical, attributes: {'property': 'og:url'}),
      meta(name: 'twitter:title', content: seo.title),
      meta(name: 'twitter:description', content: seo.description),
    ];

    // Organization lives here rather than in kSiteHead because sameAs is driven
    // by kSocialProfiles: an empty list must emit no sameAs at all, and a raw
    // HTML string cannot be conditional.
    
    // Add structured data @graph as recommended by SEO audit
    head.add(script(content: r'''
{"@context":"https://schema.org","@graph":[{"@type":"Organization","@id":"https://vidseokit.com/#organization","name":"VidSEOKit","url":"https://vidseokit.com/","logo":{"@type":"ImageObject","url":"https://vidseokit.com/images/og-image.jpg","width":1200,"height":630}},{"@type":"WebSite","@id":"https://vidseokit.com/#website","url":"https://vidseokit.com/","name":"VidSEOKit","publisher":{"@id":"https://vidseokit.com/#organization"},"inLanguage":"en"},{"@type":"WebApplication","@id":"https://vidseokit.com/#webapp","name":"VidSEOKit YouTube SEO Analyzer","url":"https://vidseokit.com/youtube-seo-analyzer","applicationCategory":"BusinessApplication","applicationSubCategory":"SEO Tool","operatingSystem":"Any (web browser)","browserRequirements":"Requires JavaScript","description":"Free tool that scores a YouTube video title, description and tags against a target keyword and lists the specific changes to make before publishing.","featureList":["Title keyword placement and length scoring","Description first-150-character analysis","Tag relevance scoring","Combined score out of 100"],"isAccessibleForFree":true,"publisher":{"@id":"https://vidseokit.com/#organization"},"offers":{"@type":"Offer","price":"0","priceCurrency":"USD"}},{"@type":"FAQPage","@id":"https://vidseokit.com/#faq","mainEntity":[{"@type":"Question","name":"What is a good YouTube SEO score?","acceptedAnswer":{"@type":"Answer","text":"Anything above 80 means your metadata is not holding the video back. Below 60 usually points to a missing keyword in the title or a description too short for YouTube to categorise confidently. The score measures metadata quality only, so a high score does not guarantee views."}},{"@type":"Question","name":"Should my target keyword go at the start of the title?","acceptedAnswer":{"@type":"Answer","text":"Where it fits naturally, yes. Front-loading the keyword helps on mobile, where titles are truncated after roughly 40 characters, and it matches how viewers scan a results page. Do not force it at the cost of a title that reads badly."}},{"@type":"Question","name":"How long should a YouTube description be?","acceptedAnswer":{"@type":"Answer","text":"Aim for 150 to 300 words. The first 150 characters appear before the more link and should contain your keyword and a reason to watch. The rest gives YouTube context, and is a reasonable place for timestamps, links and chapter markers."}},{"@type":"Question","name":"Does changing the title of an old video help?","acceptedAnswer":{"@type":"Answer","text":"It can, particularly if the video already gets impressions but a low click-through rate. Re-optimising the title and thumbnail on a video with existing watch history is often faster than publishing a new one. Change one variable at a time so you can tell what worked."}},{"@type":"Question","name":"How do I get more of my views from the US, UK and Europe?","acceptedAnswer":{"@type":"Answer","text":"Publish so the video lands in the morning in New York and London rather than overnight, since the first hours decide who the algorithm keeps showing it to. Reference the currencies, retailers and regulations those viewers recognise, and add English subtitles to widen reach into the Netherlands, the Nordics and Germany."}},{"@type":"Question","name":"Is this YouTube SEO analyzer free?","acceptedAnswer":{"@type":"Answer","text":"Yes. There is no account, no trial and no view limit. You can analyse as many videos as you like."}}]}]}
      ''', attributes: {'type': 'application/ld+json'}));
    if (kTwitterHandle.isNotEmpty) {
      head.add(meta(
        name: 'twitter:site',
        content: '@$kTwitterHandle',
      ));
    }

    // Freshness and attribution. The tool pages carried neither, and answer
    // engines discount pages that cannot say who wrote them or when — which
    // matters most for the RPM page, whose title claims a year.
    const Map<String, Object?> publisher = {
      '@type': 'Organization',
      'name': 'VidSEOKit',
      'url': kSiteUrl,
    };
    head.add(_jsonLd({
      '@context': 'https://schema.org',
      '@type': 'WebPage',
      'name': seo.title,
      'description': seo.definition.isNotEmpty ? seo.definition : seo.description,
      'url': seo.canonical,
      'inLanguage': 'en',
      'datePublished': kContentUpdated,
      'dateModified': kContentUpdated,
      'author': publisher,
      'publisher': publisher,
      'isPartOf': {'@type': 'WebSite', 'name': 'VidSEOKit', 'url': kSiteUrl},
      if (seo.sources.isNotEmpty)
        'citation': [
          for (final src in seo.sources)
            {'@type': 'CreativeWork', 'name': src.title, 'url': src.url}
        ],
    }));
    head.add(meta(
      content: kContentUpdated,
      attributes: {'property': 'og:updated_time'},
    ));

    // Breadcrumbs describe the path to *this* page, so unlike the product
    // schema in kSiteHead they cannot be shared. The homepage gets none — a
    // one-item trail says nothing.
    if (seo.breadcrumbName.isNotEmpty) {
      head.add(_jsonLd({
        '@context': 'https://schema.org',
        '@type': 'BreadcrumbList',
        'itemListElement': [
          {'@type': 'ListItem', 'position': 1, 'name': 'Home', 'item': '$kSiteUrl/'},
          {'@type': 'ListItem', 'position': 2, 'name': seo.breadcrumbName, 'item': seo.canonical},
        ],
      }));
    }

    // The blog hub lists 20 articles. Switching to the static build made the
    // jaspr /blog route overwrite build_blog.py's listing page, which carried an
    // ItemList of every post; without this the only ItemList left on the page is
    // the site-navigation one from kSiteHead, and the article list disappears
    // from structured data.
    if (activeTab == 'blog') {
      head.add(_jsonLd({
        '@context': 'https://schema.org',
        '@type': 'ItemList',
        'name': 'VidSEOKit blog articles',
        'numberOfItems': blogPosts.length,
        'itemListElement': [
          for (var i = 0; i < blogPosts.length; i++)
            {
              '@type': 'ListItem',
              'position': i + 1,
              'name': blogPosts[i].title,
              'url': '$kSiteUrl/${blogPosts[i].url}',
            }
        ],
      }));
    }

    // Only describe an FAQ in structured data when the matching questions are
    // actually rendered on the page — schema that does not match visible
    // content is a manual-action risk, not a rich-result shortcut.
    if (seo.faqs.isNotEmpty) {
      head.add(_jsonLd({
        '@context': 'https://schema.org',
        '@type': 'FAQPage',
        'mainEntity': [
          for (final f in seo.faqs)
            {
              '@type': 'Question',
              'name': f.question,
              'acceptedAnswer': {'@type': 'Answer', 'text': f.answer},
            }
        ],
      }));
    }

    return Document.head(
      title: seo.title,
      meta: {'description': seo.description},
      children: head,
    );
  }

  /// One self-contained sentence saying what this page is, placed above the
  /// tool.
  ///
  /// Answer engines quote the first passage that stands on its own; the hero
  /// ("Grow your channel with VidSEOKit") does not, because it only makes sense
  /// next to the rest of the page.
  Component _buildDefinition(String activeTab) {
    final PageSeo? seo = kPageSeo[activeTab];
    if (seo == null || seo.definition.isEmpty) return div([]);
    return p(
      classes: 'mb-8 max-w-3xl text-base leading-relaxed text-yt-gray-700 dark:text-yt-gray-300',
      [Component.text(seo.definition)],
    );
  }

  // ═══════════════════════════════════════════
  //  LONG-FORM PAGE CONTENT
  // ═══════════════════════════════════════════

  /// Renders the written sections and FAQ for the current tool.
  ///
  /// Before a visitor interacts with anything, the tools themselves emit almost
  /// no text. This is the body copy that search engines and ad reviewers read.
  Component _buildPageContent(String activeTab) {
    final PageSeo? seo = kPageSeo[activeTab];
    if (seo == null || (seo.sections.isEmpty && seo.faqs.isEmpty)) return div([]);

    return div(classes: 'mt-12 pt-8 border-t border-yt-gray-200 dark:border-yt-gray-800 max-w-3xl', [
      for (final s in seo.sections)
        div(classes: 'mb-10', [
          h2(classes: 'text-xl font-bold text-yt-gray-900 dark:text-white mb-4', [Component.text(s.heading)]),
          div(classes: 'space-y-4 text-yt-gray-600 dark:text-yt-gray-400 text-sm leading-relaxed', [
            for (final para in s.paragraphs) p([Component.text(para)]),
          ]),
        ]),
      if (seo.sources.isNotEmpty)
        div(classes: 'mb-10', [
          h2(classes: 'text-xl font-bold text-yt-gray-900 dark:text-white mb-4',
              [Component.text('Sources')]),
          ul(classes: 'space-y-2 text-sm list-disc pl-5 text-yt-gray-600 dark:text-yt-gray-400', [
            for (final src in seo.sources)
              li([
                a(
                  href: src.url,
                  classes: 'text-yt-blue-dark dark:text-yt-blue-light hover:underline',
                  attributes: {'target': '_blank', 'rel': 'noopener'},
                  [Component.text(src.title)],
                ),
              ]),
          ]),
        ]),
      if (seo.faqs.isNotEmpty)
        div([
          h2(classes: 'text-xl font-bold text-yt-gray-900 dark:text-white mb-4', [
            Component.text('Frequently asked questions')
          ]),
          div(classes: 'space-y-6', [
            for (final f in seo.faqs)
              div([
                h3(classes: 'text-base font-semibold text-yt-gray-900 dark:text-white mb-2',
                    [Component.text(f.question)]),
                p(classes: 'text-yt-gray-600 dark:text-yt-gray-400 text-sm leading-relaxed',
                    [Component.text(f.answer)]),
              ]),
          ]),
        ]),
      // Must match dateModified in the WebPage schema — a visible date is what
      // makes the structured one credible.
      div(classes: 'mt-10 pt-4 border-t border-yt-gray-200 dark:border-yt-gray-800', [
        Component.element(
          tag: 'time',
          classes: 'text-xs text-yt-gray-500',
          attributes: {'datetime': kContentUpdated},
          children: [Component.text('Last reviewed $kContentUpdatedLabel')],
        ),
      ]),
    ]);
  }

  Component _buildSeoArticle(String activeTab) {
    String title = '';
    List<Component> content = [];

    switch (activeTab) {
      case 'seo':
        title = t('article_seo_title');
        content = [
          p([Component.text(t('article_seo_p1'))]),
          p([Component.text(t('article_seo_p2'))]),
        ];
        break;
      case 'titles':
        title = t('article_titles_title');
        content = [
          p([Component.text(t('article_titles_p1'))]),
          p([Component.text(t('article_titles_p2'))]),
        ];
        break;
      case 'thumbnails':
        title = t('article_thumb_title');
        content = [
          p([Component.text(t('article_thumb_p1'))]),
          p([Component.text(t('article_thumb_p2'))]),
        ];
        break;
      case 'tags':
        title = t('article_tags_title');
        content = [
          p([Component.text(t('article_tags_p1'))]),
          p([Component.text(t('article_tags_p2'))]),
        ];
        break;
      case 'earnings':
        title = t('article_earn_title');
        content = [
          p([Component.text(t('article_earn_p1'))]),
          p([Component.text(t('article_earn_p2'))]),
        ];
        break;
      case 'blog':
        title = t('article_blog_title');
        content = [
          p([Component.text(t('article_blog_p1'))]),
          p([Component.text(t('article_blog_p2'))]),
        ];
        break;
      default:
        // Hide article on legal pages
        return div([]);
    }

    return div(classes: 'mt-12 pt-8 border-t border-yt-gray-200 dark:border-yt-gray-800 animate-fade-in animate-duration-300 max-w-3xl', [
      h2(classes: 'text-lg font-bold text-yt-gray-900 dark:text-white mb-4', [Component.text(title)]),
      div(classes: 'space-y-4 text-yt-gray-600 dark:text-yt-gray-400 text-sm leading-relaxed', content)
    ]);
  }

  // ═══════════════════════════════════════════
  //  FOOTER
  // ═══════════════════════════════════════════
  Component _buildFooter() {
    return footer(classes: 'border-t border-yt-gray-200 dark:border-yt-gray-800 mt-16 pt-12 mb-20 md:mb-0 pb-8 animate-fade-in animate-delay-500', [
      div(classes: 'max-w-6xl mx-auto px-4 sm:px-6 lg:px-8', [
        div(classes: 'grid grid-cols-2 md:grid-cols-4 gap-8 mb-12', [
          div(classes: 'col-span-2 md:col-span-1', [
            div(classes: 'flex items-center gap-2 mb-4', [
              _buildLogoIcon('w-6 h-6'),
              span(classes: 'font-bold text-base text-yt-gray-900 dark:text-white tracking-tight', [Component.text(t('nav_logo_text'))]),
            ]),
            p(classes: 'text-sm text-yt-gray-500 mb-6', [
              Component.text('Free YouTube SEO tools and calculators designed to help creators grow their channels and increase their revenue.')
            ]),
            if (kSocialProfiles.isNotEmpty)
              div(classes: 'flex flex-wrap gap-4', [
                for (final profile in kSocialProfiles)
                  a(
                    href: profile.url,
                    classes: 'text-yt-gray-400 hover:text-yt-gray-900 dark:hover:text-white transition-colors',
                    attributes: const {'rel': 'me noopener', 'target': '_blank', 'aria-label': 'Social Profile'},
                    [span(classes: 'material-symbols-outlined text-xl', [Component.text('link')])], // Use a generic icon or specific if available
                  ),
              ]),
          ]),
          div([
            h3(classes: 'font-bold text-sm text-yt-gray-900 dark:text-white uppercase tracking-wider mb-4', [Component.text('Free Tools')]),
            ul(classes: 'space-y-3', [
              li([Link(to: '/youtube-seo-analyzer', classes: 'text-sm text-yt-gray-600 dark:text-yt-gray-400 hover:text-yt-red transition-colors', child: Component.text('SEO Analyzer'))]),
              li([Link(to: '/youtube-title-generator', classes: 'text-sm text-yt-gray-600 dark:text-yt-gray-400 hover:text-yt-red transition-colors', child: Component.text('Title Generator'))]),
              li([Link(to: '/youtube-description-generator', classes: 'text-sm text-yt-gray-600 dark:text-yt-gray-400 hover:text-yt-red transition-colors', child: Component.text('Description Generator'))]),
              li([Link(to: '/youtube-hashtag-generator', classes: 'text-sm text-yt-gray-600 dark:text-yt-gray-400 hover:text-yt-red transition-colors', child: Component.text('Hashtag Generator'))]),
              li([Link(to: '/youtube-tag-extractor', classes: 'text-sm text-yt-gray-600 dark:text-yt-gray-400 hover:text-yt-red transition-colors', child: Component.text('Tag Extractor'))]),
              li([Link(to: '/youtube-keyword-tool', classes: 'text-sm text-yt-gray-600 dark:text-yt-gray-400 hover:text-yt-red transition-colors', child: Component.text('Keyword Tool'))]),
            ]),
          ]),
          div([
            h3(classes: 'font-bold text-sm text-yt-gray-900 dark:text-white uppercase tracking-wider mb-4', [Component.text('Creator Tools')]),
            ul(classes: 'space-y-3', [
              li([Link(to: '/youtube-channel-name-generator', classes: 'text-sm text-yt-gray-600 dark:text-yt-gray-400 hover:text-yt-red transition-colors', child: Component.text('Channel Name Generator'))]),
              li([Link(to: '/youtube-video-ideas', classes: 'text-sm text-yt-gray-600 dark:text-yt-gray-400 hover:text-yt-red transition-colors', child: Component.text('Video Ideas Generator'))]),
              li([Link(to: '/youtube-script-generator', classes: 'text-sm text-yt-gray-600 dark:text-yt-gray-400 hover:text-yt-red transition-colors', child: Component.text('Script Generator'))]),
              li([Link(to: '/youtube-thumbnail-ideas', classes: 'text-sm text-yt-gray-600 dark:text-yt-gray-400 hover:text-yt-red transition-colors', child: Component.text('Thumbnail Ideas'))]),
              li([Link(to: '/youtube-earnings-calculator', classes: 'text-sm text-yt-gray-600 dark:text-yt-gray-400 hover:text-yt-red transition-colors', child: Component.text('Earnings Calculator'))]),
              li([Link(to: '/tubebuddy-alternative', classes: 'text-sm text-yt-gray-600 dark:text-yt-gray-400 hover:text-yt-red transition-colors', child: Component.text('TubeBuddy Alternative'))]),
              li([Link(to: '/vidiq-vs-tubebuddy', classes: 'text-sm text-yt-gray-600 dark:text-yt-gray-400 hover:text-yt-red transition-colors', child: Component.text('VidIQ vs TubeBuddy'))]),
            ]),
          ]),
          div([
            h3(classes: 'font-bold text-sm text-yt-gray-900 dark:text-white uppercase tracking-wider mb-4', [Component.text('Company')]),
            ul(classes: 'space-y-3', [
              li([a(href: '/blog', classes: 'text-sm text-yt-gray-600 dark:text-yt-gray-400 hover:text-yt-red transition-colors', [Component.text('Creator Blog')])]),
              li([Link(to: '/about', classes: 'text-sm text-yt-gray-600 dark:text-yt-gray-400 hover:text-yt-red transition-colors', child: Component.text(t('footer_about')))]),
              li([Link(to: '/contact', classes: 'text-sm text-yt-gray-600 dark:text-yt-gray-400 hover:text-yt-red transition-colors', child: Component.text(t('footer_contact')))]),
              li([Link(to: '/privacy', classes: 'text-sm text-yt-gray-600 dark:text-yt-gray-400 hover:text-yt-red transition-colors', child: Component.text(t('footer_privacy_policy')))]),
              li([Link(to: '/terms', classes: 'text-sm text-yt-gray-600 dark:text-yt-gray-400 hover:text-yt-red transition-colors', child: Component.text(t('footer_terms_service')))]),
              li([button(classes: 'text-sm text-yt-gray-600 dark:text-yt-gray-400 hover:text-yt-red transition-colors', onClick: openConsentPreferences, [Component.text(t('footer_cookies'))])]),
            ]),
          ]),
        ]),
        div(classes: 'pt-8 border-t border-yt-gray-200 dark:border-yt-gray-800 flex flex-col md:flex-row items-center justify-between gap-4', [
          p(classes: 'text-sm text-yt-gray-500', [Component.text(t('footer_copyright'))]),
          p(classes: 'text-xs text-yt-gray-400 text-center md:text-right max-w-xl', [
            Component.text('Not affiliated with, endorsed by, or sponsored by YouTube or Google.')
          ]),
        ])
      ])
    ]);
  }

  // ═══════════════════════════════════════════
  //  STATIC PAGES
  // ═══════════════════════════════════════════
  Component _buildPrivacyPolicy() {
    return _buildStaticPage(t('footer_privacy_policy'), privacyPolicyContent());
  }

  Component _buildTerms() {
    return _buildStaticPage(t('footer_terms_service'), termsOfServiceContent());
  }

  Component _buildAbout() {
    return _buildStaticPage(t('about_title'), [
      p([Component.text(t('about_p1'))]),
      p(classes: 'mt-4', [Component.text(t('about_p2'))]),
    ]);
  }

  Component _buildContact() {
    return _buildStaticPage(t('contact_title'), [
      p([Component.text(t('contact_p1'))]),
      div(classes: 'mt-6 p-4 bg-yt-gray-100 dark:bg-yt-gray-800 rounded-lg flex items-center gap-3', [
        span(classes: 'material-symbols-rounded', [Component.text('mail')]),
        a(href: 'mailto:$legalContactEmail', classes: 'font-medium text-yt-red hover:underline', [Component.text(legalContactEmail)])
      ])
    ]);
  }

  Component _buildStaticPage(String title, List<Component> content) {
    return div(classes: 'max-w-3xl mx-auto px-4 py-12 animate-fade-in-up', [
      h1(classes: 'text-3xl font-bold mb-6 text-yt-gray-900 dark:text-white', [Component.text(title)]),
      div(classes: 'prose dark:prose-invert max-w-none text-yt-gray-600 dark:text-yt-gray-400 space-y-4 leading-relaxed', content)
    ]);
  }

  // ═══════════════════════════════════════════
  //  COMPARISON / LANDING PAGES
  //  (VidIQ Alternative, TubeBuddy Alternative, VidIQ vs TubeBuddy)
  // ═══════════════════════════════════════════
  Component _buildComparisonPage(String tab) {
    // The full SEO copy is rendered by _buildSeoArticle in the shell.
    // We just need a strong above-the-fold CTA to convert visits.
    return div(classes: 'space-y-8 max-w-4xl animate-fade-in-up', [
      div(classes: 'card p-8 text-center bg-gradient-to-br from-red-50 to-white dark:from-yt-gray-800 dark:to-yt-gray-900 border border-red-100 dark:border-yt-gray-700', [
        span(classes: 'material-symbols-rounded text-5xl text-yt-red mb-4 block', [Component.text('star')]),
        h2(classes: 'text-2xl font-bold text-yt-gray-900 dark:text-white mb-3', [
          Component.text('Try VidSEOKit Free — No Sign-Up Required')
        ]),
        p(classes: 'text-yt-gray-600 dark:text-yt-gray-400 mb-6 max-w-lg mx-auto', [
          Component.text('Get your free YouTube SEO score in 30 seconds. Paste your title, description and tags, enter your target keyword, and see exactly what to fix before you publish.')
        ]),
        a(
          href: '/youtube-seo-analyzer',
          classes: 'inline-flex items-center gap-2 btn-primary px-8 py-3 text-base font-semibold rounded-xl',
          [
            span(classes: 'material-symbols-rounded', [Component.text('analytics')]),
            Component.text('Analyze My Video For Free'),
          ]
        ),
      ]),
      div(classes: 'grid grid-cols-1 sm:grid-cols-3 gap-4', [
        _buildFeatureCard('analytics', 'SEO Score', 'Scores title, description and tags against your target keyword — with the formula shown openly.'),
        _buildFeatureCard('title', 'AI Titles', 'Generates 5 click-worthy title angles for any video topic in seconds.'),
        _buildFeatureCard('sell', 'Tag Extractor', 'Extracts the tags any YouTube video is using — see how ranking videos describe themselves.'),
      ]),
    ]);
  }

  Component _buildFeatureCard(String icon, String title, String description) {
    return div(classes: 'card p-5 text-center', [
      span(classes: 'material-symbols-rounded text-3xl text-yt-red mb-3 block', [Component.text(icon)]),
      h3(classes: 'font-bold text-yt-gray-900 dark:text-white mb-2', [Component.text(title)]),
      p(classes: 'text-sm text-yt-gray-600 dark:text-yt-gray-400', [Component.text(description)]),
    ]);
  }

  // ═══════════════════════════════════════════
  //  YOUTUBE DESCRIPTION GENERATOR
  // ═══════════════════════════════════════════
  String descriptionTopic = '';
  String? generatedDescription;

  Future<void> generateDescription() => _run('description', () async {
    if (descriptionTopic.trim().isEmpty) throw Exception('Please enter a video topic.');
    final data = await _postJson('/api/generate-description', {
      'topic': descriptionTopic.trim(),
      'lang': I18nService().currentLanguage,
    });
    setState(() => generatedDescription = data['description']?.toString() ?? '');
  });

  Component _buildDescriptionGenerator() {
    return div(classes: 'space-y-6 max-w-4xl', [
      div(classes: 'animate-fade-in-up animate-delay-100', [
        div(classes: 'flex items-center gap-2 mb-4', [
          span(classes: 'material-symbols-rounded text-2xl', [Component.text('description')]),
          h2(classes: 'text-xl font-bold', [Component.text('YouTube Description Generator')]),
        ]),
        div(classes: 'flex flex-col sm:flex-row gap-3', [
          div(classes: 'flex-1', [
            input(
              classes: 'input-field',
              attributes: {
                'id': 'description-topic', 'name': 'description-topic',
                'placeholder': 'Enter your video topic or title…',
                'aria-label': 'Video topic for description generation',
                'value': descriptionTopic,
              },
              onInput: (e) => setState(() => descriptionTopic = e.toString()),
            ),
          ]),
          button(
            classes: 'btn-primary font-medium px-6 py-2 text-sm flex items-center justify-center whitespace-nowrap pr-10 ${(tabIsLoading['description'] ?? false) ? 'btn-loading' : ''}',
            onClick: () => generateDescription(),
            [Component.text((tabIsLoading['description'] ?? false) ? t('btn_working') : 'Generate Description')]
          ),
        ]),
      ]),
      if (tabIsLoading['description'] ?? false) div(classes: 'card p-6 space-y-3 animate-fade-in', [
        div(classes: 'skeleton h-4 w-full', []),
        div(classes: 'skeleton h-4 w-full', []),
        div(classes: 'skeleton h-4', attributes: {'style': 'width: 80%'}, []),
        div(classes: 'skeleton h-4', attributes: {'style': 'width: 60%'}, []),
        div(classes: 'skeleton h-4 w-full', []),
      ]),
      if (generatedDescription != null && !(tabIsLoading['description'] ?? false))
        div(classes: 'card p-6 animate-fade-in space-y-3', [
          div(classes: 'flex items-center justify-between mb-2', [
            span(classes: 'text-sm font-medium text-yt-gray-600 dark:text-yt-gray-400', [Component.text('Generated Description')]),
            button(
              classes: 'text-xs btn-secondary px-3 py-1',
              attributes: {'onclick': 'navigator.clipboard.writeText(document.getElementById(\'desc-output\').innerText)'},
              [Component.text('Copy')]
            ),
          ]),
          pre(
            id: 'desc-output',
            classes: 'whitespace-pre-wrap text-sm text-yt-gray-700 dark:text-yt-gray-300 leading-relaxed font-sans',
            [Component.text(generatedDescription!)]
          ),
        ]),
    ]);
  }

  // ═══════════════════════════════════════════
  //  YOUTUBE HASHTAG GENERATOR
  // ═══════════════════════════════════════════
  String hashtagTopic = '';
  List<Map<String, dynamic>>? generatedHashtags;

  Future<void> generateHashtags() => _run('hashtags', () async {
    if (hashtagTopic.trim().isEmpty) throw Exception('Please enter a video topic.');
    final data = await _postJson('/api/generate-hashtags', {
      'topic': hashtagTopic.trim(),
      'lang': I18nService().currentLanguage,
    });
    final list = data['hashtags'] as List? ?? [];
    setState(() => generatedHashtags = list.map((e) => Map<String, dynamic>.from(e as Map)).toList());
  });

  Component _buildHashtagGenerator() {
    return div(classes: 'space-y-6 max-w-4xl', [
      div(classes: 'animate-fade-in-up animate-delay-100', [
        div(classes: 'flex items-center gap-2 mb-4', [
          span(classes: 'material-symbols-rounded text-2xl', [Component.text('tag')]),
          h2(classes: 'text-xl font-bold', [Component.text('YouTube Hashtag Generator')]),
        ]),
        div(classes: 'flex flex-col sm:flex-row gap-3', [
          div(classes: 'flex-1', [
            input(
              classes: 'input-field',
              attributes: {
                'id': 'hashtag-topic', 'name': 'hashtag-topic',
                'placeholder': 'Enter your video topic…',
                'aria-label': 'Video topic for hashtag generation',
                'value': hashtagTopic,
              },
              onInput: (e) => setState(() => hashtagTopic = e.toString()),
            ),
          ]),
          button(
            classes: 'btn-primary font-medium px-6 py-2 text-sm flex items-center justify-center whitespace-nowrap pr-10 ${(tabIsLoading['hashtags'] ?? false) ? 'btn-loading' : ''}',
            onClick: () => generateHashtags(),
            [Component.text((tabIsLoading['hashtags'] ?? false) ? t('btn_working') : 'Generate Hashtags')]
          ),
        ]),
      ]),
      if (tabIsLoading['hashtags'] ?? false) div(classes: 'card p-6 flex flex-wrap gap-2 animate-fade-in', [
        for (var w in [100, 130, 90, 120, 80])
          div(classes: 'skeleton h-9 rounded-full', attributes: {'style': 'width: ${w}px'}, []),
      ]),
      if (generatedHashtags != null && !(tabIsLoading['hashtags'] ?? false)) div(classes: 'card p-6 animate-fade-in', [
        p(classes: 'text-xs font-medium text-yt-gray-500 mb-3', [
          Component.text('First 3 appear above your video title on YouTube. Add all 5 to your description.')
        ]),
        div(classes: 'flex flex-wrap gap-2', [
          for (var i = 0; i < generatedHashtags!.length; i++)
            div(classes: 'flex items-center gap-1 px-4 py-2 rounded-full text-sm font-medium card-stagger ${i < 3 ? 'bg-yt-red text-white' : 'bg-yt-gray-100 dark:bg-yt-gray-800 text-yt-gray-900 dark:text-white'}', attributes: {'style': 'animation-delay: ${i * 100}ms'}, [
              if (i < 3) span(classes: 'text-xs opacity-75', [Component.text('${i+1}')]),
              Component.text(generatedHashtags![i]['hashtag']?.toString() ?? ''),
            ])
        ]),
      ]),
    ]);
  }

  // ═══════════════════════════════════════════
  //  YOUTUBE CHANNEL NAME GENERATOR
  // ═══════════════════════════════════════════
  String channelNameTopic = '';
  List<Map<String, dynamic>>? generatedChannelNames;

  Future<void> generateChannelNames() => _run('channelnames', () async {
    if (channelNameTopic.trim().isEmpty) throw Exception('Please enter a niche or content type.');
    final data = await _postJson('/api/generate-channel-names', {
      'topic': channelNameTopic.trim(),
    });
    final list = data['names'] as List? ?? [];
    setState(() => generatedChannelNames = list.map((e) => Map<String, dynamic>.from(e as Map)).toList());
  });

  Component _buildChannelNameGenerator() {
    return div(classes: 'space-y-6 max-w-4xl', [
      div(classes: 'animate-fade-in-up animate-delay-100', [
        div(classes: 'flex items-center gap-2 mb-4', [
          span(classes: 'material-symbols-rounded text-2xl', [Component.text('person')]),
          h2(classes: 'text-xl font-bold', [Component.text('YouTube Channel Name Generator')]),
        ]),
        div(classes: 'flex flex-col sm:flex-row gap-3', [
          div(classes: 'flex-1', [
            input(
              classes: 'input-field',
              attributes: {
                'id': 'channel-name-topic', 'name': 'channel-name-topic',
                'placeholder': 'Enter your niche or content type…',
                'aria-label': 'Niche for channel name generation',
                'value': channelNameTopic,
              },
              onInput: (e) => setState(() => channelNameTopic = e.toString()),
            ),
          ]),
          button(
            classes: 'btn-primary font-medium px-6 py-2 text-sm flex items-center justify-center whitespace-nowrap pr-10 ${(tabIsLoading['channelnames'] ?? false) ? 'btn-loading' : ''}',
            onClick: () => generateChannelNames(),
            [Component.text((tabIsLoading['channelnames'] ?? false) ? t('btn_working') : 'Generate Names')]
          ),
        ]),
      ]),
      if (tabIsLoading['channelnames'] ?? false) div(classes: 'space-y-3 animate-fade-in', [
        for (var i = 0; i < 4; i++) div(classes: 'card p-4', [
          div(classes: 'skeleton h-5 mb-2', attributes: {'style': 'width: 35%'}, []),
          div(classes: 'skeleton h-4', attributes: {'style': 'width: 70%'}, []),
        ]),
      ]),
      if (generatedChannelNames != null && !(tabIsLoading['channelnames'] ?? false)) div(classes: 'space-y-3', [
        for (var i = 0; i < generatedChannelNames!.length; i++)
          div(classes: 'card p-4 card-stagger', attributes: {'style': 'animation-delay: ${i * 100}ms'}, [
            div(classes: 'flex items-center gap-3 mb-1', [
              span(classes: 'font-bold text-lg text-yt-gray-900 dark:text-white', [Component.text(generatedChannelNames![i]['name']?.toString() ?? '')]),
              span(classes: 'text-xs px-2 py-0.5 rounded-full ${generatedChannelNames![i]['type'] == 'personal' ? 'bg-blue-100 text-blue-700 dark:bg-blue-900/40 dark:text-blue-300' : 'bg-green-100 text-green-700 dark:bg-green-900/40 dark:text-green-300'}', [
                Component.text(generatedChannelNames![i]['type']?.toString() ?? '')
              ]),
            ]),
            p(classes: 'text-sm text-yt-gray-600 dark:text-yt-gray-400', [Component.text(generatedChannelNames![i]['rationale']?.toString() ?? '')]),
          ]),
      ]),
    ]);
  }

  // ═══════════════════════════════════════════
  //  YOUTUBE VIDEO IDEAS GENERATOR
  // ═══════════════════════════════════════════
  String videoIdeasNiche = '';
  List<Map<String, dynamic>>? generatedVideoIdeas;

  Future<void> generateVideoIdeas() => _run('videoideas', () async {
    if (videoIdeasNiche.trim().isEmpty) throw Exception('Please enter a niche.');
    final data = await _postJson('/api/generate-video-ideas', {
      'niche': videoIdeasNiche.trim(),
      'lang': I18nService().currentLanguage,
    });
    final list = data['ideas'] as List? ?? [];
    setState(() => generatedVideoIdeas = list.map((e) => Map<String, dynamic>.from(e as Map)).toList());
  });

  Component _buildVideoIdeasGenerator() {
    return div(classes: 'space-y-6 max-w-4xl', [
      div(classes: 'animate-fade-in-up animate-delay-100', [
        div(classes: 'flex items-center gap-2 mb-4', [
          span(classes: 'material-symbols-rounded text-2xl', [Component.text('lightbulb')]),
          h2(classes: 'text-xl font-bold', [Component.text('YouTube Video Ideas Generator')]),
        ]),
        div(classes: 'flex flex-col sm:flex-row gap-3', [
          div(classes: 'flex-1', [
            input(
              classes: 'input-field',
              attributes: {
                'id': 'video-ideas-niche', 'name': 'video-ideas-niche',
                'placeholder': 'Enter your niche (e.g. personal finance, cooking, tech)…',
                'aria-label': 'Niche for video ideas generation',
                'value': videoIdeasNiche,
              },
              onInput: (e) => setState(() => videoIdeasNiche = e.toString()),
            ),
          ]),
          button(
            classes: 'btn-primary font-medium px-6 py-2 text-sm flex items-center justify-center whitespace-nowrap pr-10 ${(tabIsLoading['videoideas'] ?? false) ? 'btn-loading' : ''}',
            onClick: () => generateVideoIdeas(),
            [Component.text((tabIsLoading['videoideas'] ?? false) ? t('btn_working') : 'Generate Ideas')]
          ),
        ]),
      ]),
      if (tabIsLoading['videoideas'] ?? false) div(classes: 'space-y-3 animate-fade-in', [
        for (var i = 0; i < 4; i++) div(classes: 'card p-5', [
          div(classes: 'skeleton h-5 mb-2 w-3/4', []),
          div(classes: 'skeleton h-4 w-full', []),
          div(classes: 'skeleton h-4 w-1/2 mt-2', []),
        ]),
      ]),
      if (generatedVideoIdeas != null && !(tabIsLoading['videoideas'] ?? false)) div(classes: 'space-y-3', [
        for (var i = 0; i < generatedVideoIdeas!.length; i++) () {
          final idea = generatedVideoIdeas![i];
          final difficulty = idea['estimated_difficulty']?.toString() ?? 'medium';
          final diffColor = difficulty == 'low'
              ? 'bg-green-100 text-green-700 dark:bg-green-900/40 dark:text-green-300'
              : difficulty == 'high'
                  ? 'bg-red-100 text-red-700 dark:bg-red-900/40 dark:text-red-300'
                  : 'bg-yellow-100 text-yellow-700 dark:bg-yellow-900/40 dark:text-yellow-300';
          return div(classes: 'card p-5 card-stagger', attributes: {'style': 'animation-delay: ${i * 100}ms'}, [
            div(classes: 'flex items-start justify-between gap-3 mb-2', [
              h3(classes: 'font-bold text-yt-gray-900 dark:text-white', [Component.text(idea['title']?.toString() ?? '')]),
              span(classes: 'text-xs px-2 py-0.5 rounded-full shrink-0 $diffColor', [Component.text(difficulty)]),
            ]),
            p(classes: 'text-sm text-yt-gray-600 dark:text-yt-gray-400 italic', [Component.text('"${idea['hook']}"')]),
            span(classes: 'text-xs text-yt-gray-500 mt-2 block', [Component.text('Intent: ${idea['search_intent']}')]),
          ]);
        }(),
      ]),
    ]);
  }

  // ═══════════════════════════════════════════
  //  YOUTUBE SCRIPT GENERATOR
  // ═══════════════════════════════════════════
  String scriptTopic = '';
  int scriptDuration = 5;
  List<Map<String, dynamic>>? generatedScript;

  Future<void> generateScript() => _run('script', () async {
    if (scriptTopic.trim().isEmpty) throw Exception('Please enter a video topic.');
    final data = await _postJson('/api/generate-script', {
      'topic': scriptTopic.trim(),
      'duration_minutes': scriptDuration,
      'lang': I18nService().currentLanguage,
    });
    final list = data['sections'] as List? ?? [];
    setState(() => generatedScript = list.map((e) => Map<String, dynamic>.from(e as Map)).toList());
  });

  Component _buildScriptGenerator() {
    return div(classes: 'space-y-6 max-w-4xl', [
      div(classes: 'animate-fade-in-up animate-delay-100', [
        div(classes: 'flex items-center gap-2 mb-4', [
          span(classes: 'material-symbols-rounded text-2xl', [Component.text('article')]),
          h2(classes: 'text-xl font-bold', [Component.text('YouTube Script Generator')]),
        ]),
        div(classes: 'flex flex-col sm:flex-row gap-3', [
          div(classes: 'flex-1', [
            input(
              classes: 'input-field',
              attributes: {
                'id': 'script-topic', 'name': 'script-topic',
                'placeholder': 'Enter your video topic…',
                'aria-label': 'Video topic for script generation',
                'value': scriptTopic,
              },
              onInput: (e) => setState(() => scriptTopic = e.toString()),
            ),
          ]),
          div(classes: 'flex items-center gap-2', [
            label(attributes: {'for': 'script-duration'}, classes: 'text-sm text-yt-gray-600 dark:text-yt-gray-400 whitespace-nowrap', [Component.text('Duration:')]),
            select(
              classes: 'input-field',
              attributes: {'id': 'script-duration', 'name': 'script-duration', 'aria-label': 'Target video duration in minutes'},
              onChange: (vals) => setState(() => scriptDuration = int.tryParse(vals.firstOrNull ?? '5') ?? 5),
              [
                for (var m in [3, 5, 8, 10, 15])
                  option(value: m.toString(), attributes: scriptDuration == m ? {'selected': 'true'} : {}, [Component.text('$m min')]),
              ]
            ),
          ]),
          button(
            classes: 'btn-primary font-medium px-6 py-2 text-sm flex items-center justify-center whitespace-nowrap pr-10 ${(tabIsLoading['script'] ?? false) ? 'btn-loading' : ''}',
            onClick: () => generateScript(),
            [Component.text((tabIsLoading['script'] ?? false) ? t('btn_working') : 'Generate Script')]
          ),
        ]),
      ]),
      if (tabIsLoading['script'] ?? false) div(classes: 'space-y-4 animate-fade-in', [
        for (var i = 0; i < 4; i++) div(classes: 'card p-5', [
          div(classes: 'skeleton h-5 mb-3', attributes: {'style': 'width: 20%'}, []),
          div(classes: 'skeleton h-4 w-full mb-1', []),
          div(classes: 'skeleton h-4 w-full mb-1', []),
          div(classes: 'skeleton h-4', attributes: {'style': 'width: 70%'}, []),
        ]),
      ]),
      if (generatedScript != null && !(tabIsLoading['script'] ?? false)) div(classes: 'space-y-4', [
        for (var i = 0; i < generatedScript!.length; i++)
          div(classes: 'card p-5 card-stagger', attributes: {'style': 'animation-delay: ${i * 80}ms'}, [
            h3(classes: 'text-sm font-bold text-yt-red uppercase tracking-widest mb-3', [
              Component.text(generatedScript![i]['section']?.toString() ?? '')
            ]),
            p(classes: 'text-sm text-yt-gray-700 dark:text-yt-gray-300 leading-relaxed whitespace-pre-wrap', [
              Component.text(generatedScript![i]['content']?.toString() ?? '')
            ]),
          ]),
      ]),
    ]);
  }

  // ═══════════════════════════════════════════
  //  YOUTUBE KEYWORD TOOL
  //  (reuses the SEO Analyzer's keyword lookup — enters keyword and shows
  //   volume + competition data pulled from DataForSEO via calculate-seo)
  // ═══════════════════════════════════════════
  Component _buildKeywordTool() {
    // Delegates to the full SEO analyzer so creators can immediately
    // action the keyword data. The SEO article below the tool provides
    // all the educational context for the keyword-tool search query.
    return div(classes: 'space-y-6 max-w-4xl', [
      div(classes: 'card p-6 text-center animate-fade-in-up', [
        span(classes: 'material-symbols-rounded text-4xl text-yt-red mb-3 block', [Component.text('search')]),
        h2(classes: 'text-xl font-bold text-yt-gray-900 dark:text-white mb-2', [
          Component.text('YouTube Keyword Research Tool')
        ]),
        p(classes: 'text-yt-gray-600 dark:text-yt-gray-400 mb-5 max-w-md mx-auto text-sm', [
          Component.text('Enter your target keyword in the SEO Analyzer below. It pulls real search volume and competition data from DataForSEO and factors it into your score — so you can research keywords and optimize your metadata in one step.')
        ]),
        a(
          href: '/youtube-seo-analyzer',
          classes: 'inline-flex items-center gap-2 btn-primary px-6 py-2 text-sm font-semibold rounded-xl',
          [
            span(classes: 'material-symbols-rounded text-sm', [Component.text('analytics')]),
            Component.text('Open SEO Analyzer & Keyword Tool'),
          ]
        ),
      ]),
    ]);
  }
}

