abstract class DeeplinkEvent {}

class DeeplinkReceived extends DeeplinkEvent {
  final Uri uri;

  DeeplinkReceived(this.uri);
}
