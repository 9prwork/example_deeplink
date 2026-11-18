import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'deeplink/bloc/deeplink_bloc.dart';
import 'deeplink/bloc/deeplink_event.dart';
import 'deeplink/bloc/deeplink_state.dart';
import 'models/app_route.dart';
import 'presentation/pages/home_view.dart';
import 'presentation/pages/product_detail_view.dart';
import 'presentation/pages/profile_view.dart';
import 'utils/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DeeplinkBloc(),
      child: MaterialApp(
        title: 'Deep Link Demo',
        theme: AppTheme.light,
        home: const _RootView(),
      ),
    );
  }
}

class _RootView extends StatefulWidget {
  const _RootView();

  @override
  State<_RootView> createState() => _RootViewState();
}

class _RootViewState extends State<_RootView> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initDeeplinks();
  }

  Future<void> _initDeeplinks() async {
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) _handleUri(initialUri);

    _linkSubscription = _appLinks.uriLinkStream.listen(_handleUri);
  }

  void _handleUri(Uri uri) {
    context.read<DeeplinkBloc>().add(DeeplinkReceived(uri));
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  void _pushRoute(AppRoute route) {
    if (route.type == AppRouteType.home) return;
    _navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => _viewFor(route)),
    );
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<DeeplinkBloc, DeeplinkState>(
      listener: (context, state) {
        final route = state.route;
        if (route == null) return;
        _pushRoute(route);
      },
      child: Navigator(
        key: _navigatorKey,
        onGenerateRoute: (settings) => MaterialPageRoute(
          builder: (_) => const HomeView(),
        ),
      ),
    );
  }
}
