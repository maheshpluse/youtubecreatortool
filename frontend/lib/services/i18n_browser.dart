import 'dart:js_interop';
import 'dart:js_interop_unsafe';

List<String> detectBrowserLanguage() {
  try {
    final nav = globalContext.getProperty<JSAny?>('navigator'.toJS) as JSObject?;
    if (nav == null) return [];

    final langs = <String>[];
    final languages = nav.getProperty<JSAny?>('languages'.toJS) as JSObject?;
    if (languages != null) {
      final length = languages.getProperty<JSAny?>('length'.toJS).dartify();
      if (length is num) {
        for (var i = 0; i < length.toInt(); i++) {
          final lang = languages.getProperty<JSAny?>('$i'.toJS).dartify()?.toString();
          if (lang != null) langs.add(lang);
        }
      }
    }

    final singleLang = nav.getProperty<JSAny?>('language'.toJS).dartify()?.toString();
    if (singleLang != null) langs.add(singleLang);
    return langs;
  } catch (e) {
    print('Could not detect browser language: $e');
    return [];
  }
}

String? readStoredLanguage(String storageKey) {
  try {
    final storage = globalContext.getProperty<JSAny?>('localStorage'.toJS) as JSObject?;
    return storage?.callMethod<JSAny?>('getItem'.toJS, storageKey.toJS).dartify()?.toString();
  } catch (e) {
    return null;
  }
}

void storeLanguage(String storageKey, String code) {
  try {
    final storage = globalContext.getProperty<JSAny?>('localStorage'.toJS) as JSObject?;
    storage?.callMethod<JSAny?>('setItem'.toJS, storageKey.toJS, code.toJS);
  } catch (e) {
  }
}

void applyDocumentAttributes(String langCode, String dir) {
  try {
    final document = globalContext.getProperty<JSAny?>('document'.toJS) as JSObject?;
    final root = document?.getProperty<JSAny?>('documentElement'.toJS) as JSObject?;
    root?.callMethod<JSAny?>('setAttribute'.toJS, 'lang'.toJS, langCode.toJS);
    root?.callMethod<JSAny?>('setAttribute'.toJS, 'dir'.toJS, dir.toJS);
  } catch (e) {
    print('Could not update document language attributes: $e');
  }
}
