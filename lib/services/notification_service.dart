import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/haid_record.dart';
import '../pages/tatacara_bersuci_page.dart';
import 'fikih_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    } catch (e) {
      debugPrint('Error setting timezone, defaulting to local: $e');
      tz.setLocalLocation(tz.local);
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Notification tapped with payload: ${response.payload}');
        if (response.payload == 'bersuci_page') {
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) => const TatacaraBersuciPage(materialNumber: 13),
            ),
          );
        }
      },
    );

    final androidPlugin =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'reminder_channel',
          'Notifikasi Pengingat',
          description: 'Notifikasi pengingat untuk siklus haid',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
          sound: RawResourceAndroidNotificationSound('reminder_sound'),
        ),
      );
    }
  }

  Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> scheduleAllNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsEnabled = prefs.getBool('recording_reminder') ?? true;

    // Batalkan semua jadwal sebelumnya terlebih dahulu
    await cancelAll();

    if (!notificationsEnabled) {
      debugPrint('All notifications canceled and disabled.');
      return;
    }

    const String userNameKey = 'user_name';
    final userName = prefs.getString(userNameKey) ?? 'Pengguna';
    final haidStatus = prefs.getString('haid_status') ?? 'Baru Mengalami';
    final kebiasaanHaid = prefs.getInt('kebiasaan_haid') ?? 0;

    // Ambil data haid aktif (dari Hive)
    final box = await Hive.openBox<HaidRecord>('haidRecords');
    final activeRecord = box.values.cast<HaidRecord?>().firstWhere(
      (r) => r != null && r.endDate == null,
      orElse: () => null,
    );

    // 1. Notifikasi Terkait Siklus Aktif (Jika Sedang Haid/Pencatatan Aktif)
    if (activeRecord != null) {
      final startDate = activeRecord.startDate;

      // Rule 1: Notifikasi 1 hari pencatatan (24 jam setelah awal pencatatan)
      final rule1Time = startDate.add(const Duration(days: 1));
      await _scheduleNotification(
        id: 100001,
        title: 'Al-Heedh',
        body: 'Assalamualaikum $userName Kemarin anda sudah memulai pencatatan, jangan lupa untuk terus mengawasi darah anda dan akhiri haid anda jika darah sudah berhenti',
        scheduledDateTime: rule1Time,
      );

      // Rule 2: Notifikasi hari ke 2 hingga seterusnya (hari 2 sampai 15)
      for (int day = 2; day <= 15; day++) {
        final rule2Time = startDate.add(Duration(days: day));
        String body = '';
        if (haidStatus == 'Baru Mengalami') {
          body = 'Assalamualaikum $userName Anda sudah memulai pencatatan, jangan lupa untuk terus mengawasi darah anda dan akhiri haid anda jika darah sudah berhenti';
        } else {
          body = 'Assalamualaikum $userName Anda sedang dalam masa haid, Silahkan amalkan wirid untuk wanita haid dan jangan lupa untuk terus mengawasi darah anda';
        }

        await _scheduleNotification(
          id: 100000 + day,
          title: 'Al-Heedh',
          body: body,
          scheduledDateTime: rule2Time,
        );
      }

      // Rule 3: Notifikasi pengingat untuk mengakhiri haid (khusus Sudah Biasa, H-1 sebelum kebiasaan)
      if (haidStatus == 'Sudah Biasa' && kebiasaanHaid > 1) {
        final rule3Time = startDate.add(Duration(days: kebiasaanHaid - 1));
        await _scheduleNotification(
          id: 200000,
          title: 'Al-Heedh',
          body: 'Assalamualaikum $userName Menurut kebiasaan haid anda, Besok seharusnya darah sudah berhenti keluar jadi jangan lupa untuk mengakhiri haid anda. Silahkan baca tatacara bersuci dari haid',
          scheduledDateTime: rule3Time,
          payload: 'bersuci_page',
        );
      }
    }

    // Rule 4: Notifikasi prediksi haid (H-1 sebelum hari prediksi jatuh tempo, jam 7 pagi)
    final predictionSkipped = prefs.getBool('prediction_skipped') ?? false;

    // Jika prediksi tidak di-skip, cari tanggal prediksi berikutnya
    if (!predictionSkipped) {
      final allRecords = box.values.toList();
      final nextPredictedDate = await FikihService().getNextPredictedStartDate(allRecords);

      if (nextPredictedDate != null) {
        // H-1 sebelum prediksi
        final hMinus1Date = nextPredictedDate.subtract(const Duration(days: 1));
        // Jam 7 pagi
        final scheduledTime = DateTime(
          hMinus1Date.year,
          hMinus1Date.month,
          hMinus1Date.day,
          7,
          0,
        );

        await _scheduleNotification(
          id: 300000,
          title: 'Al-Heedh',
          body: 'Assalamualaikum $userName Besok adalah hari prediksi awal haid anda, jangan lupa untuk memastikan keluarnya darah',
          scheduledDateTime: scheduledTime,
        );
      }
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDateTime,
    String? payload,
  }) async {
    final now = DateTime.now();
    if (scheduledDateTime.isBefore(now)) return;

    final tzDateTime = tz.TZDateTime.from(scheduledDateTime, tz.local);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzDateTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminder_channel',
          'Notifikasi Pengingat',
          channelDescription: 'Notifikasi pengingat untuk siklus haid',
          importance: Importance.high,
          priority: Priority.high,
          sound: RawResourceAndroidNotificationSound('reminder_sound'),
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }
}
