# Kabar

A Flutter news reader that loads headlines from NewsAPI.org. It includes home,
article detail, and favorites screens, plus search, category filters, and
loading, error, and empty states.

## Run and test

```sh
flutter pub get
cp -n env.example.json env.json
# Add your NewsAPI.org key as NEWS_API_KEY in env.json.
flutter run --dart-define-from-file=env.json
flutter test
flutter analyze
```

Keep `env.json` private; it is excluded from Git. The API key is compiled into
the app, so restrict it appropriately for your development setup.

Favorites are kept in memory and reset when the app closes. Tests and mock
previews can inject a configured `MockNewsService` into `NewsApp`:

```dart
NewsApp(
  newsService: MockNewsService(
    response: MockResponse.error,
    delay: Duration.zero,
  ),
)
```

Set `response` to `MockResponse.success`, `MockResponse.error`, or
`MockResponse.empty`. The default delay is one second.
