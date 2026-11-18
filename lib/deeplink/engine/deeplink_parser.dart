import '../../models/app_route.dart';

class DeeplinkParser {
  static AppRoute parse(Uri uri) {
    final segments = uri.pathSegments;
    if (segments.isEmpty) return const AppRoute(type: AppRouteType.home);

    switch (segments.first) {
      case 'product':
        return AppRoute(
          type: AppRouteType.product,
          id: segments.length > 1 ? segments[1] : null,
        );
      case 'profile':
        return AppRoute(
          type: AppRouteType.profile,
          id: segments.length > 1 ? segments[1] : null,
        );
      default:
        return const AppRoute(type: AppRouteType.home);
    }
  }
}
