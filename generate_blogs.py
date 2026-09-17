import re
import os

with open('frontend/web/blog/youtube-keyword-research-tools.html', 'r') as f:
    template = f.read()

posts = [
    {
        'file': 'tubebuddy-alternative-for-small-channels.html',
        'title': 'TubeBuddy Alternative for Small Channels: Why You Don\'t Need to Pay Yet',
        'description': 'Looking for a TubeBuddy alternative for small channels? Learn how to optimize your YouTube videos for free without paying for expensive subscriptions.',
        'h1': 'The Best Free TubeBuddy Alternative for Small Channels',
        'content': '''
<p>If you have a small channel, paying a monthly subscription for TubeBuddy or VidIQ can eat into your limited budget. The good news is, you don't need to pay yet. VidSEOKit serves as a completely free TubeBuddy alternative for small channels, providing the essential SEO scoring and title generation you need.</p>
<h2>Why Small Channels Don't Need Paid Tools</h2>
<p>Paid tools offer bulk processing and advanced historical data, which are useful for channels publishing daily or managing multiple brands. For a small channel, the primary need is simple: knowing if a title and description are properly optimized for a specific keyword.</p>
<h2>Free Features You Can Use Today</h2>
<p>Instead of hitting a paywall, you can use our <strong>YouTube SEO Analyzer</strong> to check your metadata score instantly, or use the <strong>AI Title Generator</strong> to brainstorm angles that get clicks.</p>
        '''
    },
    {
        'file': 'how-to-rank-youtube-videos-zero-subscribers.html',
        'title': 'How to Rank YouTube Videos with Zero Subscribers (2026 Guide)',
        'description': 'A step-by-step guide on how to rank YouTube videos with zero subscribers by targeting long-tail keywords and optimizing your metadata.',
        'h1': 'How to Rank YouTube Videos with Zero Subscribers',
        'content': '''
<p>Starting a new channel is daunting because the YouTube algorithm has no data on who wants to watch your content. Learning how to rank YouTube videos with zero subscribers is about feeding the algorithm the exact signals it needs to categorize you.</p>
<h2>Target Long-Tail Search Intent</h2>
<p>With zero subscribers, your videos will not get pushed to the Home feed immediately. Search is your best friend. Target specific, low-competition questions that people are typing into the search bar.</p>
<h2>Optimize Metadata Relentlessly</h2>
<p>Use a tool like VidSEOKit to ensure your title, description, and tags are perfectly aligned with your target keyword. When you have no subscriber base to boost your initial click-through rate, your metadata must do all the heavy lifting.</p>
        '''
    },
    {
        'file': 'find-untapped-youtube-niches-low-competition.html',
        'title': 'How to Find Untapped YouTube Niches with Low Competition',
        'description': 'Discover proven strategies to find untapped YouTube niches with low competition and high growth potential for new creators.',
        'h1': 'How to Find Untapped YouTube Niches with Low Competition',
        'content': '''
<p>The fastest way to grow on YouTube is to be the big fish in a small pond. This guide explains how to find untapped YouTube niches with low competition where you can establish authority quickly.</p>
<h2>Look for Cross-Sections</h2>
<p>Instead of starting a general "Tech" channel, combine two interests: "Tech for Urban Farmers" or "Minimalist Tech Setup for Students." The intersection of two broad topics often reveals a highly engaged, underserved audience.</p>
<h2>Verify Demand with Search</h2>
<p>Before committing to a niche, check if people are actively asking questions about it. Use our Tag Extractor on videos in adjacent niches to see what keywords are being used, and look for gaps where no dedicated channel exists.</p>
        '''
    },
    {
        'file': 'youtube-seo-competitor-analysis-free.html',
        'title': 'How to Do Competitor YouTube SEO Analysis for Free',
        'description': 'Learn how to perform a competitor YouTube SEO analysis for free to uncover the tags, titles, and strategies driving their views.',
        'h1': 'How to Do Competitor YouTube SEO Analysis for Free',
        'content': '''
<p>You don't need expensive software to reverse-engineer what's working for your competitors. Here is how to do competitor YouTube SEO analysis for free using publicly available data and free tools.</p>
<h2>Analyze Their Metadata</h2>
<p>When a competitor's video ranks #1, their metadata is a roadmap. Use our free YouTube Tag Extractor to pull the exact tags they are using. Note how they structure their title and the first 150 characters of their description.</p>
<h2>Identify Content Gaps</h2>
<p>Read their comments section. Viewers often ask questions that the video failed to answer. Those unanswered questions are your next video topics.</p>
        '''
    },
    {
        'file': 'youtube-algorithm-ranking-factors-optimization-kit.html',
        'title': 'The Ultimate YouTube Algorithm Ranking Factors Optimization Kit',
        'description': 'Master the YouTube algorithm ranking factors with this complete optimization kit, designed to help you boost impressions and CTR.',
        'h1': 'The YouTube Algorithm Ranking Factors Optimization Kit',
        'content': '''
<p>Understanding the YouTube algorithm ranking factors is the difference between hoping for views and engineering them. This optimization kit breaks down the core signals YouTube uses to rank videos.</p>
<h2>Click-Through Rate (CTR) and Retention</h2>
<p>These are the twin pillars of YouTube growth. If people click your video (CTR) and watch it all the way through (Retention), YouTube will promote it. Everything else is secondary.</p>
<h2>Metadata as the Categorization Engine</h2>
<p>Titles, descriptions, and tags don't directly make a video "good," but they tell YouTube *who* to show it to first. Proper SEO ensures your video's initial test audience actually cares about the topic, which naturally leads to higher CTR and Retention.</p>
        '''
    }
]

for post in posts:
    content = template
    # Replace title
    content = re.sub(r'<title>.*?</title>', f'<title>{post["title"]}</title>', content)
    # Replace description meta
    content = re.sub(r'<meta name="description" content=".*?">', f'<meta name="description" content="{post["description"]}">', content)
    # Replace og:title
    content = re.sub(r'<meta property="og:title" content=".*?">', f'<meta property="og:title" content="{post["title"]}">', content)
    # Replace og:description
    content = re.sub(r'<meta property="og:description" content=".*?">', f'<meta property="og:description" content="{post["description"]}">', content)
    # Replace canonical
    content = re.sub(r'<link rel="canonical" href=".*?">', f'<link rel="canonical" href="https://vidseokit.com/blog/{post["file"]}">', content)
    
    # Replace article body
    article_pattern = re.compile(r'<article class="post">.*?</article>', re.DOTALL)
    new_article = f'''<article class="post">
      <header class="post-header">
        <h1>{post["h1"]}</h1>
        <div class="meta">
          <time datetime="2026-09-12">12 September 2026</time>
          <span class="author">The VidSEOKit Editorial Team</span>
        </div>
      </header>
      <div class="post-content">
        {post["content"]}
      </div>
    </article>'''
    content = re.sub(article_pattern, new_article, content)
    
    with open(f'frontend/web/blog/{post["file"]}', 'w') as f:
        f.write(content)

