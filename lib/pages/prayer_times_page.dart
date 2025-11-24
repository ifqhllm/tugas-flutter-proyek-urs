import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/colors.dart';
import '../services/notification_service.dart';
import '../widgets/background_widget.dart';

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

  final Map<String, IconData> _prayerIcons = {
    'Imsak': Icons.star,
    'Shubuh': Icons.brightness_2,
    'Terbit': Icons.brightness_6,
    'Dhuhur': Icons.wb_sunny,
    'Ashar': Icons.wb_cloudy,
    'Maghrib': Icons.brightness_6,
    'Isya': Icons.brightness_3,
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
      _schedulePrayerNotifications();
    }
  }

  Future<void> _initializePrayerTimes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Use default Pamekasan location
          await _setDefaultLocation();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Use default Pamekasan location
        await _setDefaultLocation();
        return;
      }

      // Request background location permission for Android 10+
      if (permission == LocationPermission.whileInUse) {
        try {
          await Geolocator.requestPermission();
          // Note: backgroundPermission might still be whileInUse on some devices
        } catch (e) {
          // Background permission not critical for initial functionality
          debugPrint('Background location permission request failed: $e');
        }
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      await _setLocation(position.latitude, position.longitude);
    } catch (e) {
      String errorMsg = 'Terjadi kesalahan: ${e.toString()}';
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Network')) {
        errorMsg =
            'Tidak ada koneksi internet. Jadwal salat memerlukan koneksi untuk perhitungan awal.';
      }
      setState(() {
        _errorMessage = errorMsg;
        _isLoading = false;
      });
    }
  }

  Future<void> _setDefaultLocation() async {
    const double defaultLat = -6.9044;
    const double defaultLon = 113.4861;
    const String defaultName = 'Pamekasan';
    await _setLocation(defaultLat, defaultLon, locationName: defaultName);
  }

  Future<void> _setLocation(double lat, double lon,
      {String? locationName}) async {
    String name = locationName ?? '';

    if (name.isEmpty) {
      // Reverse geocode to get location name
      final locationResponse = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&zoom=10&addressdetails=1',
        ),
      );

      if (locationResponse.statusCode == 200) {
        final locationData = json.decode(locationResponse.body);
        final address = locationData['address'] ?? {};
        final city =
            address['city'] ?? address['town'] ?? address['village'] ?? '';
        final country = address['country'] ?? '';
        name = city.isNotEmpty ? '$city, $country' : country;
      } else {
        name = '${lat.toStringAsFixed(2)}, ${lon.toStringAsFixed(2)}';
      }
    }

    // Save to SharedPreferences
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
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Izin lokasi diperlukan untuk update lokasi.')),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      await _setLocation(position.latitude, position.longitude);
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal update lokasi: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchPrayerTimes(double lat, double lon) async {
    try {
      // Fetch prayer times from Aladhan API (Shafi'i method = 1)
      final now = DateTime.now();
      final prayerResponse = await http.get(
        Uri.parse(
          'https://api.aladhan.com/v1/timings/${now.millisecondsSinceEpoch ~/ 1000}?latitude=$lat&longitude=$lon&method=1',
        ),
      );

      if (prayerResponse.statusCode == 200) {
        final prayerData = json.decode(prayerResponse.body);
        final timings = prayerData['data']['timings'] as Map<String, dynamic>;

        _prayerTimes = {
          'Imsak': timings['Imsak'] ?? '',
          'Shubuh': timings['Fajr'] ?? '',
          'Terbit': timings['Sunrise'] ?? '',
          'Dhuhur': timings['Dhuhr'] ?? '',
          'Ashar': timings['Asr'] ?? '',
          'Maghrib': timings['Maghrib'] ?? '',
          'Isya': timings['Isha'] ?? '',
        };

        // Save prayer times to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('prayer_times', json.encode(_prayerTimes));

        _calculateNextPrayer();
        _startCountdown();
        _schedulePrayerNotifications();
      } else {
        setState(() {
          _errorMessage =
              'Gagal mengambil data jadwal salat. Periksa koneksi internet.';
        });
      }
    } catch (e) {
      String errorMsg = 'Terjadi kesalahan: ${e.toString()}';
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Network')) {
        errorMsg =
            'Tidak ada koneksi internet. Jadwal salat memerlukan koneksi untuk perhitungan awal.';
      }
      setState(() {
        _errorMessage = errorMsg;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
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

          if (prayerTime.isAfter(now) &&
              (nextPrayerTime == null || prayerTime.isBefore(nextPrayerTime))) {
            nextPrayerTime = prayerTime;
            nextPrayerName = prayer;
          }
        }
      }
    }

    // If no prayer today, check Dawn tomorrow
    if (nextPrayerTime == null) {
      final dawnStr = _prayerTimes['Fajar'];
      if (dawnStr != null && dawnStr.isNotEmpty) {
        final parts = dawnStr.split(':');
        if (parts.length == 2) {
          final hour = int.tryParse(parts[0]) ?? 0;
          final minute = int.tryParse(parts[1]) ?? 0;
          nextPrayerTime = today
              .add(const Duration(days: 1))
              .add(Duration(hours: hour, minutes: minute));
          nextPrayerName = 'Fajar';
        }
      }
    }

    if (nextPrayerTime != null) {
      _nextPrayer = nextPrayerName;
      _timeUntilNextPrayer = nextPrayerTime.difference(now);
    }
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

  void _schedulePrayerNotifications() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    _prayerTimes.forEach((prayerName, timeStr) {
      if (timeStr.isNotEmpty &&
          prayerName != 'Imsak' &&
          prayerName != 'Terbit') {
        final parts = timeStr.split(':');
        if (parts.length == 2) {
          final hour = int.tryParse(parts[0]) ?? 0;
          final minute = int.tryParse(parts[1]) ?? 0;
          final prayerTime = today.add(Duration(hours: hour, minutes: minute));

          NotificationService()
              .schedulePrayerNotification(prayerName, prayerTime);
        }
      }
    });
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Jadwal Salat'),
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.gps_fixed),
            onPressed: _updateLocation,
            tooltip: 'Update Lokasi',
          ),
          IconButton(
            icon: const Icon(Icons.error_outline),
            onPressed: () {
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
      body: BackgroundWidget(
        child: _isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: primaryColor),
                    SizedBox(height: 16),
                    Text('Mengambil lokasi dan jadwal salat...',
                        style: TextStyle(color: Colors.black)),
                  ],
                ),
              )
            : _errorMessage.isNotEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _initializePrayerTimes,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Location and Countdown Card
                        Container(
                          padding: const EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withValues(alpha: 77),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          color: Colors.white,
                                          size: 32,
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          'Lokasi Anda',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _locationName,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (_nextPrayer.isNotEmpty)
                                    Expanded(
                                      child: Column(
                                        children: [
                                          const Text(
                                            'Waktu Salat Selanjutnya',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            _nextPrayer,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            _formatDuration(_timeUntilNextPrayer),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 32,
                                              fontWeight: FontWeight.bold,
                                              fontFeatures: [
                                                FontFeature.tabularFigures()
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              const Center(
                                child: Icon(
                                  Icons.account_balance,
                                  color: Colors.grey,
                                  size: 40,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Prayer Times List
                        const Text(
                          'Jadwal Salat Hari Ini',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),

                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: primaryColor.withValues(alpha: 77),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withValues(alpha: 26),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: _prayerTimes.entries.map((entry) {
                              final isNextPrayer = entry.key == _nextPrayer;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Row(
                                  children: [
                                    Icon(
                                      _prayerIcons[entry.key] ?? Icons.access_time,
                                      color: isNextPrayer ? secondaryColor : Colors.black,
                                      size: 28,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      entry.key,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: isNextPrayer
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      entry.value,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isNextPrayer ? secondaryColor : Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        const SizedBox(height: 20),
                        const Text(
                          'Metode Perhitungan: Shafi\'i',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
