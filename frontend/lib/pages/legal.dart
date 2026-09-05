import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

// ═══════════════════════════════════════════════════════════════════════════
//  LEGAL PAGES — Privacy Policy & Terms of Service
//
//  Drafted to cover the jurisdictions our traffic actually comes from:
//    • EEA / EU        GDPR (2016/679) + ePrivacy
//    • United Kingdom  UK GDPR + Data Protection Act 2018 + PECR
//    • Switzerland     revised FADP
//    • United States   CCPA/CPRA (CA) + VA/CO/CT/UT/TX/OR/MT/etc., COPPA
//    • Australia       Privacy Act 1988 (APPs), Australian Consumer Law
//    • Canada          PIPEDA
//
//  ─────────────────────────────────────────────────────────────────────────
//  MAINTAINER CHECKLIST — these statements must stay true of the live site.
//  If you change the stack, change the policy in the same commit.
//
//   1. Reviewed 4 Sep 2026 — Delaware is retained as the US forum in s16.2.
//      Revisit only if the LLC is registered or re-domiciled elsewhere.
//   2. DONE — web/consent.js implements Google Consent Mode v2 (denied by
//      default across the EEA/UK/CH, granted elsewhere), a granular banner
//      with equal-weight accept/reject, GPC handling, a 12-month re-ask, and
//      window.showConsentPreferences() behind the footer's Cookie Settings
//      link. Sections 4.1, 4.3 and 13.2 describe exactly that behaviour.
//      STILL TODO before enabling AdSense in Europe: our banner is NOT an
//      IAB TCF v2.2 certified CMP, which Google requires to serve ads to
//      EEA/UK users. Turn on AdSense > Privacy & messaging > GDPR message,
//      then set window.__ctDisableOwnBanner = true ahead of consent.js so
//      visitors do not see two banners. Do not claim TCF compliance in this
//      policy until that is live.
//   3. TODO(legal): the policy states tool inputs are not written to a
//      database. backend/main.py currently holds nothing — keep it that way,
//      or add a retention row here if you start persisting requests.
//   4. TODO(legal): add a postal address once one exists. Article 27 (EU/UK)
//      representative details go in "Contact and complaints" if appointed.
//   5. Review date: revisit every 12 months or on any new third-party script.
//
//  Not legal advice — have counsel review before relying on this in a
//  regulated market.
// ═══════════════════════════════════════════════════════════════════════════

const String legalLastUpdated = '4 September 2026';
const String legalContactEmail = 'support@creatortools.io';

// ── Shared building blocks ─────────────────────────────────────────────────

Component _h2(String title) => h2(
      classes: 'text-xl font-bold mt-10 mb-3 text-yt-gray-900 dark:text-white scroll-mt-24',
      [Component.text(title)],
    );

Component _h3(String title) => h3(
      classes: 'text-base font-semibold mt-6 mb-2 text-yt-gray-800 dark:text-yt-gray-200',
      [Component.text(title)],
    );

Component _p(String body) => p(classes: 'mb-3', [Component.text(body)]);

Component _bullets(List<String> items) => ul(
      classes: 'list-disc pl-5 space-y-1.5 mb-3 marker:text-yt-gray-400',
      [for (final item in items) li([Component.text(item)])],
    );

/// Definition-style list — used for the GDPR legal-basis table and the CCPA
/// category disclosures, where each row is "label — explanation".
Component _defs(List<List<String>> rows) => ul(
      classes: 'list-none pl-0 space-y-2.5 mb-3',
      [
        for (final row in rows)
          li(classes: 'border-l-2 border-yt-gray-200 dark:border-yt-gray-700 pl-3', [
            strong(classes: 'text-yt-gray-900 dark:text-white', [Component.text(row[0])]),
            span([Component.text(' — ${row[1]}')]),
          ]),
      ],
    );

Component _callout(List<Component> children) => div(
      classes: 'my-5 p-4 rounded-lg bg-yt-gray-100 dark:bg-yt-gray-800 '
          'border-l-4 border-yt-red text-sm',
      children,
    );

Component _link(String label, String url) => a(
      href: url,
      classes: 'text-yt-blue-dark dark:text-yt-blue-light hover:underline',
      attributes: {'target': '_blank', 'rel': 'noopener noreferrer'},
      [Component.text(label)],
    );

Component _updated() => p(
      classes: 'text-xs uppercase tracking-wide text-yt-gray-500 mb-6 '
          'pb-4 border-b border-yt-gray-200 dark:border-yt-gray-800',
      [Component.text('Last updated: $legalLastUpdated  ·  Effective: $legalLastUpdated')],
    );

// ═══════════════════════════════════════════
//  PRIVACY POLICY
// ═══════════════════════════════════════════

List<Component> privacyPolicyContent() => [
      _updated(),

      _p('This Privacy Policy explains how CreatorTools.io LLC ("CreatorTools", "we", '
          '"us" or "our") collects, uses, shares and protects personal information when '
          'you visit creatortools.io or use any of our free creator tools (together, the '
          '"Service").'),
      _p('We are the data controller for the processing described here. Wherever this '
          'policy refers to "personal information", read it as including "personal data" '
          'under the EU and UK GDPR and "personal information" under the Australian '
          'Privacy Act 1988 and US state privacy laws.'),

      _callout([
        strong([Component.text('The short version. ')]),
        Component.text('There are no accounts and no passwords. We do not ask for your name, we do '
            'not connect to your YouTube account, and we do not save the titles, '
            'descriptions, tags or URLs you paste into our tools. What we do have is '
            'ordinary web-server log data, a theme preference stored in your own browser, '
            'and the cookies that Google sets for reCAPTCHA and advertising. You can turn '
            'the advertising cookies off.'),
      ]),

      _h2('1. Information we collect'),

      _h3('1.1 Information you provide'),
      _p('The tools are anonymous and require no sign-up. You do, however, type things '
          'into them, and that text is sent to our servers so it can be analysed:'),
      _bullets([
        'SEO Analyzer: the video title, description, tags and target keyword you enter.',
        'Title Generator and Thumbnail Generator: the topic or subject you enter.',
        'Tag Extractor: the YouTube video URL you enter. We fetch the publicly available page at that URL to read its tags; we do not access your YouTube account and never request OAuth permissions.',
        'Earnings Calculator: your daily view count and selected niche. This runs on our servers to produce an estimate and is not linked to you.',
        'Contact: if you email us at $legalContactEmail, we receive your email address, your message and anything you attach.',
      ]),
      _p('Treat these fields as public. Do not paste personal information, client data, '
          'unreleased material or anything confidential into them — see section 3 for why.'),

      _h3('1.2 Information collected automatically'),
      _bullets([
        'Log data: your IP address, browser type and version, operating system, referring page, the pages you view, and the date and time of each request. Our hosting provider records this to keep the Service running and secure.',
        'Approximate location: inferred from your IP address at country or region level. We do not collect GPS or precise location.',
        'Device and interaction data: screen size, language, and which tools you use, so we can see which features are worth keeping.',
        'Anti-abuse signals: Google reCAPTCHA collects device and behaviour signals to tell humans apart from bots.',
      ]),

      _h3('1.3 Information stored on your device'),
      _p('We store one preference locally in your browser under the key "ct-theme", which '
          'remembers whether you chose the light or dark theme. It never leaves your '
          'device and we cannot read it from our servers. Clearing your browser storage '
          'removes it.'),

      _h3('1.4 What we do not collect'),
      _bullets([
        'We do not collect passwords, because there are no accounts.',
        'We do not collect payment or card details. The tools are free.',
        'We do not request access to your YouTube, Google or social media accounts.',
        'We do not knowingly collect information from children (see section 10).',
        'We do not collect special-category or sensitive personal information, and we ask that you do not send us any.',
      ]),

      _h2('2. How we use information, and our legal bases'),
      _p('If you are in the EEA, the UK or Switzerland, the GDPR requires us to name a '
          'legal basis for each purpose. Here they are:'),
      _defs([
        [
          'Providing the tools',
          'to process the text you submit and return a result. Legal basis: performance of a contract with you (Art. 6(1)(b)), or our legitimate interest in delivering a service you asked for.',
        ],
        [
          'Security and abuse prevention',
          'to run reCAPTCHA, apply rate limits and block abusive traffic. Legal basis: legitimate interests (Art. 6(1)(f)) in keeping the Service available and protecting it from automated abuse.',
        ],
        [
          'Service improvement',
          'to understand aggregate usage and fix faults. Legal basis: legitimate interests in improving a product we offer free of charge.',
        ],
        [
          'Advertising',
          'to fund the Service through Google AdSense. Legal basis: your consent (Art. 6(1)(a)) where consent is required for cookies and personalised advertising; otherwise legitimate interests in showing non-personalised ads.',
        ],
        [
          'Responding to you',
          'to answer support emails and business enquiries. Legal basis: legitimate interests, or performance of a contract.',
        ],
        [
          'Legal compliance',
          'to meet our obligations, respond to lawful requests and establish or defend legal claims. Legal basis: legal obligation (Art. 6(1)(c)) and legitimate interests.',
        ],
      ]),
      _p('Where we rely on legitimate interests, we have balanced those interests against '
          'your rights and freedoms. You can object to that processing at any time — '
          'see section 12.'),

      _h2('3. AI processing and your inputs'),
      _p('Our SEO Analyzer, Title Generator and Thumbnail Generator are powered by '
          'Google\'s Gemini generative AI models. When you submit a request, the text you '
          'entered is transmitted to Google\'s API for processing and the generated result '
          'is returned to you and displayed in your browser.'),
      _bullets([
        'We do not write your inputs or the generated outputs to a database, and we do not build a profile from them.',
        'Google processes those inputs under its own terms and may retain them for a limited period for abuse monitoring and, on some API tiers, for improving its models. We do not control that retention.',
        'Because of the above, you must not submit personal information about yourself or anyone else, confidential business material, or anything you are contractually barred from disclosing.',
        'AI output is generated by a statistical model. It can be inaccurate, generic or duplicated across users. Check anything before you publish it. See our Terms of Service for the full disclaimer.',
      ]),
      p(classes: 'mb-3', [
        Component.text('Google\'s handling of data sent to its APIs is described in the '),
        _link('Google Privacy Policy', 'https://policies.google.com/privacy'),
        Component.text(' and the '),
        _link('Gemini API terms', 'https://ai.google.dev/gemini-api/terms'),
        Component.text('.'),
      ]),

      _h2('4. Cookies, similar technologies and advertising'),
      _p('Cookies are small files placed on your device. We group them as follows:'),
      _defs([
        [
          'Strictly necessary',
          'required for the site to work and to defend it against abuse, including Google reCAPTCHA. These are set without consent because the Service cannot be provided safely without them.',
        ],
        [
          'Preferences',
          'the local theme setting described in section 1.3. Set only after you use the theme toggle.',
        ],
        [
          'Advertising',
          'set by Google AdSense and its partners to serve, cap and measure ads, and — with consent — to personalise them based on your browsing across sites.',
        ],
      ]),
      _h3('4.1 Consent in the EEA, UK and Switzerland'),
      _p('If you are located in the EEA, the UK or Switzerland, non-essential cookies are '
          'set only after you give consent through our cookie banner. Until you consent, '
          'advertising and measurement storage stays disabled through Google Consent Mode, '
          'and any ads shown are non-personalised.'),
      _bullets([
        'Consent is granular. You can accept analytics without accepting advertising, or refuse both, using the "Manage" option in the banner.',
        'Refusing is as easy as accepting. "Reject all" sits next to "Accept all", in the same size and style, on the first screen.',
        'You can change or withdraw your choices at any time using the Cookie Settings link in the site footer. Withdrawal takes effect immediately and is as easy as giving consent.',
        'We record what you chose and when. We ask again after 12 months so your consent does not go stale, and again whenever we materially change what the cookies do.',
        'Strictly necessary cookies are always on and are not covered by the banner, because the Service cannot be provided securely without them.',
      ]),
      _h3('4.2 Google AdSense'),
      p(classes: 'mb-3', [
        Component.text('Google, as a third-party vendor, uses cookies to serve ads on this site and '
            'may use the DoubleClick cookie or similar identifiers to serve ads based on '
            'your prior visits here and to other websites. You can opt out of personalised '
            'advertising at '),
        _link('Google Ads Settings', 'https://adssettings.google.com'),
        Component.text(', opt out of many vendors at once at '),
        _link('youradchoices.com', 'https://optout.aboutads.info/'),
        Component.text(' (US), '),
        _link('youronlinechoices.eu', 'https://www.youronlinechoices.eu/'),
        Component.text(' (EU/UK) or '),
        _link('youronlinechoices.com.au', 'https://www.youronlinechoices.com.au/'),
        Component.text(' (Australia). How Google uses data from sites that use its services is '
            'explained at '),
        _link('policies.google.com/technologies/partner-sites',
            'https://policies.google.com/technologies/partner-sites'),
        Component.text('.'),
      ]),
      _h3('4.3 Browser controls and Global Privacy Control'),
      _p('Most browsers let you block or delete cookies in their settings; blocking '
          'strictly necessary cookies may break parts of the Service. Where your browser '
          'or an extension sends a Global Privacy Control (GPC) signal, we treat it as a '
          'valid request to opt out of the sale or sharing of your personal information '
          'under applicable US state laws.'),

      _h2('5. Third parties we share information with'),
      _p('We do not sell your personal information for money. We share it only in the '
          'circumstances below, and only to the extent needed:'),
      _defs([
        [
          'Google LLC',
          'Gemini API (processing tool inputs), reCAPTCHA (abuse prevention), AdSense (advertising) and Google Fonts (typefaces). Requests to Google Fonts and to our other content delivery networks expose your IP address to those providers as a technical necessity of loading files.',
        ],
        [
          'Hosting and infrastructure providers',
          'who run our servers and produce the log data described in section 1.2, acting on our instructions as processors.',
        ],
        [
          'Content delivery networks',
          'that serve stylesheets and scripts used by the site.',
        ],
        [
          'Professional advisers',
          'such as lawyers and accountants, where they need the information to advise us.',
        ],
        [
          'Authorities and legal claims',
          'where we are required by law, court order or a valid request from a public authority, or where disclosure is necessary to establish, exercise or defend legal claims, prevent fraud, or protect the rights and safety of any person.',
        ],
        [
          'A successor entity',
          'in connection with a merger, acquisition, financing or sale of assets. We will notify you before your information becomes subject to a materially different privacy policy.',
        ],
      ]),
      _p('For the purposes of certain US state laws, allowing advertising partners to set '
          'cookies for cross-context behavioural advertising can count as "sharing" or a '
          '"sale" even though no money changes hands. Section 13 explains how to opt out.'),

      _h2('6. International transfers of information'),
      _p('We operate from the United States, and our service providers are located in the '
          'United States and other countries. If you use the Service from the EEA, the UK, '
          'Switzerland, Australia or elsewhere, your information will be transferred to and '
          'processed in countries whose data protection laws may differ from those in your '
          'own country.'),
      _bullets([
        'For transfers out of the EEA, we rely on the European Commission’s Standard Contractual Clauses, on an adequacy decision, or on our providers’ certification under the EU-US Data Privacy Framework, as applicable.',
        'For transfers out of the UK, we rely on the UK International Data Transfer Agreement or the UK Addendum to the Standard Contractual Clauses.',
        'For transfers out of Switzerland, we rely on the Swiss Standard Contractual Clauses or the Swiss-US Data Privacy Framework.',
        'For Australian users, this is an overseas disclosure under Australian Privacy Principle 8. We take reasonable steps to ensure overseas recipients handle your information consistently with the Australian Privacy Principles.',
      ]),
      _p('You may request a copy of the safeguards we rely on by emailing us.'),

      _h2('7. How long we keep information'),
      _defs([
        [
          'Tool inputs and AI outputs',
          'held only for as long as it takes to process your request and return a result. Not written to a database by us.',
        ],
        [
          'Server logs',
          'retained for a limited period — ordinarily no more than 90 days — for security, diagnostics and abuse investigation, then deleted or aggregated.',
        ],
        [
          'Support emails',
          'retained for up to 24 months after your enquiry is resolved, so we can handle follow-ups and keep a record of what was agreed.',
        ],
        [
          'Advertising and analytics cookies',
          'retained for the periods set by the relevant provider, which are disclosed in our consent banner and in Google’s documentation.',
        ],
        [
          'Records we must keep by law',
          'retained for the period the relevant law requires, and then deleted.',
        ],
      ]),

      _h2('8. Security'),
      _p('We use HTTPS for all traffic, transmit tool requests over encrypted connections, '
          'apply rate limiting and bot protection, and keep the amount of personal '
          'information we hold deliberately small — the strongest protection being that '
          'we do not retain your inputs at all.'),
      _p('No method of transmission or storage is completely secure, and we cannot '
          'guarantee absolute security. If a personal data breach occurs, we will notify '
          'the relevant supervisory authority and, where required, affected individuals, '
          'within the timeframes set by applicable law — including 72 hours under the EU '
          'and UK GDPR and the Notifiable Data Breaches scheme under the Australian Privacy '
          'Act.'),

      _h2('9. Automated decision-making'),
      _p('The Service generates scores, suggestions and estimates automatically, but these '
          'are informational outputs about content you supply. We do not carry out '
          'automated decision-making that produces legal effects concerning you or '
          'similarly significantly affects you within the meaning of Article 22 of the GDPR, '
          'and we do not profile you for that purpose.'),

      _h2('10. Children’s privacy'),
      _p('The Service is intended for people aged 16 and over and is not directed to '
          'children. We do not knowingly collect personal information from children under '
          '16 (or under 13 in the United States, for the purposes of the Children’s '
          'Online Privacy Protection Act). If you believe a child has provided us with '
          'personal information, contact us and we will delete it promptly. Where local law '
          'sets a different age of digital consent, that age applies.'),

      _h2('11. Your rights — everyone'),
      _p('Wherever you live, you may ask us to:'),
      _bullets([
        'confirm whether we hold personal information about you, and give you a copy;',
        'correct information that is inaccurate or incomplete;',
        'delete information we no longer have a lawful reason to keep;',
        'stop sending you marketing, and withdraw any consent you have given;',
        'explain how we handled your information.',
      ]),
      _p('We will not discriminate against you for exercising any of these rights.'),

      _h2('12. If you are in the EEA, the UK or Switzerland'),
      _p('Under the EU GDPR, the UK GDPR and the Swiss FADP you have the rights to:'),
      _bullets([
        'Access — obtain confirmation of processing and a copy of your personal data.',
        'Rectification — have inaccurate data corrected and incomplete data completed.',
        'Erasure — have your data deleted where one of the grounds in Article 17 applies.',
        'Restriction — limit how we use your data while a dispute about it is resolved.',
        'Portability — receive data you provided in a structured, machine-readable format, and have it sent to another controller where technically feasible.',
        'Object — object at any time to processing based on legitimate interests, and object absolutely to processing for direct marketing.',
        'Withdraw consent — at any time, without affecting the lawfulness of processing carried out before withdrawal.',
        'Complain — lodge a complaint with a supervisory authority (see section 16).',
      ]),
      _p('We respond within one month, extendable by two further months for complex '
          'requests, and we will tell you if we need that extension.'),

      _h2('13. If you are in the United States'),
      _p('This section applies to residents of California, Virginia, Colorado, Connecticut, '
          'Utah, Texas, Oregon, Montana, and other states with comprehensive privacy laws in '
          'force. It supplements the rest of this policy.'),
      _h3('13.1 Categories of personal information'),
      _p('In the 12 months before the date at the top of this policy, we collected the '
          'following categories under the California Consumer Privacy Act, as amended by '
          'the CPRA:'),
      _defs([
        [
          'Identifiers',
          'IP address and, if you email us, your email address. Source: you and your device. Purpose: security, service delivery, support. Disclosed to: hosting, security and advertising providers.',
        ],
        [
          'Internet or network activity',
          'pages viewed, tools used, referring URL, browser and device characteristics. Source: your device. Purpose: security, improvement, advertising. Disclosed to: hosting and advertising providers.',
        ],
        [
          'Geolocation data',
          'coarse country or region inferred from IP. Source: your device. Purpose: security, legal compliance, ad delivery. Disclosed to: hosting and advertising providers.',
        ],
        [
          'Commercial or inference data',
          'advertising interest signals inferred by Google. Source: advertising cookies. Purpose: advertising. Disclosed to: Google and its ad partners.',
        ],
        [
          'Sensitive personal information',
          'none. We do not collect it and do not use or disclose it for purposes that would trigger the right to limit.',
        ],
      ]),
      _h3('13.2 Sale and sharing'),
      _p('We do not sell personal information for monetary consideration. We do allow '
          'advertising partners to set cookies for cross-context behavioural advertising, '
          'which counts as "sharing" under the CPRA and as a "sale" or "targeted '
          'advertising" under several other state laws. You may opt out at any time by '
          'using the Cookie Settings link in the site footer, by enabling Global Privacy '
          'Control in your browser, by using the Google opt-out links in section 4.2, or by '
          'emailing us. We do not knowingly sell or share the personal '
          'information of consumers under 16.'),
      _h3('13.3 Your state-law rights'),
      _bullets([
        'Know and access the categories and specific pieces of personal information we collected about you.',
        'Delete personal information we collected from you, subject to statutory exceptions.',
        'Correct inaccurate personal information.',
        'Opt out of the sale or sharing of personal information and of targeted advertising.',
        'Limit the use and disclosure of sensitive personal information (not applicable, as we collect none).',
        'Appeal a refused request, in states that provide an appeal right. If we deny your appeal, we will tell you how to contact your state Attorney General.',
        'Be free from discrimination or retaliation for exercising these rights.',
      ]),
      _p('Send requests to $legalContactEmail with "Privacy Request" in the subject line. '
          'Because we do not maintain accounts, we verify requests by matching them against '
          'the limited information we hold; we may ask for additional detail, and we may be '
          'unable to complete a request we cannot reasonably verify. An authorised agent may '
          'submit a request on your behalf with written proof of authority. We respond '
          'within 45 days, extendable by a further 45 days with notice.'),

      _h2('14. If you are in Australia'),
      _p('We handle personal information in accordance with the Privacy Act 1988 (Cth) and '
          'the Australian Privacy Principles. In addition to the rights in section 11:'),
      _bullets([
        'You may deal with us anonymously or under a pseudonym wherever it is lawful and practicable — and with our tools, it always is, because no identification is required.',
        'You may request access to the personal information we hold about you (APP 12) and ask us to correct it (APP 13). We will respond within a reasonable period, ordinarily 30 days, and will give reasons in writing if we refuse.',
        'We disclose personal information to overseas recipients as described in section 6, principally in the United States (APP 8).',
        'Eligible data breaches are notified to the Office of the Australian Information Commissioner and to affected individuals under the Notifiable Data Breaches scheme.',
      ]),
      p(classes: 'mb-3', [
        Component.text('If you are unhappy with our response, you may complain to the Office of the '
            'Australian Information Commissioner at '),
        _link('oaic.gov.au', 'https://www.oaic.gov.au/privacy/privacy-complaints'),
        Component.text('.'),
      ]),

      _h2('15. If you are in Canada'),
      _p('We handle personal information in accordance with the Personal Information '
          'Protection and Electronic Documents Act (PIPEDA) and applicable provincial laws. '
          'You may access and correct your personal information and withdraw consent '
          'subject to legal and contractual restrictions, and you may complain to the '
          'Office of the Privacy Commissioner of Canada.'),

      _h2('16. Contact and complaints'),
      p(classes: 'mb-3', [
        Component.text('For any privacy question or request, email '),
        a(
          href: 'mailto:$legalContactEmail',
          classes: 'font-medium text-yt-red hover:underline',
          [Component.text(legalContactEmail)],
        ),
        Component.text('. A postal address is available on request. We ask that you contact us first '
            'so we have a chance to put things right — but you always have the right to '
            'go straight to a regulator:'),
      ]),
      _defs([
        [
          'EEA',
          'your national data protection authority. The list is maintained by the European Data Protection Board at edpb.europa.eu.',
        ],
        [
          'United Kingdom',
          'the Information Commissioner’s Office at ico.org.uk, or 0303 123 1113.',
        ],
        [
          'Switzerland',
          'the Federal Data Protection and Information Commissioner at edoeb.admin.ch.',
        ],
        [
          'Australia',
          'the Office of the Australian Information Commissioner at oaic.gov.au.',
        ],
        [
          'Canada',
          'the Office of the Privacy Commissioner of Canada at priv.gc.ca.',
        ],
        [
          'United States',
          'your state Attorney General; in California, also the California Privacy Protection Agency.',
        ],
      ]),

      _h2('17. Changes to this policy'),
      _p('We may update this policy to reflect changes to the Service, our providers or the '
          'law. The "Last updated" date at the top always shows the current version. If a '
          'change materially affects how we use your personal information, we will give '
          'prominent notice on the site before it takes effect and, where the law requires '
          'it, ask for your consent again. Continuing to use the Service after an update '
          'means you accept the revised policy.'),
    ];

// ═══════════════════════════════════════════
//  TERMS OF SERVICE
// ═══════════════════════════════════════════

List<Component> termsOfServiceContent() => [
      _updated(),

      _p('These Terms of Service ("Terms") are a legal agreement between you and '
          'CreatorTools.io LLC ("CreatorTools", "we", "us" or "our") governing your access '
          'to and use of creatortools.io and the tools available on it (the "Service"). '
          'Please read them before using the Service.'),

      _callout([
        strong([Component.text('Please note. ')]),
        Component.text('Section 13 limits our liability and section 11 disclaims warranties. If you '
            'are a consumer in the UK, the EEA or Australia, section 12 explains the '
            'statutory rights those sections cannot take away from you. Nothing in these '
            'Terms excludes liability that cannot lawfully be excluded.'),
      ]),

      _h2('1. Acceptance of these Terms'),
      _p('By accessing or using the Service you agree to be bound by these Terms and by our '
          'Privacy Policy, which is incorporated by reference. If you do not agree, do not '
          'use the Service. If you are using the Service on behalf of a company or other '
          'organisation, you confirm that you have authority to bind that organisation, and '
          '"you" means that organisation.'),

      _h2('2. Who we are'),
      p(classes: 'mb-3', [
        Component.text('The Service is operated by CreatorTools.io LLC, a limited liability company '
            'organised in the United States. You can reach us at '),
        a(
          href: 'mailto:$legalContactEmail',
          classes: 'font-medium text-yt-red hover:underline',
          [Component.text(legalContactEmail)],
        ),
        Component.text('.'),
      ]),

      _h2('3. Eligibility'),
      _p('You must be at least 16 years old to use the Service. If you are under 18, or '
          'under the age of majority where you live, you may use the Service only with the '
          'involvement and consent of a parent or legal guardian who agrees to these Terms. '
          'You must also be legally capable of entering into a binding contract and not '
          'barred from using the Service under the laws of your country, including any '
          'applicable sanctions or export control laws.'),

      _h2('4. The Service'),
      _p('CreatorTools provides free, browser-based tools for online video creators, '
          'currently including an SEO Analyzer, a Title Generator, a Thumbnail Generator, a '
          'Tag Extractor, an Earnings Calculator and an editorial blog.'),
      _bullets([
        'No account is required and nothing is charged. We may introduce paid features in future, in which case separate terms will apply and you will not be charged without agreeing to them.',
        'The Service is provided for informational and productivity purposes only. It is not professional, financial, tax, legal or investment advice.',
        'We may add, change, suspend or discontinue any part of the Service at any time. Because the Service is free, we may do so without notice, but we will give reasonable notice where it is practical to do so.',
        'We may set fair-use limits, rate limits and bot checks, and may restrict access from any source that appears to be abusing the Service.',
      ]),

      _h2('5. AI-generated content'),
      _p('Several tools use third-party generative AI models to produce titles, thumbnail '
          'concepts and SEO feedback. You should understand how that works before relying on '
          'the results:'),
      _bullets([
        'Output is generated statistically and may be inaccurate, outdated, misleading, biased or nonsensical. It is your responsibility to review and verify anything before you publish it.',
        'Output is not unique to you. Another user submitting a similar prompt may receive similar or identical output, and we make no claim that output is original or free of third-party rights.',
        'As between you and us, we make no ownership claim over the output you generate. You are responsible for ensuring your use of it complies with applicable law, platform rules and any third-party rights. Copyright in AI-generated material may be limited or unavailable in your jurisdiction.',
        'You retain ownership of the text you submit. You grant us a limited, worldwide, non-exclusive, royalty-free licence to host, transmit and process it for the sole purpose of operating the Service and returning your result. That licence ends when your request completes.',
        'You must not submit content that is unlawful, infringing, defamatory, or that contains personal information about other people.',
      ]),

      _h2('6. Estimates and earnings disclaimer'),
      _p('The Earnings Calculator, SEO scores and any figures presented by the Service are '
          'illustrative estimates produced from generalised industry averages. They are not '
          'a forecast, a promise or a guarantee of any result.'),
      _p('Actual advertising revenue depends on factors entirely outside our control, '
          'including your audience geography, watch time, seasonality, advertiser demand, '
          'content category, platform policy changes and your own monetisation status. Your '
          'results will differ, and may differ substantially. We are not responsible for any '
          'business, financial or commercial decision you make on the basis of an estimate '
          'produced by the Service.'),

      _h2('7. Acceptable use'),
      _p('You agree not to, and not to permit anyone else to:'),
      _bullets([
        'use the Service in breach of any applicable law or regulation;',
        'scrape, crawl, mirror, frame or systematically extract the Service or its content, except as permitted by our robots.txt;',
        'use bots, scripts or automated means to access the tools, or circumvent reCAPTCHA, rate limits or any other technical restriction;',
        'attempt to gain unauthorised access to the Service, its servers, or any connected system or network;',
        'interfere with the operation of the Service, including through denial-of-service attacks, injection of malicious code, or excessive request volume;',
        'reverse engineer, decompile or disassemble any part of the Service, except to the extent that restriction is prohibited by law;',
        'use the Service to generate content that is unlawful, harassing, hateful, deceptive, spam, malware, or that infringes anyone’s intellectual property or privacy;',
        'use the Service to create content designed to manipulate or deceive a platform’s ranking, recommendation or monetisation systems in breach of that platform’s rules;',
        'resell, sublicense or commercially exploit the Service or its output as a standalone product;',
        'remove or obscure any proprietary notice, or misrepresent your affiliation with us.',
      ]),
      _p('We may investigate suspected breaches and may suspend or block access, remove '
          'content, or report conduct to the relevant authorities.'),

      _h2('8. Third-party services and no affiliation'),
      _p('CreatorTools.io is an independent tool. We are not affiliated with, endorsed by, '
          'sponsored by or in any way officially connected to YouTube, Google LLC, or any '
          'other platform. YouTube and the YouTube logo are trademarks of Google LLC, and '
          'all other trademarks are the property of their respective owners. References to '
          'them are nominative and descriptive only.'),
      _p('When you use the Tag Extractor, you are asking us to retrieve information from a '
          'publicly accessible page. You are responsible for ensuring your use of that '
          'information complies with the source platform’s terms of service. Your use of '
          'YouTube remains governed by YouTube’s own terms and policies.'),
      _p('The Service relies on third-party providers including Google (Gemini API, '
          'reCAPTCHA, AdSense, Fonts) and content delivery networks. Their services are '
          'governed by their own terms and privacy policies, and we are not responsible for '
          'their acts or omissions. Links to third-party sites are provided for convenience '
          'and are not an endorsement.'),

      _h2('9. Advertising'),
      _p('The Service is funded by advertising, currently through Google AdSense. Ads and '
          'sponsored content are the responsibility of the advertiser. We do not endorse '
          'advertised products or services and are not a party to any dealing between you '
          'and an advertiser. Interfering with the display of ads by technical means in '
          'order to abuse the Service is a breach of section 7.'),

      _h2('10. Intellectual property'),
      _p('The Service, including its software, design, layout, text, graphics, logos and '
          'blog articles, is owned by CreatorTools.io LLC or its licensors and is protected '
          'by copyright, trademark and other intellectual property laws. We grant you a '
          'limited, personal, non-exclusive, non-transferable, revocable licence to access '
          'and use the Service for your own creative or business purposes in accordance '
          'with these Terms. All rights not expressly granted are reserved.'),
      _p('If you believe material on the Service infringes your copyright, email us with '
          'enough detail to identify the work and the material complained of, your contact '
          'details, and a statement of good faith belief. We respond to valid notices under '
          'the US Digital Millennium Copyright Act and equivalent laws elsewhere, and we '
          'will remove or disable infringing material.'),

      _h2('11. Warranties and disclaimers'),
      _p('To the fullest extent permitted by law, and subject always to section 12, the '
          'Service is provided "as is" and "as available" without warranties of any kind, '
          'whether express, implied or statutory. We specifically disclaim implied '
          'warranties of merchantability, fitness for a particular purpose, title and '
          'non-infringement.'),
      _p('We do not warrant that the Service will be uninterrupted, timely, secure or '
          'error-free, that results will be accurate or reliable, or that defects will be '
          'corrected. No advice or information obtained from the Service creates any '
          'warranty not expressly stated here.'),

      _h2('12. Your rights as a consumer'),
      _p('Nothing in these Terms excludes, restricts or modifies any guarantee, warranty, '
          'right or remedy that applies to you under law and cannot lawfully be excluded. '
          'In particular:'),
      _defs([
        [
          'Australia',
          'our services come with guarantees that cannot be excluded under the Australian Consumer Law, including that services will be supplied with due care and skill. Where our liability can be limited, it is limited at our option to resupplying the services or paying the cost of having them resupplied. Nothing here excludes your rights under the Competition and Consumer Act 2010 (Cth).',
        ],
        [
          'United Kingdom',
          'if you are a consumer, you have statutory rights under the Consumer Rights Act 2015, including that digital services be supplied with reasonable care and skill. Those rights are unaffected by these Terms.',
        ],
        [
          'European Economic Area',
          'if you are a consumer, you keep the mandatory rights and remedies given to you by the consumer protection law of your country of residence, including under Directive (EU) 2019/770 on digital content and digital services. Those rights are unaffected by these Terms.',
        ],
        [
          'United States and elsewhere',
          'some jurisdictions do not allow the exclusion of implied warranties or the limitation of certain damages, so parts of sections 11 and 13 may not apply to you. In that case they apply only to the maximum extent permitted in your jurisdiction.',
        ],
      ]),

      _h2('13. Limitation of liability'),
      _p('Nothing in these Terms limits or excludes our liability for death or personal '
          'injury caused by our negligence, for fraud or fraudulent misrepresentation, for '
          'gross negligence or wilful misconduct, or for any other liability that cannot '
          'lawfully be limited or excluded — including under the consumer protections '
          'described in section 12.'),
      _p('Subject to that, and to the fullest extent permitted by law:'),
      _bullets([
        'we are not liable for indirect, incidental, special, consequential, exemplary or punitive damages, or for loss of profit, revenue, business, goodwill, data, subscribers, views or anticipated savings, however caused and under any theory of liability;',
        'we are not liable for any loss arising from your reliance on AI-generated output, SEO scores or earnings estimates, or from any decision you take on the basis of them;',
        'we are not liable for any action taken against you by a third-party platform, including demonetisation, restriction, strikes or account termination;',
        'we are not liable for failures caused by third-party services, your internet connection, or events beyond our reasonable control;',
        'our total aggregate liability arising out of or in connection with the Service and these Terms is limited to the greater of the amount you paid us in the 12 months before the claim arose (which, for a free service, is nil) or USD 100.',
      ]),
      _p('If you are a consumer, we are liable only for loss that is a foreseeable result of '
          'our breach, and we are not liable for loss you suffer in the course of a trade, '
          'business, craft or profession.'),

      _h2('14. Indemnity'),
      _p('If you use the Service other than as a consumer, you agree to indemnify and hold '
          'harmless CreatorTools.io LLC and its officers, members, employees and agents from '
          'any claim, liability, damage, loss or expense, including reasonable legal fees, '
          'arising out of your breach of these Terms, your misuse of the Service, your '
          'content, or your violation of any law or third-party right. This section does not '
          'apply to consumers to the extent local law prohibits it.'),

      _h2('15. Suspension and termination'),
      _p('You may stop using the Service at any time. We may suspend or terminate your '
          'access immediately, without notice, if we reasonably believe you have breached '
          'these Terms, if required by law, or if continuing to provide access would create '
          'risk or legal exposure for us or another user. Sections 5, 6, 10, 11, 12, 13, 14, '
          '16 and 17 survive termination.'),

      _h2('16. Governing law and disputes'),
      _h3('16.1 Talk to us first'),
      p(classes: 'mb-3', [
        Component.text('Most problems can be resolved quickly. Before starting formal proceedings, '
            'please email '),
        a(
          href: 'mailto:$legalContactEmail',
          classes: 'font-medium text-yt-red hover:underline',
          [Component.text(legalContactEmail)],
        ),
        Component.text(' describing the issue and the resolution you want. We will try to resolve it '
            'informally within 30 days.'),
      ]),
      _h3('16.2 Governing law'),
      _p('These Terms and any dispute arising out of them are governed by the laws of the '
          'State of Delaware, United States, without regard to its conflict-of-laws rules. '
          'The United Nations Convention on Contracts for the International Sale of Goods '
          'does not apply. Subject to section 16.3, the state and federal courts located in '
          'Delaware have exclusive jurisdiction.'),
      _h3('16.3 Consumers keep their home courts'),
      _p('If you are a consumer resident in the EEA, the UK, Australia or another country '
          'whose law gives you a non-waivable right to the protection of your local courts '
          'and mandatory local law, section 16.2 does not deprive you of that protection. '
          'You may bring proceedings in the courts of your country of residence, and the '
          'mandatory consumer law of that country continues to apply to you. UK and EEA '
          'consumers may also use an approved alternative dispute resolution or consumer '
          'ombudsman scheme available in their country, and Australian consumers may contact '
          'their state or territory fair trading office or the Australian Competition and '
          'Consumer Commission.'),
      _h3('16.4 No class actions'),
      _p('To the extent permitted by law, disputes must be brought in your individual '
          'capacity and not as a plaintiff or class member in any purported class or '
          'representative proceeding. This section does not apply where it is unenforceable '
          'under the law that applies to you.'),

      _h2('17. General'),
      _defs([
        [
          'Changes to these Terms',
          'we may update these Terms; the "Last updated" date shows the current version. Material changes will be announced on the site before they take effect. Continuing to use the Service afterwards means you accept the revised Terms. If you do not accept them, stop using the Service.',
        ],
        [
          'Severability',
          'if any provision is held invalid or unenforceable, it is modified to the minimum extent necessary or severed, and the rest of the Terms remain in full force.',
        ],
        [
          'No waiver',
          'a failure to enforce any provision is not a waiver of the right to enforce it later.',
        ],
        [
          'Assignment',
          'you may not assign or transfer these Terms without our written consent. We may assign them to an affiliate or in connection with a merger, acquisition or sale of assets.',
        ],
        [
          'Force majeure',
          'we are not liable for any failure or delay caused by events beyond our reasonable control.',
        ],
        [
          'Entire agreement',
          'these Terms and the Privacy Policy are the entire agreement between us regarding the Service and supersede any prior understanding, except that nothing limits liability for fraudulent misrepresentation.',
        ],
        [
          'Notices',
          'we may give notice by posting on the Service or by emailing an address you have given us. You give notice to us at $legalContactEmail.',
        ],
        [
          'Language',
          'these Terms are drafted in English. Any translation is provided for convenience, and the English version prevails to the extent local law permits.',
        ],
        [
          'Third parties',
          'no one other than you and us has any right to enforce these Terms, including under the Contracts (Rights of Third Parties) Act 1999 in the UK.',
        ],
      ]),
    ];
