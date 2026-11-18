# example_deeplink

A minimal Flutter example demonstrating custom URL scheme deep linking on
Android and iOS, using [`app_links`](https://pub.dev/packages/app_links) and
`flutter_bloc`.

## How it works

- The custom scheme `exampledeeplink://` is registered in
  [android/app/src/main/AndroidManifest.xml](android/app/src/main/AndroidManifest.xml)
  and [ios/Runner/Info.plist](ios/Runner/Info.plist).
- `AppLinks().uriLinkStream` (and `getInitialLink()` for cold starts) feeds
  incoming URIs into `DeeplinkBloc` ([lib/deeplink/bloc](lib/deeplink/bloc)).
- `DeeplinkParser` ([lib/deeplink/engine/deeplink_parser.dart](lib/deeplink/engine/deeplink_parser.dart))
  turns a `Uri` into an `AppRoute` (home / product / profile + id).
- `main.dart` listens to the bloc and pushes the matching page onto the
  app's `Navigator`.

Supported links:

| Link | Opens |
|---|---|
| `exampledeeplink://product/42` | Product detail page, id `42` |
| `exampledeeplink://profile/9prwork` | Profile page, id `9prwork` |

## Testing deep links

Run the app on a simulator/device/emulator first (`flutter run`), then:

**Android (emulator or device via adb):**

```sh
adb shell am start -W -a android.intent.action.VIEW -d "exampledeeplink://product/42"
```

**iOS Simulator:**

```sh
xcrun simctl openurl booted "exampledeeplink://profile/9prwork"
```

You can also tap the sample buttons on the home screen to trigger the same
navigation without leaving the app.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
