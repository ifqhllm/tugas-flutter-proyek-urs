import 'dart:async'; // Tambahkan untuk penanganan TimeoutException
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/jadwal_harian.dart';

class SholatService {
  static const String baseUrl = 'https://api.aladhan.com/v1';

  static Future<JadwalHarian?> fetchJadwalHarianByCoordinates(
      double latitude, double longitude, DateTime targetDate) async {
    try {
      final url = Uri.parse(
          '$baseUrl/calendar/${targetDate.year}/${targetDate.month}?latitude=$latitude&longitude=$longitude&method=9');
      print('🔗 ALADHAN API URL: $url');

      final response = await http.get(url).timeout(const Duration(seconds: 30));
      print('📡 HTTP Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['code'] == 200 && data['data'] != null) {
          final jadwalData = data['data'] as List;
          print('📋 Jadwal data count: ${jadwalData.length}');

          // Cari data untuk tanggal target
          print(
              '📅 Looking for date: ${targetDate.day}/${targetDate.month}/${targetDate.year}');

          // Logika pencarian harian yang telah diperbaiki: Membandingkan STRING vs STRING.
          final targetJadwal = jadwalData.firstWhere(
            (jadwal) {
              final gregorian = jadwal['date']['gregorian'];

              // Pastikan data API dikonversi atau dibaca sebagai String.
              final dayApi = gregorian['day']?.toString();
              final monthApi = gregorian['month']['number']?.toString();
              final yearApi = gregorian['year']?.toString();

              // Target date dikonversi ke String untuk perbandingan yang benar.
              // Pad day with leading zero to match API format ("07" vs "7")
              final String targetDay =
                  targetDate.day.toString().padLeft(2, '0');
              return dayApi == targetDay &&
                  monthApi == targetDate.month.toString() &&
                  yearApi == targetDate.year.toString();
            },
            orElse: () => null,
          );

          if (targetJadwal != null) {
            print(
                '✅ Found jadwal for target date: ${targetJadwal['date']['readable']}');

            final timings = targetJadwal['timings'];
            final jadwalHarian = JadwalHarian.fromJson(timings);

            print(
                '🕐 Converted times: Imsak=${jadwalHarian.imsak}, Subuh=${jadwalHarian.subuh}, Dzuhur=${jadwalHarian.dzuhur}');
            return jadwalHarian;
          } else {
            print(
                '❌ No jadwal found for target date (${targetDate.day}/${targetDate.month}/${targetDate.year})');
            return null;
          }
        } else {
          print('❌ API response code not 200 or no data');
          return null;
        }
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('💥 Error fetching jadwal harian: $e');

      // Penanganan khusus untuk error jaringan/timeout
      if (e is http.ClientException || e is TimeoutException) {
        print(
            '🌐 Network error or timeout detected, returning default prayer times');
        return _getDefaultPrayerTimes();
      }

      return null;
    }
  }

  /// Mengembalikan jadwal salat default sebagai fallback
  static JadwalHarian _getDefaultPrayerTimes() {
    // Default times for Jakarta area (can be adjusted based on location)
    return JadwalHarian(
      imsak: '04:30',
      subuh: '04:40',
      terbit: '05:55',
      dhuha: '06:25',
      dzuhur: '12:00',
      ashar: '15:00',
      maghrib: '18:00',
      isya: '19:15',
    );
  }
}
