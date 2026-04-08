import 'package:bmi_calculator/app/app_root.dart';
import 'package:bmi_calculator/features/bmi/data/local_store.dart';
import 'package:bmi_calculator/features/bmi/data/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final store = LocalStore();
  final preferences = await store.loadPreferences();

  // Initialize notifications.
  await NotificationService().initializeNotifications();
  final permissionsGranted = await NotificationService().requestPermissions();

  // Respect persisted reminder preferences on startup.
  if (permissionsGranted &&
      preferences.notificationsEnabled &&
      preferences.dailyReminderEnabled) {
    await NotificationService().scheduleDailyReminder(
      hour: preferences.reminderHour,
      minute: 0,
    );
  } else {
    await NotificationService().cancelNotification(0);
  }

  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  ).then((_) => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppRoot();
  }
}
