import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/material.dart'; 
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

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
      },
    );

    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
      
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'prayer_channel',
          'Waktu Shalat',
          description: 'Notifikasi untuk waktu shalat (Adzan)',
          importance: Importance.max, // Penting agar notifikasi muncul sebagai Heads-up
          playSound: true,
          enableVibration: true,
          sound: RawResourceAndroidNotificationSound('azan'), // Ganti 'azan' jika Anda memiliki file suara kustom
        ),
      );
      
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'reminder_channel',
          'Pengingat Harian',
          description: 'Pengingat rutin untuk pencatatan harian',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ),
      );
    }
  }
  
  Future<void> cancelPrayerNotifications() async {
    final List<PendingNotificationRequest> pending =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    
    for (var notification in pending) {
      if (notification.id != 999999) {
        await flutterLocalNotificationsPlugin.cancel(notification.id);
        debugPrint('Canceled prayer notification ID: ${notification.id}');
      }
    }
  }

  Future<void> cancelRecordingReminder() async {
    await flutterLocalNotificationsPlugin.cancel(999999);
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> _scheduleSinglePrayerNotification(
      String prayerName, DateTime prayerTime, int notificationId) async {
    
    
    final prefs = await SharedPreferences.getInstance();
    final notificationsEnabled = prefs.getBool('prayer_notifications') ?? true;

    if (!notificationsEnabled) return;

    final now = DateTime.now();
    if (prayerTime.isBefore(now)) return; 

    final scheduledTime = tz.TZDateTime.from(prayerTime, tz.local);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId, // Menggunakan ID yang dilewatkan
      'Waktu Shalat $prayerName',
      'Saatnya melaksanakan shalat $prayerName',
      scheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'prayer_channel',
          'Waktu Shalat',
          channelDescription: 'Notifikasi untuk waktu shalat',
          importance: Importance.max,
          priority: Priority.max,
          enableVibration: true,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
    debugPrint('Scheduled $prayerName (ID: $notificationId) at $scheduledTime');
  }

  Future<void> scheduleAllPrayersForTheDay(Map<String, DateTime> allPrayerTimes) async {
    
    await cancelPrayerNotifications(); 

    final Map<String, int> prayerIdMap = {
      'Shubuh': 1, 'Dhuhur': 2, 'Ashar': 3, 'Maghrib': 4, 'Isya': 5,
    };

    int scheduledCount = 0;
    
    // B. Loop dan Jadwalkan setiap waktu shalat
    allPrayerTimes.forEach((name, time) {
      final notificationId = prayerIdMap[name] ?? name.hashCode;
      _scheduleSinglePrayerNotification(name, time, notificationId);
      scheduledCount++;
    });
    
    debugPrint('Total ${scheduledCount} notifikasi shalat dijadwalkan ulang.');
  }

  
  Future<void> scheduleDailyRecordingReminder() async {
    
    await cancelRecordingReminder(); 

    final prefs = await SharedPreferences.getInstance();
    final notificationsEnabled = prefs.getBool('recording_reminder') ?? true;
    const int reminderId = 999999;
    
    const String userNameKey = 'user_name'; 
    final userName = prefs.getString(userNameKey) ?? 'Pengguna'; 

    if (!notificationsEnabled) return;

    final now = tz.TZDateTime.now(tz.local);
    var scheduledTime = tz.TZDateTime(tz.local, now.year, now.month, now.day, 5, 0);

    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      reminderId, // ID Unik untuk reminder harian
      'Pengingat Pencatatan',
      'Assalamualaikum $userName, bagaimana hari ini? Sudahkah darah keluar? Ayo catat!',
      scheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminder_channel',
          'Pengingat Harian',
          channelDescription: 'Pengingat rutin untuk pencatatan',
          importance: Importance.high,
          priority: Priority.high,
          sound: RawResourceAndroidNotificationSound('default'),
          enableVibration: true,
          actions: [
            // Tambahkan aksi notifikasi
            AndroidNotificationAction('record_action', 'CATAT SEKARANG', showsUserInterface: true),
          ],
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
    debugPrint('Daily recording reminder scheduled for 5:00 AM (ID: $reminderId).');
  }
}