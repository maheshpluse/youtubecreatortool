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

Future<String> getRecaptchaToken() async {
  final token = await globalContext
      .callMethod<JSPromise<JSString>>('executeRecaptcha'.toJS)
      .toDart;
  return token.toDart;
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
