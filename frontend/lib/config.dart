/// Base URL of the CreatorTools API, without a trailing slash.
///
/// Defaults to the local backend so `jaspr serve` works with no extra setup.
/// For a deployed build, override it at compile time:
///
///   jaspr build --dart-define=API_BASE_URL=https://api.vidseokit.com
///
/// The same origin must also appear in the backend's ALLOWED_ORIGINS.
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://127.0.0.1:8001',
);
