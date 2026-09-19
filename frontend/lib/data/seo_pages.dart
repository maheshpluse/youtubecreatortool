/// Per-route SEO metadata and the long-form copy rendered beneath each tool.
///
/// The tools are interactive and, before a visitor types anything, produce
/// almost no crawlable text — the pre-rendered homepage was ~150 words, most of
/// it the language picker. Search engines and ad reviewers read the page as it
/// ships, not as it looks after someone clicks, so every route carries a
/// written section and an FAQ here.
library;

const String kSiteUrl = 'https://vidseokit.com';

class FaqItem {
  final String question;
  final String answer;
  const FaqItem(this.question, this.answer);
}

class ContentSection {
  final String heading;
  final List<String> paragraphs;
  const ContentSection(this.heading, this.paragraphs);
}

class Source {
  final String title;
  final String url;
  const Source(this.title, this.url);
}

class PageSeo {
  /// Rendered as `<title>`. Kept under ~60 characters so it is not truncated
  /// in results.
  final String title;
  final String h1;

  /// Rendered as `<meta name="description">` and `og:description`.
  final String description;

  /// Absolute URL this page should be indexed under. Routes that render
  /// identical content point at a single canonical so they are consolidated
  /// rather than competing with each other.
  final String canonical;

  /// Whether this route belongs in sitemap.xml. False for pages that
  /// canonicalise elsewhere or carry no search intent.
  final bool indexable;

  /// One self-contained sentence defining what this page is.
  ///
  /// Answer engines lift the first passage that stands on its own without
  /// surrounding context; a marketing hero does not qualify. Rendered above the
  /// tool and reused as the schema description.
  final String definition;

  /// Label for this page in the breadcrumb trail. Empty means no trail is
  /// emitted (the homepage, where a one-item breadcrumb says nothing).
  final String breadcrumbName;

  /// Where the claims on this page come from. Rendered visibly and mirrored
  /// into the WebPage `citation` property.
  final List<Source> sources;

  final List<ContentSection> sections;
  final List<FaqItem> faqs;

  const PageSeo({
    required this.title,
    this.h1 = '',
    required this.description,
    required this.canonical,
    this.definition = '',
    this.breadcrumbName = '',
    this.indexable = true,
    this.sections = const [],
    this.faqs = const [],
    this.sources = const [],
  });
}

/// Date the written content was last reviewed, in ISO form.
///
/// Emitted as `dateModified` and shown on the page. Undated pages get
/// discounted by answer engines, and the RPM page is explicitly time-sensitive.
/// Bump this when the copy or the figures change.
const String kContentUpdated = '2026-09-19';
const String kContentUpdatedLabel = '19 September 2026';

/// Keyed by the tab id that [_getTabFromPath] resolves, so routing and metadata
/// cannot drift apart.
const Map<String, PageSeo> kPageSeo = {

  'home': PageSeo(
    title: 'VidSEOKit — Free YouTube SEO Toolkit & Creator Tools',
    h1: 'Free Video SEO & Growth Tools — VidSEOKit',
    description: 'Free YouTube SEO toolkit for creators. Score your title, description and tags, generate titles and thumbnail ideas, extract competitor tags and estimate AdSense earnings. No sign-up.',
    canonical: 'https://vidseokit.com/',
    definition: 'VidSEOKit is a free suite of YouTube SEO and analytics tools - SEO scoring, title generation, thumbnail concepts, tag extraction and earnings estimation - that requires no account to use.',
    sections: [
      ContentSection('Free YouTube Tools for Creators', [
        'Welcome to VidSEOKit. We build free tools to help you optimize your metadata, research competitors, and calculate earnings. Get started with our YouTube SEO Analyzer or explore our other tools below.'
      ])
    ],
  ),
  'seo': PageSeo(
    title: 'How to Rank High in YouTube Search - Free SEO Analyzer',
    h1: 'How to Rank High in YouTube Search (Free SEO Analyzer)',
    description:
        'Analyze your video SEO score, generate viral titles, extract competitor tags and estimate YouTube earnings. 100% free, no sign-up required.',
    canonical: '$kSiteUrl/youtube-seo-analyzer',
    definition:
        'The VidSEOKit YouTube SEO Analyzer is a free tool that scores a video\'s title, description and tags against a target keyword, then lists the specific changes to make before publishing.',
    sections: [
      ContentSection('How the YouTube SEO score is calculated', [
        'The analyzer checks the three fields YouTube reads when it decides what a video is about: the title, the description and the tags. Each is scored against the target keyword you enter, then combined into a single number out of 100 so you can tell at a glance whether a video is ready to publish.',
        'Keyword placement carries the most weight. A target keyword that appears in the first few words of the title scores higher than one buried at the end, because both YouTube and the viewer scanning a results page read left to right. The first 150 characters of the description matter for the same reason: that is the portion shown above the fold before anyone clicks "more".',
        'Length is scored as a range rather than a target. Titles between roughly 50 and 60 characters survive truncation on mobile search results, and descriptions under about 100 words tend to under-explain the video to the algorithm. The score flags both extremes instead of pushing you toward one magic number.',
      ]),
      ContentSection('YouTube SEO Score: A Worked Example', [
        'A good score requires balancing keywords and readability. For example, a title like "My Vlog #12" will score poorly. Changing it to "Vlog 12: Exploring the Best Coffee Shops in London" adds targeted keywords. A description that simply says "Subscribe!" misses an opportunity. A good description will weave the keyword "Best Coffee Shops in London" naturally into the first 150 characters, alongside a clear call to action and helpful timestamps.',
        'By testing different combinations of title, description, and tags in the analyzer above, you can often push a video from a 45/100 to an 85/100 in minutes, giving it a much stronger foundation for search and discovery.'
      ]),
    ],
    faqs: [
      FaqItem('What is a good YouTube SEO score?',
          'Anything above 80 means your metadata is not holding the video back. Below 60 usually points to a missing keyword in the title or a description too short for YouTube to categorise confidently. The score measures metadata quality only, so a high score does not guarantee views.'),
      FaqItem('Should my target keyword go at the start of the title?',
          'Where it fits naturally, yes. Front-loading the keyword helps on mobile, where titles are truncated after roughly 40 characters, and it matches how viewers scan a results page. Do not force it at the cost of a title that reads badly - a keyword nobody clicks is worth nothing.'),
      FaqItem('How long should a YouTube description be?',
          'Aim for 150 to 300 words. The first 150 characters appear before the "more" link and should contain your keyword and a reason to watch. The rest gives YouTube context, and is a reasonable place for timestamps, links and chapter markers.'),
      FaqItem('Does changing the title of an old video help?',
          'It can, particularly if the video already gets impressions but a low click-through rate. Re-optimising the title and thumbnail on a video with existing watch history is often faster than publishing a new one. Change one variable at a time so you can tell what worked.'),
      FaqItem('How do I get more of my views from the US, UK and Europe?',
          'Publish so the video lands in the morning in New York and London rather than overnight, since the first hours decide who the algorithm keeps showing it to. Then make the video legibly for that audience - reference the currencies, retailers and regulations those viewers recognise. English subtitles widen reach into the Netherlands, the Nordics and Germany, where English fluency is high.'),
      FaqItem('Is this YouTube SEO analyzer free?',
          'Yes. There is no account, no trial and no view limit. You can analyse as many videos as you like.'),
    ],
  ),
  'titles': PageSeo(
    title: 'AI YouTube Title and Tag Generator — VidSEOKit',
    h1: 'AI YouTube Title & Tag Generator',
    description:
        'Generate click-worthy YouTube titles from any topic. Multiple angles - curiosity, listicle, how-to and result-driven - around your keyword, free.',
    canonical: '$kSiteUrl/youtube-title-generator',
    definition:
        'The VidSEOKit YouTube Title Generator is a free tool that turns a video topic into several ready-to-use title options, each written to a different framing so you can compare angles side by side.',
    breadcrumbName: 'YouTube Title Generator',
    sections: [
      ContentSection('Why the title decides whether the video gets watched', [
        'YouTube shows almost every video to a small test audience first. What happens in that window decides everything after it, and the title is half of what those viewers see. A video with strong retention and a weak title never gets far enough for the retention to matter.',
        'The generator returns several titles per topic rather than one, deliberately. Different framings suit different videos: a curiosity gap works for a story, a number works for a roundup, and a plain how-to phrasing works when people are searching for a specific fix. Seeing them side by side makes the right choice obvious in a way that staring at a blank field does not.',
      ]),
      ContentSection('Choosing between the options', [
        'Pick for search intent first. If people find the video by typing a question, the title should contain something close to that question. If they find it in suggested video or on the home feed, the title is competing on curiosity against everything else on screen, and specificity beats cleverness.',
        'Read each candidate at mobile width, where titles are cut after roughly 40 characters. If the first half stops making sense on its own, rewrite it so the meaning survives truncation.'
      ]),
      ContentSection('Pair your title with a strong description', [
        'While the title grabs attention, the description provides the context that search algorithms need. A good title generator works best when paired with a video description that seamlessly weaves in the same target keywords.',
        'Always ensure the first 150 characters of your description complement the generated title. This snippet appears in search results and acts as a secondary hook for viewers deciding whether to click. Use our YouTube Description Generator to produce the description in the same pass.'
      ]),
    ],
    faqs: [
      FaqItem('How long should a YouTube title be?',
          'Between 50 and 60 characters is the practical range. That fits before truncation on most surfaces while leaving room for a specific claim. Titles under 30 characters usually leave useful keywords on the table.'),
      FaqItem('Do numbers in titles actually improve click-through rate?',
          'They help when the number is real and the video delivers it - a list of seven things, a result achieved in 30 days. They stop helping the moment they become decoration, because viewers learn to discount them.'),
      FaqItem('Should every title contain my keyword?',
          'Include it when the video is aimed at search. For videos aimed at the home feed or suggested video, the keyword matters less than a reason to click, and the description and tags can carry the search signal instead.'),
      FaqItem('Can I edit the generated titles?',
          'Yes, and you generally should. Treat the output as a set of starting angles - the strongest final titles usually come from taking one option and tightening it with details only you know about the video.'),
      FaqItem('Should I use US or UK spelling in titles?',
          'Match the audience you want. YouTube search treats "optimize" and "optimise" as near-equivalent, so ranking barely changes, but the spelling signals to a viewer whether the video is written for them. If your audience spans both, US spelling has the larger search volume.'),
      FaqItem('Is the title generator free to use?',
          'Yes, with no account required and no cap on how many topics you can run.'),
    ],
  ),
  'thumbnails': PageSeo(
    title: 'YouTube Thumbnail Ideas Generator - Free AI Concepts',
    h1: 'YouTube Thumbnail Ideas Generator',
    description:
        'Get AI thumbnail concepts for any video topic - subject, expression, text overlay and colour direction - so you stop guessing at what to design.',
    canonical: '$kSiteUrl/youtube-thumbnail-ideas',
    definition:
        'The VidSEOKit Thumbnail Ideas Generator is a free tool that turns a video topic into concrete thumbnail concepts - subject, expression, overlay text and colour direction - to design or brief from.',
    breadcrumbName: 'YouTube Thumbnail Ideas',
    sections: [
      ContentSection('What makes a thumbnail work', [
        'A thumbnail is judged at about 210 pixels wide on a phone, next to a dozen competitors, in under a second. Almost every failure traces back to ignoring that: too many elements, text sized for a desktop preview, or a colour palette that disappears against the YouTube background in dark mode.',
        'The generator returns concepts rather than finished images - a subject, an expression, a short text overlay and a colour direction. That is deliberate. The design decision that matters is what the thumbnail communicates, and it is far easier to judge four written concepts against your video than to redraw four images.',
      ]),
      ContentSection('Testing rather than guessing', [
        'Keep overlay text to three or four words. The title is already next to the thumbnail, so repeating it wastes the only space you have; the text should add a second idea, not restate the first.',
        'Once a video is live, YouTube Studio can test thumbnail variants against each other on real traffic. Use the concepts here to produce genuinely different options - a different subject or framing, not the same image with a new font - because a test between two near-identical thumbnails tells you nothing.',
      ]),
    ],
    faqs: [
      FaqItem('What size should a YouTube thumbnail be?',
          '1280 by 720 pixels, 16:9, under 2MB, as JPG or PNG. Design it at that size but review it scaled down to roughly 210 pixels wide, which is closer to how most people will actually see it.'),
      FaqItem('How much text belongs on a thumbnail?',
          'Three to four words at most. Anything longer is unreadable at feed size, and the words compete with the title sitting directly beneath.'),
      FaqItem('Does my face need to be in the thumbnail?',
          'Faces reliably draw attention, and a clear expression tends to outperform a neutral one. It is not a rule - product shots, before-and-after comparisons and screenshots all work when the subject is legible at small size.'),
      FaqItem('Can I change a thumbnail after publishing?',
          'Yes, and it is one of the highest-leverage edits available. A video with impressions but a low click-through rate is usually a thumbnail problem, and swapping it can revive a video months after upload.'),
      FaqItem('Does this tool generate the image itself?',
          'It generates the concept - subject, expression, text and colour direction - which you then design or brief to a designer. The thinking is the part that decides whether the thumbnail works.'),
    ],
  ),
  'tags': PageSeo(
    title: 'YouTube Competitor Analysis & Tag Extractor Tool',
    h1: 'YouTube Competitor Analysis & Tag Extractor',
    description:
        'Paste any YouTube URL to extract its tags. See how ranking videos in your niche describe themselves and find keywords worth targeting.',
    canonical: '$kSiteUrl/youtube-tag-extractor',
    definition:
        'The VidSEOKit YouTube Tag Extractor is a free tool that reads the public tags off any YouTube video URL, so you can see how videos already ranking in your niche describe themselves.',
    breadcrumbName: 'YouTube Tag Extractor',
    sections: [
      ContentSection('What tags are worth to you now', [
        'Tags are a minor ranking factor. YouTube has said so directly, and the description and title carry far more weight. Their remaining value is diagnostic: they show how a video that is already ranking chooses to describe itself, and that is competitive research you cannot get any other way.',
        'The practical use is pattern-finding across several videos rather than copying one. Extract tags from the top five results for a query you want to rank for, and the vocabulary that repeats is the vocabulary the algorithm already associates with that topic. That belongs in your title and description, where it counts, not just in your own tag field.',
      ]),
      ContentSection('Using tags on your own videos', [
        'Ten to fifteen tags is plenty. Start with the exact phrase someone would search, add a few close variants, and include your channel name so your own videos surface alongside each other in suggested video.',
        'Do not stuff tags with unrelated high-volume terms. It does not work - YouTube reads the video itself - and tagging a video with topics it does not cover risks it being shown to an audience that leaves immediately, which is the one signal that genuinely damages reach.',
      ]),
    ],
    faqs: [
      FaqItem('Do YouTube tags still matter in 2026?',
          'Only slightly for ranking. YouTube relies mainly on the title, description and the content of the video itself. Tags are most useful as research - seeing what already ranks - and for catching common misspellings of your topic.'),
      FaqItem('How many tags should I add to a video?',
          'Around ten to fifteen relevant ones. Beyond that you are diluting rather than adding, and YouTube caps the tag field at 500 characters in any case.'),
      FaqItem('Can I see the tags on any YouTube video?',
          'Tags are part of a video public metadata, so yes for public videos. Paste the URL and the extractor returns them. Private and unlisted videos are not accessible.'),
      FaqItem('Should I copy a competitor tags exactly?',
          'No. Copy the vocabulary, not the list. Look for terms that appear across several ranking videos and work those phrases into your own title and description, which carry far more weight than the tag field does.'),
      FaqItem('Is the tag extractor free?',
          'Yes, with no account and no limit on how many videos you check.'),
    ],
  ),
  'earnings': PageSeo(
    title: 'YouTube Earnings Calculator - Estimate AdSense Revenue',
    h1: 'YouTube Earnings Calculator',
    description:
        'Estimate YouTube AdSense income from your daily views and niche. See how CPM and RPM differ by category and what actually changes what you get paid.',
    canonical: '$kSiteUrl/youtube-earnings-calculator',
    definition:
        'The VidSEOKit YouTube Earnings Calculator is a free tool that estimates monthly AdSense revenue from your daily view count and content niche, reported as an RPM-based range rather than a single figure.',
    breadcrumbName: 'YouTube Earnings Calculator',
    sections: [
      ContentSection('YouTube Monetization Requirements (2026 Updated)', [
        'Before you can earn AdSense revenue, your channel must meet the YouTube Partner Program monetization requirements. As of 2026, the baseline requirements remain: 1,000 subscribers and either 4,000 valid public watch hours in the last 12 months on long-form videos, or 10 million valid public Shorts views in the last 90 days.',
        'There is also an early access tier for fan funding (Super Chat, Memberships) unlocked at 500 subscribers, 3 public uploads in the last 90 days, and either 3,000 watch hours or 3 million Shorts views. This calculator assumes you meet the full monetization requirements for ad revenue.'
      ]),
      ContentSection('YouTube Shorts Monetization', [
        'YouTube Shorts monetization operates on a pooled revenue model, which is why Shorts RPMs are significantly lower than long-form videos. Creators typically see Shorts RPMs between \$0.04 and \$0.07 per thousand views.',
        'If your primary view source is Shorts, you will need millions of views to generate the same revenue as a long-form video with tens of thousands of views. Adjust the views slider in the calculator accordingly to estimate Shorts earnings.'
      ]),
      ContentSection('CPM, RPM and what you actually get paid', [
        'CPM is what an advertiser pays per thousand ad impressions. RPM is what lands in your account per thousand video views, after YouTube takes its 45% share and after accounting for the views that never showed an ad at all. RPM is always the lower and more useful number, and it is the one this calculator estimates.',
        'The gap between the two surprises most creators. A niche with a \$12 CPM does not pay \$12 per thousand views: only a fraction of views are monetised, and the split applies to what remains. Expect real RPM to land somewhere between a quarter and a half of the headline CPM in most categories.',
      ]),
      ContentSection('Getting paid in the US, UK, Canada and the EU', [
        'AdSense pays once your balance passes \$100 (or the local equivalent - roughly £60, CA\$130, or €70 depending on the rate), and it pays in your local currency, converting at Google\'s rate on the payment date. Payments run monthly, around the 21st, for the balance earned two months prior.',
        'Tax paperwork catches out creators outside the United States. Every creator has to submit US tax information to Google, because views from US viewers are US-sourced income regardless of where you live. Creators in the UK, Ireland, Germany, France and most of the EU can claim treaty benefits on the W-8BEN form and have US withholding reduced to zero or near it; skipping the form means a flat 24% withheld on your total earnings, not just the US portion.',
        'UK and EU creators should also expect currency movement to change their reported earnings month to month even when views are flat, since AdSense accrues in US dollars and converts at payout.',
      ]),
      ContentSection('Why niche moves the number more than view count', [
        'Advertiser demand, not audience size, sets the rate. Finance, software, insurance and business categories command high CPMs because a converted viewer is worth a great deal to the advertiser. Gaming, entertainment and general vlog content sit far lower on the same view count, sometimes by a factor of ten.',
        'Audience geography and video length matter too. Views from the US, UK, Canada and Australia are worth substantially more than the global average, and videos over eight minutes can carry mid-roll ads, which lifts RPM directly. Treat any estimate here as a range for planning, not a forecast - your own YouTube Studio RPM is the only accurate figure.',
      ]),
    ],
    faqs: [
      FaqItem('How much does YouTube pay per 1,000 views?',
          'Most channels see an RPM between roughly \$1 and \$8 per thousand views. Finance and business content can exceed \$15; gaming and entertainment often sit under \$2. Niche, audience country and video length explain nearly all of the variation.'),
      FaqItem('What is the difference between CPM and RPM?',
          'CPM is the advertiser cost per thousand ad impressions before YouTube share. RPM is your revenue per thousand video views after the 55/45 split and after unmonetised views are counted. RPM is what you are actually paid.'),
      FaqItem('When can I start earning from YouTube?',
          'The YouTube Partner Programme requires 1,000 subscribers plus either 4,000 valid public watch hours in twelve months or 10 million Shorts views in 90 days, along with an AdSense account and no active community guideline strikes.'),
      FaqItem('Why is my actual RPM lower than the estimate?',
          'Usually because a large share of your audience is outside high-CPM countries, your videos are under eight minutes so cannot carry mid-rolls, or a meaningful portion of your views come from Shorts, which monetise at a much lower rate.'),
      FaqItem('What is the AdSense payment threshold in the UK and Europe?',
          'The threshold is \$100 or the local equivalent - roughly £60 in the UK and around €70 in the eurozone. Below that, the balance rolls over to the following month. Payments are issued around the 21st for earnings from two months earlier.'),
      FaqItem('Do non-US creators pay US tax on YouTube earnings?',
          'Only on the portion of earnings from US viewers, and most treaty countries reduce it to zero. Creators in the UK, Ireland, Germany, France, Canada and Australia can claim treaty benefits on the W-8BEN form in AdSense. If you submit nothing, Google withholds 24% of your total earnings rather than just the US share.'),
      FaqItem('Are these earnings figures guaranteed?',
          'No. They are planning estimates built from typical CPM ranges per niche. Real earnings vary with season - advertiser spend peaks in Q4 and drops in January - audience location and ad format.'),
    ],
    sources: [
      Source('YouTube Partner Program overview & eligibility, YouTube Help',
          'https://support.google.com/youtube/answer/72851'),
      Source('Understand ad revenue analytics, YouTube Help',
          'https://support.google.com/youtube/answer/9314357'),
      Source('Payment thresholds, Google AdSense Help',
          'https://support.google.com/adsense/answer/1709871'),
      Source('Submitting your U.S. tax info to Google, YouTube Help',
          'https://support.google.com/youtube/answer/10390801'),
    ],
  ),
  'blog': PageSeo(
    title: 'YouTube Growth Blog - SEO, Monetization & Analytics',
    h1: 'YouTube Growth Blog',
    description:
        'In-depth guides on YouTube SEO, the algorithm, monetization, RPM, keyword research and channel analytics - written for creators growing a channel.',
    canonical: '$kSiteUrl/blog',
    definition:
        'The VidSEOKit blog publishes in-depth guides on YouTube SEO, the recommendation algorithm, monetization requirements, RPM and channel analytics.',
    breadcrumbName: 'Blog',
    sections: [
      ContentSection('Guides for growing a channel', [
        'These articles go deeper than the tools do. Where the analyzer gives you a score, the guides explain what the score is measuring and what to change; where the earnings calculator gives you a range, the monetization guides explain what determines which end of that range you land on.',
        'The collection covers four areas: how discovery actually works on YouTube, how to research and target keywords, how monetization and RPM are calculated, and which analytics genuinely predict growth as opposed to merely describing it.',
      ]),
    ],
    faqs: [],
  ),
  'youtube-rpm-by-country': PageSeo(
    title: 'YouTube RPM by Country - US, UK, Canada & Europe 2026',
    h1: 'YouTube RPM by Country',
    description:
        'What YouTube pays per 1,000 views in the US, UK, Canada, Germany, France and across Europe. Typical RPM ranges by country, and why they differ.',
    canonical: '$kSiteUrl/youtube-rpm-by-country',
    definition:
        'YouTube RPM by country is the revenue a channel earns per 1,000 views in each market, which varies roughly fourfold between the highest-paying countries such as the United States and Norway and the lowest-paying European markets.',
    breadcrumbName: 'YouTube RPM by Country',
    sections: [
      ContentSection('Why the same video earns different amounts in each country', [
        'A view from Manhattan and a view from Manila are worth very different amounts, because YouTube is auctioning your ad slot to advertisers who care where the viewer lives. Advertiser demand per head - not audience size - sets your RPM, which is why a channel with 100,000 monthly views from the United States can out-earn one with a million views spread across low-CPM markets.',
        'The practical consequence is that two creators in the same niche, publishing at the same quality, can see a fourfold difference in revenue purely from audience geography. Before concluding that your niche pays badly, check where your viewers actually are: YouTube Studio reports this under Analytics, Audience, Top geographies.',
      ]),
      ContentSection('The United States, Canada and the United Kingdom', [
        'The United States is the benchmark almost every published RPM figure is quoted against, and it has the deepest pool of bidding advertisers. Canada tracks it closely - the gap is widest in finance and narrowest in entertainment. The United Kingdom is the strongest European market, with unusually heavy competition in finance, insurance and property driving rates up in those niches specifically.',
        'For an English-language channel, these three markets plus Australia typically make up the bulk of monetised revenue even when they are a minority of total views. That concentration is worth knowing before you decide which audience to write for.',
      ]),
      ContentSection('Germany, France and the rest of Europe', [
        'Germany is the largest European advertising market by total spend and pays strongly in automotive, software and B2B categories. France has a large audience but lower per-view rates. The Nordic countries and Switzerland are the interesting case: small audiences, but income per viewer high enough that Norway and Switzerland sit close to United States rates.',
        'The Netherlands, Sweden, Denmark and Ireland share a useful property for English-language creators - English fluency is widespread enough that an English channel reaches those audiences at close to local rates without translation. Southern and central Europe pay less per view today, though Poland and its neighbours are rising year on year.',
      ]),
      ContentSection('How to shift your audience toward higher-paying markets', [
        'Publishing time is the lever most creators ignore. Uploading so that a video lands in the morning in New York and London, rather than overnight, changes who sees it first and therefore who the algorithm decides to keep showing it to.',
        'Beyond that, the changes are editorial: reference currencies, retailers, regulations and examples your target market recognises. A video about tax-free savings that says ISA rather than Roth IRA is telling both the viewer and the algorithm which country it is for. Subtitles in English on non-English videos widen reach into exactly these markets.',
      ]),
    ],
    faqs: [
      FaqItem('Which country has the highest YouTube RPM?',
          'The United States, Australia, Norway and Switzerland sit at the top, typically \$5 to \$12 per thousand views across niches. Norway and Switzerland punch above their audience size because income per viewer is very high.'),
      FaqItem('How much does YouTube pay per 1,000 views in the UK?',
          'Typically between \$4 and \$8, making the United Kingdom the strongest large market in Europe. Finance, insurance and property content sits at the top of that range; entertainment and vlogs at the bottom.'),
      FaqItem('How much does YouTube pay in Canada?',
          'Roughly \$4 to \$8.50 per thousand views, close behind the United States. Canadian rates track US rates most closely in technology and finance.'),
      FaqItem('What is the YouTube RPM in Germany?',
          'Around \$3 to \$7 per thousand views. Germany is Europe largest ad market by total spend, and pays particularly well in automotive, software and business categories.'),
      FaqItem('Why is my RPM lower than these figures?',
          'Most often because a large share of your views come from outside these markets, because your videos are under eight minutes and cannot carry mid-roll ads, or because a meaningful portion of your views are Shorts, which monetise at a much lower rate.'),
      FaqItem('Are these RPM figures guaranteed?',
          'No. They are typical reported ranges, not measurements of your channel. Advertiser spend also swings seasonally - it peaks in the fourth quarter and drops sharply in January. Your own YouTube Studio RPM is the only accurate number.'),
    ],
    sources: [
      Source('Understand ad revenue analytics, YouTube Help',
          'https://support.google.com/youtube/answer/9314357'),
      Source('How much will you earn with AdSense?, Google AdSense Help',
          'https://support.google.com/adsense/answer/9903'),
      Source('Payment thresholds, Google AdSense Help',
          'https://support.google.com/adsense/answer/1709871'),
      Source('YouTube Partner Program overview & eligibility, YouTube Help',
          'https://support.google.com/youtube/answer/72851'),
    ],
  ),

  'vidiq-alternative-free': PageSeo(
    title: 'VidIQ Alternative Free: VidSEOKit vs VidIQ (2026)',
    h1: 'The Best Free VidIQ Alternative',
    description: 'Looking for a free VidIQ alternative? VidSEOKit offers YouTube SEO scoring, AI titles, and tag extraction with zero paywalls and no sign-ups required.',
    canonical: '$kSiteUrl/vidiq-alternative-free',
    definition: 'VidSEOKit is a 100% free alternative to VidIQ, providing essential YouTube SEO tools without subscriptions, paywalled features, or mandatory account creation.',
    breadcrumbName: 'VidIQ Alternative',
    sections: [
      ContentSection('Why Choose a Free VidIQ Alternative?', [
        'VidIQ is a powerful tool, but its best features are locked behind expensive monthly subscriptions. For small to medium creators, paying for keyword research and AI title generation eats into production budgets.',
        'VidSEOKit was built as a VidIQ alternative free of paywalls. You get unrestricted access to our YouTube SEO Analyzer, AI Title Generator, and Tag Extractor immediately, without even needing to create an account.'
      ]),
      ContentSection('Feature Comparison', [
        'Both platforms offer SEO scoring. However, VidSEOKit transparently shows you exactly how the score is calculated (based on keyword placement and length) rather than relying on a proprietary black-box metric.',
        'Our suite includes an automated video hashtag categorizer tool and AI thumbnail concepts, designed specifically to help you optimize metadata before you hit publish, entirely for free.'
      ]),
    ],
    faqs: [
      FaqItem('Is VidSEOKit completely free compared to VidIQ?', 'Yes. While VidIQ limits features on its free tier, VidSEOKit offers its entire suite of tools 100% free with no hidden costs.'),
      FaqItem('Do I need to install a browser extension?', 'No. VidSEOKit operates entirely in your browser, meaning you don\'t need to install any extensions that might slow down your computer or require intrusive permissions.')
    ]
  ),

  'youtube-description-generator': PageSeo(
    title: 'YouTube Description Generator — Free AI Tool',
    h1: 'Free YouTube Description Generator',
    description:
        'Generate SEO-optimized YouTube descriptions instantly with AI. Includes keyword placement, timestamp format and a call-to-action — free, no sign-up.',
    canonical: '$kSiteUrl/youtube-description-generator',
    definition:
        'The VidSEOKit YouTube Description Generator is a free AI tool that writes a complete, keyword-rich video description from a topic or title in seconds.',
    breadcrumbName: 'YouTube Description Generator',
    sections: [
      ContentSection('Why the description matters more than most creators think', [
        'The YouTube description is the primary document the algorithm reads to categorise a video. The title names it; the description explains it. A description that opens with the target keyword, delivers a complete summary in the first 150 characters, and naturally repeats related terms throughout tells YouTube exactly which searches to show the video for.',
        'Viewers rarely read the full description on desktop and almost never on mobile — but the algorithm does. Writing for the algorithm in the body and for the viewer in the first two sentences is the balance that earns both rankings and clicks.',
      ]),
      ContentSection('What a high-performing description contains', [
        'The first 150 characters should contain the target keyword and a single clear reason to watch, because that is the portion Google shows in search snippets next to the title. Treat it as a second title, not a continuation of the first.',
        'Chapters with timestamps in the format 0:00 Introduction are picked up by YouTube and displayed as seekable sections in search results, adding visible structure and a quality signal. Links to related playlists, your channel, and relevant tools belong in the middle section. A single call-to-action at the end — subscribe, comment, or visit a link — outperforms listing three, because viewers follow one clear instruction more reliably than three competing ones.',
      ]),
      ContentSection('AI description generator vs writing from scratch', [
        'Manually writing 200–300 words of keyword-rich copy for every video is time-consuming and easy to deprioritise after a long edit. The generator produces a complete draft — opening hook, keyword-rich body, chapter markers placeholder, and call-to-action — from a topic in seconds. Edit it for accuracy and publish.',
        'The output uses natural language rather than keyword stuffing: search algorithms have penalised exact-match repetition in favour of semantic relevance since at least 2019. The goal is a description that reads well to a person and signals clearly to a machine.',
      ]),
    ],
    faqs: [
      FaqItem('How long should a YouTube description be?',
          'Aim for 200 to 350 words. The first 150 characters appear in search snippets; the remainder gives YouTube context and is where you place timestamps, links and keywords. Descriptions under 100 words are too short for YouTube to categorise the video confidently.'),
      FaqItem('Where should I put the keyword in a YouTube description?',
          'In the first sentence, naturally. Aim to include the exact phrase in the first 50–70 characters so it is visible in both the search snippet and the expanded description without truncation. Include related phrases two or three more times in the body without forcing them.'),
      FaqItem('Do YouTube descriptions affect search rankings?',
          'Yes, directly. YouTube reads descriptions to understand what a video is about and which searches to match it with. A description that matches search intent — not just the keyword — consistently outperforms one that keyword-stuffs without providing context.'),
      FaqItem('Should I include hashtags in the description?',
          'Three to five relevant hashtags at the bottom of the description are indexed separately and appear as clickable links above the title on some surfaces. They help discovery in hashtag feeds but have minimal effect on search rankings compared to the description text itself.'),
      FaqItem('Can I use the same description on multiple videos?',
          'No. Identical descriptions across videos signal low-quality content to both YouTube and Google. Each video should have a unique description that reflects its specific content, even if it covers a similar topic.'),
    ],
  ),

  'youtube-hashtag-generator': PageSeo(
    title: 'YouTube Hashtag Generator — Free AI Tool (2026)',
    h1: 'Free YouTube Hashtag Generator',
    description:
        'Generate the right YouTube hashtags for any video topic. AI picks relevant hashtags that surface your content in hashtag feeds — free.',
    canonical: '$kSiteUrl/youtube-hashtag-generator',
    definition:
        'The VidSEOKit YouTube Hashtag Generator is a free AI tool that suggests ranked, relevant hashtags for any video topic to improve discoverability in YouTube hashtag feeds.',
    breadcrumbName: 'YouTube Hashtag Generator',
    sections: [
      ContentSection('How YouTube hashtags work', [
        'Hashtags on YouTube work differently from Instagram. Adding a hashtag to your description makes it appear as a clickable link above the title on the video watch page, and adds your video to that hashtag\'s feed. The first three hashtags you add are displayed above the title; any beyond that are stored but not shown.',
        'YouTube uses hashtags as a categorisation signal, not a primary ranking factor. They help with discovery in hashtag browse pages and occasionally in search, but they do not substitute for keyword optimisation in the title and description.',
      ]),
      ContentSection('Broad, niche, and branded hashtags', [
        'A working hashtag strategy uses three types. Broad hashtags like #YouTubeSEO have millions of videos and low visibility but occasionally surface your content to a large audience. Niche hashtags like #YouTubeSEOTips have a smaller pool and a higher chance of appearing in the feed. Branded hashtags like #VidSEOKit tie your content together in a navigable collection.',
        'The generator suggests a mix of all three for every topic: one or two broad category tags, two or three mid-sized niche tags, and one branded tag. Use five hashtags total: the first three are the ones viewers see, so they should be your strongest niche-specific choices.',
      ]),
    ],
    faqs: [
      FaqItem('How many hashtags should I add to a YouTube video?',
          'Add three to five. YouTube displays the first three above the title — those are the ones viewers see and click. Adding more than fifteen hashtags triggers a policy that removes all hashtags from the video, so stay well under that limit.'),
      FaqItem('Do hashtags increase YouTube views?',
          'Hashtags contribute marginally to discovery through hashtag feeds and browse pages. They are a secondary signal. The primary drivers of YouTube views remain title, thumbnail, and audience retention — hashtags supplement those, not replace them.'),
      FaqItem('Should hashtags match my keywords?',
          'They should overlap but not duplicate. Your target keyword belongs in the title and description. The hashtag version of that keyword — #YouTubeSEO rather than the phrase "youtube seo" — belongs in the hashtag list. They reinforce each other rather than competing.'),
      FaqItem('Can hashtags get my video penalised?',
          'Using misleading hashtags — tagging a cooking video with #gaming to poach views — violates YouTube\'s spam policy and can result in strikes or reduced reach. Stay accurate and relevant.'),
    ],
  ),

  'youtube-channel-name-generator': PageSeo(
    title: 'YouTube Channel Name Generator — Free AI Ideas',
    h1: 'Free YouTube Channel Name Generator',
    description:
        'Generate unique, memorable YouTube channel names from your niche with AI. Get dozens of ideas instantly — free, no sign-up required.',
    canonical: '$kSiteUrl/youtube-channel-name-generator',
    definition:
        'The VidSEOKit YouTube Channel Name Generator is a free AI tool that suggests original, niche-relevant channel name ideas from a topic or content type.',
    breadcrumbName: 'YouTube Channel Name Generator',
    sections: [
      ContentSection('What makes a good YouTube channel name', [
        'A channel name serves two audiences simultaneously: the viewer who needs to understand what the channel is about, and the search index that ranks it. A name that is descriptive enough to self-explain and short enough to be memorable — ideally under 25 characters — does both. Spelling variants and homophones are a consistent problem: a name that sounds memorable in a video recommendation may be unsearchable if the spelling is ambiguous.',
        'Brand names built around the creator\'s own name have the advantage of uniqueness and often survive niche pivots. Topic-specific names like "FinanceWithFred" perform better in early search discovery but trap the channel if it later evolves. The generator produces both types so you can compare angles.',
      ]),
      ContentSection('Checking availability before committing', [
        'A name that already belongs to an active channel creates confusion in search and cannot be registered identically on YouTube. Before committing, search the exact name on YouTube, check the handle availability in YouTube Studio, and run a quick domain search — even if you never build a website, a matching domain protects the brand.',
        'The generator deliberately includes names that are slightly distinctive rather than exact-match topic descriptions, because exact-match names are almost always taken. The generated options use creative constructions — portmanteaux, action phrases, character names — that balance memorability with availability.',
      ]),
    ],
    faqs: [
      FaqItem('Can I change my YouTube channel name later?',
          'Yes. YouTube allows you to change your channel name at any time through YouTube Studio, with no limit on how often. However, changing a name after building an audience causes temporary recognition confusion, so choosing carefully early is worthwhile.'),
      FaqItem('Should my channel name contain keywords?',
          'It can help with early discovery but is not necessary. YouTube search weights video titles and descriptions far more than channel names. A channel named "TechWithTara" that consistently publishes well-optimised tech videos will outrank a channel named "Best Tech Reviews" with weak metadata.'),
      FaqItem('Does the channel handle have to match the channel name?',
          'No. The handle (starting with @) can differ from the display name. The handle is what appears in URLs and @mentions; the display name is what viewers see on the channel page. Use the handle for brand consistency across platforms and the display name for the full descriptive version.'),
    ],
  ),

  'youtube-video-ideas': PageSeo(
    title: 'YouTube Video Ideas Generator — Free AI Tool',
    h1: 'Free YouTube Video Ideas Generator',
    description:
        'Generate unique YouTube video ideas for any niche with AI. Get topics with search intent, angle, and content structure — free, no account needed.',
    canonical: '$kSiteUrl/youtube-video-ideas',
    definition:
        'The VidSEOKit YouTube Video Ideas Generator is a free AI tool that produces searchable, niche-specific video topic ideas with suggested angles and hooks.',
    breadcrumbName: 'YouTube Video Ideas',
    sections: [
      ContentSection('Finding ideas that are both searchable and watchable', [
        'The hardest part of content planning is not coming up with ideas — it is finding ideas that people are actively searching for and that a video can genuinely satisfy better than an article or a competitor\'s existing video. Those two filters — search demand and video-native format — are what separate high-performing ideas from content that never finds an audience.',
        'The generator produces ideas that match search intent and that are inherently visual or demonstration-based, because YouTube rewards content where the format adds something a written tutorial cannot.',
      ]),
      ContentSection('Turning an idea into a content calendar', [
        'A single broad topic produces a cluster of related ideas that support each other through internal linking and playlist structure. A video about YouTube SEO basics links to a video about title optimisation, which links to a video about tags — each narrower and more specific than the last, each targeting a different long-tail keyword.',
        'Running the generator on your core niche once a month produces enough material for a 4–8 week publishing calendar. Sort the outputs by estimated search difficulty — start with the most specific, long-tail topics where competition is lower, establish authority, then work toward the broader keywords as your channel grows.',
      ]),
    ],
    faqs: [
      FaqItem('How do I know if a video idea will get views?',
          'Check whether people are searching for it: type the topic phrase into YouTube search and look at the autocomplete suggestions and the view counts on existing videos in those results. High view counts on a similar topic confirm demand; low competition signals a gap.'),
      FaqItem('Should I make videos about trending topics?',
          'Trend-chasing can produce a spike of views but rarely builds a lasting audience. A video on a trend usually has a shelf life of days to weeks; an evergreen tutorial on a persistent problem keeps getting views for years. A content calendar that is mostly evergreen with occasional timely pieces balances both.'),
      FaqItem('How many video ideas do I need before starting a channel?',
          'Plan at least 20 before publishing the first. That is enough for a consistent posting schedule for three to five months without ideation pressure, and it lets you spot the natural clusters and series that give a channel its structure.'),
    ],
  ),

  'youtube-script-generator': PageSeo(
    title: 'YouTube Script Generator — Free AI Script Writer',
    h1: 'Free YouTube Script Generator',
    description:
        'Generate a complete YouTube video script from any topic with AI. Hook, structure, and CTA included — free, no sign-up, no watermark.',
    canonical: '$kSiteUrl/youtube-script-generator',
    definition:
        'The VidSEOKit YouTube Script Generator is a free AI tool that turns a video topic into a structured script including hook, main sections, and a call-to-action.',
    breadcrumbName: 'YouTube Script Generator',
    sections: [
      ContentSection('Why scripting improves retention', [
        'Audience retention — the percentage of your video that viewers watch — is the strongest algorithmic ranking signal YouTube publishes. Scripted videos consistently outperform improvised ones in retention because every sentence has a reason to be there. An unscripted video meanders: the creator circles back, over-explains, and loses the viewer\'s attention before the point lands.',
        'A script does not need to be read word-for-word on camera. It functions as a tightly edited outline that you internalize and deliver naturally, knowing the structure is solid.',
      ]),
      ContentSection('Script structure that retains viewers', [
        'The first 30 seconds determine whether a viewer stays. The hook should state the payoff of watching — not the topic, but the benefit — and it should do so in a way that raises a question the rest of the video answers. An open loop opened in the first 30 seconds and closed at the end is the structural principle behind most high-retention YouTube content.',
        'After the hook, a clear statement of what the video will cover acts as a content roadmap that reduces viewer anxiety about whether the video will waste their time. The closing CTA should be specific and earn itself: a viewer who just watched a complete, useful video is more likely to subscribe than one who is simply asked to.',
      ]),
    ],
    faqs: [
      FaqItem('How long should a YouTube script be?',
          'Script length maps roughly to video length: 130–150 words per minute of spoken content at a natural pace. A 10-minute video needs approximately 1,300–1,500 words of script. Write for the length the content requires, not for a target duration — padded filler is the primary cause of low retention.'),
      FaqItem('Should I use a teleprompter for my script?',
          'A teleprompter helps with consistency but shows in the eyes of an inexperienced reader. The better approach is to script fully, memorize the structure, and deliver from memory with the script as a safety net.'),
      FaqItem('Can AI write a complete video script?',
          'AI can produce a solid first draft that covers the topic competently. Edit it for personal anecdotes, proprietary insights, and the specific reason your perspective on the topic differs from a generic answer.'),
    ],
  ),

  'tubebuddy-alternative': PageSeo(
    title: 'TubeBuddy Alternative Free — VidSEOKit vs TubeBuddy (2026)',
    h1: 'The Best Free TubeBuddy Alternative',
    description:
        'Skip the TubeBuddy subscription. VidSEOKit is a free TubeBuddy alternative — SEO scoring, AI titles, and tag extraction with no paywall or browser extension.',
    canonical: '$kSiteUrl/tubebuddy-alternative',
    definition:
        'VidSEOKit is a free alternative to TubeBuddy, providing YouTube SEO scoring, AI title generation, tag extraction, and earnings estimation without any subscription or browser extension.',
    breadcrumbName: 'TubeBuddy Alternative',
    sections: [
      ContentSection('Why small channels leave TubeBuddy', [
        'TubeBuddy\'s most useful features — A/B title testing, keyword explorer, and bulk processing — sit behind its Pro and Legend tiers at \$9–\$49 per month. For a creator with under 10,000 subscribers, the channel is unlikely to generate enough revenue to justify that expense, and the free tier\'s core limitation is search volume data being hidden behind a paywall.',
        'VidSEOKit was built specifically for this gap. Every feature — SEO scoring, AI title generation, tag extraction, thumbnail concepts, and earnings estimation — is available immediately, with no account creation and no usage limit.',
      ]),
      ContentSection('Side-by-side feature comparison', [
        'TubeBuddy installs as a browser extension that overlays data onto the YouTube Studio interface. VidSEOKit runs entirely in your browser without any extension to install, which means no ongoing browser permissions and no dependency on YouTube\'s UI not changing in a way that breaks the overlay.',
        'Both tools score video metadata. TubeBuddy\'s score uses a proprietary algorithm that is not explained. VidSEOKit\'s score is published openly: keyword presence in the title (20 points), description (15 points), length scoring, tag coverage, and search volume from live data. You know exactly what to change to improve it.',
      ]),
      ContentSection('When TubeBuddy is worth paying for', [
        'TubeBuddy adds genuine value at scale: A/B thumbnail testing on live videos, bulk metadata editing across a large back-catalogue, and competitor video tracking over time. A channel publishing five videos per week with a team of editors will recoup the subscription cost through the time saved on bulk operations alone.',
        'For a channel publishing once or twice per week and still building an audience, the free tools available today — VidSEOKit for metadata and scoring, YouTube Studio for analytics — cover all practical needs without the monthly cost.',
      ]),
    ],
    faqs: [
      FaqItem('Is VidSEOKit a browser extension like TubeBuddy?',
          'No. VidSEOKit is a web application you open in any browser tab. There is nothing to install, no permissions to grant, and no extension that needs updating when YouTube changes its interface.'),
      FaqItem('Does VidSEOKit show keyword search volume like TubeBuddy Pro?',
          'Yes. The YouTube SEO Analyzer pulls keyword data including search volume and competition level from the DataForSEO API — the same type of data TubeBuddy Pro shows — and factors it into the score.'),
      FaqItem('Can VidSEOKit replace TubeBuddy entirely?',
          'For most small and medium channels, yes. The tools that VidSEOKit does not replicate are bulk operations on existing video libraries and A/B testing of live thumbnails — both of which require YouTube API access that can only be provided by an extension with Studio integration.'),
      FaqItem('Is there a limit on how many videos I can analyse?',
          'No. All VidSEOKit tools are unlimited. Run the SEO Analyzer on every video you publish without any cap or credit system.'),
    ],
  ),

  'youtube-keyword-tool': PageSeo(
    title: 'YouTube Keyword Tool — Free Keyword Research for Creators',
    h1: 'Free YouTube Keyword Research Tool',
    description:
        'Find high-volume, low-competition YouTube keywords for any niche. Get real search volume and CPC data from DataForSEO — free, no account needed.',
    canonical: '$kSiteUrl/youtube-keyword-tool',
    definition:
        'The VidSEOKit YouTube Keyword Tool surfaces real search volume and competition data for YouTube keywords, helping creators identify high-opportunity topics before publishing.',
    breadcrumbName: 'YouTube Keyword Tool',
    sections: [
      ContentSection('How to find the right keywords for YouTube', [
        'YouTube keyword research starts with a question: what phrase does my target viewer type into the search bar when they are looking for a video like this? The answer is rarely the same as what the creator would call the topic themselves. "How to grow vegetables" is a phrase a creator might use; "growing tomatoes in containers" is what the viewer types.',
        'The keyword tool pulls real monthly search volumes and competition scores for any phrase you enter. The combination that produces the best results for a growing channel is high search volume and medium-to-low competition — the pockets of demand that larger channels have not fully covered.',
      ]),
      ContentSection('Search volume, CPC, and what they tell you', [
        'Search volume measures how many times a phrase is searched per month. A phrase searched 1,000 times per month is achievable for a new channel; 100,000 per month is competitive territory. CPC — cost per click — is an advertising metric, but it doubles as a proxy for commercial intent: advertisers pay more for audiences with money to spend, so a high CPC keyword usually indicates an audience that converts well.',
        'Competition index reflects how many advertisers are bidding on a keyword, not how many YouTube videos cover it. A keyword with high advertising competition but few dedicated YouTube videos is a significant opportunity: the audience exists and is commercially valuable, but the content supply is thin.',
      ]),
    ],
    faqs: [
      FaqItem('Is YouTube keyword research different from Google keyword research?',
          'Yes. YouTube search results serve different intent than Google web search. YouTube favours visual, instructional, and entertainment content; Google favours text-based resources. A keyword that performs well in Google may underperform on YouTube if the intent is better served by an article.'),
      FaqItem('How many keywords should I target in one video?',
          'One primary keyword and two or three closely related secondary phrases. A video optimised for too many unrelated keywords tells YouTube it is about nothing in particular. The primary keyword goes in the title and the opening of the description; secondary phrases appear naturally in the body.'),
      FaqItem('What is a good search volume for a new YouTube channel?',
          'Start with keywords in the 1,000–10,000 per month range. These have enough demand to generate real views if you rank, but low enough competition that a new channel has a realistic chance. As the channel grows, target higher-volume terms.'),
    ],
  ),

  'vidiq-vs-tubebuddy': PageSeo(
    title: 'VidIQ vs TubeBuddy: Which Is Better for YouTube SEO? (2026)',
    h1: 'VidIQ vs TubeBuddy: Full Comparison (2026)',
    description:
        'VidIQ vs TubeBuddy compared feature by feature. Pricing, SEO scoring, keyword research, and which is worth the subscription for your channel size.',
    canonical: '$kSiteUrl/vidiq-vs-tubebuddy',
    definition:
        'This page compares VidIQ and TubeBuddy across pricing, features, keyword research, and channel analytics to help YouTube creators decide which tool suits their needs.',
    breadcrumbName: 'VidIQ vs TubeBuddy',
    sections: [
      ContentSection('VidIQ vs TubeBuddy at a glance', [
        'Both VidIQ and TubeBuddy install as Chrome browser extensions and overlay data on the YouTube Studio interface. Both offer keyword research, SEO scoring, and thumbnail performance tracking. The differences are in how each weighs the signals it tracks, where each tool restricts features to paid tiers, and which additional tools each includes beyond the core SEO overlay.',
        'VidIQ leans toward a dashboard-first experience with channel analytics, competitor channel tracking, and an AI coaching tool on higher tiers. TubeBuddy leans toward in-workflow assistance — checklist prompts at upload time, A/B thumbnail testing, and bulk metadata editing. Which emphasis matches your workflow determines which is the better fit.',
      ]),
      ContentSection('Pricing compared', [
        'VidIQ\'s free tier includes basic SEO scores and keyword data but restricts search volume numbers to Pro (\$7.50/mo) and higher. TubeBuddy\'s free tier includes more features for channels under 1,000 subscribers, with Pro at \$5.99/mo unlocking the full keyword explorer.',
        'For creators not yet monetised, both free tiers offer useful starting points. For creators actively earning revenue, the \$6–\$9/mo jump to the first paid tier on either platform typically pays for itself through the time saved in keyword research and upload optimisation — but only at a publishing frequency of at least two videos per week.',
      ]),
      ContentSection('The free alternative both miss', [
        'Both tools require browser extensions and ongoing subscriptions for their most valuable features. VidSEOKit offers SEO scoring, real search volume data, AI title generation, thumbnail concepts, and tag extraction entirely free, with no extension to install and no account required.',
        'The tools VidSEOKit does not currently replicate are A/B thumbnail testing on live videos and historical analytics overlays inside YouTube Studio — both of which require extension-level YouTube API access.',
      ]),
    ],
    faqs: [
      FaqItem('Is VidIQ or TubeBuddy better for small channels?',
          'TubeBuddy offers more features on its free tier for channels under 1,000 subscribers. VidIQ\'s free tier shows score breakdowns but restricts search volume numbers. For a channel not yet generating revenue, TubeBuddy\'s free tier or VidSEOKit\'s entirely free suite are the practical starting points.'),
      FaqItem('Do VidIQ and TubeBuddy work on Firefox or Safari?',
          'Both are primarily Chrome extensions. TubeBuddy has a Firefox version; VidIQ does not. Neither works on Safari. VidSEOKit works in any browser on any device as a web app.'),
      FaqItem('Can I use both VidIQ and TubeBuddy at the same time?',
          'Technically yes, but the overlapping interfaces create visual conflicts inside YouTube Studio and slow the page load. Most creators pick one and commit to it rather than running both simultaneously.'),
      FaqItem('Which has better keyword research, VidIQ or TubeBuddy?',
          'VidIQ shows keyword data within its keyword inspector panel; TubeBuddy shows it in the Tag Explorer within YouTube. Both pull from similar third-party search volume providers. The difference in data quality is marginal; the difference in interface is a matter of preference.'),
    ],
  ),

  'about': PageSeo(
    title: 'About VidSEOKit - Free YouTube SEO Tools',
    h1: 'About VidSEOKit',
    description:
        'VidSEOKit builds free, no-signup SEO and analytics tools for YouTube creators - SEO scoring, title generation, tag extraction and earnings estimation.',
    canonical: '$kSiteUrl/about',
    definition:
        'VidSEOKit is a free suite of YouTube SEO and analytics tools - SEO scoring, title generation, thumbnail concepts, tag extraction and earnings estimation - that requires no account to use.',
    breadcrumbName: 'About',
  ),
  'contact': PageSeo(
    title: 'Contact VidSEOKit - Get in Touch with Our Support Team',
    h1: 'Contact VidSEOKit',
    description:
        'Get in touch with the VidSEOKit team about the YouTube SEO tools, bug reports, feature requests or partnership enquiries.',
    canonical: '$kSiteUrl/contact',
    definition:
        'This page lists how to reach the VidSEOKit team about the tools, bug reports, feature requests and partnership enquiries.',
    breadcrumbName: 'Contact',
  ),
  'privacy': PageSeo(
    title: 'Privacy Policy - VidSEOKit Data Collection & Usage Terms',
    h1: 'Privacy Policy',
    description:
        'How VidSEOKit collects, uses and protects your data, including cookies, Google AdSense advertising and your choices under GDPR and CCPA.',
    canonical: '$kSiteUrl/privacy',
    definition:
        'This privacy policy explains what data VidSEOKit collects, how cookies and Google AdSense advertising are used, and the choices available under GDPR and CCPA.',
    breadcrumbName: 'Privacy Policy',
  ),
  'terms': PageSeo(
    title: 'Terms of Service - VidSEOKit Acceptable Use & Legal Terms',
    h1: 'Terms of Service',
    description:
        'The terms governing use of VidSEOKit free YouTube SEO and analytics tools, including acceptable use, disclaimers and limitation of liability.',
    canonical: '$kSiteUrl/terms',
    definition:
        'These terms of service govern use of the free VidSEOKit YouTube tools, covering acceptable use, disclaimers and limitation of liability.',
    breadcrumbName: 'Terms of Service',
  ),
  "youtube-earnings-calculator-finance": PageSeo(
    title: "YouTube Earnings Calculator for Finance Channels - Estimate AdSense",
    h1: "YouTube Earnings Calculator: Finance",
    description: "Estimate YouTube AdSense income for Finance channels based on daily views. See average CPM and RPM rates specifically for the Finance category.",
    canonical: "$kSiteUrl/youtube-earnings-calculator-finance",
    definition: "This calculator estimates monthly AdSense revenue for Finance content on YouTube, using typical RPM data for the Finance category.",
    breadcrumbName: "Finance Earnings",
    sections: [
      ContentSection("How Finance Channels Are Monetized", [
        "The Finance niche on YouTube has its own unique CPM and RPM rates based on advertiser demand. Using this calculator, you can estimate how much a Finance channel can earn from AdSense.",
        "Remember that view count is only part of the equation; audience demographics and retention play a major role in your final RPM."
      ])
    ],
  ),
  "youtube-earnings-calculator-tech": PageSeo(
    title: "YouTube Earnings Calculator for Tech Channels - Estimate AdSense",
    h1: "YouTube Earnings Calculator: Tech",
    description: "Estimate YouTube AdSense income for Tech channels based on daily views. See average CPM and RPM rates specifically for the Tech category.",
    canonical: "$kSiteUrl/youtube-earnings-calculator-tech",
    definition: "This calculator estimates monthly AdSense revenue for Tech content on YouTube, using typical RPM data for the Tech category.",
    breadcrumbName: "Tech Earnings",
    sections: [
      ContentSection("How Tech Channels Are Monetized", [
        "The Tech niche on YouTube has its own unique CPM and RPM rates based on advertiser demand. Using this calculator, you can estimate how much a Tech channel can earn from AdSense.",
        "Remember that view count is only part of the equation; audience demographics and retention play a major role in your final RPM."
      ])
    ],
  ),
  "youtube-earnings-calculator-gaming": PageSeo(
    title: "YouTube Earnings Calculator for Gaming Channels - Estimate AdSense",
    h1: "YouTube Earnings Calculator: Gaming",
    description: "Estimate YouTube AdSense income for Gaming channels based on daily views. See average CPM and RPM rates specifically for the Gaming category.",
    canonical: "$kSiteUrl/youtube-earnings-calculator-gaming",
    definition: "This calculator estimates monthly AdSense revenue for Gaming content on YouTube, using typical RPM data for the Gaming category.",
    breadcrumbName: "Gaming Earnings",
    sections: [
      ContentSection("How Gaming Channels Are Monetized", [
        "The Gaming niche on YouTube has its own unique CPM and RPM rates based on advertiser demand. Using this calculator, you can estimate how much a Gaming channel can earn from AdSense.",
        "Remember that view count is only part of the equation; audience demographics and retention play a major role in your final RPM."
      ])
    ],
  ),
  "youtube-earnings-calculator-vlog": PageSeo(
    title: "YouTube Earnings Calculator for Vlog Channels - Estimate AdSense",
    h1: "YouTube Earnings Calculator: Vlog",
    description: "Estimate YouTube AdSense income for Vlog channels based on daily views. See average CPM and RPM rates specifically for the Vlog category.",
    canonical: "$kSiteUrl/youtube-earnings-calculator-vlog",
    definition: "This calculator estimates monthly AdSense revenue for Vlog content on YouTube, using typical RPM data for the Vlog category.",
    breadcrumbName: "Vlog Earnings",
    sections: [
      ContentSection("How Vlog Channels Are Monetized", [
        "The Vlog niche on YouTube has its own unique CPM and RPM rates based on advertiser demand. Using this calculator, you can estimate how much a Vlog channel can earn from AdSense.",
        "Remember that view count is only part of the equation; audience demographics and retention play a major role in your final RPM."
      ])
    ],
  ),
  "youtube-earnings-calculator-education": PageSeo(
    title: "YouTube Earnings Calculator for Education Channels - Estimate AdSense",
    h1: "YouTube Earnings Calculator: Education",
    description: "Estimate YouTube AdSense income for Education channels based on daily views. See average CPM and RPM rates specifically for the Education category.",
    canonical: "$kSiteUrl/youtube-earnings-calculator-education",
    definition: "This calculator estimates monthly AdSense revenue for Education content on YouTube, using typical RPM data for the Education category.",
    breadcrumbName: "Education Earnings",
    sections: [
      ContentSection("How Education Channels Are Monetized", [
        "The Education niche on YouTube has its own unique CPM and RPM rates based on advertiser demand. Using this calculator, you can estimate how much a Education channel can earn from AdSense.",
        "Remember that view count is only part of the equation; audience demographics and retention play a major role in your final RPM."
      ])
    ],
  ),
  "youtube-earnings-calculator-entertainment": PageSeo(
    title: "YouTube Earnings Calculator for Entertainment Channels - Estimate AdSense",
    h1: "YouTube Earnings Calculator: Entertainment",
    description: "Estimate YouTube AdSense income for Entertainment channels based on daily views. See average CPM and RPM rates specifically for the Entertainment category.",
    canonical: "$kSiteUrl/youtube-earnings-calculator-entertainment",
    definition: "This calculator estimates monthly AdSense revenue for Entertainment content on YouTube, using typical RPM data for the Entertainment category.",
    breadcrumbName: "Entertainment Earnings",
    sections: [
      ContentSection("How Entertainment Channels Are Monetized", [
        "The Entertainment niche on YouTube has its own unique CPM and RPM rates based on advertiser demand. Using this calculator, you can estimate how much a Entertainment channel can earn from AdSense.",
        "Remember that view count is only part of the equation; audience demographics and retention play a major role in your final RPM."
      ])
    ],
  ),
  "youtube-earnings-calculator-health": PageSeo(
    title: "YouTube Earnings Calculator for Health Channels - Estimate AdSense",
    h1: "YouTube Earnings Calculator: Health",
    description: "Estimate YouTube AdSense income for Health channels based on daily views. See average CPM and RPM rates specifically for the Health category.",
    canonical: "$kSiteUrl/youtube-earnings-calculator-health",
    definition: "This calculator estimates monthly AdSense revenue for Health content on YouTube, using typical RPM data for the Health category.",
    breadcrumbName: "Health Earnings",
    sections: [
      ContentSection("How Health Channels Are Monetized", [
        "The Health niche on YouTube has its own unique CPM and RPM rates based on advertiser demand. Using this calculator, you can estimate how much a Health channel can earn from AdSense.",
        "Remember that view count is only part of the equation; audience demographics and retention play a major role in your final RPM."
      ])
    ],
  ),
  "youtube-earnings-calculator-beauty": PageSeo(
    title: "YouTube Earnings Calculator for Beauty Channels - Estimate AdSense",
    h1: "YouTube Earnings Calculator: Beauty",
    description: "Estimate YouTube AdSense income for Beauty channels based on daily views. See average CPM and RPM rates specifically for the Beauty category.",
    canonical: "$kSiteUrl/youtube-earnings-calculator-beauty",
    definition: "This calculator estimates monthly AdSense revenue for Beauty content on YouTube, using typical RPM data for the Beauty category.",
    breadcrumbName: "Beauty Earnings",
    sections: [
      ContentSection("How Beauty Channels Are Monetized", [
        "The Beauty niche on YouTube has its own unique CPM and RPM rates based on advertiser demand. Using this calculator, you can estimate how much a Beauty channel can earn from AdSense.",
        "Remember that view count is only part of the equation; audience demographics and retention play a major role in your final RPM."
      ])
    ],
  ),
  "youtube-earnings-calculator-cooking": PageSeo(
    title: "YouTube Earnings Calculator for Cooking Channels - Estimate AdSense",
    h1: "YouTube Earnings Calculator: Cooking",
    description: "Estimate YouTube AdSense income for Cooking channels based on daily views. See average CPM and RPM rates specifically for the Cooking category.",
    canonical: "$kSiteUrl/youtube-earnings-calculator-cooking",
    definition: "This calculator estimates monthly AdSense revenue for Cooking content on YouTube, using typical RPM data for the Cooking category.",
    breadcrumbName: "Cooking Earnings",
    sections: [
      ContentSection("How Cooking Channels Are Monetized", [
        "The Cooking niche on YouTube has its own unique CPM and RPM rates based on advertiser demand. Using this calculator, you can estimate how much a Cooking channel can earn from AdSense.",
        "Remember that view count is only part of the equation; audience demographics and retention play a major role in your final RPM."
      ])
    ],
  ),
};

