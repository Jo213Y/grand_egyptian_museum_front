import 'dart:async';

class AppEvents {
  static final StreamController<String> _controller =
  StreamController<String>.broadcast();

  static Stream<String> get stream => _controller.stream;

  static void emit(String event) {
    _controller.add(event);
  }
}

class AppEventTypes {
  static const usersUpdated = "users_updated";
  static const hallsUpdated = "halls_updated";
  static const logsUpdated = "logs_updated";
  static const statsUpdated = "stats_updated";
}