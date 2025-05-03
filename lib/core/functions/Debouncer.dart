import 'dart:async';

/// Debouncer utility class that helps in managing frequently invoked callbacks.
/// It ensures that the actual execution is delayed by a specified duration,
/// and if multiple calls are made within this timeframe, only the last one is executed.
class Debouncer {
  final int milliseconds;
  Timer? _timer;

  /// Creates a new Debouncer with the specified delay in milliseconds.
  ///
  /// [milliseconds] - The duration to wait before executing the callback.
  Debouncer({required this.milliseconds});

  /// Runs the provided action after waiting for the specified duration.
  /// If run is called again before the duration has passed, the previous
  /// action will be canceled and the timer will be reset.
  ///
  /// [action] - The function to execute after the delay.
  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  /// Cancels any pending action and disposes of the timer.
  /// Should be called when the debouncer is no longer needed to prevent memory leaks.
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}

/// Type alias for a function with no parameters and no return value
typedef VoidCallback = void Function();