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
    client_interop.setupPrivacyCallback(() => switchTab('privacy'));
  }

  String _getPathForTab(String tab) {
    if (tab == 'seo') return '/youtube-seo-analyzer';
    if (tab == 'titles') return '/youtube-title-generator';
    if (tab == 'thumbnails') return '/youtube-thumbnail-ideas';
    if (tab == 'tags') return '/youtube-tag-extractor';
    if (tab == 'earnings') return '/youtube-earnings-calculator';
    return '/$tab';
  }

  void switchTab(String tab) {
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
    final token = await client_interop.getRecaptchaToken();
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
        final data = await _postJson('/api/generate-titles', {
          'topic': titleTopic,
          'lang': I18nService().currentLanguage,
        });
        setState(() => generatedTitles = data['titles'] as List<dynamic>);
      });

  Future<void> generateThumbnails() => _run(() async {
        final data = await _postJson('/api/generate-thumbnails', {
          'topic': thumbnailTopic,
          'lang': I18nService().currentLanguage,
        });
        setState(() => generatedThumbnails = data['thumbnails'] as List<dynamic>);
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
    return Router(
      routes: [
        ShellRoute(
          builder: (context, state, child) {
            // ShellRoute has no path of its own, so RouteState.path is '' here
            // (empty, not null) — reading it blanked activeTab and hid every
            // per-tool article. location carries the real URI.
            String activeTab = _getTabFromPath(Uri.parse(state.location).path);
            return div(classes: 'min-h-screen font-sans transition-colors duration-300', [
              _buildSeoHead(activeTab),
              _buildNavbar(),
              _buildHero(),
              div(classes: 'max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 pb-32 md:pb-16', [
                _buildDesktopTabs(activeTab),
                if (errorMessage != null) _buildErrorBanner(errorMessage!),
                _buildDefinition(activeTab),
                div(classes: 'animate-fade-in-up animate-delay-100', [
                  child,
                ]),
                _buildSeoArticle(activeTab),
                _buildPageContent(activeTab),
              ]),
              _buildFooter(),
              _buildMobileNav(activeTab),
            ]);
          },
          routes: [
            Route(path: '/', builder: (context, state) => _buildSeoAnalyzer()),
            Route(path: '/youtube-seo-analyzer', builder: (context, state) => _buildSeoAnalyzer()),
            Route(path: '/youtube-title-generator', builder: (context, state) => _buildTitleGenerator()),
            Route(path: '/youtube-thumbnail-ideas', builder: (context, state) => _buildThumbnailGenerator()),
            Route(path: '/youtube-tag-extractor', builder: (context, state) => _buildTagExtractor()),
            Route(path: '/youtube-earnings-calculator', builder: (context, state) => _buildEarningsCalculator()),
            Route(path: '/youtube-rpm-by-country', builder: (context, state) => _buildRpmByCountry()),
            Route(path: '/blog', builder: (context, state) => _buildBlogSection()),
            Route(path: '/privacy', builder: (context, state) => _buildPrivacyPolicy()),
            Route(path: '/terms', builder: (context, state) => _buildTerms()),
            Route(path: '/about', builder: (context, state) => _buildAbout()),
            Route(path: '/contact', builder: (context, state) => _buildContact()),
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
    if (path == '/youtube-seo-analyzer' || path == '/') return 'seo';
    if (path == '/youtube-title-generator') return 'titles';
    if (path == '/youtube-thumbnail-ideas') return 'thumbnails';
    if (path == '/youtube-tag-extractor') return 'tags';
    if (path == '/youtube-earnings-calculator') return 'earnings';
    if (path.startsWith('/')) return path.substring(1);
    return path;
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
            span(classes: 'text-xl font-bold tracking-tighter', [Component.text(t('nav_logo_text'))]),
          ]),
          // Right Actions
          div(classes: 'flex items-center gap-3', [
            div(classes: 'relative flex items-center bg-gray-100 dark:bg-gray-800 rounded-lg px-2 py-1', [
              span(classes: 'material-symbols-rounded text-lg mr-1 text-gray-600 dark:text-gray-400', [Component.text('language')]),
              select(
                classes: 'bg-transparent text-sm font-medium text-gray-700 dark:text-gray-300 focus:outline-none cursor-pointer outline-none border-none',
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
              attributes: {'data-theme-toggle': 'true'},
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
    return div(classes: 'hidden md:flex items-center gap-3 mb-8 animate-fade-in-up animate-delay-500 overflow-x-auto pb-2', [
      _buildTabChip(t('tab_seo'), 'seo', activeTab),
      _buildTabChip(t('tab_titles'), 'titles', activeTab),
      _buildTabChip(t('tab_thumbnails'), 'thumbnails', activeTab),
      _buildTabChip(t('tab_tags'), 'tags', activeTab),
      _buildTabChip(t('tab_earnings'), 'earnings', activeTab),
      _buildTabChip(t('tab_blog'), 'blog', activeTab),
    ]);
  }

  /// Inline banner for a failed request, dismissible so it never blocks the UI.
  Component _buildErrorBanner(String message) {
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
          onClick: () => setState(() => errorMessage = null),
          [Component.text('close')],
        ),
      ],
    );
  }

  Component _buildTabChip(String label, String id, String activeTab) {
    bool isActive = activeTab == id;
    return Link(
      to: _getPathForTab(id),
      classes: 'px-4 py-1.5 text-sm font-medium rounded-lg transition-colors whitespace-nowrap ${isActive
              ? 'bg-yt-gray-900 text-white dark:bg-white dark:text-yt-gray-900'
              : 'bg-yt-gray-100 text-yt-gray-900 dark:bg-yt-gray-800 dark:text-white hover:bg-yt-gray-200 dark:hover:bg-yt-gray-700'}',
      child: Component.text(label),
    );
  }

  // ═══════════════════════════════════════════
  //  MOBILE BOTTOM NAV
  // ═══════════════════════════════════════════
  Component _buildMobileNav(String activeTab) {
    return div(classes: 'mobile-nav md:hidden', [
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
    return Link(
      to: _getPathForTab(tab),
      classes: 'flex flex-col items-center gap-1 py-1 px-3 transition-all duration-300 ${isActive ? 'text-yt-gray-900 dark:text-white' : 'text-yt-gray-600 dark:text-yt-gray-400'}',
      child: div(classes: 'flex flex-col items-center gap-1', [
        span(classes: 'material-symbols-rounded text-2xl ${isActive ? 'filled' : ''}', [Component.text(icon)]),
        span(classes: 'text-[10px] font-medium', [Component.text(label)]),
      ])
    );
  }

  // ═══════════════════════════════════════════
  //  SEO ANALYZER
  // ═══════════════════════════════════════════
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
            attributes: {'placeholder': t('seo_placeholder_keyword')},
            onInput: (e) => setState(() => seoTargetKeyword = e.toString()),
          ),
        ]),
        div([
          input(
            classes: 'input-field',
            attributes: {'placeholder': t('seo_placeholder_title')},
            onInput: (e) => setState(() => seoTitle = e.toString()),
          ),
        ]),
        div([
          textarea(
            classes: 'input-field resize-none',
            attributes: {'placeholder': t('seo_placeholder_desc'), 'rows': '5'},
            onInput: (e) => setState(() => seoDescription = e.toString()),
            [],
          ),
        ]),
        div(classes: 'flex justify-end', [
          button(
            classes: 'btn-primary font-medium px-6 py-2 text-sm flex items-center justify-center gap-2 w-full md:w-auto',
            onClick: () => calculateSeo(),
            [
              Component.text(isLoading ? t('btn_analyzing') : t('btn_analyze')),
            ]
          ),
        ])
      ]),
      div(classes: 'card p-6 flex flex-col items-center justify-center min-h-[300px] animate-fade-in-right animate-delay-200', [
        if (seoResult != null) ...[
          div(classes: 'score-ring mb-6', [
            div(classes: 'text-center', [
              span(classes: 'text-4xl font-bold ${(seoResult!['score'] as int) > 75 ? 'text-[#2BA640]' : 'text-yt-red'}', [
                Component.text(seoResult!['score'].toString())
              ]),
              p(classes: 'text-sm font-medium text-yt-gray-500 mt-1', [Component.text(t('seo_score_label'))])
            ])
          ]),
          div(classes: 'w-full space-y-2', [
            for (var fb in seoResult!['feedback'])
              _buildSeoFeedbackRow(fb as Map<String, dynamic>)
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
              attributes: {'placeholder': t('title_gen_placeholder')},
              onInput: (e) => setState(() => titleTopic = e.toString()),
            ),
          ]),
          button(
            classes: 'btn-primary font-medium px-6 py-2 text-sm flex items-center justify-center whitespace-nowrap',
            onClick: () => generateTitles(),
            [Component.text(isLoading ? t('btn_working') : t('btn_generate'))]
          ),
        ]),
      ]),
      if (generatedTitles != null) div(classes: 'grid grid-cols-1 md:grid-cols-2 gap-4 animate-fade-in-up animate-delay-200', [
        for (var i = 0; i < generatedTitles!.length; i++)
          div(classes: 'card p-4 hover:bg-yt-gray-50 dark:hover:bg-yt-gray-800 cursor-pointer', [
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
              attributes: {'placeholder': t('thumb_gen_placeholder')},
              onInput: (e) => setState(() => thumbnailTopic = e.toString()),
            ),
          ]),
          button(
            classes: 'btn-primary font-medium px-6 py-2 text-sm flex items-center justify-center whitespace-nowrap',
            onClick: () => generateThumbnails(),
            [Component.text(isLoading ? t('btn_working') : t('btn_generate'))]
          ),
        ]),
      ]),
      if (generatedThumbnails != null) div(classes: 'space-y-4 animate-fade-in-up animate-delay-200', [
        for (var i = 0; i < generatedThumbnails!.length; i++)
          div(classes: 'card p-5 hover:bg-yt-gray-50 dark:hover:bg-yt-gray-800 transition-colors', [
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
                'placeholder': t('tag_ext_placeholder'),
                'value': tagUrl
              },
              onInput: (e) => setState(() => tagUrl = e.toString()),
            ),
          ]),
          button(
            classes: 'btn-primary font-medium px-6 py-2 text-sm flex items-center justify-center whitespace-nowrap',
            onClick: () => extractTags(),
            [Component.text(isLoading ? t('btn_extracting') : t('btn_extract'))]
          ),
        ]),
      ]),
      if (extractedTags != null) div(classes: 'card p-6 animate-fade-in-up animate-delay-200', [
        div(classes: 'flex items-center gap-2 mb-4', [
          span(classes: 'text-sm font-medium text-yt-gray-600 dark:text-yt-gray-400', [
            Component.text(t('tag_ext_result', {'count': extractedTags!.length.toString()}))
          ])
        ]),
        div(classes: 'flex flex-wrap gap-2', [
          for (var tag in extractedTags!)
            span(classes: 'bg-yt-gray-100 dark:bg-yt-gray-800 text-yt-gray-900 dark:text-white px-3 py-1.5 rounded-full text-sm hover:bg-yt-gray-200 dark:hover:bg-yt-gray-700 cursor-pointer transition-colors', [
              Component.text(tag.toString())
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
              attributes: {'type': 'range', 'min': '1000', 'max': '100000', 'step': '1000'},
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
              classes: 'btn-primary font-medium px-6 py-2 text-sm flex items-center justify-center gap-2 w-full sm:w-auto',
              onClick: () => calculateEarnings(),
              [Component.text(isLoading ? t('btn_calculating') : t('btn_calculate'))]
            ),
          ])
        ]),
      ]),
      div(classes: 'card p-6 flex flex-col items-center justify-center min-h-[300px] animate-fade-in-right animate-delay-200', [
        if (earningsResult != null) ...[
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
              th([Component.text('Country')], classes: 'text-left py-3 pr-4 font-semibold', scope: 'col'),
              th([Component.text('Currency')], classes: 'text-left py-3 pr-4 font-semibold', scope: 'col'),
              th([Component.text('Typical RPM (USD)')], classes: 'text-left py-3 pr-4 font-semibold', scope: 'col'),
              th([Component.text('Notes')], classes: 'text-left py-3 font-semibold', scope: 'col'),
            ])
          ]),
          tbody([
            for (final c in kCountryRpm)
              tr(classes: 'border-b border-yt-gray-200 dark:border-yt-gray-800 align-top', [
                th([Component.text(c.country)],
                    classes: 'text-left py-3 pr-4 font-medium text-yt-gray-900 dark:text-white whitespace-nowrap',
                    scope: 'row'),
                td([Component.text(c.currency)], classes: 'py-3 pr-4 text-yt-gray-600 dark:text-yt-gray-400'),
                td([
                  Component.text('\$${c.minRpm.toStringAsFixed(2)} - \$${c.maxRpm.toStringAsFixed(2)}')
                ], classes: 'py-3 pr-4 font-medium text-yt-gray-900 dark:text-white whitespace-nowrap'),
                td([Component.text(c.note)], classes: 'py-3 text-yt-gray-600 dark:text-yt-gray-400'),
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

  Component _buildBlogSection() {
    return div(classes: 'space-y-6', [
      div(classes: 'flex items-center justify-between gap-3 mb-4 animate-fade-in-down animate-delay-100', [
        div(classes: 'flex items-center gap-2', [
          span(classes: 'material-symbols-rounded text-2xl', [Component.text('article')]),
          h2(classes: 'text-xl font-bold', [Component.text(t('blog_latest'))]),
        ]),
        a(
          href: 'blog/index.html',
          classes: 'text-sm font-medium text-yt-blue-dark dark:text-yt-blue-light hover:underline whitespace-nowrap',
          [Component.text(t('blog_view_all', {'count': blogPosts.length.toString()}))]
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
            h3(classes: 'text-sm font-medium text-yt-gray-900 dark:text-white line-clamp-2 leading-tight group-hover:text-yt-red transition-colors', [Component.text(post.title)]),
            p(classes: 'text-xs text-yt-gray-600 dark:text-yt-gray-400 mt-1', [
              Component.text('${post.category} \u2022 ${post.date} \u2022 ${post.readMinutes} min read')
            ]),
          ])
        ])
      ]
    );
  }

  // ═══════════════════════════════════════════
  //  SEO ARTICLE
  // ═══════════════════════════════════════════
  // ═══════════════════════════════════════════
  //  PER-ROUTE <head>
  // ═══════════════════════════════════════════

  Component _jsonLd(Map<String, Object?> data) => Component.element(
        tag: 'script',
        attributes: {'type': 'application/ld+json'},
        children: [RawText(jsonEncode(data))],
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
      Component.element(tag: 'link', attributes: {'rel': 'canonical', 'href': seo.canonical}),
      Component.element(tag: 'meta', attributes: {'property': 'og:title', 'content': seo.title}),
      Component.element(tag: 'meta', attributes: {'property': 'og:description', 'content': seo.description}),
      Component.element(tag: 'meta', attributes: {'property': 'og:url', 'content': seo.canonical}),
      Component.element(tag: 'meta', attributes: {'name': 'twitter:title', 'content': seo.title}),
      Component.element(tag: 'meta', attributes: {'name': 'twitter:description', 'content': seo.description}),
    ];

    // Organization lives here rather than in kSiteHead because sameAs is driven
    // by kSocialProfiles: an empty list must emit no sameAs at all, and a raw
    // HTML string cannot be conditional.
    head.add(_jsonLd({
      '@context': 'https://schema.org',
      '@type': 'Organization',
      'name': 'VidSEOKit',
      'url': kSiteUrl,
      'logo': '\$kSiteUrl/images/og-image.jpg',
      'description': 'Premium YouTube SEO & Growth Tools for Content Creators',
      'areaServed': const [
        {'@type': 'Country', 'name': 'United States'},
        {'@type': 'Country', 'name': 'Canada'},
        {'@type': 'Country', 'name': 'United Kingdom'},
        {'@type': 'Country', 'name': 'Ireland'},
        {'@type': 'Country', 'name': 'Australia'},
        {'@type': 'Place', 'name': 'Europe'},
      ],
      'knowsLanguage': const ['en-US', 'en-GB', 'en-CA', 'en-AU'],
      if (kSocialProfiles.isNotEmpty)
        'sameAs': [for (final s in kSocialProfiles) s.url],
    }));

    // Attributes the X card to the brand account. Omitted entirely while the
    // handle is unset — an empty twitter:site attributes the card to nobody.
    if (kTwitterHandle.isNotEmpty) {
      head.add(Component.element(
        tag: 'meta',
        attributes: {'name': 'twitter:site', 'content': '@\$kTwitterHandle'},
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
    head.add(Component.element(
      tag: 'meta',
      attributes: {'property': 'og:updated_time', 'content': kContentUpdated},
    ));

    // Breadcrumbs describe the path to *this* page, so unlike the product
    // schema in kSiteHead they cannot be shared. The homepage gets none — a
    // one-item trail says nothing.
    if (seo.breadcrumbName.isNotEmpty) {
      head.add(_jsonLd({
        '@context': 'https://schema.org',
        '@type': 'BreadcrumbList',
        'itemListElement': [
          {'@type': 'ListItem', 'position': 1, 'name': 'Home', 'item': '\$kSiteUrl/'},
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
              'url': '\$kSiteUrl/${blogPosts[i].url}',
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
    return div(classes: 'border-t border-yt-gray-200 dark:border-yt-gray-800 mt-16 mb-20 md:mb-0 pb-8 animate-fade-in animate-delay-500', [
      div(classes: 'max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-6', [
        div(classes: 'flex flex-col md:flex-row items-center justify-between gap-4', [
           div(classes: 'flex items-center gap-2', [
            _buildLogoIcon('w-5 h-5'),
            span(classes: 'font-bold text-sm text-yt-gray-900 dark:text-white tracking-tight', [Component.text(t('nav_logo_text'))]),
          ]),
          div(classes: 'flex flex-wrap justify-center gap-4', [
            button(classes: 'text-xs text-yt-gray-500 hover:text-yt-gray-900 dark:hover:text-white transition-colors', onClick: () => switchTab('about'), [Component.text(t('footer_about'))]),
            button(classes: 'text-xs text-yt-gray-500 hover:text-yt-gray-900 dark:hover:text-white transition-colors', onClick: () => switchTab('contact'), [Component.text(t('footer_contact'))]),
            button(classes: 'text-xs text-yt-gray-500 hover:text-yt-gray-900 dark:hover:text-white transition-colors', onClick: () => switchTab('privacy'), [Component.text(t('footer_privacy_policy'))]),
            button(classes: 'text-xs text-yt-gray-500 hover:text-yt-gray-900 dark:hover:text-white transition-colors', onClick: () => switchTab('terms'), [Component.text(t('footer_terms_service'))]),
            button(classes: 'text-xs text-yt-gray-500 hover:text-yt-gray-900 dark:hover:text-white transition-colors', onClick: openConsentPreferences, [Component.text(t('footer_cookies'))]),
          ]),
          if (kSocialProfiles.isNotEmpty)
            div(classes: 'flex flex-wrap justify-center gap-4', [
              for (final profile in kSocialProfiles)
                a(
                  href: profile.url,
                  classes: 'text-xs text-yt-gray-500 hover:text-yt-gray-900 dark:hover:text-white transition-colors',
                  attributes: const {'rel': 'me noopener', 'target': '_blank'},
                  [Component.text(profile.name)],
                ),
            ]),
          p(classes: 'text-xs text-yt-gray-500', [Component.text(t('footer_copyright'))]),
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
        a(href: 'mailto:info@easysignly.com', classes: 'font-medium text-yt-red hover:underline', [Component.text('info@easysignly.com')])
      ])
    ]);
  }

  Component _buildStaticPage(String title, List<Component> content) {
    return div(classes: 'max-w-3xl mx-auto px-4 py-12 animate-fade-in-up', [
      h1(classes: 'text-3xl font-bold mb-6 text-yt-gray-900 dark:text-white', [Component.text(title)]),
      div(classes: 'prose dark:prose-invert max-w-none text-yt-gray-600 dark:text-yt-gray-400 space-y-4 leading-relaxed', content)
    ]);
  }
}
