import 'package:jaspr/jaspr.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class App extends StatefulComponent {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  String _activeTab = 'seo';
  
  // SEO Analyzer State
  String seoTargetKeyword = '';
  String seoTitle = '';
  String seoDescription = '';
  Map<String, dynamic>? seoResult;

  // Title Generator State
  String titleTopic = '';
  List<dynamic>? generatedTitles;

  // Tag Extractor State
  String tagUrl = '';
  List<dynamic>? extractedTags;

  // Earnings Calculator State
  int dailyViews = 10000;
  String selectedNiche = 'Finance';
  Map<String, dynamic>? earningsResult;
  
  bool isLoading = false;

  void switchTab(String tab) {
    setState(() {
      _activeTab = tab;
    });
  }

  Future<void> calculateSeo() async {
    setState(() => isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/calculate-seo'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'target_keyword': seoTargetKeyword,
          'title': seoTitle,
          'description': seoDescription,
          'tags': [],
        }),
      );
      if (response.statusCode == 200) {
        setState(() => seoResult = jsonDecode(response.body));
      }
    } catch (e) {
      print('Error: $e');
    }
    setState(() => isLoading = false);
  }

  Future<void> generateTitles() async {
    setState(() => isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/generate-titles'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'topic': titleTopic}),
      );
      if (response.statusCode == 200) {
        setState(() => generatedTitles = jsonDecode(response.body));
      }
    } catch (e) {
      print('Error: $e');
    }
    setState(() => isLoading = false);
  }

  Future<void> extractTags() async {
    setState(() => isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/extract-tags'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'url': tagUrl}),
      );
      if (response.statusCode == 200) {
        setState(() => extractedTags = jsonDecode(response.body)['tags']);
      }
    } catch (e) {
      print('Error: $e');
    }
    setState(() => isLoading = false);
  }

  Future<void> calculateEarnings() async {
    setState(() => isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/calculate-earnings'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'daily_views': dailyViews,
          'niche': selectedNiche,
        }),
      );
      if (response.statusCode == 200) {
        setState(() => earningsResult = jsonDecode(response.body));
      }
    } catch (e) {
      print('Error: $e');
    }
    setState(() => isLoading = false);
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(classes: 'min-h-screen bg-[#09090b] text-[#f3f4f6] font-sans', [
      // Header
      header(classes: 'py-6 px-4 border-b border-[#27272a] text-center', [
        h1(classes: 'text-3xl font-bold text-[#3b82f6]', [text('CreatorTools.io')]),
        p(classes: 'text-[#9ca3af] mt-2', [text('Premium Web Utility for YouTube Creators (Tier-1)')])
      ]),
      
      // Main Content
      main(classes: 'container mx-auto px-4 py-8 max-w-4xl', [
        // Tabs
        div(classes: 'flex overflow-x-auto space-x-2 pb-2 mb-6 border-b border-[#27272a]', [
          _buildTabButton('SEO Analyzer', 'seo'),
          _buildTabButton('Title Generator', 'titles'),
          _buildTabButton('Tag Extractor', 'tags'),
          _buildTabButton('Earnings Calculator', 'earnings'),
        ]),

        // Tab Content
        div(classes: 'bg-[#18181b] rounded-xl p-6 border border-[#27272a] animate-fade-up', [
          if (_activeTab == 'seo') _buildSeoAnalyzer(),
          if (_activeTab == 'titles') _buildTitleGenerator(),
          if (_activeTab == 'tags') _buildTagExtractor(),
          if (_activeTab == 'earnings') _buildEarningsCalculator(),
        ]),
        
        // SEO & Content Strategy Article
        _buildSeoArticle(),
      ])
    ]);
  }

  Component _buildTabButton(String label, String id) {
    bool isActive = _activeTab == id;
    return button(
      classes: 'whitespace-nowrap px-6 py-3 rounded-lg font-medium transition-all duration-300 btn-press ' +
          (isActive ? 'bg-[#3b82f6] text-white shadow-[0_8px_20px_rgba(37,99,235,0.3)]' : 'bg-transparent text-[#9ca3af] hover:bg-[#27272a] hover:text-white'),
      events: {'click': (e) => switchTab(id)},
      [text(label)],
    );
  }

  Component _buildSeoAnalyzer() {
    return div(classes: 'grid grid-cols-1 md:grid-cols-2 gap-6', [
      div(classes: 'space-y-4', [
        h2(classes: 'text-xl font-semibold text-white', [text('SEO Analyzer')]),
        input(
          classes: 'w-full bg-[#09090b] border border-[#27272a] rounded-lg py-3 px-4 focus:-translate-y-1 focus:shadow-lg focus:shadow-blue-500/10 transition-all duration-300 outline-none focus:border-[#3b82f6]',
          placeholder: 'Target Keyword',
          onInput: (e) => setState(() => seoTargetKeyword = e),
        ),
        input(
          classes: 'w-full bg-[#09090b] border border-[#27272a] rounded-lg py-3 px-4 focus:-translate-y-1 focus:shadow-lg focus:shadow-blue-500/10 transition-all duration-300 outline-none focus:border-[#3b82f6]',
          placeholder: 'Video Title',
          onInput: (e) => setState(() => seoTitle = e),
        ),
        textarea(
          classes: 'w-full bg-[#09090b] border border-[#27272a] rounded-lg py-3 px-4 focus:-translate-y-1 focus:shadow-lg focus:shadow-blue-500/10 transition-all duration-300 outline-none focus:border-[#3b82f6] h-32',
          placeholder: 'Description Snippet',
          events: {'input': (e) => setState(() => seoDescription = e.target.value)},
        ),
        button(
          classes: 'w-full bg-[#3b82f6] hover:bg-blue-600 text-white font-semibold py-4 rounded-lg transition-all duration-300 hover:-translate-y-1 hover:shadow-[0_8px_20px_rgba(37,99,235,0.3)] btn-press',
          events: {'click': (e) => calculateSeo()},
          [text(isLoading ? 'Analyzing...' : 'Analyze SEO')],
        ),
      ]),
      div(classes: 'bg-[#09090b] rounded-lg p-6 border border-[#27272a] h-full', [
        if (seoResult != null) div(classes: 'animate-scale-in text-center', [
          div(classes: 'text-5xl font-bold mb-4 ' + ((seoResult!['score'] as int) > 75 ? 'text-[#22c55e]' : 'text-[#eab308]'), [
            text('${seoResult!['score']}/100')
          ]),
          div(classes: 'text-left mt-6 space-y-2', [
            for (var fb in seoResult!['feedback'])
              p(classes: 'text-sm ' + (fb.startsWith('Pass') ? 'text-[#22c55e]' : 'text-[#ef4444]'), [text(fb)])
          ])
        ]) else p(classes: 'text-[#9ca3af] text-center mt-20', [text('Results will appear here')])
      ])
    ]);
  }

  Component _buildTitleGenerator() {
    return div(classes: 'space-y-6', [
      h2(classes: 'text-xl font-semibold text-white', [text('Title Generator')]),
      div(classes: 'flex gap-4', [
        input(
          classes: 'flex-1 bg-[#09090b] border border-[#27272a] rounded-lg py-3 px-4 focus:-translate-y-1 focus:shadow-lg focus:shadow-blue-500/10 transition-all duration-300 outline-none focus:border-[#3b82f6]',
          placeholder: 'Enter a topic (e.g., Personal Finance)',
          onInput: (e) => setState(() => titleTopic = e),
        ),
        button(
          classes: 'bg-[#3b82f6] text-white px-8 py-3 rounded-lg hover:-translate-y-1 transition-all duration-300 btn-press',
          events: {'click': (e) => generateTitles()},
          [text(isLoading ? '...' : 'Generate')],
        )
      ]),
      if (generatedTitles != null) div(classes: 'grid grid-cols-1 md:grid-cols-2 gap-4 animate-scale-in', [
        for (var t in generatedTitles!)
          div(classes: 'bg-[#09090b] p-4 rounded-lg border border-[#27272a] hover:border-[#3b82f6] transition-colors', [
            p(classes: 'text-white font-medium', [text(t['title'])]),
            p(classes: 'text-[#22c55e] text-sm mt-2', [text('Est. CTR: ${t['ctr_score']}%')])
          ])
      ])
    ]);
  }

  Component _buildTagExtractor() {
    return div(classes: 'space-y-6', [
      h2(classes: 'text-xl font-semibold text-white', [text('Tag Extractor (Spy)')]),
      div(classes: 'flex gap-4', [
        input(
          classes: 'flex-1 bg-[#09090b] border border-[#27272a] rounded-lg py-3 px-4 focus:-translate-y-1 focus:shadow-lg transition-all duration-300 outline-none focus:border-[#3b82f6]',
          placeholder: 'Enter YouTube URL',
          onInput: (e) => setState(() => tagUrl = e),
        ),
        button(
          classes: 'bg-[#3b82f6] text-white px-8 py-3 rounded-lg hover:-translate-y-1 transition-all duration-300 btn-press',
          events: {'click': (e) => extractTags()},
          [text(isLoading ? '...' : 'Extract')],
        )
      ]),
      if (extractedTags != null) div(classes: 'flex flex-wrap gap-2 animate-scale-in', [
        for (var tag in extractedTags!)
          span(classes: 'bg-[#27272a] text-[#f3f4f6] px-3 py-1 rounded-full text-sm', [text(tag)])
      ])
    ]);
  }

  Component _buildEarningsCalculator() {
    return div(classes: 'grid grid-cols-1 md:grid-cols-2 gap-6', [
      div(classes: 'space-y-6', [
        h2(classes: 'text-xl font-semibold text-white', [text('Earnings Calculator')]),
        div([
          label(classes: 'block text-sm text-[#9ca3af] mb-2', [text('Daily Views: $dailyViews')]),
          input(
            classes: 'w-full accent-[#3b82f6]',
            attributes: {'type': 'range', 'min': '1000', 'max': '100000', 'step': '1000'},
            events: {'input': (e) => setState(() => dailyViews = int.parse(e.target.value))},
          ),
        ]),
        div([
          label(classes: 'block text-sm text-[#9ca3af] mb-2', [text('Select Niche')]),
          select(
            classes: 'w-full bg-[#09090b] border border-[#27272a] rounded-lg py-3 px-4 outline-none focus:border-[#3b82f6]',
            events: {'change': (e) => setState(() => selectedNiche = e.target.value)},
            [
              option(attributes: {'value': 'Finance'}, [text('Finance & Investing')]),
              option(attributes: {'value': 'Tech'}, [text('Technology')]),
              option(attributes: {'value': 'Gaming'}, [text('Gaming')]),
              option(attributes: {'value': 'Vlog'}, [text('Vlogging & Lifestyle')]),
            ]
          )
        ]),
        button(
          classes: 'w-full bg-[#3b82f6] text-white font-semibold py-4 rounded-lg hover:-translate-y-1 transition-all duration-300 btn-press',
          events: {'click': (e) => calculateEarnings()},
          [text(isLoading ? 'Calculating...' : 'Calculate Revenue')],
        ),
      ]),
      div(classes: 'bg-[#09090b] rounded-lg p-6 border border-[#27272a] h-full flex flex-col justify-center items-center', [
        if (earningsResult != null) div(classes: 'animate-scale-in text-center', [
          p(classes: 'text-[#9ca3af]', [text('Estimated Monthly Revenue (Tier-1)')]),
          h3(classes: 'text-3xl font-bold text-[#22c55e] mt-4', [
            text('\$${earningsResult!['min_monthly']} - \$${earningsResult!['max_monthly']}')
          ])
        ]) else p(classes: 'text-[#9ca3af] text-center', [text('Select options to calculate')])
      ])
    ]);
  }

  Component _buildSeoArticle() {
    return div(classes: 'mt-12 bg-[#18181b] rounded-xl p-8 border border-[#27272a]', [
      h2(classes: 'text-2xl font-bold text-white mb-4', [text('The Ultimate Guide to YouTube Monetization & Growth')]),
      div(classes: 'prose prose-invert max-w-none text-[#9ca3af] leading-relaxed', [
        p([text('To succeed on YouTube today, mastering Search Engine Optimization (SEO) is critical. Whether your goal is to boost your AdSense revenue or reach a highly targeted target audience, leveraging tools for video analytics and calculating your Click-Through Rate (CTR) can significantly improve your video engagement rate.')]),
        p(classes: 'mt-4', [text('Using a robust keyword research tool helps you conduct in-depth competitor analysis to find high CPC keywords. These High RPM keywords are essential when building passive income streams or diversifying with affiliate marketing strategies and sponsored content.')]),
        p(classes: 'mt-4', [text('Treating your channel as an online business means adapting quickly to every new algorithm update. By utilizing the best content creation tools, you can ensure steady organic traffic growth and execute an effective digital marketing plan. Ultimately, this approach will help you rank higher on YouTube and maximize your monetization efforts.')]),
      ])
    ]);
  }
}
