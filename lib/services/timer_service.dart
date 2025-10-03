import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:time_tracker_app/models/time_entry.dart';
import 'package:home_widget/home_widget.dart';
import 'package:time_tracker_app/home_widget_logic.dart';

class TimerService extends ChangeNotifier {
  static const String _boxName = 'time_entries';
  static const String _timerStateBox = 'timer_state';
  static const String _widgetCommandsBox = 'widget_commands';
  static const String _startTimeKey = 'start_time';
  static const String _isRunningKey = 'is_running';

  bool _isRunning = false;
  DateTime? _startTime;
  Duration _elapsedTime = Duration.zero;
  Timer? _timer;
  DateTime? _lastStopTime;
  StreamSubscription? _commandListener;

  bool get isRunning => _isRunning;
  Duration get elapsedTime => _elapsedTime;

  TimerService() {
    _loadState();
    _listenForWidgetCommands();
  }

  void _listenForWidgetCommands() {
    final commandBox = Hive.box(_widgetCommandsBox);
    _commandListener = commandBox.watch().listen((event) {
      if (event.key == 'command' && event.value == 'toggle') {
        toggleTimer();
        commandBox.delete('command');
      }
    });
  }

  Future<void> _loadState() async {
    final box = await Hive.openBox(_timerStateBox);
    _isRunning = box.get(_isRunningKey, defaultValue: false);
    final startTimeMillis = box.get(_startTimeKey);
    if (_isRunning && startTimeMillis != null) {
      _startTime = DateTime.fromMillisecondsSinceEpoch(startTimeMillis);
      _elapsedTime = DateTime.now().difference(_startTime!);
      _startTimer();
    }
    notifyListeners();
  }

  Future<void> _saveState() async {
    final box = await Hive.openBox(_timerStateBox);
    await box.put(_isRunningKey, _isRunning);
    if (_startTime != null) {
      await box.put(_startTimeKey, _startTime!.millisecondsSinceEpoch);
    } else {
      await box.delete(_startTimeKey);
    }
  }

  void startTimer() {
    if (!_isRunning) {
      _startTime = DateTime.now();
      _isRunning = true;
      _elapsedTime = Duration.zero;
      _startTimer();
      _saveState();
      notifyListeners();
      _updateWidget();
    }
  }

  void stopTimer({VoidCallback? onConfirmationNeeded}) {
    final now = DateTime.now();
    if (_lastStopTime != null && now.difference(_lastStopTime!) < const Duration(seconds: 2)) {
      _confirmStop();
      _lastStopTime = null;
    } else {
      _lastStopTime = now;
      onConfirmationNeeded?.call();
    }
  }

  void _confirmStop() {
    if (_isRunning && _startTime != null) {
      final endTime = DateTime.now();
      final duration = endTime.difference(_startTime!);
      final entry = TimeEntry(
        date: _startTime!,
        startTime: _startTime!,
        endTime: endTime,
        duration: duration,
      );
      final box = Hive.box<TimeEntry>(_boxName);
      box.add(entry);

      _isRunning = false;
      _startTime = null;
      _timer?.cancel();
      _elapsedTime = Duration.zero;
      _saveState();
      notifyListeners();
      _updateWidget();
    }
  }

  void toggleTimer() {
    if (_isRunning) {
      _confirmStop();
    } else {
      startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_startTime != null) {
        _elapsedTime = DateTime.now().difference(_startTime!);
        notifyListeners();
        if (_elapsedTime.inSeconds % 60 == 0) {
          _updateWidget();
        }
      }
    });
  }

  Future<void> _updateWidget() async {
    final yesterdayDuration = await _getYesterdayDuration();
    final isRunningText = _isRunning ? 'Running' : 'Stopped';
    final elapsedTimeText = '${_elapsedTime.inHours}h ${_elapsedTime.inMinutes.remainder(60)}m';

    await HomeWidget.saveWidgetData<String>('yesterday_total', '${yesterdayDuration.inHours}h ${yesterdayDuration.inMinutes.remainder(60)}m');
    await HomeWidget.saveWidgetData<String>('timer_state', isRunningText);
    await HomeWidget.saveWidgetData<String>('elapsed_time', elapsedTimeText);
    await HomeWidget.updateWidget(name: androidWidgetName, iOSName: iOSWidgetName);
  }

  Future<Duration> _getYesterdayDuration() async {
    final box = Hive.box<TimeEntry>(_boxName);
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayEntry = box.values.firstWhere(
      (entry) =>
          entry.date.year == yesterday.year &&
          entry.date.month == yesterday.month &&
          entry.date.day == yesterday.day,
      orElse: () => TimeEntry(date: yesterday, startTime: yesterday, endTime: yesterday, duration: Duration.zero),
    );
    return yesterdayEntry.duration;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _commandListener?.cancel();
    super.dispose();
  }
}