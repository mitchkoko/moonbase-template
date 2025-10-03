import 'package:home_widget/home_widget.dart';
import 'package:hive/hive.dart';
import 'package:time_tracker_app/models/time_entry.dart';

const String appGroupId = 'group.com.example.time_tracker';
const String iOSWidgetName = 'TimeTrackerWidget';
const String androidWidgetName = 'TimeTrackerWidget';

@pragma('vm:entry-point')
void backgroundCallback(Uri? uri) async {
  if (uri?.host == 'start_stop_widget') {
    final hivePath = await HomeWidget.getWidgetData<String>('hive_path');
    if (hivePath != null) {
      Hive.init(hivePath);
      if (!Hive.isAdapterRegistered(TimeEntryAdapter().typeId)) {
        Hive.registerAdapter(TimeEntryAdapter());
      }
      final commandBox = await Hive.openBox('widget_commands');
      await commandBox.put('command', 'toggle');
      await commandBox.close();
    }
  }
}

class HomeWidgetLogic {
  static void initialize() {
    HomeWidget.setAppGroupId(appGroupId);
    HomeWidget.registerBackgroundCallback(backgroundCallback);
  }

  static Future<void> updateWidget() async {
    await HomeWidget.updateWidget(
      name: androidWidgetName,
      iOSName: iOSWidgetName,
    );
  }
}