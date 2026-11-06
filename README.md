# Kabar

A Flutter news reader built with sample data for learning Flutter. It includes
home, article detail, and favorites screens, plus search, category filters, and
loading, error, and empty states.

The app currently uses `MockNewsService` and
[`assets/mock/articles.json`](assets/mock/articles.json). It does not call
NewsAPI.org and does not contain or require an API key.

## Run and test

```sh
flutter pub get
flutter run
flutter test
flutter analyze
```

Favorites are kept in memory and reset when the app closes.

To preview the mock states while developing, inject a configured
`MockNewsService` into `NewsApp`:

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
