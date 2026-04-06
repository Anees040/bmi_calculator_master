import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

/// Singleton service for managing local notifications in the BMI app.
/// 
/// Provides methods for:
/// - Initializing the notification system on app startup
/// - Scheduling daily BMI reminder notifications
/// - Scheduling weekly progress report notifications
/// - Sending instant notifications to users
/// 
/// Implementation uses [FlutterLocalNotificationsPlugin] with support
/// for both Android and iOS platforms. All scheduled notifications are
/// timezone-aware and handle system timezone changes gracefully.
class NotificationService {
  /// Singleton instance of [NotificationService]
  static final NotificationService _instance = NotificationService._internal();

  /// Factory constructor returning the singleton instance
  factory NotificationService() {
    return _instance;
  }

  /// Private internal constructor
  NotificationService._internal();

  /// Flutter Local Notifications plugin instance
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Initialize notification system with platform-specific settings.
  /// 
  /// Must be called once during app initialization.
  /// Sets up Android notification channels and iOS permissions.
  /// Unsafe to call multiple times; the plugin handles repeated calls gracefully.
  Future<void> initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onSelectNotification,
    );
  }

  /// Schedule a daily reminder notification at the specified time.
  /// 
  /// Parameters:
  ///   - [hour]: Hour of day (0-23) when reminder should appear
  ///   - [minute]: Minute of hour (0-59) when reminder should appear
  /// 
  /// The notification will repeat daily at the specified time.
  /// Uses timezone-aware scheduling to handle timezone changes.
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    await _notificationsPlugin.zonedSchedule(
      0,
      'BMI Check-In',
      'Time to log your daily BMI! Keep track of your health journey.',
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Daily Reminders',
          channelDescription: 'Daily BMI check-in reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          sound: 'default',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleWeeklyReport({required int dayOfWeek}) async {
    await _notificationsPlugin.zonedSchedule(
      1,
      'Weekly Report Ready',
      'Your weekly BMI progress report is ready to view!',
      _nextInstanceOfWeekday(dayOfWeek, 10, 0),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'weekly_report',
          'Weekly Reports',
          channelDescription: 'Weekly progress reports',
          importance: Importance.high,
        ),
        iOS: DarwinNotificationDetails(
          sound: 'default',
          presentAlert: true,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  Future<void> sendInstantNotification({
    required String title,
    required String body,
  }) async {
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        'instant_notifications',
        'Instant Notifications',
        channelDescription: 'Instant app notifications',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        sound: 'default',
        presentAlert: true,
      ),
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecond,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  tz.TZDateTime _nextInstanceOfWeekday(
    int weekday,
    int hour,
    int minute,
  ) {
    tz.TZDateTime scheduledDate = _nextInstanceOfTime(hour, minute);

    while (scheduledDate.weekday != weekday) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  Future<void> _onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) async {
    // Handle iOS notification display
  }

  Future<void> _onSelectNotification(
    NotificationResponse notificationResponse,
  ) async {
    // Handle notification tap
  }
}
