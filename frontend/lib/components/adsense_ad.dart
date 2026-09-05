import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';

class AdSenseAd extends StatelessComponent {
  final String slotId;
  final String format;
  final bool fullWidthResponsive;

  const AdSenseAd({
    required this.slotId,
    this.format = 'auto',
    this.fullWidthResponsive = true,
  });

  @override
  Component build(BuildContext context) {
    return div(classes: 'ad-slot my-6 w-full flex flex-col items-center bg-yt-gray-50 dark:bg-yt-gray-800 rounded-xl p-2', [
      span(classes: 'text-[10px] uppercase tracking-wider text-yt-gray-500 mb-2', [Component.text('Advertisement')]),
      RawText('''
        <ins class="adsbygoogle"
             style="display:block; min-width:250px; width:100%;"
             data-ad-client="ca-pub-3988155577590737"
             data-ad-slot="8979837127"
             data-ad-format="$format"
             data-full-width-responsive="${fullWidthResponsive ? 'true' : 'false'}"></ins>
        <script>(adsbygoogle = window.adsbygoogle || []).push({});</script>
      ''')
    ]);
  }
}
