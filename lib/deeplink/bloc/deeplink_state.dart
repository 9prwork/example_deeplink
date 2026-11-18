import '../../models/app_route.dart';

class DeeplinkState {
  final AppRoute? route;

  const DeeplinkState({this.route});

  DeeplinkState copyWith({AppRoute? route, bool clearRoute = false}) =>
      DeeplinkState(route: clearRoute ? null : route ?? this.route);
}
