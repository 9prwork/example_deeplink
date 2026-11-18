# example_deeplink

A minimal Flutter example demonstrating custom URL scheme deep linking on
Android and iOS, using [`app_links`](https://pub.dev/packages/app_links) and
`flutter_bloc`.

Example links:
```
exampledeeplink://product/42
exampledeeplink://profile/9prwork
```

## Deep link flow

```
URL ถูกเปิด (เบราว์เซอร์ / terminal / แอปอื่น)
        │
        ▼
OS จับคู่ scheme "exampledeeplink" → เปิดแอปนี้
        │
        ▼
AppLinks().uriLinkStream  →  ยิง Uri ออกมา
        │
        ▼
_RootViewState._handleUri(uri)   (lib/main.dart)
  - กันเหตุการณ์ซ้ำ (ลิงก์เดิมถูกยิงซ้ำตอน cold start)
        │
        ▼
DeeplinkBloc.add(DeeplinkReceived(uri))
        │
        ▼
DeeplinkParser.parse(uri)   (engine, pure function)
  - แยก host + path segments → map เป็น AppRoute
        │
        ▼
emit(DeeplinkState(route: route))
        │
        ▼
BlocListener รับ state ใหม่ → _pushRoute(route)
        │
        ▼
Navigator.push(Viewที่ตรงกับ route.type)
```

### 1. ลงทะเบียน URL scheme ในแต่ละแพลตฟอร์ม

**Android** — [android/app/src/main/AndroidManifest.xml](android/app/src/main/AndroidManifest.xml)
เพิ่ม `intent-filter` ให้ `MainActivity` ดักจับ scheme:
```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW"/>
    <category android:name="android.intent.category.DEFAULT"/>
    <category android:name="android.intent.category.BROWSABLE"/>
    <data android:scheme="exampledeeplink"/>
</intent-filter>
```

**iOS** — [ios/Runner/Info.plist](ios/Runner/Info.plist)
ประกาศ `CFBundleURLSchemes`:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>com.example.exampleDeeplink</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>exampledeeplink</string>
        </array>
    </dict>
</array>
```

ทั้งสองแพลตฟอร์มผูก scheme เดียวกันคือ `exampledeeplink`

### 2. รับ Uri ด้วย `app_links` — [lib/main.dart](lib/main.dart)

`_RootViewState` สร้าง `AppLinks()` แล้ว subscribe `uriLinkStream` ตอน `initState`:

```dart
final _appLinks = AppLinks();
StreamSubscription<Uri>? _linkSubscription;

@override
void initState() {
  super.initState();
  _linkSubscription = _appLinks.uriLinkStream.listen(_handleUri);
}
```

จุดสำคัญ: `uriLinkStream` จะ replay ลิงก์ตอน cold start (เปิดแอปครั้งแรกจากลิงก์) เป็น event แรกอยู่แล้ว จึง**ไม่ต้อง**เรียก `getInitialLink()` เพิ่ม ไม่งั้นจะได้ลิงก์เดิมซ้ำ 2 ครั้ง — และทั้ง Android/iOS บางเคสยิง event cold-start ซ้ำเองด้วย จึงกัน duplicate ด้วย `_lastHandledUri`:

```dart
void _handleUri(Uri uri) {
  if (uri == _lastHandledUri) return;
  _lastHandledUri = uri;
  context.read<DeeplinkBloc>().add(DeeplinkReceived(uri));
}
```

### 3. Bloc รับ event → เรียก engine — [lib/deeplink/bloc/](lib/deeplink/bloc/)

- `DeeplinkEvent` / `DeeplinkReceived(Uri uri)` — event เดียว ถือ `Uri` ที่รับมา
- `DeeplinkState` — เก็บ `AppRoute? route` ปัจจุบัน (immutable, มี `copyWith`)
- `DeeplinkBloc` รับ `DeeplinkReceived` แล้ว **ไม่ parse เองใน bloc** แต่ส่งต่อให้ engine:

```dart
void _onDeeplinkReceived(DeeplinkReceived event, Emitter<DeeplinkState> emit) {
  final route = DeeplinkParser.parse(event.uri);
  emit(state.copyWith(route: route));
}
```

### 4. Engine แปลง Uri → AppRoute (pure logic) — [lib/deeplink/engine/deeplink_parser.dart](lib/deeplink/engine/deeplink_parser.dart)

`DeeplinkParser.parse` เป็น static method ล้วน ๆ ไม่มี side effect: รวม `host` + `pathSegments` เป็น segment list เดียว แล้ว `switch` บน segment แรกเพื่อ map เป็น `AppRoute`:

```dart
static AppRoute parse(Uri uri) {
  final segments = [if (uri.host.isNotEmpty) uri.host, ...uri.pathSegments];
  if (segments.isEmpty) return const AppRoute(type: AppRouteType.home);

  switch (segments.first) {
    case 'product':
      return AppRoute(type: AppRouteType.product, id: segments.length > 1 ? segments[1] : null);
    case 'profile':
      return AppRoute(type: AppRouteType.profile, id: segments.length > 1 ? segments[1] : null);
    default:
      return const AppRoute(type: AppRouteType.home);
  }
}
```

ที่รวม `host` เข้ากับ `pathSegments` เพราะ custom scheme แบบ `exampledeeplink://product/42` ถูก Dart's `Uri` ตีความให้ `product` เป็น `host` ไม่ใช่ path segment แรก — ทดสอบ 2 รูปแบบนี้ถูก cover ไว้ใน [test/deeplink_parser_test.dart](test/deeplink_parser_test.dart)

รูปแบบ route ที่รองรับตอนนี้ ([lib/models/app_route.dart](lib/models/app_route.dart)):

| Path | AppRouteType | ตัวอย่าง |
|---|---|---|
| `product/<id>` | `product` | `exampledeeplink://product/42` |
| `profile/<id>` | `profile` | `exampledeeplink://profile/9prwork` |
| อื่น ๆ / ไม่มี path | `home` | `exampledeeplink://` |

### 5. Routing ไปหน้าที่ตรงกัน — [lib/main.dart](lib/main.dart)

`_RootView` ฟัง state เปลี่ยนด้วย `BlocListener` แล้ว push หน้าด้วย `Navigator` ตรง ๆ (ไม่ใช้ named routes):

```dart
void _pushRoute(AppRoute route) {
  if (route.type == AppRouteType.home) return;
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => _viewFor(route)));
}

Widget _viewFor(AppRoute route) {
  switch (route.type) {
    case AppRouteType.product:
      return ProductDetailView(id: route.id);
    case AppRouteType.profile:
      return ProfileView(id: route.id);
    case AppRouteType.home:
      return const HomeView();
  }
}
```

`route.type == home` ไม่ push ซ้อนเพราะ `HomeView` เป็นหน้าแรกอยู่แล้ว

### โครงสร้างไฟล์

```
lib/
  models/app_route.dart              # AppRoute, AppRouteType — pure data
  deeplink/
    bloc/
      deeplink_event.dart            # DeeplinkReceived(uri)
      deeplink_state.dart            # DeeplinkState(route)
      deeplink_bloc.dart             # event → เรียก engine → emit state
    engine/
      deeplink_parser.dart           # Uri → AppRoute (pure, static)
  main.dart                          # subscribe uriLinkStream, bind bloc → Navigator
```

## Testing deep links

Run the app on a simulator/device/emulator first (`flutter run`), then:

**Unit test ของ parser:**
```sh
flutter test test/deeplink_parser_test.dart
```

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
