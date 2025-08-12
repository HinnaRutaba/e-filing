import 'dart:async';
import 'dart:ui';

class TypingDetector {
  final int milliseconds;

  Timer? _timer;

  TypingDetector({this.milliseconds = 500});

  run(VoidCallback action) {
    if (null != _timer) {
      _timer!.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
