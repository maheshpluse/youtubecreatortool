import 'dart:js_interop';
import 'dart:js_interop_unsafe';

void setupPrivacyCallback(void Function() onPrivacyClicked) {
  globalContext.setProperty(
    'ctOpenPrivacy'.toJS,
    onPrivacyClicked.toJS,
  );
}

void openConsentPreferences() {
  final fn = globalContext.getProperty<JSAny?>('showConsentPreferences'.toJS);
  if (fn != null) {
    globalContext.callMethod<JSAny?>('showConsentPreferences'.toJS);
  }
}

/// Fetches a reCAPTCHA token, or throws if one cannot be obtained.
///
/// executeRecaptcha resolves `null` whenever grecaptcha.enterprise.execute()
/// yields nothing, which happens on repeat calls within a single page session.
/// Typing the promise as `JSPromise<JSString>` made that null cross the interop
/// boundary as a type error raised inside a JS microtask: it never surfaced as
/// a Dart exception, so the awaiting Future never completed. The tool sat on
/// "Working..." forever and never issued the request. Take the value as
/// nullable and convert it explicitly so a missing token is an ordinary
/// exception the caller can show.
Future<String> getRecaptchaToken() async {
  final result = await globalContext
      .callMethod<JSPromise<JSAny?>>('executeRecaptcha'.toJS)
      .toDart;
  final token = result?.dartify();
  if (token is! String || token.isEmpty) {
    throw Exception(
        'Could not verify you are human. Please reload the page and try again.');
  }
  return token;
}

void pushAdSense() {
  try {
    var queue = globalContext.getProperty<JSObject?>('adsbygoogle'.toJS);
    if (queue == null) {
      queue = globalContext.getProperty<JSFunction>('Array'.toJS).callAsConstructor<JSObject>();
      globalContext.setProperty('adsbygoogle'.toJS, queue);
    }
    queue.callMethod<JSAny?>('push'.toJS, JSObject());
  } catch (e) {
    print('AdSense could not be requested: $e');
  }
}
