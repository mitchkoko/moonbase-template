import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:home_widget/home_widget.dart';
import 'package:time_tracker_app/home_widget_logic.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker_app/models/time_entry.dart';
import 'package:time_tracker_app/screens/home_page.dart';
import 'package:time_tracker_app/services/timer_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HomeWidgetLogic.initialize();
  final appDocumentDir = await getApplicationDocumentsDirectory();
  await HomeWidget.saveWidgetData<String>('hive_path', appDocumentDir.path);
  await Hive.initFlutter(appDocumentDir.path);
  Hive.registerAdapter(TimeEntryAdapter());
  await Hive.openBox<TimeEntry>('time_entries');
  await Hive.openBox('timer_state');
  await Hive.openBox('widget_commands');

  // Add a dummy entry for testing
  final box = Hive.box<TimeEntry>('time_entries');
  if (box.isEmpty) {
    box.add(
      TimeEntry(
        date: DateTime.now().subtract(const Duration(days: 1)),
        startTime: DateTime.now().subtract(const Duration(days: 1, hours: 8)),
        endTime: DateTime.now().subtract(const Duration(days: 1)),
        duration: const Duration(hours: 8),
      ),
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TimerService(),
      child: MaterialApp(
        title: 'Time Tracker',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const HomePage(),
      ),
    );
  }
}