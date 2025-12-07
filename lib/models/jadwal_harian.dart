class JadwalHarian {
  final String imsak;
  final String subuh;
  final String terbit;
  final String dhuha;
  final String dzuhur;
  final String ashar;
  final String maghrib;
  final String isya;

  JadwalHarian({
    required this.imsak,
    required this.subuh,
    required this.terbit,
    required this.dhuha,
    required this.dzuhur,
    required this.ashar,
    required this.maghrib,
    required this.isya,
  });

  factory JadwalHarian.fromJson(Map<String, dynamic> timings) {
    final fajr = _extractTime(timings['Fajr'] ?? '');
    final sunrise = _extractTime(timings['Sunrise'] ?? '');
    return JadwalHarian(
      imsak: _adjustTime(fajr, -10), // Imsak 10 minutes before Fajr
      subuh: fajr,
      terbit: sunrise,
      dhuha: _adjustTime(
          sunrise, 30), // Dhuha approximately 30 minutes after sunrise
      dzuhur: _extractTime(timings['Dhuhr'] ?? ''),
      ashar: _extractTime(timings['Asr'] ?? ''),
      maghrib: _extractTime(timings['Maghrib'] ?? ''),
      isya: _extractTime(timings['Isha'] ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imsak': imsak,
      'subuh': subuh,
      'terbit': terbit,
      'dhuha': dhuha,
      'dzuhur': dzuhur,
      'ashar': ashar,
      'maghrib': maghrib,
      'isya': isya,
    };
  }

  /// Extract time from Aladhan timing format (e.g., "04:43 (WIB)")
  static String _extractTime(String timingStr) {
    if (timingStr.isEmpty) return '';
    // Extract time before the timezone (e.g., "04:43" from "04:43 (WIB)")
    final timeMatch = RegExp(r'(\d{1,2}:\d{2})').firstMatch(timingStr);
    return timeMatch?.group(1) ?? '';
  }

  /// Adjust time by minutes offset
  static String _adjustTime(String baseTime, int minutesOffset) {
    if (baseTime.isEmpty) return '';
    try {
      final parts = baseTime.split(':');
      if (parts.length != 2) return baseTime;
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final baseDateTime = DateTime(2024, 1, 1, hour, minute);
      final adjusted = baseDateTime.add(Duration(minutes: minutesOffset));
      return '${adjusted.hour.toString().padLeft(2, '0')}:${adjusted.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return baseTime;
    }
  }
}
