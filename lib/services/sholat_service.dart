import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/jadwal_harian.dart';

class SholatService {
  // Changed to Aladhan API which supports all locations via GPS coordinates
  static const String baseUrl = 'https://api.aladhan.com/v1';

  /// Mengambil jadwal salat harian berdasarkan koordinat GPS
  /// Menggunakan Aladhan API yang mendukung semua lokasi di dunia
  static Future<JadwalHarian?> fetchJadwalHarianByCoordinates(
      double latitude, double longitude, int tahun, int bulan) async {
    try {
      // Aladhan API endpoint untuk calendar berdasarkan koordinat
      final url = Uri.parse(
          '$baseUrl/calendar/$tahun/$bulan?latitude=$latitude&longitude=$longitude&method=2');
      print('🔗 ALADHAN API URL: $url');

      final response = await http.get(url).timeout(const Duration(seconds: 30));
      print('📡 HTTP Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('📦 Raw Response: ${response.body.substring(0, 200)}...');

        if (data['code'] == 200 && data['data'] != null) {
          final jadwalData = data['data'] as List;
          print('📋 Jadwal data count: ${jadwalData.length}');

          // Cari data untuk tanggal hari ini
          final today = DateTime.now();
          final todayDate = today.day;
          print('📅 Looking for date: $todayDate');

          // Cari jadwal yang sesuai dengan tanggal hari ini
          final todayJadwal = jadwalData.firstWhere(
            (jadwal) {
              final dateStr = jadwal['date']['readable'];
              final day = DateTime.parse(dateStr).day;
              return day == todayDate;
            },
            orElse: () => null,
          );

          if (todayJadwal != null) {
            print(
                '✅ Found jadwal for today: ${todayJadwal['date']['readable']}');

            // Extract prayer times from Aladhan format
            final timings = todayJadwal['timings'];
            print('🕐 Raw timings: $timings');

            // Convert to JadwalHarian format
            final jadwalHarian = JadwalHarian(
              imsak: _extractTime(timings['Fajr'] ?? ''),
              subuh: _extractTime(timings['Fajr'] ?? ''),
              terbit: _extractTime(timings['Sunrise'] ?? ''),
              dhuha:
                  _extractTime(timings['Dhuhr'] ?? ''), // Using Dhuhr for Dhuha
              dzuhur: _extractTime(timings['Dhuhr'] ?? ''),
              ashar: _extractTime(timings['Asr'] ?? ''),
              maghrib: _extractTime(timings['Maghrib'] ?? ''),
              isya: _extractTime(timings['Isha'] ?? ''),
            );

            print(
                '🕐 Converted times: imsak=${jadwalHarian.imsak}, subuh=${jadwalHarian.subuh}, dzuhur=${jadwalHarian.dzuhur}');
            return jadwalHarian;
          } else {
            print('❌ No jadwal found for today ($todayDate)');
            print(
                '📋 Available dates: ${jadwalData.map((j) => j['date']['readable']).toList()}');
            return null;
          }
        } else {
          print('❌ API response code not 200 or no data');
          print('📦 Full response: $data');
          return null;
        }
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        print('📦 Error body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('💥 Error fetching jadwal harian from Aladhan: $e');
      print('🔍 Error type: ${e.runtimeType}');
      print('🔍 Error message: ${e.toString()}');

      // Jika error koneksi, coba gunakan data default
      if (e.toString().contains('ClientException') ||
          e.toString().contains('SocketException') ||
          e.toString().contains('TimeoutException')) {
        print('🌐 Network error detected, returning default prayer times');
        return _getDefaultPrayerTimes();
      }

      return null;
    }
  }

  /// Extract time from Aladhan timing format (e.g., "04:43 (WIB)")
  static String _extractTime(String timingStr) {
    if (timingStr.isEmpty) return '';
    // Extract time before the timezone (e.g., "04:43" from "04:43 (WIB)")
    final timeMatch = RegExp(r'(\d{1,2}:\d{2})').firstMatch(timingStr);
    return timeMatch?.group(1) ?? '';
  }

  /// Mengembalikan jadwal salat default sebagai fallback
  static JadwalHarian _getDefaultPrayerTimes() {
    // Default times for Jakarta area (can be adjusted based on location)
    return JadwalHarian(
      imsak: '04:30',
      subuh: '04:40',
      terbit: '05:55',
      dhuha: '06:30',
      dzuhur: '12:00',
      ashar: '15:00',
      maghrib: '18:00',
      isya: '19:15',
    );
  }
}
