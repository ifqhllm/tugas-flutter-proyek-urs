import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../constants/colors.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap - open app
        // This will automatically open the app
      },
    );

    // Request permissions for Android 13+
    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
      // Create notification channels
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'prayer_channel',
          'Prayer Times',
          description: 'Notifications for prayer times',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'reminder_channel',
          'Recording Reminders',
          description: 'Daily reminders for recording',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ),
      );
    }
  }

  Future<void> schedulePrayerNotification(
      String prayerName, DateTime prayerTime) async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsEnabled = prefs.getBool('prayer_notifications') ?? true;

    if (!notificationsEnabled) return;

    final now = DateTime.now();
    if (prayerTime.isBefore(now)) return; // Don't schedule past prayers

    await flutterLocalNotificationsPlugin.zonedSchedule(
      prayerName.hashCode, // Unique ID
      'Waktu Shalat $prayerName',
      'Saatnya melaksanakan shalat $prayerName',
      tz.TZDateTime.from(prayerTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'prayer_channel',
          'Prayer Times',
          channelDescription: 'Notifications for prayer times',
          importance: Importance.high,
          priority: Priority.high,
          sound: RawResourceAndroidNotificationSound('default'),
          enableVibration: true,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleDailyRecordingReminder() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsEnabled = prefs.getBool('recording_reminder') ?? true;
    final userName = prefs.getString(userNameKey) ?? 'Pengguna';

    if (!notificationsEnabled) return;

    // Schedule for Fajr time (assume 5:00 AM)
    final now = DateTime.now();
    final fajrTime = DateTime(now.year, now.month, now.day, 5, 0);

    // If already passed today, schedule for tomorrow
    final scheduledTime = fajrTime.isBefore(now)
        ? fajrTime.add(const Duration(days: 1))
        : fajrTime;

    await flutterLocalNotificationsPlugin.zonedSchedule(
      999999, // Unique ID for recording reminder
      'Pengingat Pencatatan',
      'Assalamualaikum $userName, bagaimana hari ini? apakah darah keluar lagi?, ayo catat!!!',
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminder_channel',
          'Recording Reminders',
          channelDescription: 'Daily reminders for recording',
          importance: Importance.high,
          priority: Priority.high,
          sound: RawResourceAndroidNotificationSound('default'),
          enableVibration: true,
          actions: [
            AndroidNotificationAction('record', 'CATAT', showsUserInterface: true),
          ],
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> cancelRecordingReminder() async {
    await flutterLocalNotificationsPlugin.cancel(999999);
  }

  Future<void> cancelPrayerNotifications() async {
    // Cancel specific prayer notifications if needed
    // For now, cancel all and reschedule
    await cancelAllNotifications();
  }
}