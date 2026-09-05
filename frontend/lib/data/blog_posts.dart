// GENERATED FILE - do not edit by hand.
// Source: blog_src/posts.json + blog_src/posts/*.html
// Regenerate with: python3 blog_src/build_blog.py

/// Metadata for one published article under web/blog/.
class BlogPost {
  final String slug;
  final String title;
  final String description;
  final String category;
  final String date;
  final int readMinutes;
  final String imageUrl;

  const BlogPost({
    required this.slug,
    required this.title,
    required this.description,
    required this.category,
    required this.date,
    required this.readMinutes,
    required this.imageUrl,
  });

  /// Path to the standalone, crawlable article page.
  String get url => 'blog/$slug.html';
}

/// Every article, newest first.
const List<BlogPost> blogPosts = [
  BlogPost(
    slug: 'rank-higher-youtube-search',
    title: 'How to Rank Higher on YouTube Search: A 9-Step Optimization Workflow',
    description: 'YouTube search rewards relevance, engagement and satisfaction — in that order. Here is the repeatable nine-step workflow we use to plan, publish and re-optimise a video so it earns search traffic for years.',
    category: 'SEO',
    date: 'September #d, 2026',
    readMinutes: 7,
    imageUrl: 'images/blog/hero/rank-higher-youtube-search.svg',
  ),
  BlogPost(
    slug: 'improve-youtube-click-through-rate',
    title: 'How to Improve Your YouTube Click-Through Rate Without Clickbait',
    description: 'Half of all YouTube channels sit between a 2% and 10% impressions click-through rate. Here is how packaging, thumbnail contrast and title–promise alignment lift CTR without wrecking retention.',
    category: 'Analytics',
    date: 'August #d, 2026',
    readMinutes: 6,
    imageUrl: 'images/blog/hero/improve-youtube-click-through-rate.svg',
  ),
  BlogPost(
    slug: 'youtube-monetization-requirements-guide',
    title: 'YouTube Monetization Requirements: The Complete Eligibility Guide',
    description: '500 subscribers or 1,000? 3,000 watch hours or 4,000? Here are the current YouTube Partner Program thresholds, what each tier actually unlocks, and the policy checks that quietly disqualify channels.',
    category: 'Monetization',
    date: 'August #d, 2026',
    readMinutes: 6,
    imageUrl: 'images/blog/hero/youtube-monetization-requirements-guide.svg',
  ),
  BlogPost(
    slug: 'how-to-increase-youtube-rpm',
    title: 'How to Increase Your YouTube RPM: 11 Levers That Actually Move Revenue',
    description: 'RPM is the only revenue metric that reflects what you actually keep. Here are eleven levers — from ad load and video length to audience geography and niche selection — ranked by how much they realistically move the number.',
    category: 'Monetization',
    date: 'August #d, 2026',
    readMinutes: 6,
    imageUrl: 'images/blog/hero/how-to-increase-youtube-rpm.svg',
  ),
  BlogPost(
    slug: 'youtube-keyword-research-tools',
    title: 'YouTube Keyword Research: Finding Search Terms Your Channel Can Actually Rank For',
    description: 'Most keyword research fails because it chases volume instead of winnability. This guide covers the free data sources, the competition test, and how to build a keyword map that fills a publishing calendar for six months.',
    category: 'SEO',
    date: 'August #d, 2026',
    readMinutes: 7,
    imageUrl: 'images/blog/hero/youtube-keyword-research-tools.svg',
  ),
  BlogPost(
    slug: 'high-cpc-keywords-youtube-niches',
    title: 'High CPC Keywords and the YouTube Niches That Attract Them',
    description: 'Advertiser demand, not view count, sets your ad rates. Here is how high CPC keywords work, which niches consistently attract them, and how to move a channel toward higher-value topics without abandoning your audience.',
    category: 'Monetization',
    date: 'August #d, 2026',
    readMinutes: 6,
    imageUrl: 'images/blog/hero/high-cpc-keywords-youtube-niches.svg',
  ),
  BlogPost(
    slug: 'youtube-analytics-metrics-that-matter',
    title: 'The 8 YouTube Analytics Metrics That Actually Predict Growth',
    description: 'YouTube Studio reports dozens of numbers and most of them are noise. These eight metrics — and the specific thresholds attached to them — tell you whether a video is working and what to fix next.',
    category: 'Analytics',
    date: 'August #d, 2026',
    readMinutes: 6,
    imageUrl: 'images/blog/hero/youtube-analytics-metrics-that-matter.svg',
  ),
  BlogPost(
    slug: 'how-youtube-algorithm-works',
    title: 'How the YouTube Algorithm Works (and What an Algorithm Update Really Changes)',
    description: 'There is no single YouTube algorithm. There are separate systems for search, home and suggested — and understanding which one is feeding a video tells you exactly what to fix when views fall off a cliff.',
    category: 'Strategy',
    date: 'July #d, 2026',
    readMinutes: 6,
    imageUrl: 'images/blog/hero/how-youtube-algorithm-works.svg',
  ),
  BlogPost(
    slug: 'youtube-competitor-analysis-guide',
    title: 'YouTube Competitor Analysis: A Repeatable 6-Step Teardown',
    description: 'Copying a competitor\'s topics is the least useful thing you can do. This teardown method finds the format gaps, packaging patterns and neglected keywords that a bigger channel has left on the table.',
    category: 'Strategy',
    date: 'July #d, 2026',
    readMinutes: 6,
    imageUrl: 'images/blog/hero/youtube-competitor-analysis-guide.svg',
  ),
  BlogPost(
    slug: 'youtube-engagement-rate-calculation',
    title: 'Video Engagement Rate: How to Calculate It and What Counts as Good',
    description: 'Brands ask for your engagement rate, but nobody agrees on the formula. Here are the three definitions in circulation, the one to quote in a media kit, and realistic benchmarks by channel size.',
    category: 'Analytics',
    date: 'July #d, 2026',
    readMinutes: 5,
    imageUrl: 'images/blog/hero/youtube-engagement-rate-calculation.svg',
  ),
  BlogPost(
    slug: 'find-target-audience-youtube',
    title: 'How to Find Your Target Audience on YouTube (Without Guessing)',
    description: '“Everyone interested in tech” is not an audience. This is the data-led process for narrowing a target audience using your own analytics, the other-videos-your-audience-watched report and a simple viewer profile.',
    category: 'Growth',
    date: 'July #d, 2026',
    readMinutes: 6,
    imageUrl: 'images/blog/hero/find-target-audience-youtube.svg',
  ),
  BlogPost(
    slug: 'adsense-revenue-per-1000-views',
    title: 'AdSense Revenue Explained: What YouTube Actually Pays per 1,000 Views',
    description: 'Where the money comes from, how the 55% split works, why your RPM is far below the CPM you see in Studio, and how to build an earnings estimate you can plan a business around.',
    category: 'Monetization',
    date: 'July #d, 2026',
    readMinutes: 6,
    imageUrl: 'images/blog/hero/adsense-revenue-per-1000-views.svg',
  ),
  BlogPost(
    slug: 'passive-income-streams-youtube-creators',
    title: '7 Passive Income Streams That Work for YouTube Creators',
    description: 'Ad revenue is the least reliable money a channel makes. Here are seven income streams ranked by how much upkeep they need, with realistic conversion rates and the traffic level each one needs to be worth building.',
    category: 'Monetization',
    date: 'July #d, 2026',
    readMinutes: 6,
    imageUrl: 'images/blog/hero/passive-income-streams-youtube-creators.svg',
  ),
  BlogPost(
    slug: 'youtube-affiliate-marketing-strategies',
    title: 'Affiliate Marketing Strategies for YouTube Creators That Don\'t Annoy Your Audience',
    description: 'The gap between a channel earning \$40 a month in affiliate commission and one earning \$4,000 is almost never traffic. It is intent matching, placement and trust. Here is how the high earners structure it.',
    category: 'Marketing',
    date: 'July #d, 2026',
    readMinutes: 6,
    imageUrl: 'images/blog/hero/youtube-affiliate-marketing-strategies.svg',
  ),
  BlogPost(
    slug: 'youtube-sponsored-content-brand-deals',
    title: 'Sponsored Content: How Small Channels Land (and Price) Brand Deals',
    description: 'You do not need 100,000 subscribers to be sponsored. You need a defined audience, honest numbers and a media kit. Here is the outreach process, the pricing maths and the contract terms worth arguing about.',
    category: 'Marketing',
    date: 'June #d, 2026',
    readMinutes: 6,
    imageUrl: 'images/blog/hero/youtube-sponsored-content-brand-deals.svg',
  ),
  BlogPost(
    slug: 'content-creation-tools-youtube-creators',
    title: 'The Content Creation Tools Stack for a One-Person YouTube Channel',
    description: 'A practical tool stack for solo creators, organised by the stage it serves — research, scripting, recording, editing, packaging and analysis — with notes on what is genuinely worth paying for.',
    category: 'Tools',
    date: 'June #d, 2026',
    readMinutes: 6,
    imageUrl: 'images/blog/hero/content-creation-tools-youtube-creators.svg',
  ),
  BlogPost(
    slug: 'organic-traffic-growth-strategy',
    title: 'Organic Traffic Growth: Pairing a YouTube Channel With a Website',
    description: 'A channel and a website feed each other: video answers the query, the article captures the search demand video cannot. Here is how to run both without doubling your workload.',
    category: 'SEO',
    date: 'June #d, 2026',
    readMinutes: 6,
    imageUrl: 'images/blog/hero/organic-traffic-growth-strategy.svg',
  ),
  BlogPost(
    slug: 'digital-marketing-funnel-creators',
    title: 'Digital Marketing for Creators: Building a Funnel Behind Your Videos',
    description: 'Views are rented; an email list is owned. This is the four-stage funnel model adapted for creators, with the specific call to action that belongs at each stage and the numbers to track.',
    category: 'Marketing',
    date: 'June #d, 2026',
    readMinutes: 6,
    imageUrl: 'images/blog/hero/digital-marketing-funnel-creators.svg',
  ),
  BlogPost(
    slug: 'youtube-channel-online-business',
    title: 'Turning a YouTube Channel Into a Real Online Business',
    description: 'The difference between a channel and a business is revenue concentration, documented processes and assets you own. Here is the transition, in the order most sustainable creators actually make it.',
    category: 'Strategy',
    date: 'June #d, 2026',
    readMinutes: 6,
    imageUrl: 'images/blog/hero/youtube-channel-online-business.svg',
  ),
  BlogPost(
    slug: 'youtube-seo-checklist-small-channels',
    title: 'The YouTube SEO Checklist for Channels Under 1,000 Subscribers',
    description: 'Small-channel SEO is a different game: you cannot win on authority, so you win on specificity. This checklist covers the pre-production, upload and post-publish steps that actually move a new channel.',
    category: 'SEO',
    date: 'May #d, 2026',
    readMinutes: 6,
    imageUrl: 'images/blog/hero/youtube-seo-checklist-small-channels.svg',
  ),
];
