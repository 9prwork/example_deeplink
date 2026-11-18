import 'package:flutter_bloc/flutter_bloc.dart';

import '../engine/deeplink_parser.dart';
import 'deeplink_event.dart';
import 'deeplink_state.dart';

class DeeplinkBloc extends Bloc<DeeplinkEvent, DeeplinkState> {
  DeeplinkBloc() : super(const DeeplinkState()) {
    on<DeeplinkReceived>(_onDeeplinkReceived);
  }

  void _onDeeplinkReceived(
    DeeplinkReceived event,
    Emitter<DeeplinkState> emit,
  ) {
    final route = DeeplinkParser.parse(event.uri);
    emit(state.copyWith(route: route));
  }
}
