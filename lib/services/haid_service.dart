import 'package:hive_flutter/hive_flutter.dart';
import '../models/haid_record.dart';
import 'package:flutter/foundation.dart';

class HaidService {
  static const String _boxName = 'haidRecords';

  Future<Box<HaidRecord>> _openBox() async {
    return await Hive.openBox<HaidRecord>(_boxName);
  }

  Future<List<HaidRecord>> getAllRecords() async {
    final box = await _openBox();
    final records = box.values.toList().cast<HaidRecord>();
    records.sort((a, b) => b.startDate.compareTo(a.startDate));
    return records;
  }

  Future<HaidRecord?> getCurrentActiveRecord() async {
    final box = await _openBox();

    final activeRecords = box.values
        .cast<HaidRecord>()
        .where((record) => record.endDate == null)
        .toList();

    if (activeRecords.isNotEmpty) {
      return activeRecords.first;
    }
    return null;
  }

  Future<void> startHaid(DateTime startDate) async {
    final active = await getCurrentActiveRecord();
    if (active != null) {
      throw Exception("Siklus haid sebelumnya belum diakhiri.");
    }

    final newRecord = HaidRecord(startDate: startDate);

    final box = await _openBox();
    await box.add(newRecord);
  }

  Future<void> logBloodEvent(DateTime timestamp, String type) async {
    final activeRecord = await getCurrentActiveRecord();

    if (activeRecord == null) {
      throw Exception(
          "Tidak ada siklus haid yang aktif untuk mencatat event darah.");
    }

    debugPrint("Event darah '$type' dicatat pada $timestamp untuk siklus ini.");
  }

  Future<void> endHaidFinal(DateTime endDate) async {
    final activeRecord = await getCurrentActiveRecord();

    if (activeRecord == null) {
      throw Exception("Tidak ada siklus haid aktif yang dapat diakhiri.");
    }

    if (endDate.isBefore(activeRecord.startDate)) {
      throw Exception(
          "Tanggal berhenti harus setelah tanggal mulai: ${activeRecord.startDate}");
    }

    activeRecord.endDate = endDate;

    await activeRecord.save();
  }

  Future<void> clearAllRecords() async {
    final box = await _openBox();
    await box.clear();
  }
}
