import 'dart:async';

class DebounceService {
  final Duration duration;
  Timer? _timer;

  DebounceService({this.duration = const Duration(milliseconds: 300)});

  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  void dispose() {
    _timer?.cancel();
  }
}