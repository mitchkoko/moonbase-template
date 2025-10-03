import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:time_tracker_app/main.dart';
import 'package:time_tracker_app/models/time_entry.dart';

void main() {
  setUpAll(() async {
    // Initialize Hive and register the adapter for testing
    final testPath = './test/hive_test_path';
    Hive.init(testPath);
    Hive.registerAdapter(TimeEntryAdapter());
    await Hive.openBox<TimeEntry>('time_entries');
    await Hive.openBox('timer_state');
  });

  testWidgets('App starts and displays home page', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our app starts on the HomePage.
    expect(find.text('Time Tracker'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}