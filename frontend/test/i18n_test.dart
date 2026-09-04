// Regression: ISSUE-002 — a language file drifting from en.json (or a registry
// entry with no file) silently degraded that language to English at runtime,
// with nothing failing until a user picked it.
// Found by /qa on 2026-09-05
// Report: .gstack/qa-reports/qa-report-localhost-2026-09-05.md
@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:frontend/services/i18n_strings.dart';
import 'package:test/test.dart';

final _i18nDir = Directory('web/assets/i18n');

Map<String, String> _load(String code) =>
    (jsonDecode(File('${_i18nDir.path}/$code.json').readAsStringSync()) as Map)
        .map((key, value) => MapEntry(key as String, value as String));

/// Language codes declared in the picker, read as text so this test stays off
/// i18n_service.dart (it imports dart:js_util and cannot load on the VM).
List<String> _registryCodes() {
  final source = File('lib/services/i18n_service.dart').readAsStringSync();
  return RegExp(r"LanguageOption\('([^']+)'")
      .allMatches(source)
      .map((match) => match.group(1)!)
      .toList();
}

List<String> _shippedCodes() => _i18nDir
    .listSync()
    .whereType<File>()
    .where((file) => file.path.endsWith('.json'))
    .map((file) => file.uri.pathSegments.last.replaceAll('.json', ''))
    .toList()
  ..sort();

void main() {
  final english = _load('en');

  group('i18n catalogue', () {
    test('every registry language ships a file', () {
      expect(_registryCodes().toSet().difference(_shippedCodes().toSet()), isEmpty);
    });

    test('every shipped file is offered in the picker', () {
      expect(_shippedCodes().toSet().difference(_registryCodes().toSet()), isEmpty);
    });

    test('the picker lists each language once', () {
      final codes = _registryCodes();
      expect(codes.length, codes.toSet().length);
    });

    test('the compiled English fallback matches en.json', () {
      // Guards against editing en.json without rerunning tool/gen_i18n_fallback.dart.
      expect(kEnglishStrings, english);
    });

    for (final code in _shippedCodes()) {
      test('$code has exactly the English key set', () {
        final translation = _load(code);
        expect(translation.keys.toSet().difference(english.keys.toSet()), isEmpty,
            reason: '$code.json has keys English does not');
        expect(english.keys.toSet().difference(translation.keys.toSet()), isEmpty,
            reason: '$code.json is missing keys');
      });

      test('$code keeps every {count} placeholder', () {
        final translation = _load(code);
        for (final entry in english.entries) {
          if (entry.value.contains('{count}')) {
            expect(translation[entry.key], contains('{count}'),
                reason: '$code.json dropped {count} from ${entry.key}, so the '
                    'number would never be substituted');
          }
        }
      });

      test('$code leaves no value empty', () {
        _load(code).forEach((key, value) {
          expect(value.trim(), isNotEmpty, reason: '$code.json has an empty $key');
        });
      });
    }
  });
}
