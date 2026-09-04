import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:js_util' as js_util;

import 'i18n_strings.dart';

/// One entry in the language picker.
///
/// [code] doubles as the filename under `web/assets/i18n/` and as the value
/// written to the `lang` attribute of `<html>`.
class LanguageOption {
  final String code;

  /// Name written the way speakers of that language write it, so the picker is
  /// readable to someone who cannot read the current UI language.
  final String nativeName;

  final String englishName;
  final bool rtl;

  const LanguageOption(this.code, this.nativeName, this.englishName, {this.rtl = false});
}

/// Every shipped language, ordered by how widely the language is used online so
/// the picker opens on the ones most visitors need.
///
/// Adding a language is two steps: drop `<code>.json` next to `en.json` with the
/// same keys, then add its row here.
const List<LanguageOption> kSupportedLanguages = [
  // ── Tier 1: largest speaker / internet populations ──
  LanguageOption('en', 'English', 'English'),
  LanguageOption('zh', '简体中文', 'Chinese (Simplified)'),
  LanguageOption('hi', 'हिन्दी', 'Hindi'),
  LanguageOption('es', 'Español', 'Spanish'),
  LanguageOption('ar', 'العربية', 'Arabic', rtl: true),
  LanguageOption('fr', 'Français', 'French'),
  LanguageOption('bn', 'বাংলা', 'Bengali'),
  LanguageOption('pt', 'Português', 'Portuguese'),
  LanguageOption('ru', 'Русский', 'Russian'),
  LanguageOption('ur', 'اردو', 'Urdu', rtl: true),
  LanguageOption('id', 'Bahasa Indonesia', 'Indonesian'),
  LanguageOption('de', 'Deutsch', 'German'),
  LanguageOption('ja', '日本語', 'Japanese'),
  LanguageOption('tr', 'Türkçe', 'Turkish'),

  // ── Tier 2 ──
  LanguageOption('ko', '한국어', 'Korean'),
  LanguageOption('vi', 'Tiếng Việt', 'Vietnamese'),
  LanguageOption('it', 'Italiano', 'Italian'),
  LanguageOption('th', 'ไทย', 'Thai'),
  LanguageOption('fil', 'Filipino', 'Filipino'),
  LanguageOption('fa', 'فارسی', 'Persian', rtl: true),
  LanguageOption('pl', 'Polski', 'Polish'),
  LanguageOption('uk', 'Українська', 'Ukrainian'),
  LanguageOption('nl', 'Nederlands', 'Dutch'),
  LanguageOption('ms', 'Bahasa Melayu', 'Malay'),
  LanguageOption('zh-TW', '繁體中文', 'Chinese (Traditional)'),

  // ── Tier 3: South Asia ──
  LanguageOption('ta', 'தமிழ்', 'Tamil'),
  LanguageOption('te', 'తెలుగు', 'Telugu'),
  LanguageOption('mr', 'मराठी', 'Marathi'),
  LanguageOption('gu', 'ગુજરાતી', 'Gujarati'),
  LanguageOption('kn', 'ಕನ್ನಡ', 'Kannada'),
  LanguageOption('ml', 'മലയാളം', 'Malayalam'),
  LanguageOption('pa', 'ਪੰਜਾਬੀ', 'Punjabi'),
  LanguageOption('si', 'සිංහල', 'Sinhala'),
  LanguageOption('ne', 'नेपाली', 'Nepali'),

  // ── Tier 4: Europe, Africa, Middle East, rest of Asia ──
  LanguageOption('sw', 'Kiswahili', 'Swahili'),
  LanguageOption('he', 'עברית', 'Hebrew', rtl: true),
  LanguageOption('el', 'Ελληνικά', 'Greek'),
  LanguageOption('cs', 'Čeština', 'Czech'),
  LanguageOption('sv', 'Svenska', 'Swedish'),
  LanguageOption('ro', 'Română', 'Romanian'),
  LanguageOption('hu', 'Magyar', 'Hungarian'),
  LanguageOption('da', 'Dansk', 'Danish'),
  LanguageOption('fi', 'Suomi', 'Finnish'),
  LanguageOption('no', 'Norsk', 'Norwegian'),
  LanguageOption('sk', 'Slovenčina', 'Slovak'),
  LanguageOption('bg', 'Български', 'Bulgarian'),
  LanguageOption('sr', 'Српски', 'Serbian'),
  LanguageOption('hr', 'Hrvatski', 'Croatian'),
  LanguageOption('sl', 'Slovenščina', 'Slovenian'),
  LanguageOption('lt', 'Lietuvių', 'Lithuanian'),
  LanguageOption('lv', 'Latviešu', 'Latvian'),
  LanguageOption('et', 'Eesti', 'Estonian'),
  LanguageOption('sq', 'Shqip', 'Albanian'),
  LanguageOption('ca', 'Català', 'Catalan'),
  LanguageOption('af', 'Afrikaans', 'Afrikaans'),
  LanguageOption('am', 'አማርኛ', 'Amharic'),
  LanguageOption('ha', 'Hausa', 'Hausa'),
  LanguageOption('yo', 'Yorùbá', 'Yoruba'),
  LanguageOption('ig', 'Igbo', 'Igbo'),
  LanguageOption('zu', 'isiZulu', 'Zulu'),
  LanguageOption('so', 'Soomaali', 'Somali'),
  LanguageOption('my', 'မြန်မာ', 'Burmese'),
  LanguageOption('km', 'ខ្មែរ', 'Khmer'),
  LanguageOption('lo', 'ລາວ', 'Lao'),
  LanguageOption('mn', 'Монгол', 'Mongolian'),
  LanguageOption('ka', 'ქართული', 'Georgian'),
  LanguageOption('hy', 'Հայերեն', 'Armenian'),
  LanguageOption('az', 'Azərbaycan', 'Azerbaijani'),
  LanguageOption('kk', 'Қазақша', 'Kazakh'),
  LanguageOption('uz', 'Oʻzbekcha', 'Uzbek'),
  LanguageOption('ps', 'پښتو', 'Pashto', rtl: true),
];

/// Regional tags the browser reports that should resolve to a shipped file
/// rather than falling back to the bare base language.
const Map<String, String> _regionAliases = {
  'zh-hant': 'zh-TW',
  'zh-tw': 'zh-TW',
  'zh-hk': 'zh-TW',
  'zh-mo': 'zh-TW',
  'zh-hans': 'zh',
  'zh-cn': 'zh',
  'zh-sg': 'zh',
  'tl': 'fil',
  'nb': 'no',
  'nn': 'no',
  'in': 'id', // legacy code some browsers still report
  'iw': 'he', // legacy code some browsers still report
  'sh': 'sr',
};

const String _storageKey = 'ct_lang';

class I18nService {
  static final I18nService _instance = I18nService._internal();
  factory I18nService() => _instance;
  I18nService._internal();

  Map<String, dynamic> _translations = kEnglishStrings;
  final Map<String, dynamic> _fallback = kEnglishStrings;
  String _currentLanguage = 'en';
  bool _isInitialized = false;

  String get currentLanguage => _currentLanguage;

  LanguageOption get currentOption => optionFor(_currentLanguage);

  bool get isRtl => currentOption.rtl;

  static LanguageOption optionFor(String code) {
    for (final option in kSupportedLanguages) {
      if (option.code == code) return option;
    }
    return kSupportedLanguages.first;
  }

  /// Maps anything the browser reports (`pt-BR`, `zh-Hant-TW`, `EN_us`) onto a
  /// shipped language code, or null when nothing matches.
  static String? resolve(String? tag) {
    if (tag == null || tag.isEmpty) return null;
    final normalized = tag.replaceAll('_', '-').toLowerCase();

    if (_regionAliases.containsKey(normalized)) return _regionAliases[normalized];

    for (final option in kSupportedLanguages) {
      if (option.code.toLowerCase() == normalized) return option.code;
    }

    final base = normalized.split('-')[0];
    if (_regionAliases.containsKey(base)) return _regionAliases[base];
    for (final option in kSupportedLanguages) {
      if (option.code.toLowerCase() == base) return option.code;
    }
    return null;
  }

  Future<void> init() async {
    if (_isInitialized) return;

    final saved = resolve(_readStoredLanguage());
    final detected = saved ?? _detectBrowserLanguage() ?? 'en';

    await _apply(detected, persist: false);
    _isInitialized = true;
  }

  String? _detectBrowserLanguage() {
    try {
      final nav = js_util.getProperty(js_util.globalThis, 'navigator');

      // navigator.languages is ordered by user preference; the first entry we
      // actually ship wins.
      final languages = js_util.getProperty(nav, 'languages');
      if (languages != null) {
        final length = js_util.getProperty(languages, 'length');
        if (length is num) {
          for (var i = 0; i < length.toInt(); i++) {
            final match = resolve(js_util.getProperty(languages, '$i')?.toString());
            if (match != null) return match;
          }
        }
      }

      return resolve(js_util.getProperty(nav, 'language')?.toString());
    } catch (e) {
      print('Could not detect browser language: $e');
      return null;
    }
  }

  String? _readStoredLanguage() {
    try {
      final storage = js_util.getProperty(js_util.globalThis, 'localStorage');
      return js_util.callMethod(storage, 'getItem', [_storageKey])?.toString();
    } catch (e) {
      return null; // Private browsing or blocked storage: fall through to detection.
    }
  }

  void _storeLanguage(String code) {
    try {
      final storage = js_util.getProperty(js_util.globalThis, 'localStorage');
      js_util.callMethod(storage, 'setItem', [_storageKey, code]);
    } catch (e) {
      // Not being able to remember the choice is not worth breaking the switch over.
    }
  }

  /// Keeps `<html lang>` and `<html dir>` in step with the active language so
  /// screen readers, search engines and RTL scripts all behave.
  void _applyDocumentAttributes(LanguageOption option) {
    try {
      final document = js_util.getProperty(js_util.globalThis, 'document');
      final root = js_util.getProperty(document, 'documentElement');
      js_util.callMethod(root, 'setAttribute', ['lang', option.code]);
      js_util.callMethod(root, 'setAttribute', ['dir', option.rtl ? 'rtl' : 'ltr']);
    } catch (e) {
      print('Could not update document language attributes: $e');
    }
  }

  Future<Map<String, dynamic>?> _fetch(String langCode) async {
    try {
      final response = await http.get(Uri.parse('/assets/i18n/$langCode.json'));
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      }
    } catch (e) {
      print('Failed to load language $langCode: $e');
    }
    return null;
  }

  Future<void> _apply(String langCode, {required bool persist}) async {
    if (langCode == 'en') {
      // No fetch needed: English is compiled in.
      _translations = kEnglishStrings;
      _currentLanguage = 'en';
    } else {
      final loaded = await _fetch(langCode);
      if (loaded == null) {
        // Missing or unreachable file: stay on English rather than showing keys.
        _translations = _fallback;
        _currentLanguage = 'en';
      } else {
        _translations = loaded;
        _currentLanguage = langCode;
      }
    }

    if (persist) _storeLanguage(_currentLanguage);
    _applyDocumentAttributes(optionFor(_currentLanguage));
  }

  /// Switches language for the rest of the session and remembers the choice.
  Future<void> setLanguage(String langCode) async {
    final resolved = resolve(langCode) ?? 'en';
    if (resolved == _currentLanguage) return;
    await _apply(resolved, persist: true);
  }

  /// Kept for callers that only need a one-off load without persisting.
  Future<void> loadLanguage(String langCode) => _apply(resolve(langCode) ?? 'en', persist: false);

  String t(String key, [Map<String, String>? params]) {
    String text = (_translations[key] ?? _fallback[key] ?? key).toString();

    if (params != null) {
      params.forEach((k, v) {
        text = text.replaceAll('{$k}', v);
      });
    }

    return text;
  }
}

// Global helper for easy access
String t(String key, [Map<String, String>? params]) {
  return I18nService().t(key, params);
}
