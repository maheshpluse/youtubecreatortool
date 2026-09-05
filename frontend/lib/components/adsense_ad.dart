import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';

/// One AdSense slot.
///
/// The `<ins>` is rendered as a real element rather than through `RawText()`.
/// Raw HTML is injected with innerHTML, which silently refuses to run
/// `<script>` tags, so the `adsbygoogle.push` that used to sit inside the
/// markup never actually fired. It now runs from [initState] instead, once
/// the element is mounted.
class AdSenseAd extends StatefulComponent {
  final String slotId;
  final String format;
  final bool fullWidthResponsive;

  const AdSenseAd({
    required this.slotId,
    this.format = 'auto',
    this.fullWidthResponsive = true,
    super.key,
  });

  @override
  State<AdSenseAd> createState() => _AdSenseAdState();
}

class _AdSenseAdState extends State<AdSenseAd> {
  @override
  void initState() {
    super.initState();
    // Deferred a turn so the <ins> exists before AdSense measures it.
    Future.delayed(Duration.zero, _requestAd);
  }

  /// The Dart equivalent of `(adsbygoogle = window.adsbygoogle || []).push({})`.
  void _requestAd() {
    try {
      var queue = globalContext.getProperty<JSObject?>('adsbygoogle'.toJS);
      if (queue == null) {
        queue = globalContext.getProperty<JSFunction>('Array'.toJS).callAsConstructor<JSObject>();
        globalContext.setProperty('adsbygoogle'.toJS, queue);
      }
      queue.callMethod<JSAny?>('push'.toJS, JSObject());
    } catch (e) {
      // A blocked or missing ad library must never take the page down.
      print('AdSense slot ${component.slotId} could not be requested: $e');
    }
  }

  @override
  Component build(BuildContext context) {
    return div(
      classes: 'ad-slot my-6 w-full flex flex-col items-center bg-yt-gray-50 dark:bg-yt-gray-800 rounded-xl p-2',
      [
        span(
          classes: 'text-[10px] uppercase tracking-wider text-yt-gray-500 mb-2',
          [Component.text('Advertisement')],
        ),
        Component.element(
          tag: 'ins',
          classes: 'adsbygoogle',
          attributes: {
            'style': 'display:block; min-width:250px; width:100%;',
            'data-ad-client': 'ca-pub-3988155577590737',
            'data-ad-slot': '8979837127',
            'data-ad-format': component.format,
            'data-full-width-responsive': component.fullWidthResponsive ? 'true' : 'false',
          },
        ),
      ],
    );
  }
}
