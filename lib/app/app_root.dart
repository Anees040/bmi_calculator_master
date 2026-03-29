import 'dart:async';

import 'package:bmi_calculator/app/theme/app_theme.dart';
import 'package:bmi_calculator/features/bmi/presentation/pages/bmi_home_page.dart';
import 'package:bmi_calculator/features/bmi/presentation/pages/splash_page.dart';
import 'package:flutter/material.dart';

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  ThemeMode _mode = ThemeMode.system;
  bool _showSplash = true;
  Timer? _splashTimer;

  @override
  void initState() {
    super.initState();
    _splashTimer = Timer(const Duration(milliseconds: 1700), () {
      if (mounted) {
        setState(() => _showSplash = false);
      }
    });
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    super.dispose();
  }

  void _toggleTheme() {
    setState(() {
      if (_mode == ThemeMode.light) {
        _mode = ThemeMode.dark;
      } else {
        _mode = ThemeMode.light;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BMI Smart Companion',
      themeMode: _mode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 450),
        child: _showSplash
            ? const SplashPage(key: ValueKey('splash'))
            : BmiHomePage(
                key: const ValueKey('home'),
                onToggleTheme: _toggleTheme,
                mode: _mode,
              ),
      ),
    );
  }
}
