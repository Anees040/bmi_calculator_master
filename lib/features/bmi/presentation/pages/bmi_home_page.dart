import 'dart:math';
import 'dart:async';

import 'package:bmi_calculator/features/bmi/data/local_store.dart';
import 'package:bmi_calculator/features/bmi/data/notification_service.dart';
import 'package:bmi_calculator/features/bmi/domain/bmi_models.dart';
import 'package:bmi_calculator/features/bmi/domain/health_metrics.dart';
import 'package:bmi_calculator/features/bmi/presentation/widgets/app_logo.dart';
import 'package:bmi_calculator/features/bmi/presentation/pages/settings_page.dart';
import 'package:bmi_calculator/features/bmi/presentation/pages/weekly_report_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BmiHomePage extends StatefulWidget {
  const BmiHomePage({
    super.key,
    required this.onToggleTheme,
    required this.mode,
  });

  final VoidCallback onToggleTheme;
  final ThemeMode mode;

  @override
  State<BmiHomePage> createState() => _BmiHomePageState();
}

class _BmiHomePageState extends State<BmiHomePage>
    with SingleTickerProviderStateMixin {
  final LocalStore _store = LocalStore();
  final PageController _pageController = PageController();
  late final AnimationController _bgMotionController;
  int _selectedTab = 0;
  bool _showOnboarding = false;
  int _onboardingStep = 0;
  Timer? _onboardingTimer;

  double _heightCm = 170;
  double _weightKg = 70;
  int _age = 24;
  Gender _gender = Gender.male;
  HeightUnit _heightUnit = HeightUnit.cm;
  WeightUnit _weightUnit = WeightUnit.kg;
  ActivityLevel _activityLevel = ActivityLevel.moderate;
  AppPreferences _preferences = AppPreferences.defaults;

  int _xp = 0;
  int _streak = 0;
  double _hydrationQuest = 0.3;
  double _stepsQuest = 0.2;
  String _lastCheckIn = '';

  List<BmiRecord> _history = <BmiRecord>[];

  HealthMetrics get _metrics => HealthMetrics(
    heightCm: _heightCm,
    weightKg: _weightKg,
    age: _age,
    gender: _gender,
    activityLevel: _activityLevel,
    xp: _xp,
  );

  @override
  void initState() {
    super.initState();
    _bgMotionController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
    _loadState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _bgMotionController.dispose();
    _onboardingTimer?.cancel();
    super.dispose();
  }

  Future<void> _tapFeedback({bool strong = false}) async {
    try {
      if (strong) {
        await HapticFeedback.mediumImpact();
      } else {
        await HapticFeedback.selectionClick();
      }
    } catch (_) {
      // Haptics can be unavailable on some platforms (e.g., web).
    }
  }

  Future<void> _loadState() async {
    final history = await _store.loadHistory();
    final game = await _store.loadGameState();
    final onboardingSeen = await _store.loadOnboardingSeen();
    final preferences = await _store.loadPreferences();
    if (!mounted) {
      return;
    }
    setState(() {
      _history = history;
      _xp = game.xp;
      _streak = game.streak;
      _hydrationQuest = game.hydrationQuest;
      _stepsQuest = game.stepsQuest;
      _lastCheckIn = game.lastCheckIn;
      _showOnboarding = !onboardingSeen;
      _preferences = preferences;
      _heightUnit = preferences.heightUnit;
      _weightUnit = preferences.weightUnit;
    });
    if (!onboardingSeen) {
      _startOnboardingTips();
    }
  }

  void _startOnboardingTips() {
    _onboardingTimer?.cancel();
    _onboardingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted || !_showOnboarding) {
        timer.cancel();
        return;
      }
      setState(() {
        _onboardingStep = (_onboardingStep + 1) % _onboardingTips.length;
      });
    });
  }

  Future<void> _dismissOnboarding() async {
    _onboardingTimer?.cancel();
    await _store.saveOnboardingSeen(true);
    if (!mounted) {
      return;
    }
    setState(() {
      _showOnboarding = false;
    });
  }

  List<_OnboardingTip> get _onboardingTips => const [
    _OnboardingTip(
      title: 'Start in Dashboard',
      body: 'See your live BMI score and save snapshots as you improve.',
      icon: Icons.speed,
    ),
    _OnboardingTip(
      title: 'Tune in Tracker',
      body:
          'Adjust units, weight, height, age, and activity with quick controls.',
      icon: Icons.tune,
    ),
    _OnboardingTip(
      title: 'Review Insights',
      body: 'Read chart cards for targets, hydration, and calorie strategy.',
      icon: Icons.insights,
    ),
  ];

  Future<void> _persistGame() {
    return _store.saveGameState(
      GameState(
        xp: _xp,
        streak: _streak,
        hydrationQuest: _hydrationQuest,
        stepsQuest: _stepsQuest,
        lastCheckIn: _lastCheckIn,
      ),
    );
  }

  Future<void> _persistHistory() {
    return _store.saveHistory(_history);
  }

  void _setHeightUnit(HeightUnit unit) {
    unawaited(_onPreferencesChanged(_preferences.copyWith(heightUnit: unit)));
  }

  void _setWeightUnit(WeightUnit unit) {
    unawaited(_onPreferencesChanged(_preferences.copyWith(weightUnit: unit)));
  }

  Future<void> _onPreferencesChanged(AppPreferences preferences) async {
    setState(() {
      _preferences = preferences;
      _heightUnit = preferences.heightUnit;
      _weightUnit = preferences.weightUnit;
    });
    await _store.savePreferences(preferences);
    await _syncReminderNotifications(preferences);
  }

  Future<void> _syncReminderNotifications(AppPreferences preferences) async {
    if (!preferences.notificationsEnabled ||
        !preferences.dailyReminderEnabled) {
      await NotificationService().cancelNotification(0);
      return;
    }

    await NotificationService().scheduleDailyReminder(
      hour: preferences.reminderHour,
      minute: 0,
    );
  }

  String get _heightDisplay {
    if (_heightUnit == HeightUnit.cm) {
      return '${_heightCm.toStringAsFixed(1)} cm';
    }
    if (_heightUnit == HeightUnit.meter) {
      return '${(_heightCm / 100).toStringAsFixed(2)} m';
    }
    final totalInches = _heightCm / 2.54;
    final ft = totalInches ~/ 12;
    final inch = totalInches - (ft * 12);
    return '$ft ft ${inch.toStringAsFixed(1)} in';
  }

  String get _weightDisplay {
    if (_weightUnit == WeightUnit.kg) {
      return '${_weightKg.toStringAsFixed(1)} kg';
    }
    return '${(_weightKg * 2.2046226218).toStringAsFixed(1)} lb';
  }

  Color _statusColor(ColorScheme scheme) {
    switch (_metrics.status) {
      case 'Underweight':
        return const Color(0xFF2980F0);
      case 'Normal':
        return const Color(0xFF21A66E);
      case 'Overweight':
        return const Color(0xFFF0882A);
      default:
        return scheme.error;
    }
  }

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  BoxDecoration _softCardDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(18),
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(
        alpha: _isDark ? 0.30 : 0.45,
      ),
      border: Border.all(
        color: Theme.of(
          context,
        ).colorScheme.primary.withValues(alpha: _isDark ? 0.16 : 0.08),
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: Theme.of(
            context,
          ).colorScheme.primary.withValues(alpha: _isDark ? 0.16 : 0.08),
          blurRadius: 20,
          offset: const Offset(0, 6),
          spreadRadius: 1,
        ),
      ],
    );
  }

  void _adjustHeight(bool increase) {
    _tapFeedback();
    final step = _heightUnit == HeightUnit.ftIn ? 1.27 : 0.5;
    setState(() {
      _heightCm = (_heightCm + (increase ? step : -step)).clamp(100, 230);
    });
  }

  void _adjustWeight(bool increase) {
    _tapFeedback();
    final step = _weightUnit == WeightUnit.kg ? 0.5 : 0.226796;
    setState(() {
      _weightKg = (_weightKg + (increase ? step : -step)).clamp(30, 250);
    });
  }

  void _copySummary() {
    final text =
        'BMI ${_metrics.bmi.toStringAsFixed(1)} (${_metrics.status})\n'
        'Height: ${_metrics.heightShareText}\n'
        'Weight: ${_weightKg.toStringAsFixed(1)} kg (${_metrics.weightLb.toStringAsFixed(1)} lb)\n'
        'Ideal range: ${_metrics.idealWeightMinKg.toStringAsFixed(1)} - ${_metrics.idealWeightMaxKg.toStringAsFixed(1)} kg\n'
        'Water target: ${_metrics.waterLiters.toStringAsFixed(1)} L/day\n'
        'Maintenance calories: ${_metrics.maintenanceCalories.toStringAsFixed(0)} kcal/day';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Summary copied to clipboard.')),
    );
  }

  void _saveRecord() {
    _tapFeedback(strong: true);
    final record = BmiRecord(
      timestamp: DateTime.now(),
      bmi: _metrics.bmi,
      status: _metrics.status,
      heightCm: _heightCm,
      weightKg: _weightKg,
      age: _age,
      gender: _gender.name,
    );
    setState(() {
      _history = <BmiRecord>[record, ..._history].take(50).toList();
      _xp += 10;
    });
    _persistHistory();
    _persistGame();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Record saved. +10 XP')));
  }

  void _dailyCheckIn() {
    _tapFeedback();
    final now = DateTime.now();
    final marker =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    if (_lastCheckIn == marker) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Already checked in today.')),
      );
      return;
    }
    setState(() {
      _lastCheckIn = marker;
      _streak += 1;
      _xp += 15;
    });
    _persistGame();
  }

  void _claimQuest({required bool hydration}) {
    _tapFeedback();
    final progress = hydration ? _hydrationQuest : _stepsQuest;
    if (progress < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quest is not complete yet.')),
      );
      return;
    }
    setState(() {
      _xp += 20;
      if (hydration) {
        _hydrationQuest = 0;
      } else {
        _stepsQuest = 0;
      }
    });
    _persistGame();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = _isDark;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompactNav = screenWidth < 390;
    final contentBottomInset =
        108.0 +
        MediaQuery.paddingOf(context).bottom +
        (_showOnboarding ? 150 : 0);

    return Scaffold(
      extendBody: false,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _bgMotionController,
            builder: (context, _) {
              final t = _bgMotionController.value;
              return DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(-1 + (t * 0.6), -1),
                    end: Alignment(1, 1 - (t * 0.6)),
                    colors: isDark
                        ? const [
                            Color(0xFF090F1A),
                            Color(0xFF111D31),
                            Color(0xFF1A1232),
                          ]
                        : const [
                            Color(0xFFEFF8FF),
                            Color(0xFFF8FFF9),
                            Color(0xFFF4F3FF),
                          ],
                  ),
                ),
                child: const SizedBox.expand(),
              );
            },
          ),
          AnimatedBuilder(
            animation: _bgMotionController,
            builder: (context, _) {
              return Positioned(
                top: -80 + (18 * _bgMotionController.value),
                right: -40 + (12 * _bgMotionController.value),
                child: _GlowOrb(
                  color: Theme.of(context).colorScheme.primary,
                  size: 220,
                  alpha: isDark ? 0.24 : 0.12,
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: _bgMotionController,
            builder: (context, _) {
              return Positioned(
                bottom: 120 - (16 * _bgMotionController.value),
                left: -70 + (10 * _bgMotionController.value),
                child: _GlowOrb(
                  color: Theme.of(context).colorScheme.secondary,
                  size: 210,
                  alpha: isDark ? 0.20 : 0.10,
                ),
              );
            },
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
                  child: Row(
                    children: [
                      const AppLogo(size: 40),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'BMI Smart Companion',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w800),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Modern health dashboard',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Weekly Report',
                        onPressed: () async {
                          _tapFeedback();
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => WeeklyReportPage(history: _history),
                            ),
                          );
                        },
                        icon: const Icon(Icons.show_chart),
                      ),
                      IconButton(
                        tooltip: 'Settings',
                        onPressed: () async {
                          _tapFeedback();
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => SettingsPage(
                                initialPreferences: _preferences,
                                onPreferencesChanged: _onPreferencesChanged,
                                onThemeToggle: widget.onToggleTheme,
                                isDarkMode: widget.mode == ThemeMode.dark,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.settings),
                      ),
                      IconButton(
                        onPressed: () {
                          _tapFeedback();
                          widget.onToggleTheme();
                        },
                        icon: Icon(
                          widget.mode == ThemeMode.dark
                              ? Icons.light_mode
                              : Icons.dark_mode,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      if (_selectedTab != index) {
                        setState(() => _selectedTab = index);
                      }
                    },
                    children: [
                      _dashboardTab(scheme),
                      _trackerTab(contentBottomInset),
                      _insightsTab(contentBottomInset),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_showOnboarding)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                  child: _onboardingBanner(),
                ),
              _bottomNavBar(isCompact: isCompactNav),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomNavBar({required bool isCompact}) {
    final navBg = _isDark ? const Color(0xFF121E32) : Colors.white;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: navBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.primary.withValues(alpha: _isDark ? 0.30 : 0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: _isDark ? 0.18 : 0.08),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: NavigationBar(
          height: isCompact ? 64 : 70,
          backgroundColor: navBg,
          indicatorColor: Colors.transparent,
          labelBehavior: isCompact
              ? NavigationDestinationLabelBehavior.onlyShowSelected
              : NavigationDestinationLabelBehavior.alwaysShow,
          selectedIndex: _selectedTab,
          onDestinationSelected: (index) {
            _tapFeedback();
            setState(() => _selectedTab = index);
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 380),
              curve: Curves.easeOutCubic,
            );
          },
          destinations: [
            NavigationDestination(
              icon: _tabIcon(
                icon: Icons.dashboard_outlined,
                color: const Color(0xFF2B7FFF),
                selected: _selectedTab == 0,
                compact: isCompact,
              ),
              selectedIcon: _tabIcon(
                icon: Icons.dashboard,
                color: const Color(0xFF2B7FFF),
                selected: true,
                compact: isCompact,
              ),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: _tabIcon(
                icon: Icons.tune_outlined,
                color: const Color(0xFF1CBA73),
                selected: _selectedTab == 1,
                compact: isCompact,
              ),
              selectedIcon: _tabIcon(
                icon: Icons.tune,
                color: const Color(0xFF1CBA73),
                selected: true,
                compact: isCompact,
              ),
              label: 'Tracker',
            ),
            NavigationDestination(
              icon: _tabIcon(
                icon: Icons.insights_outlined,
                color: const Color(0xFFF08A29),
                selected: _selectedTab == 2,
                compact: isCompact,
              ),
              selectedIcon: _tabIcon(
                icon: Icons.insights,
                color: const Color(0xFFF08A29),
                selected: true,
                compact: isCompact,
              ),
              label: 'Insights',
            ),
          ],
        ),
      ),
    );
  }

  Widget _dashboardTab(ColorScheme scheme) {
    final statusColor = _statusColor(scheme);
    return ListView(
      padding: EdgeInsets.fromLTRB(
        14,
        14,
        14,
        14 +
            108 +
            MediaQuery.paddingOf(context).bottom +
            (_showOnboarding ? 150 : 0),
      ),
      children: [
        _revealCard(0, _heroArena(statusColor)),
        const SizedBox(height: 14),
        _revealCard(1, _dashboardQuickActions()),
        const SizedBox(height: 14),
        _revealCard(2, _historyDeck(compact: true)),
        const SizedBox(height: 14),
        _revealCard(3, _questDeck()),
      ],
    );
  }

  Widget _dashboardQuickActions() {
    return _InteractiveCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader('Quick Actions', Icons.flash_on_rounded),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _actionPill(
                  title: 'Save Record',
                  icon: Icons.bookmark_add_rounded,
                  color: const Color(0xFF2B7FFF),
                  onTap: _saveRecord,
                ),
                _actionPill(
                  title: 'Daily Check-In',
                  icon: Icons.bolt_rounded,
                  color: const Color(0xFF1CBA73),
                  onTap: _dailyCheckIn,
                ),
                _actionPill(
                  title: 'Copy Summary',
                  icon: Icons.copy_rounded,
                  color: const Color(0xFFF08A29),
                  onTap: _copySummary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionPill({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _tapFeedback();
          onTap();
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _trackerTab(double contentBottomInset) {
    return ListView(
      padding: EdgeInsets.fromLTRB(14, 12, 14, 14 + contentBottomInset),
      children: [
        _revealCard(0, _trackerCompactHeader()),
        const SizedBox(height: 16),
        _revealCard(1, _trackerMeasurementCompact()),
        const SizedBox(height: 16),
        _revealCard(2, _trackerProfileCompact()),
      ],
    );
  }

  Widget _insightsTab(double contentBottomInset) {
    return ListView(
      padding: EdgeInsets.fromLTRB(14, 14, 14, 14 + contentBottomInset),
      children: [_revealCard(0, _insightsDeck())],
    );
  }

  Widget _trackerCompactHeader() {
    final scheme = Theme.of(context).colorScheme;
    final statusColor = _statusColor(scheme);
    final bmiValue = _metrics.bmi.toStringAsFixed(1);
    
    return _InteractiveCard(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: _metrics.healthScore / 100),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 70,
                          height: 70,
                          child: CircularProgressIndicator(
                            value: value,
                            strokeWidth: 6,
                            backgroundColor: Colors.white.withValues(alpha: 0.15),
                            valueColor: AlwaysStoppedAnimation(statusColor),
                          ),
                        ),
                        Text(
                          bmiValue,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: statusColor,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _metrics.status,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Level ${_metrics.level} • $_streak day streak',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.star, size: 14, color: scheme.primary),
                          const SizedBox(width: 4),
                          Text('$_xp XP',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: _saveRecord,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Save Record'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: _copySummary,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Copy Summary'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _trackerMeasurementCompact() {
    return _InteractiveCard(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            _compactMeasurementRow(
              icon: Icons.straighten,
              label: 'Height',
              value: _heightDisplay,
              onMinus: () => _adjustHeight(false),
              onPlus: () => _adjustHeight(true),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  SegmentedButton<HeightUnit>(
                    segments: const [
                      ButtonSegment(value: HeightUnit.cm, label: Text('cm'), icon: Icon(Icons.straighten)),
                      ButtonSegment(value: HeightUnit.meter, label: Text('m')),
                      ButtonSegment(value: HeightUnit.ftIn, label: Text('ft')),
                    ],
                    selected: <HeightUnit>{_heightUnit},
                    onSelectionChanged: (v) => _setHeightUnit(v.first),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Slider(
              min: 100,
              max: 230,
              value: _heightCm,
              divisions: 260,
              onChanged: (v) => setState(() => _heightCm = v),
            ),
            const SizedBox(height: 12),
            _compactMeasurementRow(
              icon: Icons.monitor_weight,
              label: 'Weight',
              value: _weightDisplay,
              onMinus: () => _adjustWeight(false),
              onPlus: () => _adjustWeight(true),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  SegmentedButton<WeightUnit>(
                    segments: const [
                      ButtonSegment(value: WeightUnit.kg, label: Text('kg'), icon: Icon(Icons.monitor_weight)),
                      ButtonSegment(value: WeightUnit.lb, label: Text('lb')),
                    ],
                    selected: <WeightUnit>{_weightUnit},
                    onSelectionChanged: (v) => _setWeightUnit(v.first),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Slider(
              min: 30,
              max: 250,
              value: _weightKg,
              divisions: 440,
              onChanged: (v) => setState(() => _weightKg = v),
            ),
          ],
        ),
      ),
    );
  }

  Widget _compactMeasurementRow({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: _isDark ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: scheme.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        IconButton(
          onPressed: onMinus,
          icon: const Icon(Icons.remove_circle_outline),
          iconSize: 24,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        IconButton(
          onPressed: onPlus,
          icon: const Icon(Icons.add_circle_outline),
          iconSize: 24,
        ),
      ],
    );
  }

  Widget _trackerProfileCompact() {
    final scheme = Theme.of(context).colorScheme;
    return _InteractiveCard(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: _isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.badge, size: 18, color: scheme.primary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Profile',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SegmentedButton<Gender>(
              segments: const [
                ButtonSegment(value: Gender.male, icon: Icon(Icons.male), label: Text('Male')),
                ButtonSegment(value: Gender.female, icon: Icon(Icons.female), label: Text('Female')),
                ButtonSegment(value: Gender.other, icon: Icon(Icons.transgender), label: Text('Other')),
              ],
              selected: <Gender>{_gender},
              onSelectionChanged: (value) => setState(() => _gender = value.first),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: _isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.cake, size: 18, color: scheme.primary),
                ),
                const SizedBox(width: 10),
                Text(
                  'Age: $_age',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => setState(() => _age = max(1, _age - 1)),
                  icon: const Icon(Icons.remove_circle_outline),
                  iconSize: 20,
                ),
                IconButton(
                  onPressed: () => setState(() => _age = min(100, _age + 1)),
                  icon: const Icon(Icons.add_circle_outline),
                  iconSize: 20,
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ActivityLevel>(
              initialValue: _activityLevel,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                labelText: 'Activity Level',
                isDense: true,
                prefixIcon: Icon(Icons.directions_run, size: 18),
              ),
              items: const [
                DropdownMenuItem(value: ActivityLevel.sedentary, child: Text('Sedentary')),
                DropdownMenuItem(value: ActivityLevel.light, child: Text('Light (1-3x/week)')),
                DropdownMenuItem(value: ActivityLevel.moderate, child: Text('Moderate (3-5x/week)')),
                DropdownMenuItem(value: ActivityLevel.active, child: Text('Active (6-7x/week)')),
                DropdownMenuItem(value: ActivityLevel.athlete, child: Text('Athlete')),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() => _activityLevel = value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _revealCard(int index, Widget child) {
    if (!_isDark) {
      return child;
    }
    return TweenAnimationBuilder<double>(
      key: ValueKey<String>('reveal-$_selectedTab-$index'),
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 260 + (index * 140)),
      curve: Curves.easeOutCubic,
      builder: (context, value, builtChild) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 22),
            child: builtChild,
          ),
        );
      },
      child: child,
    );
  }

  Widget _heroArena(Color statusColor) {
    return _InteractiveCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: _metrics.healthScore / 100),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        value: value,
                        strokeWidth: 8,
                        backgroundColor: Colors.white.withValues(alpha: 0.25),
                      ),
                    ),
                    Text(
                      '${_metrics.healthScore}',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'BMI ${_metrics.bmi.toStringAsFixed(1)} • ${_metrics.status}',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.w800,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _statusMascot(statusColor),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(_metrics.advice),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.icon(
                        onPressed: _saveRecord,
                        icon: const Icon(Icons.save_alt),
                        label: const Text('Save'),
                      ),
                      OutlinedButton.icon(
                        onPressed: _copySummary,
                        icon: const Icon(Icons.share),
                        label: const Text('Copy'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusMascot(Color statusColor) {
    final status = _metrics.status;
    IconData icon;
    if (status == 'Normal') {
      icon = Icons.sentiment_very_satisfied;
    } else if (status == 'Underweight') {
      icon = Icons.sentiment_neutral;
    } else if (status == 'Overweight') {
      icon = Icons.sentiment_dissatisfied;
    } else {
      icon = Icons.health_and_safety;
    }

    return TweenAnimationBuilder<double>(
      key: ValueKey<String>('mascot-$status'),
      tween: Tween<double>(begin: 0.9, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutBack,
      builder: (context, value, _) {
        return Transform.scale(
          scale: value,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: statusColor.withValues(alpha: _isDark ? 0.26 : 0.16),
              boxShadow: [
                BoxShadow(
                  color: statusColor.withValues(alpha: _isDark ? 0.35 : 0.15),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: statusColor, size: 22),
          ),
        );
      },
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: _isDark ? 0.26 : 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: scheme.primary),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _questDeck() {
    return _InteractiveCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader('Gamification Quests', Icons.sports_esports),
            const SizedBox(height: 10),
            _questTile(
              title: 'Hydration Quest',
              subtitle:
                  'Complete ${_metrics.waterLiters.toStringAsFixed(1)}L target',
              progress: _hydrationQuest,
              onChanged: (v) {
                setState(() => _hydrationQuest = v);
                _persistGame();
              },
              onClaim: () => _claimQuest(hydration: true),
            ),
            const SizedBox(height: 10),
            _questTile(
              title: 'Move Quest',
              subtitle: 'Simulate steps progress and claim reward',
              progress: _stepsQuest,
              onChanged: (v) {
                setState(() => _stepsQuest = v);
                _persistGame();
              },
              onClaim: () => _claimQuest(hydration: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _questTile({
    required String title,
    required String subtitle,
    required double progress,
    required ValueChanged<double> onChanged,
    required VoidCallback onClaim,
  }) {
    final canClaim = progress >= 1;
    final progressPercent = (progress * 100).clamp(0, 100).toStringAsFixed(0);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _softCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text(subtitle),
                  ],
                ),
              ),
              FilledButton.tonal(
                onPressed: canClaim ? onClaim : null,
                child: Text(canClaim ? 'Claim' : '$progressPercent%'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            borderRadius: BorderRadius.circular(12),
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.12),
          ),
          const SizedBox(height: 6),
          Text(
            canClaim ? 'Ready to claim reward' : 'Progress: $progressPercent%',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 2),
          Slider(value: progress, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _insightsDeck() {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final insightTileRatio = screenWidth < 380 ? 1.06 : 1.22;
    final items = [
      _InsightItem('Height', _metrics.heightShareText, Icons.height),
      _InsightItem(
        'Ideal Weight',
        '${_metrics.idealWeightMinKg.toStringAsFixed(1)} - ${_metrics.idealWeightMaxKg.toStringAsFixed(1)} kg',
        Icons.monitor_weight,
      ),
      _InsightItem(
        'Hydration',
        '${_metrics.waterLiters.toStringAsFixed(1)} L/day',
        Icons.water_drop,
      ),
      _InsightItem(
        'BMR',
        '${_metrics.bmr.toStringAsFixed(0)} kcal/day',
        Icons.local_fire_department,
      ),
      _InsightItem(
        'Maintenance',
        '${_metrics.maintenanceCalories.toStringAsFixed(0)} kcal/day',
        Icons.bolt,
      ),
      _InsightItem(
        'Level',
        '${_metrics.level} (XP $_xp)',
        Icons.workspace_premium,
      ),
    ];

    return _InteractiveCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader('Health Insights', Icons.monitor_heart_outlined),
            const SizedBox(height: 10),
            _insightChartCard(),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: insightTileRatio,
              ),
              itemBuilder: (context, index) {
                final it = items[index];
                final color = _insightAccent(index);
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Theme.of(context).colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: color.withValues(alpha: _isDark ? 0.25 : 0.14),
                        ),
                        child: Icon(it.icon, size: 18, color: color),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        it.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: Text(
                          it.value,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _insightAccent(int index) {
    const colors = [
      Color(0xFF2B7FFF),
      Color(0xFF34B96A),
      Color(0xFF16A6D9),
      Color(0xFFE26A3F),
      Color(0xFFF08A29),
      Color(0xFF8E66FF),
    ];
    return colors[index % colors.length];
  }

  Widget _historyDeck({bool compact = false}) {
    return _InteractiveCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader('Recent Results', Icons.history),
            const SizedBox(height: 8),
            if (_history.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('No saved history yet.'),
              )
            else if (compact)
              SizedBox(
                height: 130,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: min(8, _history.length),
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final item = _history[index];
                    return _historyMiniCard(item);
                  },
                ),
              )
            else
              ..._history
                  .take(8)
                  .map(
                    (e) => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        radius: 16,
                        child: Text(e.bmi.toStringAsFixed(1)),
                      ),
                      title: Text(
                        '${e.status} • ${e.weightKg.toStringAsFixed(1)} kg • ${e.heightCm.toStringAsFixed(1)} cm',
                      ),
                      subtitle: Text(
                        '${e.timestamp.year}-${e.timestamp.month.toString().padLeft(2, '0')}-${e.timestamp.day.toString().padLeft(2, '0')}',
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _historyMiniCard(BmiRecord record) {
    final date =
        '${record.timestamp.month.toString().padLeft(2, '0')}/${record.timestamp.day.toString().padLeft(2, '0')}';
    final statusColor = _statusColor(Theme.of(context).colorScheme);
    return SizedBox(
      width: 198,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).colorScheme.surfaceContainerHighest
              .withValues(alpha: _isDark ? 0.40 : 0.34),
          border: Border.all(color: statusColor.withValues(alpha: 0.20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: statusColor.withValues(alpha: 0.14),
                    ),
                    child: Text(
                      record.bmi.toStringAsFixed(1),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(date, style: Theme.of(context).textTheme.labelSmall),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                record.status,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                '${record.weightKg.toStringAsFixed(1)} kg • ${record.heightCm.toStringAsFixed(0)} cm',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _insightChartCard() {
    final bmiRatio = (_metrics.bmi / 40).clamp(0.0, 1.0);
    final hydrationRatio = (_metrics.waterLiters / 4.5).clamp(0.0, 1.0);
    final energyRatio = (_metrics.maintenanceCalories / 3500).clamp(0.0, 1.0);

    final bars = [
      _ChartBarData(
        'BMI',
        bmiRatio,
        const Color(0xFF2B7FFF),
        _metrics.bmi.toStringAsFixed(1),
      ),
      _ChartBarData(
        'Water',
        hydrationRatio,
        const Color(0xFF16A6D9),
        '${_metrics.waterLiters.toStringAsFixed(1)}L',
      ),
      _ChartBarData(
        'Energy',
        energyRatio,
        const Color(0xFFF08A29),
        _metrics.maintenanceCalories.toStringAsFixed(0),
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _softCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Body Snapshot Chart',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'A visual view of your current body metrics and daily targets.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 130,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: bars
                  .map(
                    (bar) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: _animatedChartBar(bar: bar),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _animatedChartBar({required _ChartBarData bar}) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: bar.value),
      duration: const Duration(milliseconds: 750),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              bar.label,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: 28,
                  height: 90 * value,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [bar.color, bar.color.withValues(alpha: 0.45)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: bar.color.withValues(
                          alpha: _isDark ? 0.30 : 0.18,
                        ),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(bar.title, style: Theme.of(context).textTheme.labelSmall),
          ],
        );
      },
    );
  }

  Widget _tabIcon({
    required IconData icon,
    required Color color,
    required bool selected,
    required bool compact,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: selected ? 1 : 0),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      builder: (context, t, _) {
        return Transform.scale(
          scale: 1 + (0.08 * t),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 8 : 10,
              vertical: compact ? 6 : 7,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: t > 0
                  ? LinearGradient(
                      colors: [
                        color.withValues(alpha: 0.32),
                        color.withValues(alpha: 0.14),
                      ],
                    )
                  : null,
              border: Border.all(
                color: color.withValues(alpha: t > 0 ? 0.50 : 0.18),
              ),
              boxShadow: t > 0
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: _isDark ? 0.28 : 0.20),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ]
                  : const [],
            ),
            child: Icon(icon, color: color, size: compact ? 20 : 22),
          ),
        );
      },
    );
  }

  Widget _onboardingBanner() {
    final tip = _onboardingTips[_onboardingStep];
    return _InteractiveCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(tip.icon, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Quick Onboarding',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _dismissOnboarding,
                  child: const Text('Done'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: Column(
                key: ValueKey<int>(_onboardingStep),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tip.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(tip.body),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightItem {
  const _InsightItem(this.title, this.value, this.icon);

  final String title;
  final String value;
  final IconData icon;
}

class _ChartBarData {
  const _ChartBarData(this.title, this.value, this.color, this.label);

  final String title;
  final double value;
  final Color color;
  final String label;
}

class _OnboardingTip {
  const _OnboardingTip({
    required this.title,
    required this.body,
    required this.icon,
  });

  final String title;
  final String body;
  final IconData icon;
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.color,
    required this.size,
    required this.alpha,
  });

  final Color color;
  final double size;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: alpha),
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}

class _InteractiveCard extends StatefulWidget {
  const _InteractiveCard({required this.child});

  final Widget child;

  @override
  State<_InteractiveCard> createState() => _InteractiveCardState();
}

class _InteractiveCardState extends State<_InteractiveCard> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scale = _pressed ? 0.992 : (_hovered ? 1.008 : 1.0);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() {
        _hovered = false;
        _pressed = false;
      }),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 120),
          scale: scale,
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color:
                      (isDark
                              ? Theme.of(context).colorScheme.primary
                              : Colors.black)
                          .withValues(alpha: _hovered ? 0.16 : 0.08),
                  blurRadius: _hovered ? 22 : 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Card(margin: EdgeInsets.zero, child: widget.child),
          ),
        ),
      ),
    );
  }
}
