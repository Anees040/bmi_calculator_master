import 'package:bmi_calculator/app/app_root.dart';
import 'package:bmi_calculator/features/bmi/data/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notifications
  await NotificationService().initializeNotifications();
  
  // Schedule daily reminder at 9 AM
  await NotificationService().scheduleDailyReminder(hour: 9, minute: 0);
  
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
