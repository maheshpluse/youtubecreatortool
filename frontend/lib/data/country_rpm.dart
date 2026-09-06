/// Typical YouTube RPM by country, for the markets this site targets.
///
/// These are the ranges commonly reported by creators and ad-industry
/// summaries, not figures measured by us — advertiser demand moves them every
/// quarter and niche moves them more than country does. They are presented as
/// ranges, and the page says plainly that YouTube Studio is the only accurate
/// source for any individual channel.
///
/// Ordered by the upper bound, so the highest-paying markets read first.
library;

class CountryRpm {
  final String country;

  /// ISO 3166-1 alpha-2, used for the flag emoji and hreflang-style labelling.
  final String code;

  /// Local currency advertisers bid in, which is what creators in that market
  /// actually want to see.
  final String currency;

  /// Typical all-niche RPM range in USD.
  final double minRpm;
  final double maxRpm;

  /// What makes this market behave the way it does.
  final String note;

  const CountryRpm(this.country, this.code, this.currency, this.minRpm, this.maxRpm, this.note);
}

const List<CountryRpm> kCountryRpm = [
  CountryRpm('United States', 'US', 'USD', 6.0, 12.0,
      'The deepest advertiser pool of any market, and the benchmark most published RPM figures are quoted against.'),
  CountryRpm('Australia', 'AU', 'AUD', 5.0, 10.0,
      'Consistently at or just below US rates, with strong finance and insurance bidding.'),
  CountryRpm('Norway', 'NO', 'NOK', 4.5, 9.5,
      'Small audience, high purchasing power - excellent RPM on a low view count.'),
  CountryRpm('Switzerland', 'CH', 'CHF', 4.5, 9.0,
      'Among the highest per-viewer value in Europe, particularly in finance and B2B.'),
  CountryRpm('Canada', 'CA', 'CAD', 4.0, 8.5,
      'Tracks US rates closely; the gap is widest in finance and narrowest in entertainment.'),
  CountryRpm('United Kingdom', 'GB', 'GBP', 4.0, 8.0,
      'The strongest European market, with heavy competition in finance, insurance and property.'),
  CountryRpm('Denmark', 'DK', 'DKK', 3.5, 7.0,
      'High income per viewer, though the addressable audience is small.'),
  CountryRpm('Germany', 'DE', 'EUR', 3.0, 7.0,
      'Europe’s largest ad market by spend. Strong in automotive, software and B2B.'),
  CountryRpm('Netherlands', 'NL', 'EUR', 3.0, 6.5,
      'High English-language viewing, which lets English channels earn near-local rates.'),
  CountryRpm('Sweden', 'SE', 'SEK', 3.0, 6.5,
      'Similar profile to the Netherlands - widespread English fluency lifts effective reach.'),
  CountryRpm('Ireland', 'IE', 'EUR', 3.0, 6.0,
      'English-language market with a heavy technology-sector advertiser base.'),
  CountryRpm('Austria', 'AT', 'EUR', 2.8, 6.0,
      'Broadly tracks Germany at a slightly lower rate.'),
  CountryRpm('Belgium', 'BE', 'EUR', 2.5, 5.5,
      'Split across Dutch and French audiences, which fragments advertiser targeting.'),
  CountryRpm('France', 'FR', 'EUR', 2.5, 5.0,
      'Large audience, but lower per-view rates than Germany or the UK.'),
  CountryRpm('Finland', 'FI', 'EUR', 2.5, 5.0,
      'Small market with solid rates in technology and gaming.'),
  CountryRpm('Spain', 'ES', 'EUR', 1.8, 4.0,
      'Large Spanish-speaking reach; rates sit below the northern European average.'),
  CountryRpm('Italy', 'IT', 'EUR', 1.8, 4.0,
      'Comparable to Spain, with stronger performance in food and lifestyle.'),
  CountryRpm('Poland', 'PL', 'PLN', 1.2, 3.0,
      'The largest of the fast-growing central European markets; rates are rising year on year.'),
];

/// The share of a channel's audience that has to come from the top markets
/// before overall RPM moves noticeably. Referenced in the page copy.
const String kTierOneShareNote =
    'Audience geography is reported in YouTube Studio under Analytics > Audience > Top geographies.';
