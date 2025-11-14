import 'package:hive/hive.dart';

part 'haid_record.g.dart';

@HiveType(typeId: 0)
class HaidRecord extends HiveObject {
  // Tanggal mulai haid
  @HiveField(0)
  late DateTime startDate;

  // Tanggal selesai haid (bisa null jika haid masih berlangsung)
  @HiveField(1)
  late DateTime? endDate;

  // Durasi haid dalam hari (dihitung saat endDate terisi)
  @HiveField(2)
  late int durationDays;

  // Keterangan tambahan (opsional)
  @HiveField(3)
  late String notes;

  HaidRecord({
    required this.startDate,
    this.endDate,
    this.durationDays = 0,
    this.notes = '',
  });

  // Metode untuk menghitung durasi saat haid selesai
  void calculateDuration() {
    if (endDate != null) {
      durationDays = endDate!.difference(startDate).inDays + 1;
    } else {
      durationDays = 0;
    }
  }
}
