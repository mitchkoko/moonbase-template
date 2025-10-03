import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:hive/hive.dart';
import 'package:time_tracker_app/models/time_entry.dart';

const String appGroupId = 'group.com.example.time_tracker';
const String iOSWidgetName = 'TimeTrackerWidget';
const String androidWidgetName = 'TimeTrackerWidget';

void backgroundCallback(Uri? uri) async {
  if (uri?.host == 'start_stop_widget') {
    // This function is called from the background isolate, so we need to
    // initialize Hive again.
    await Hive.initFlutter('hive_background');
    Hive.registerAdapter(TimeEntryAdapter());
    final commandBox = await Hive.openBox('widget_commands');
    commandBox.put('command', 'toggle');
    commandBox.close();
  }
}

class HomeWidgetLogic {
  static void initialize() {
    HomeWidget.setAppGroupId(appGroupId);
    HomeWidget.registerBackgroundCallback(backgroundCallback);
  }

  static Future<void> updateWidget() async {
    return HomeWidget.updateWidget(
      name: androidWidgetName,
      iOSName: iOSWidgetName,
    );
  }
}