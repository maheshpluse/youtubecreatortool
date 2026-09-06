/// The site-wide `<head>`, verbatim.
///
/// Held as a string rather than loaded from `web/index.template.html`:
/// `Document.template` resolves the template through the build server, which
/// finds it under `jaspr serve` but not under `jaspr build`, so every route
/// failed to generate. Inlining it removes the lookup entirely.
///
/// Anything page-specific (title, description, canonical, og:*) is deliberately
/// absent — `_buildSeoHead` supplies those per route. The Organization block
/// also moved there, because its `sameAs` is driven by [kSocialProfiles] and a
/// raw string cannot be conditional.
library;

const String kBodyClasses = 'font-sans antialiased bg-white dark:bg-yt-gray-900 text-yt-gray-900 dark:text-yt-gray-100 transition-colors duration-300';

const String kSiteHead = r'''
        <meta name="google-site-verification" content="LJOA2oJqaJnJ3Gda1cHAO78TKwu8aYLSP0FwnPAA-3I" />
        <script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-3988155577590737" crossorigin="anonymous"></script>
        <meta name="google-adsense-account" content="ca-pub-3988155577590737">
        
        <!-- Primary SEO Meta Tags -->
        <meta name="author" content="VidSEOKit">
        <meta name="robots" content="index, follow, max-image-preview:large, max-snippet:-1, max-video-preview:-1">
        
        <!-- Theme Color -->
        <meta name="theme-color" content="#FF0000">
        
        <!-- Open Graph / Facebook -->
        <meta property="og:type" content="website">
        <meta property="og:site_name" content="VidSEOKit">
        <meta property="og:image" content="https://vidseokit.com/images/og-image.jpg">
        <meta property="og:image:width" content="1200">
        <meta property="og:image:height" content="630">
        <meta property="og:image:alt" content="VidSEOKit - Free YouTube SEO & Growth Tools">
        <meta property="og:locale" content="en_US">
        <!-- The site ships one English version; these tell social and search
             surfaces it is written for the English-speaking markets it targets
             rather than implying localised URLs that do not exist. -->
        <meta property="og:locale:alternate" content="en_GB">
        <meta property="og:locale:alternate" content="en_CA">
        <meta property="og:locale:alternate" content="en_AU">
        <meta property="og:locale:alternate" content="en_IE">
        
        <!-- Twitter Card -->
        <meta name="twitter:card" content="summary_large_image">
        <meta name="twitter:image" content="https://vidseokit.com/images/og-image.jpg">
        <meta name="twitter:image:alt" content="VidSEOKit - YouTube Creator Tools">
        
        <!-- Additional SEO Meta -->
        <meta name="application-name" content="VidSEOKit">
        <meta name="apple-mobile-web-app-title" content="VidSEOKit">
        <meta name="apple-mobile-web-app-capable" content="yes">
        <meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
        <meta name="mobile-web-app-capable" content="yes">
        <meta name="format-detection" content="telephone=no">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        
        <!-- JSON-LD: WebApplication -->
        <script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "WebApplication",
  "name": "VidSEOKit",
  "url": "https://vidseokit.com",
  "description": "Free YouTube SEO tools for creators. Analyze video SEO, generate viral titles, extract competitor tags, calculate AdSense earnings and get AI thumbnail ideas.",
  "applicationCategory": "UtilitiesApplication",
  "operatingSystem": "Web Browser",
  "offers": {
    "@type": "Offer",
    "price": "0",
    "priceCurrency": "USD"
  },
  "featureList": [
    "YouTube SEO Score Analyzer",
    "AI-Powered Title Generator",
    "YouTube Tag Extractor",
    "AdSense Earnings Calculator",
    "AI Thumbnail Idea Generator"
  ],
  "screenshot": "https://vidseokit.com/images/og-image.jpg",
  "creator": {
    "@type": "Organization",
    "name": "VidSEOKit",
    "url": "https://vidseokit.com"
  }
}
        </script>
        <!-- JSON-LD: ItemList -->
        <script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "ItemList",
  "itemListElement": [
    {
      "@type": "SiteNavigationElement",
      "position": 1,
      "name": "YouTube SEO Analyzer",
      "description": "Analyze your video SEO and get a score.",
      "url": "https://vidseokit.com/youtube-seo-analyzer"
    },
    {
      "@type": "SiteNavigationElement",
      "position": 2,
      "name": "Title Generator",
      "description": "Generate viral YouTube titles using AI.",
      "url": "https://vidseokit.com/youtube-title-generator"
    },
    {
      "@type": "SiteNavigationElement",
      "position": 3,
      "name": "Thumbnail Ideas",
      "description": "Get AI generated ideas for your thumbnails.",
      "url": "https://vidseokit.com/youtube-thumbnail-ideas"
    },
    {
      "@type": "SiteNavigationElement",
      "position": 4,
      "name": "Tag Extractor",
      "description": "Extract tags from any YouTube video.",
      "url": "https://vidseokit.com/youtube-tag-extractor"
    },
    {
      "@type": "SiteNavigationElement",
      "position": 5,
      "name": "Earnings Calculator",
      "description": "Calculate estimated AdSense revenue.",
      "url": "https://vidseokit.com/youtube-earnings-calculator"
    },
    {
      "@type": "SiteNavigationElement",
      "position": 6,
      "name": "Creator Blog",
      "description": "Learn YouTube strategies and growth tips.",
      "url": "https://vidseokit.com/blog/"
    }
  ]
}
        </script>

        <link rel="icon" href="favicon.ico" type="image/x-icon">

        <!-- Fonts: Roboto (YouTube's standard font) -->
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700;900&display=swap" rel="stylesheet">
        
        <!-- Material Symbols (Rounded) -->
        <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Rounded:opsz,wght,FILL,GRAD@24,400,1,0" rel="stylesheet">

        <!-- Generated CSS -->
        
        <!-- Tailwind CSS -->
        <link rel="stylesheet" href="tailwind.css?v=1">
        

        
        <link rel="stylesheet" href="styles.css">

        <!-- Theme Toggle -->
        <script>
          (function() {
            var saved = localStorage.getItem('ct-theme');
            if (saved === 'light') document.documentElement.classList.remove('dark');
            else document.documentElement.classList.add('dark');
          })();
          document.addEventListener('click', function(e) {
            var btn = e.target.closest('[data-theme-toggle]');
            if (btn) {
              document.documentElement.classList.toggle('dark');
              var isDark = document.documentElement.classList.contains('dark');
              localStorage.setItem('ct-theme', isDark ? 'dark' : 'light');
            }
          });
        </script>

        <!-- Cookie consent + Google Consent Mode v2.
             MUST stay above every Google tag (reCAPTCHA, AdSense, gtag) and
             must NOT be async/defer: the consent defaults have to be in
             dataLayer before Google reads storage. -->
        <script>window.__ctDisableOwnBanner = true;</script>
        <script src="consent.js"></script>

        <!-- reCAPTCHA integration -->
        <script src="https://www.google.com/recaptcha/enterprise.js?render=6LetP6ktAAAAAPn6G2UlIc-EQSMoVHBsJ4FWu5RH"></script>
        <script>
          window.executeRecaptcha = function() {
            return new Promise((resolve) => {
              if (typeof grecaptcha === 'undefined' || !grecaptcha.enterprise) {
                resolve("DUMMY_TOKEN");
                return;
              }
              try {
                grecaptcha.enterprise.ready(async () => {
                  try {
                    const token = await grecaptcha.enterprise.execute('6LetP6ktAAAAAPn6G2UlIc-EQSMoVHBsJ4FWu5RH', {action: 'submit'});
                    resolve(token);
                  } catch (e) {
                    console.error('reCAPTCHA execution failed', e);
                    resolve("DUMMY_TOKEN");
                  }
                });
              } catch (err) {
                console.error('reCAPTCHA ready failed', err);
                resolve("DUMMY_TOKEN");
              }
            });
          };
        </script>

        <script src="https://www.gstatic.com/firebasejs/10.12.0/firebase-app-compat.js"></script>
        <script src="https://www.gstatic.com/firebasejs/10.12.0/firebase-auth-compat.js"></script>
        <script src="auth.js?v=2"></script>
        <script defer src="main.dart.js?v=2"></script>
        
        <!-- Google AdSense Integration -->
        <script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-3988155577590737" crossorigin="anonymous"></script>
    
''';
