/// Brand profiles, used for the `sameAs` entity signal and the footer links.
///
/// `sameAs` is how Google ties this domain to the accounts that carry the same
/// brand — it is the one piece of off-page SEO that lives in the codebase. It
/// only works for profiles you actually control: pointing it at an account you
/// do not own is worse than leaving it out, so this list ships empty.
///
/// To switch it on, uncomment the lines that apply and correct the handles.
/// Everything downstream is conditional on this list being non-empty, so an
/// empty list emits no `sameAs`, no footer row and no `twitter:site` — there is
/// no placeholder to leak.
library;

class SocialProfile {
  /// Label shown in the footer.
  final String name;

  /// Full canonical profile URL.
  final String url;

  const SocialProfile(this.name, this.url);
}

const List<SocialProfile> kSocialProfiles = [
  // SocialProfile('X', 'https://x.com/<handle>'),
  // SocialProfile('YouTube', 'https://www.youtube.com/@<handle>'),
  // SocialProfile('LinkedIn', 'https://www.linkedin.com/company/<slug>'),
  // SocialProfile('Reddit', 'https://www.reddit.com/user/<handle>'),
  // SocialProfile('GitHub', 'https://github.com/<handle>'),
];

/// X/Twitter handle for the `twitter:site` card attribution, without the `@`.
///
/// Left empty the meta tag is omitted entirely. Set it only once the account
/// exists, or X will attribute cards to nobody.
const String kTwitterHandle = '';
