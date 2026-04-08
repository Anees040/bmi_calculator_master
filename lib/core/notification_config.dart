/// Notification configuration and setup
library notification_config;

/// Notification channel configuration
class NotificationChannel {
  NotificationChannel({
    required this.id,
    required this.name,
    required this.description,
    this.importance = NotificationImportance.high,
    this.enableVibration = true,
    this.sound = 'default',
  });

  final String id;
  final String name;
  final String description;
  final NotificationImportance importance;
  final bool enableVibration;
  final String sound;
}

/// Notification importance levels
enum NotificationImportance { none, low, medium, high }

/// Predefined notification channels
class NotificationChannels {
  static final daily = NotificationChannel(
    id: 'daily_reminder',
    name: 'Daily Reminders',
    description: 'Daily BMI check-in reminders',
    importance: NotificationImportance.high,
  );

  static final weekly = NotificationChannel(
    id: 'weekly_report',
    name: 'Weekly Reports',
    description: 'Weekly progress reports',
    importance: NotificationImportance.medium,
  );

  static final alerts = NotificationChannel(
    id: 'alerts',
    name: 'Alerts',
    description: 'Important app alerts',
    importance: NotificationImportance.high,
  );

  static final info = NotificationChannel(
    id: 'info',
    name: 'Information',
    description: 'General information',
    importance: NotificationImportance.low,
  );

  static final List<NotificationChannel> all = [
    daily,
    weekly,
    alerts,
    info,
  ];
}

/// Notification metadata
class NotificationMeta {
  NotificationMeta({
    required this.channelId,
    required this.title,
    required this.body,
    this.data = const {},
    this.smallIcon,
    this.largeIcon,
    this.color,
    this.sound = 'default',
    this.priority = 0,
  });

  final String channelId;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final String? smallIcon;
  final String? largeIcon;
  final int? color;
  final String sound;
  final int priority;

  /// Convert to map for plugin
  Map<String, dynamic> toMap() => {
    'channelId': channelId,
    'title': title,
    'body': body,
    'data': data,
    'sound': sound,
    'priority': priority,
  };
}
