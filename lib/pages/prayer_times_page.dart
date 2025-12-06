import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/colors.dart';
import '../services/notification_service.dart';
import '../services/sholat_service.dart';
import '../models/jadwal_harian.dart';

const Color lightText = Colors.white;
const Color darkText = Colors.black87;
const Color darkGreen = Color.fromARGB(255, 0, 100, 80);
const Color primaryColor1 = Color.fromARGB(255, 2, 180, 150);

class PrayerTimesPage extends StatefulWidget {
  const PrayerTimesPage({super.key});

  @override
  State<PrayerTimesPage> createState() => _PrayerTimesPageState();
}

class _PrayerTimesPageState extends State<PrayerTimesPage> {
  bool _isLoading = true;
  String _locationName = '';
  Map<String, String> _prayerTimes = {};
  String _nextPrayer = '';
  Duration _timeUntilNextPrayer = Duration.zero;
  Timer? _countdownTimer;
  String _errorMessage = '';
  DateTime _selectedDate = DateTime.now();

  final Map<String, IconData> _prayerIcons = {
    'Imsak': Icons.nights_stay,
    'Shubuh': Icons.wb_cloudy,
    'Terbit': Icons.wb_sunny_outlined,
    'Dhuhur': Icons.wb_sunny,
    'Ashar': Icons.cloud,
    'Maghrib': Icons.nightlight_round,
    'Isya': Icons.nights_stay_outlined,
  };

  @override
  void initState() {
    super.initState();
    _loadSavedLocation();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocationName = prefs.getString('location_name');
    final savedLatitude = prefs.getDouble('latitude');
    final savedLongitude = prefs.getDouble('longitude');

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    if (savedLocationName != null &&
        savedLatitude != null &&
        savedLongitude != null) {
      setState(() {
        _locationName = savedLocationName;
      });
      await _loadSavedPrayerTimes();
      await _fetchPrayerTimes(savedLatitude, savedLongitude);
    } else {
      await _initializePrayerTimes();
    }
  }

  Future<void> _loadSavedPrayerTimes() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTimes = prefs.getString('prayer_times');
    if (savedTimes != null) {
      _prayerTimes = Map<String, String>.from(json.decode(savedTimes));
      _calculateNextPrayer();
      _startCountdown();
      // Schedule notifications only if service is initialized
      try {
        _schedulePrayerNotifications();
      } catch (e) {
        // Notification service not ready
      }
    }
  }

  Future<void> _initializePrayerTimes() async {
    // Set loading di awal agar di layar tampil loading spinner
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        print('⚠️ GPS Permission denied, requesting permission...');
        permission = await Geolocator.requestPermission();
        print('📍 GPS Permission after request: $permission');

        if (permission == LocationPermission.denied) {
          print('❌ GPS Permission denied by user');
          setState(() {
            _errorMessage =
                'Izin lokasi ditolak. Periksa pengaturan perangkat Anda.';
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('❌ GPS Permission denied forever');
        setState(() {
          _errorMessage =
              'Izin lokasi ditolak permanen. Periksa pengaturan perangkat Anda.';
          _isLoading = false;
        });
        return;
      }

      print('✅ GPS Permission granted, getting current position...');
      // --- Ambil Posisi Saat Ini ---
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      print(
          '🎯 GPS Position obtained: Lat=${position.latitude}, Lon=${position.longitude}');
      await _setLocation(position.latitude, position.longitude);
    } catch (e) {
      print('💥 GPS INITIALIZE ERROR: ${e.runtimeType} -> ${e.toString()}');
      String errorMsg =
          'Gagal mendapatkan lokasi. Periksa koneksi internet dan izin lokasi perangkat Anda.';

      if (e.toString().toLowerCase().contains('timeout')) {
        errorMsg = 'Waktu pengambilan lokasi habis (Timeout). Coba lagi.';
      }

      setState(() {
        _errorMessage = errorMsg;
        _isLoading = false;
      });
    }
  }

  Future<void> _setLocation(double lat, double lon,
      {String? locationName}) async {
    String name = locationName ?? '';

    if (name.isEmpty) {
      // First, get city name from reverse geocoding
      try {
        final locationResponse = await http
            .get(
              Uri.parse(
                'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&zoom=10&addressdetails=1',
              ),
            )
            .timeout(const Duration(seconds: 20));

        if (locationResponse.statusCode == 200) {
          final locationData = json.decode(locationResponse.body);

          final address = locationData['address'] ?? {};
          final displayName = locationData['display_name'] ?? '';

          // Try multiple address fields to get city name
          String city = address['city'] ??
              address['town'] ??
              address['village'] ??
              address['county'] ??
              address['state'] ??
              '';

          // If city is still empty, try to extract from display_name
          if (city.isEmpty && displayName.isNotEmpty) {
            // Split display_name and take the first meaningful part
            final parts = displayName.split(', ');
            if (parts.isNotEmpty) {
              city = parts[0]; // Usually the most specific location
            }
          }

          final country = address['country'] ?? '';
          name = city.isNotEmpty
              ? '$city, $country'
              : (country.isNotEmpty ? country : 'Unknown Location');
        } else {
          name = '${lat.toStringAsFixed(2)}, ${lon.toStringAsFixed(2)}';
        }
      } catch (e) {
        name = '${lat.toStringAsFixed(2)}, ${lon.toStringAsFixed(2)}';
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('location_name', name);
    await prefs.setDouble('latitude', lat);
    await prefs.setDouble('longitude', lon);

    setState(() {
      _locationName = name;
    });

    await _fetchPrayerTimes(lat, lon);
  }

  Future<void> _updateLocation() async {
    await _initializePrayerTimes();
  }

  Future<void> _fetchPrayerTimes(double lat, double lon,
      {DateTime? date}) async {
    _countdownTimer?.cancel();

    setState(() {
      if (date != null || _prayerTimes.isEmpty) {
        _isLoading = true;
      }
      _errorMessage = '';
    });

    try {
      final now = DateTime.now();
      final targetDate = date ?? now;

      final month = targetDate.month;
      final year = targetDate.year;

      final JadwalHarian? jadwalHarian =
          await SholatService.fetchJadwalHarianByCoordinates(
              lat, lon, year, month);

      if (jadwalHarian != null) {
        // Convert JadwalHarian to Map<String, String> format for compatibility
        _prayerTimes = {
          'Imsak': jadwalHarian.imsak,
          'Shubuh': jadwalHarian.subuh,
          'Terbit': jadwalHarian.terbit,
          'Dhuhur': jadwalHarian.dzuhur,
          'Ashar': jadwalHarian.ashar,
          'Maghrib': jadwalHarian.maghrib,
          'Isya': jadwalHarian.isya,
        };

        print('Successfully fetched prayer times for $targetDate');

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Jadwal salat $_locationName berhasil dimuat'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }

        final isToday = targetDate.year == now.year &&
            targetDate.month == now.month &&
            targetDate.day == now.day;

        if (isToday) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('prayer_times', json.encode(_prayerTimes));

          _calculateNextPrayer();
          _startCountdown();
          // Schedule notifications only if service is initialized
          try {
            _schedulePrayerNotifications();
          } catch (e) {
            // Notification service not ready
          }
        } else {
          setState(() {
            _nextPrayer = 'Jadwal Hari Lain';
            _timeUntilNextPrayer = Duration.zero;
          });
        }

        setState(() {
          _isLoading = false;
        });
      } else {
        // API failed, show error
        String errorMsg =
            'Gagal mendapatkan jadwal salat. API mungkin diblokir atau ada masalah koneksi.';
        setState(() {
          _errorMessage = errorMsg;
          _isLoading = false;
        });
        // Show error snackbar
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ $errorMsg'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        return;
      }
    } catch (e) {
      String errorMsg = 'Gagal memuat jadwal salat. Silakan coba lagi.';

      if (e.toString().contains('SocketException') ||
          e.toString().contains('Network') ||
          e is TimeoutException) {
        errorMsg =
            'Koneksi internet bermasalah. Periksa koneksi internet Anda.\n\n'
            'Solusi:\n'
            '• Gunakan data seluler\n'
            '• Restart router Wi-Fi\n'
            '• Gunakan VPN\n'
            '• Input jadwal manual';
      } else {
        errorMsg =
            'API Aladhan diblokir atau tidak tersedia. Silakan gunakan input manual.';
      }

      if (_prayerTimes.isEmpty || date != null) {
        setState(() {
          _errorMessage = errorMsg;
        });
      }
    } finally {
      if (_isLoading) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _calculateNextPrayer() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final prayerOrder = ['Shubuh', 'Dhuhur', 'Ashar', 'Maghrib', 'Isya'];
    DateTime? nextPrayerTime;
    String nextPrayerName = '';

    for (final prayer in prayerOrder) {
      final timeStr = _prayerTimes[prayer];
      if (timeStr != null && timeStr.isNotEmpty) {
        final parts = timeStr.split(':');
        if (parts.length == 2) {
          final hour = int.tryParse(parts[0]) ?? 0;
          final minute = int.tryParse(parts[1]) ?? 0;
          final prayerTime = today.add(Duration(hours: hour, minutes: minute));

          if (prayerTime.isAfter(now)) {
            if (nextPrayerTime == null || prayerTime.isBefore(nextPrayerTime)) {
              nextPrayerTime = prayerTime;
              nextPrayerName = prayer;
            }
          }
        }
      }
    }

    // 2. Jika tidak ada salat yang tersisa hari ini, cari Shubuh besok
    if (nextPrayerTime == null) {
      final dawnStr = _prayerTimes['Shubuh'];
      if (dawnStr != null && dawnStr.isNotEmpty) {
        final parts = dawnStr.split(':');
        if (parts.length == 2) {
          final hour = int.tryParse(parts[0]) ?? 0;
          final minute = int.tryParse(parts[1]) ?? 0;

          // Waktu Shubuh besok
          nextPrayerTime = today
              .add(const Duration(days: 1))
              .add(Duration(hours: hour, minutes: minute));

          nextPrayerName = 'Shubuh';
        }
      }
    }

    setState(() {
      if (nextPrayerTime != null) {
        _nextPrayer = nextPrayerName;
        _timeUntilNextPrayer = nextPrayerTime.difference(now);
      } else {
        // Kasus darurat: jika data salat tidak lengkap
        _nextPrayer = 'Tidak Ada Data';
        _timeUntilNextPrayer = Duration.zero;
      }
    });
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeUntilNextPrayer.inSeconds > 0) {
          _timeUntilNextPrayer =
              _timeUntilNextPrayer - const Duration(seconds: 1);
        } else {
          // Recalculate when countdown reaches zero
          _calculateNextPrayer();
        }
      });
    });
  }

  void _schedulePrayerNotifications() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final Map<String, DateTime> prayerTimesToSchedule = {};

    _prayerTimes.forEach((prayerName, timeStr) {
      if (timeStr.isNotEmpty &&
          prayerName != 'Imsak' &&
          prayerName != 'Terbit') {
        final parts = timeStr.split(':');
        if (parts.length == 2) {
          final hour = int.tryParse(parts[0]) ?? 0;
          final minute = int.tryParse(parts[1]) ?? 0;

          final prayerTime = today.add(Duration(hours: hour, minutes: minute));

          if (prayerTime.isAfter(now.subtract(const Duration(minutes: 5)))) {
            prayerTimesToSchedule[prayerName] = prayerTime;
          }
        }
      }
    });

    if (prayerTimesToSchedule.isNotEmpty) {
      await NotificationService()
          .scheduleAllPrayersForTheDay(prayerTimesToSchedule);
    }
  }

  void _showManualInputDialog() {
    final TextEditingController shubuhController =
        TextEditingController(text: _prayerTimes['Shubuh'] ?? '');
    final TextEditingController dhuhurController =
        TextEditingController(text: _prayerTimes['Dhuhur'] ?? '');
    final TextEditingController asharController =
        TextEditingController(text: _prayerTimes['Ashar'] ?? '');
    final TextEditingController maghribController =
        TextEditingController(text: _prayerTimes['Maghrib'] ?? '');
    final TextEditingController isyaController =
        TextEditingController(text: _prayerTimes['Isya'] ?? '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Input Jadwal Salat Manual'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📍 Jadwal Salat $_locationName',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Cari jadwal salat resmi dari:',
                        style: TextStyle(fontSize: 12),
                      ),
                      const Text(
                        '• Website Kemenag Surabaya\n'
                        '• Masjid Agung Surabaya\n'
                        '• Aplikasi salat lokal',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const Text(
                  'Masukkan waktu salat dalam format HH:MM (24 jam)\nContoh: 05:30',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                _buildTimeInputField('Shubuh', shubuhController),
                _buildTimeInputField('Dhuhur', dhuhurController),
                _buildTimeInputField('Ashar', asharController),
                _buildTimeInputField('Maghrib', maghribController),
                _buildTimeInputField('Isya', isyaController),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                // Validate and save manual times
                final newTimes = {
                  'Imsak': _adjustTime(
                      shubuhController.text, -10), // 10 minutes before Shubuh
                  'Shubuh': shubuhController.text,
                  'Terbit': _adjustTime(
                      shubuhController.text, 20), // Approximate sunrise
                  'Dhuhur': dhuhurController.text,
                  'Ashar': asharController.text,
                  'Maghrib': maghribController.text,
                  'Isya': isyaController.text,
                };

                // Validate format
                bool isValid = true;
                newTimes.forEach((key, value) {
                  if (value.isNotEmpty &&
                      !RegExp(r'^\d{1,2}:\d{2}$').hasMatch(value)) {
                    isValid = false;
                  }
                });

                if (!isValid) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Format waktu salah. Gunakan HH:MM')),
                  );
                  return;
                }

                setState(() {
                  _prayerTimes = Map<String, String>.from(newTimes);
                  _errorMessage = '';
                  _isLoading = false;
                });

                _calculateNextPrayer();
                _startCountdown();
                // Schedule notifications only if service is initialized
                try {
                  _schedulePrayerNotifications();
                } catch (e) {
                  // Notification service not ready
                }

                // Save to preferences
                final prefs = SharedPreferences.getInstance();
                prefs.then((prefs) {
                  prefs.setString('prayer_times', json.encode(_prayerTimes));
                  prefs.setString(
                      'manual_input', 'true'); // Mark as manual input
                });

                Navigator.of(context).pop();
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTimeInputField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'HH:MM',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
              keyboardType: TextInputType.datetime,
            ),
          ),
        ],
      ),
    );
  }

  String _adjustTime(String baseTime, int minutesOffset) {
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

  String _formatDate(DateTime date) {
    const List<String> months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final double headerHeight = MediaQuery.of(context).size.height * 0.35;
    return Scaffold(
      body: Stack(
        children: [
          Container(color: Colors.white),

          // 1. Latar Belakang Gradien Hijau (Mirip BackgroundWidget)
          Container(
            height: headerHeight,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  secondaryColor,
                  Color.fromARGB(255, 252, 69, 160),
                ],
              ),
            ),
            child: Stack(
              children: [
                Opacity(
                  opacity: 0.1,
                  child: Image.asset(
                    'assets/silhouette.png',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ],
            ),
          ),

          // 2. AppBar Transparan
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              title: const Text('Jadwal Salat',
                  style: TextStyle(color: lightText)),
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: lightText),
              actions: [
                IconButton(
                  icon: const Icon(Icons.info_outline, color: lightText),
                  onPressed: () {
                    // Logic showDialog yang sudah ada
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Peringatan'),
                          content: const Text(
                            'waktu salat dalam aplikasi ini hanya bersifat membantu dan bukan sebagai referensi waktu salat. Untuk memastikan akurasi waktu, silakan periksa perhitungan jadwal salat di daerah Anda.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Mengerti'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),

          // 3. Konten Utama (Header dan List)
          Positioned.fill(
            top: headerHeight + 30,
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(color: lightText),
                        const SizedBox(height: 100),
                      ],
                    ),
                  )
                : _errorMessage.isNotEmpty
                    ? _buildErrorWidget()
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildPrayerTimesList(),
                            const SizedBox(height: 25),
                            _buildFooterNote(),
                          ],
                        ),
                      ),
          ),

          Positioned(
            top: AppBar().preferredSize.height + 10, // Di bawah AppBar
            left: 0,
            right: 0,
            child: _isLoading || _errorMessage.isNotEmpty
                ? const SizedBox()
                : _buildHeaderContent(),
          ),

          // Navigasi Tanggal di Tengah
          Positioned(
            top: headerHeight - 30,
            left: 20,
            right: 20,
            child: _buildDateNavigationCard(),
          ),
        ],
      ),
    );
  }

  // --- Widget Pembantu untuk Tampilan ---

  // Widget untuk menampilkan Error
  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: darkText),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: darkText),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Solusi yang bisa dicoba:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  SizedBox(height: 8),
                  Text('• Gunakan data seluler',
                      style: TextStyle(fontSize: 13)),
                  Text('• Restart router Wi-Fi',
                      style: TextStyle(fontSize: 13)),
                  Text('• Gunakan VPN jika diperlukan',
                      style: TextStyle(fontSize: 13)),
                  Text('• Atau input jadwal salat manual',
                      style: TextStyle(fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        // Force clear old data and retry with new API
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.remove('prayer_times');
                        await prefs.remove(
                            'api_version'); // Force re-initialize API version
                        await _initializePrayerTimes();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor1,
                        foregroundColor: lightText,
                      ),
                      child: const Text('Coba Lagi\n(Aladhan API)'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _showManualInputDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: lightText,
                        foregroundColor: primaryColor,
                      ),
                      child: const Text('Input Manual'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget Bagian Atas: Lokasi dan Waktu Salat Berikutnya
  Widget _buildHeaderContent() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_on,
                color: Color.fromARGB(255, 227, 0, 0), size: 18),
            const SizedBox(width: 4),
            Text(
              _locationName,
              style: const TextStyle(color: lightText, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          _nextPrayer.isNotEmpty ? _nextPrayer : 'Jadwal Salat',
          style: const TextStyle(
              color: lightText, fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        Text(
          _nextPrayer.isNotEmpty
              ? '${_prayerTimes[_nextPrayer] ?? ''} WIB'
              : '',
          style: const TextStyle(
              color: lightText, fontSize: 20, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          _nextPrayer.isNotEmpty
              ? '- ${_formatDuration(_timeUntilNextPrayer)}'
              : '--:--:--',
          style: const TextStyle(
            color: lightText,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        _buildUpdateKiblatRow(),
      ],
    );
  }

  // Widget Baris Update dan Kiblat
  Widget _buildUpdateKiblatRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: _updateLocation,
            icon: const Icon(Icons.gps_fixed, color: lightText),
            label: const Text('Update', style: TextStyle(color: lightText)),
          ),
        ],
      ),
    );
  }

  // Widget Card Navigasi Tanggal
  Widget _buildDateNavigationCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: lightText,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 20),
            onPressed: () async {
              final prefs =
                  await SharedPreferences.getInstance(); // <-- AMBIL PREFS
              final lat = prefs.getDouble('latitude');
              final lon = prefs.getDouble('longitude');

              if (lat != null && lon != null) {
                setState(() {
                  _selectedDate =
                      _selectedDate.subtract(const Duration(days: 1));
                });

                // Panggil fetchPrayerTimes dengan tanggal baru
                await _fetchPrayerTimes(lat, lon, date: _selectedDate);
              }
            },
          ),
          Column(
            children: [
              Text(
                _formatDate(_selectedDate),
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 20),
            onPressed: () async {
              // <-- JADIKAN ASYNC
              final prefs =
                  await SharedPreferences.getInstance(); // <-- AMBIL PREFS
              final lat = prefs.getDouble('latitude');
              final lon = prefs.getDouble('longitude');

              if (lat != null && lon != null) {
                setState(() {
                  _selectedDate = _selectedDate.add(const Duration(days: 1));
                });

                // Panggil fetchPrayerTimes dengan tanggal baru
                await _fetchPrayerTimes(lat, lon, date: _selectedDate);
              }
            },
          ),
        ],
      ),
    );
  }

  // Widget Daftar Waktu Salat
  Widget _buildPrayerTimesList() {
    final List<String> displayOrder = [
      'Imsak',
      'Shubuh',
      'Terbit',
      'Dhuhur',
      'Ashar',
      'Maghrib',
      'Isya',
    ];

    return Column(
      children: displayOrder.map((prayerName) {
        final timeValue = _prayerTimes[prayerName] ?? '---';
        final isNextPrayer = prayerName == _nextPrayer &&
            _selectedDate.day == DateTime.now().day;

        return Container(
          margin: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10.0),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            child: Row(
              children: [
                Icon(
                  _prayerIcons[prayerName] ?? Icons.access_time,
                  color: isNextPrayer ? primaryColor1 : darkText,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  prayerName,
                  style: TextStyle(
                    fontSize: 10,
                    color: darkText,
                  ),
                ),
                const Spacer(),
                Text(
                  timeValue,
                  style: TextStyle(
                    fontSize: 10,
                    color: isNextPrayer ? primaryColor1 : darkText,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // Widget Catatan Kaki
  Widget _buildFooterNote() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 20.0),
      child: Column(
        children: [
          // Footer note removed as per user request
        ],
      ),
    );
  }
}
