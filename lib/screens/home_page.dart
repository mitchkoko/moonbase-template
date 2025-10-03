import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker_app/models/time_entry.dart';
import 'package:time_tracker_app/services/timer_service.dart';
import 'package:time_tracker_app/widgets/time_entry_list_item.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final timerService = Provider.of<TimerService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Tracker'),
        bottom: timerService.isRunning
            ? PreferredSize(
                preferredSize: const Size.fromHeight(30.0),
                child: Container(
                  color: Colors.lightBlueAccent,
                  child: Center(
                    child: Text(
                      'Elapsed Time: ${timerService.elapsedTime.inHours}:${(timerService.elapsedTime.inMinutes % 60).toString().padLeft(2, '0')}:${(timerService.elapsedTime.inSeconds % 60).toString().padLeft(2, '0')}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              )
            : null,
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<TimeEntry>('time_entries').listenable(),
        builder: (context, Box<TimeEntry> box, _) {
          if (box.values.isEmpty) {
            return const Center(
              child: Text('No time entries yet.'),
            );
          }

          final entriesByMonth = <String, List<TimeEntry>>{};
          for (final entry in box.values) {
            final month = DateFormat.yMMMM().format(entry.date);
            if (!entriesByMonth.containsKey(month)) {
              entriesByMonth[month] = [];
            }
            entriesByMonth[month]!.add(entry);
          }

          final sortedMonths = entriesByMonth.keys.toList()
            ..sort((a, b) {
              final aDate = DateFormat.yMMMM().parse(a);
              final bDate = DateFormat.yMMMM().parse(b);
              return bDate.compareTo(aDate);
            });

          return ListView.builder(
            itemCount: sortedMonths.length,
            itemBuilder: (context, index) {
              final month = sortedMonths[index];
              final entries = entriesByMonth[month]!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      month,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  ...entries.map((entry) => TimeEntryListItem(entry: entry)),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (timerService.isRunning) {
            timerService.stopTimer(onConfirmationNeeded: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tap again to stop'),
                  duration: Duration(seconds: 2),
                ),
              );
            });
          } else {
            timerService.startTimer();
          }
        },
        child: Icon(timerService.isRunning ? Icons.stop : Icons.play_arrow),
      ),
    );
  }
}