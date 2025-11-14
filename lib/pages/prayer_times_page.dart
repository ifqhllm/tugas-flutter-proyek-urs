import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../constants/colors.dart';

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

  @override
  void initState() {
    super.initState();
    _initializePrayerTimes();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
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
          setState(() {
            _errorMessage =
                'Izin lokasi diperlukan untuk mendapatkan jadwal salat.';
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage =
              'Izin lokasi ditolak secara permanen. Silakan aktifkan di pengaturan.';
          _isLoading = false;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Reverse geocode to get location name
      final locationResponse = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&zoom=10&addressdetails=1',
        ),
      );

      if (locationResponse.statusCode == 200) {
        final locationData = json.decode(locationResponse.body);
        final address = locationData['address'] ?? {};
        final city =
            address['city'] ?? address['town'] ?? address['village'] ?? '';
        final country = address['country'] ?? '';
        _locationName = city.isNotEmpty ? '$city, $country' : country;
      } else {
        _locationName =
            '${position.latitude.toStringAsFixed(2)}, ${position.longitude.toStringAsFixed(2)}';
      }

      // Fetch prayer times from Aladhan API (Shafi'i method = 1)
      final now = DateTime.now();
      final prayerResponse = await http.get(
        Uri.parse(
          'https://api.aladhan.com/v1/timings/${now.millisecondsSinceEpoch ~/ 1000}?latitude=${position.latitude}&longitude=${position.longitude}&method=1',
        ),
      );

      if (prayerResponse.statusCode == 200) {
        final prayerData = json.decode(prayerResponse.body);
        final timings = prayerData['data']['timings'] as Map<String, dynamic>;

        _prayerTimes = {
          'Imsak': timings['Imsak'] ?? '',
          'Fajar': timings['Fajr'] ?? '',
          'Terbit': timings['Sunrise'] ?? '',
          'Dhuhur': timings['Dhuhr'] ?? '',
          'Ashar': timings['Asr'] ?? '',
          'Maghrib': timings['Maghrib'] ?? '',
          'Isya': timings['Isha'] ?? '',
        };

        _calculateNextPrayer();
        _startCountdown();
      } else {
        setState(() {
          _errorMessage = 'Gagal mengambil data jadwal salat.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
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

    final prayerOrder = ['Fajar', 'Dhuhur', 'Ashar', 'Maghrib', 'Isya'];
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

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Salat'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initializePrayerTimes,
          ),
          IconButton(
            icon: const Icon(Icons.warning),
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
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: primaryColor),
                  SizedBox(height: 16),
                  Text('Mengambil lokasi dan jadwal salat...'),
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
                          style: const TextStyle(fontSize: 16),
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
                      // Location Card
                      Container(
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
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
                      const SizedBox(height: 20),

                      // Next Prayer Countdown
                      if (_nextPrayer.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                            color: secondaryColor,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: secondaryColor.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
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
                                  fontFeatures: [FontFeature.tabularFigures()],
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
                          color: primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),

                      ..._prayerTimes.entries.map((entry) {
                        final isNextPrayer = entry.key == _nextPrayer;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isNextPrayer
                                ? secondaryColor.withOpacity(0.1)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isNextPrayer
                                  ? secondaryColor
                                  : primaryColor.withOpacity(0.3),
                              width: isNextPrayer ? 2 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                entry.key,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: isNextPrayer
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color:
                                      isNextPrayer ? secondaryColor : textColor,
                                ),
                              ),
                              Text(
                                entry.value,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isNextPrayer
                                      ? secondaryColor
                                      : primaryColor,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 20),
                      const Text(
                        'Metode Perhitungan: Shafi\'i',
                        style: TextStyle(
                          fontSize: 14,
                          color: textColor,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
    );
  }
}