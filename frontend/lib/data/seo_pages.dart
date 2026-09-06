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
const String kContentUpdated = '2026-09-06';
const String kContentUpdatedLabel = '6 September 2026';

/// Keyed by the tab id that [_getTabFromPath] resolves, so routing and metadata
/// cannot drift apart.
const Map<String, PageSeo> kPageSeo = {
  'seo': PageSeo(
    title: 'Free YouTube SEO Analyzer - Score Your Video in Seconds',
    description:
        'Paste your title, description and target keyword to get an instant YouTube SEO score, plus specific fixes for ranking higher in search and suggested video.',
    canonical: '$kSiteUrl/',
    definition:
        'The VidSEOKit YouTube SEO Analyzer is a free tool that scores a video\'s title, description and tags against a target keyword, then lists the specific changes to make before publishing.',
    sections: [
      ContentSection('How the YouTube SEO score is calculated', [
        'The analyzer checks the three fields YouTube reads when it decides what a video is about: the title, the description and the tags. Each is scored against the target keyword you enter, then combined into a single number out of 100 so you can tell at a glance whether a video is ready to publish.',
        'Keyword placement carries the most weight. A target keyword that appears in the first few words of the title scores higher than one buried at the end, because both YouTube and the viewer scanning a results page read left to right. The first 150 characters of the description matter for the same reason: that is the portion shown above the fold before anyone clicks "more".',
        'Length is scored as a range rather than a target. Titles between roughly 50 and 60 characters survive truncation on mobile search results, and descriptions under about 100 words tend to under-explain the video to the algorithm. The score flags both extremes instead of pushing you toward one magic number.',
      ]),
      ContentSection('What metadata can and cannot do', [
        'Metadata gets a video into consideration; it does not keep it there. Once YouTube shows your video to a test audience, click-through rate and average view duration decide whether the impressions keep coming. A perfectly optimised title on a video nobody finishes will stall.',
        'Treat the SEO score as a pre-publish checklist rather than a growth strategy. Fix what the analyzer flags, publish, then watch the retention graph in YouTube Studio for the first 48 hours. That combination - clean metadata plus a video that holds attention - is what compounds.',
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
    title: 'YouTube Title Generator - Free AI Titles That Get Clicks',
    description:
        'Generate click-worthy YouTube titles from any topic. Get multiple angles - curiosity, listicle, how-to and result-driven - built around your target keyword, free.',
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
        'Read each candidate at mobile width, where titles are cut after roughly 40 characters. If the first half stops making sense on its own, rewrite it so the meaning survives truncation. Avoid all-caps and manufactured shock - they raise click-through rate briefly and damage the channel over time, because viewers who feel misled leave early and that is the signal YouTube actually measures.',
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
    description:
        'Get concrete AI thumbnail concepts for any video topic - subject, expression, text overlay and colour direction - so you stop guessing at what to design.',
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
    title: 'YouTube Tag Extractor - See Any Video Tags Free',
    description:
        'Paste any YouTube URL to extract the tags that video is using. See how ranking videos in your niche describe themselves and find keywords worth targeting.',
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
    description:
        'Estimate YouTube AdSense income from your daily views and niche. See how CPM and RPM differ by category and what actually changes what you get paid.',
    canonical: '$kSiteUrl/youtube-earnings-calculator',
    definition:
        'The VidSEOKit YouTube Earnings Calculator is a free tool that estimates monthly AdSense revenue from your daily view count and content niche, reported as an RPM-based range rather than a single figure.',
    breadcrumbName: 'YouTube Earnings Calculator',
    sections: [
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
    description:
        'In-depth guides on YouTube SEO, the algorithm, monetization requirements, RPM, keyword research and channel analytics - written for creators growing a channel.',
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
    description:
        'What YouTube pays per 1,000 views in the US, UK, Canada, Germany, France and across Europe. Typical RPM ranges by country, and why the same video earns different amounts in each.',
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
  'about': PageSeo(
    title: 'About VidSEOKit - Free YouTube SEO Tools',
    description:
        'VidSEOKit builds free, no-signup SEO and analytics tools for YouTube creators - SEO scoring, title generation, tag extraction and earnings estimation.',
    canonical: '$kSiteUrl/about',
    definition:
        'VidSEOKit is a free suite of YouTube SEO and analytics tools - SEO scoring, title generation, thumbnail concepts, tag extraction and earnings estimation - that requires no account to use.',
    breadcrumbName: 'About',
  ),
  'contact': PageSeo(
    title: 'Contact VidSEOKit - Get in Touch with Our Support Team',
    description:
        'Get in touch with the VidSEOKit team about the YouTube SEO tools, bug reports, feature requests or partnership enquiries.',
    canonical: '$kSiteUrl/contact',
    definition:
        'This page lists how to reach the VidSEOKit team about the tools, bug reports, feature requests and partnership enquiries.',
    breadcrumbName: 'Contact',
  ),
  'privacy': PageSeo(
    title: 'Privacy Policy - VidSEOKit Data Collection & Usage Terms',
    description:
        'How VidSEOKit collects, uses and protects your data, including cookies, Google AdSense advertising and your choices under GDPR and CCPA.',
    canonical: '$kSiteUrl/privacy',
    definition:
        'This privacy policy explains what data VidSEOKit collects, how cookies and Google AdSense advertising are used, and the choices available under GDPR and CCPA.',
    breadcrumbName: 'Privacy Policy',
  ),
  'terms': PageSeo(
    title: 'Terms of Service - VidSEOKit Acceptable Use & Legal Terms',
    description:
        'The terms governing use of VidSEOKit free YouTube SEO and analytics tools, including acceptable use, disclaimers and limitation of liability.',
    canonical: '$kSiteUrl/terms',
    definition:
        'These terms of service govern use of the free VidSEOKit YouTube tools, covering acceptable use, disclaimers and limitation of liability.',
    breadcrumbName: 'Terms of Service',
  ),
};
