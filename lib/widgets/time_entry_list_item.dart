import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:time_tracker_app/models/time_entry.dart';

class TimeEntryListItem extends StatelessWidget {
  final TimeEntry entry;

  const TimeEntryListItem({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat.yMMMd().format(entry.date);
    final formattedStartTime = DateFormat.jm().format(entry.startTime);
    final formattedEndTime = DateFormat.jm().format(entry.endTime);
    final duration = entry.duration;
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    return ExpansionTile(
      title: Text(formattedDate),
      subtitle: Text('Duration: ${hours}h ${minutes}m'),
      children: [
        ListTile(
          title: Text('Start Time: $formattedStartTime'),
          subtitle: Text('End Time: $formattedEndTime'),
        ),
      ],
    );
  }
}