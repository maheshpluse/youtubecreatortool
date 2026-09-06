import 'package:jaspr/server.dart';
import 'package:jaspr/dom.dart';
import 'package:frontend/app.dart';
import 'package:frontend/data/site_head.dart';

import 'main.server.options.dart';

void main() {
  Jaspr.initializeApp(options: defaultServerOptions);

  runApp(Document(
    lang: 'en',
    // Kept byte-identical to the previous web/index.html. Note that
    // user-scalable=no is flagged by Lighthouse's accessibility audit; worth
    // revisiting, but not a silent change to make here.
    viewport: 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no',
    head: [RawText(kSiteHead)],
    // The client entrypoint attaches to #app, so the pre-rendered markup has to
    // live inside that same element or hydration would discard all of it.
    body: div(id: 'app', [
      // Document() builds <html> and <body> itself and would otherwise drop the
      // classes the stylesheet keys off — the page rendered unstyled without
      // these. 'dark' is the default the inline theme script in kSiteHead
      // expects; it flips the class from localStorage on load.
      const Document.html(attributes: {'class': 'dark'}),
      const Document.body(attributes: {'class': kBodyClasses}),
      App(),
    ]),
  ));
}
