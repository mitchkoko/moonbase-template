import 'package:hive/hive.dart';

part 'time_entry.g.dart';

@HiveType(typeId: 0)
class TimeEntry extends HiveObject {
  @HiveField(0)
  late DateTime date;

  @HiveField(1)
  late DateTime startTime;

  @HiveField(2)
  late DateTime endTime;

  @HiveField(3)
  late Duration duration;

  TimeEntry({
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.duration,
  });
}