import 'package:hive/hive.dart';

part 'blood_event.g.dart';

@HiveType(typeId: 1)
class BloodEvent extends HiveObject {
  @HiveField(0)
  late DateTime timestamp;

  @HiveField(1)
  late String type; // e.g., 'CONTINUE_FLOW', 'START', 'END', etc.

  BloodEvent({
    required this.timestamp,
    required this.type,
  });

  @override
  String toString() {
    return 'BloodEvent(timestamp: $timestamp, type: $type)';
  }
}