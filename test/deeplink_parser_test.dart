import 'package:flutter_test/flutter_test.dart';

import 'package:example_deeplink/deeplink/engine/deeplink_parser.dart';
import 'package:example_deeplink/models/app_route.dart';

void main() {
  group('DeeplinkParser', () {
    test('parses product link with host-style scheme', () {
      final route = DeeplinkParser.parse(
        Uri.parse('exampledeeplink://product/42'),
      );

      expect(route.type, AppRouteType.product);
      expect(route.id, '42');
    });

    test('parses profile link with host-style scheme', () {
      final route = DeeplinkParser.parse(
        Uri.parse('exampledeeplink://profile/9prwork'),
      );

      expect(route.type, AppRouteType.profile);
      expect(route.id, '9prwork');
    });

    test('falls back to home for unknown path', () {
      final route = DeeplinkParser.parse(Uri.parse('exampledeeplink://'));

      expect(route.type, AppRouteType.home);
      expect(route.id, isNull);
    });
  });
}
