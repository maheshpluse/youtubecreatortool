/// Base URL of the VidSEOKit API, without a trailing slash.
///
/// Defaults to the production API for deployed builds.
/// For local development, override it at compile time:
///
///   jaspr serve --dart-define=API_BASE_URL=http://127.0.0.1:8001
///
/// The same origin must also appear in the backend's ALLOWED_ORIGINS.
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://vidseokit.com',
);
