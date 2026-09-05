@TestOn('browser')
library;

import 'package:jaspr_test/jaspr_test.dart';
import 'package:frontend/app.dart';

void main() {
  group('App Tests', () {
    testComponents('Renders Navbar and Hero', (tester) async {
      tester.pumpComponent(App());
      
      expect(find.text('CreatorTools'), findsComponents);
      expect(find.text('Grow your channel with '), findsOneComponent);
      expect(find.text('SEO Analyzer'), findsComponents);
    });
  });
}
