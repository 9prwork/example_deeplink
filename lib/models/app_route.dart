enum AppRouteType { home, product, profile }

class AppRoute {
  final AppRouteType type;
  final String? id;

  const AppRoute({required this.type, this.id});

  AppRoute copyWith({AppRouteType? type, String? id}) => AppRoute(
        type: type ?? this.type,
        id: id ?? this.id,
      );
}
