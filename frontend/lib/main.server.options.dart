// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/server.dart';
import 'package:frontend/components/adsense_ad.dart' as _adsense_ad;
import 'package:frontend/constants/theme.dart' as _theme;

/// Default [ServerOptions] for use with your Jaspr project.
///
/// Use this to initialize Jaspr **before** calling [runApp].
///
/// Example:
/// ```dart
/// import 'main.server.options.dart';
///
/// void main() {
///   Jaspr.initializeApp(
///     options: defaultServerOptions,
///   );
///
///   runApp(...);
/// }
/// ```
ServerOptions get defaultServerOptions => ServerOptions(
  clients: {
    _adsense_ad.AdSenseAd: ClientTarget<_adsense_ad.AdSenseAd>(
      'adsense_ad',
      params: __adsense_adAdSenseAd,
    ),
  },
  styles: () => [..._theme.styles],
);

Map<String, Object?> __adsense_adAdSenseAd(_adsense_ad.AdSenseAd c) => {
  'slotId': c.slotId,
  'format': c.format,
  'fullWidthResponsive': c.fullWidthResponsive,
};
