/*
 * FLauncher — version Edgar & Margot
 * Minuteur de veille : met le projecteur en veille après un délai.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */

import 'dart:async';

import 'package:flauncher/flauncher_channel.dart';
import 'package:flutter/foundation.dart';

class SleepTimerService extends ChangeNotifier {
  final FLauncherChannel _channel;

  DateTime? _deadline;
  Timer? _timer;
  Timer? _ticker;

  SleepTimerService(this._channel);

  bool get isActive => _deadline != null;

  Duration get remaining {
    if (_deadline == null) {
      return Duration.zero;
    }
    final d = _deadline!.difference(DateTime.now());
    return d.isNegative ? Duration.zero : d;
  }

  /// Texte court du temps restant, ex. « 28 min » ou « 1 h 12 ».
  String get remainingLabel {
    final minutes = (remaining.inSeconds / 60).ceil();
    if (minutes >= 60) {
      final h = minutes ~/ 60;
      final m = minutes % 60;
      return m == 0 ? '$h h' : '$h h ${m.toString().padLeft(2, '0')}';
    }
    return '$minutes min';
  }

  void start(Duration duration) {
    cancel(notify: false);
    _deadline = DateTime.now().add(duration);
    _timer = Timer(duration, _goToSleep);
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) => notifyListeners());
    notifyListeners();
  }

  void cancel({bool notify = true}) {
    _timer?.cancel();
    _ticker?.cancel();
    _timer = null;
    _ticker = null;
    _deadline = null;
    if (notify) {
      notifyListeners();
    }
  }

  Future<void> _goToSleep() async {
    cancel();
    try {
      await _channel.sleepNow();
    } catch (e) {
      debugPrint('Mise en veille impossible : $e');
    }
  }

  @override
  void dispose() {
    cancel(notify: false);
    super.dispose();
  }
}
