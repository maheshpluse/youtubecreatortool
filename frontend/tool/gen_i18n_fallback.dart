// Regenerates lib/services/i18n_strings.dart from web/assets/i18n/en.json.
//
// Run after editing en.json:  dart run tool/gen_i18n_fallback.dart
import 'dart:convert';
import 'dart:io';

String _escape(String value) => value
    .replaceAll(r'\', r'\\')
    .replaceAll("'", r"\'")
    .replaceAll(r'$', r'\$')
    .replaceAll('\n', r'\n');

void main() {
  final source = File('web/assets/i18n/en.json');
  final strings = (jsonDecode(source.readAsStringSync()) as Map).cast<String, dynamic>();

  final buffer = StringBuffer()
    ..writeln('// GENERATED FILE — do not edit by hand.')
    ..writeln('//')
    ..writeln('// Source: web/assets/i18n/en.json')
    ..writeln('// Regenerate: dart run tool/gen_i18n_fallback.dart')
    ..writeln()
    ..writeln('/// English copy compiled into the bundle.')
    ..writeln('///')
    ..writeln('/// Every other language is fetched at runtime, but English ships with the app so')
    ..writeln('/// a failed or slow asset fetch degrades to readable English instead of raw keys.')
    ..writeln('const Map<String, String> kEnglishStrings = {');

  for (final entry in strings.entries) {
    buffer.writeln("  '${_escape(entry.key)}': '${_escape(entry.value.toString())}',");
  }

  buffer.writeln('};');
  File('lib/services/i18n_strings.dart').writeAsStringSync(buffer.toString());
  stdout.writeln('Wrote lib/services/i18n_strings.dart (${strings.length} keys)');
}
