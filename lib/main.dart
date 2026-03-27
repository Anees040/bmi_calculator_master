import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.white,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  ).then((_) => runApp(const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _showSplash = true;
  Timer? _splashTimer;

  @override
  void initState() {
    super.initState();
    _splashTimer = Timer(const Duration(milliseconds: 1800), () {
      if (!mounted) {
        return;
      }
      setState(() => _showSplash = false);
    });
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BMI Calculator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0B6E99)),
        useMaterial3: true,
      ),
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 450),
        child: _showSplash
            ? const SplashScreen(key: ValueKey('splash'))
            : const BmiHomePage(key: ValueKey('home')),
      ),
    );
  }
}

enum Gender { male, female, other }

enum HeightUnit { cm, meter, ftIn }

enum WeightUnit { kg, lb }

enum ActivityLevel { sedentary, light, moderate, active, athlete }

class BmiHomePage extends StatefulWidget {
  const BmiHomePage({super.key});

  @override
  State<BmiHomePage> createState() => _BmiHomePageState();
}

class _BmiHomePageState extends State<BmiHomePage> {
  static const String _historyKey = 'bmi_history_v1';
  static const String _gameKey = 'bmi_game_state_v1';

  double _heightCm = 170;
  double _weightKg = 70;
  int _age = 25;
  Gender _gender = Gender.male;
  HeightUnit _heightUnit = HeightUnit.cm;
  WeightUnit _weightUnit = WeightUnit.kg;
  ActivityLevel _activityLevel = ActivityLevel.moderate;

  double _hydrationQuest = 0.3;
  double _stepsQuest = 0.2;
  int _xp = 0;
  int _streak = 0;
  String _lastCheckIn = '';

  List<BmiRecord> _history = <BmiRecord>[];

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _loadGameState();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey);
    if (raw == null || raw.isEmpty) {
      return;
    }
    final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
    final loaded = decoded
        .map((dynamic e) => BmiRecord.fromJson(e as Map<String, dynamic>))
        .toList();
    if (!mounted) {
      return;
    }
    setState(() => _history = loaded);
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _history.map((e) => e.toJson()).toList();
    await prefs.setString(_historyKey, jsonEncode(jsonList));
  }

  Future<void> _loadGameState() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_gameKey);
    if (raw == null || raw.isEmpty) {
      return;
    }
    final data = jsonDecode(raw) as Map<String, dynamic>;
    if (!mounted) {
      return;
    }
    setState(() {
      _xp = (data['xp'] as num?)?.toInt() ?? 0;
      _streak = (data['streak'] as num?)?.toInt() ?? 0;
      _hydrationQuest = ((data['hydrationQuest'] as num?)?.toDouble() ?? 0.3)
          .clamp(0, 1);
      _stepsQuest = ((data['stepsQuest'] as num?)?.toDouble() ?? 0.2).clamp(0, 1);
      _lastCheckIn = data['lastCheckIn'] as String? ?? '';
    });
  }

  Future<void> _saveGameState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _gameKey,
      jsonEncode({
        'xp': _xp,
        'streak': _streak,
        'hydrationQuest': _hydrationQuest,
        'stepsQuest': _stepsQuest,
        'lastCheckIn': _lastCheckIn,
      }),
    );
  }

  double get _bmi => _weightKg / pow(_heightCm / 100, 2);

  double get _heightM => _heightCm / 100;

  double get _weightLb => _weightKg * 2.2046226218;

  double get _idealWeightMinKg => 18.5 * _heightM * _heightM;

  double get _idealWeightMaxKg => 24.9 * _heightM * _heightM;

  double get _waterLiters => _weightKg * 0.033;

  double get _bmr {
    if (_gender == Gender.male) {
      return 10 * _weightKg + 6.25 * _heightCm - 5 * _age + 5;
    }
    if (_gender == Gender.female) {
      return 10 * _weightKg + 6.25 * _heightCm - 5 * _age - 161;
    }
    return 10 * _weightKg + 6.25 * _heightCm - 5 * _age - 78;
  }

  double get _activityFactor {
    switch (_activityLevel) {
      case ActivityLevel.sedentary:
        return 1.2;
      case ActivityLevel.light:
        return 1.375;
      case ActivityLevel.moderate:
        return 1.55;
      case ActivityLevel.active:
        return 1.725;
      case ActivityLevel.athlete:
        return 1.9;
    }
  }

  double get _maintenanceCalories => _bmr * _activityFactor;

  int get _level => (_xp ~/ 100) + 1;

  int get _healthScore {
    final bmiPenalty = ((22 - _bmi).abs() * 7).round();
    final bonus = min(15, _xp ~/ 20);
    return (100 - bmiPenalty + bonus).clamp(0, 100);
  }

  String get _heightShareText {
    final totalInches = (_heightCm / 2.54);
    final ft = totalInches ~/ 12;
    final inch = (totalInches - (ft * 12)).round();
    return '${_heightCm.toStringAsFixed(1)} cm | ${_heightM.toStringAsFixed(2)} m | ${ft}ft ${inch}in';
  }

  String get _heightDisplay {
    if (_heightUnit == HeightUnit.cm) {
      return '${_heightCm.toStringAsFixed(1)} cm';
    }
    if (_heightUnit == HeightUnit.meter) {
      return '${_heightM.toStringAsFixed(2)} m';
    }
    final totalInches = _heightCm / 2.54;
    final ft = totalInches ~/ 12;
    final inch = totalInches - ft * 12;
    return '$ft ft ${inch.toStringAsFixed(1)} in';
  }

  String get _weightDisplay {
    if (_weightUnit == WeightUnit.kg) {
      return '${_weightKg.toStringAsFixed(1)} kg';
    }
    return '${_weightLb.toStringAsFixed(1)} lb';
  }

  String get _status {
    final bmi = _bmi;
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  String get _advice {
    switch (_status) {
      case 'Underweight':
        return 'Add nutrient-dense meals and light strength training.';
      case 'Normal':
        return 'Great zone. Maintain routine with balanced food and activity.';
      case 'Overweight':
        return 'Aim for gradual fat loss with daily walking and portion control.';
      default:
        return 'Consult a health professional and start with sustainable steps.';
    }
  }

  Color _statusColor(ColorScheme cs) {
    switch (_status) {
      case 'Underweight':
        return const Color(0xFF1565C0);
      case 'Normal':
        return const Color(0xFF2E7D32);
      case 'Overweight':
        return const Color(0xFFEF6C00);
      default:
        return cs.error;
    }
  }

  void _setHeightUnit(HeightUnit unit) {
    setState(() {
      _heightUnit = unit;
    });
  }

  void _setWeightUnit(WeightUnit unit) {
    setState(() {
      _weightUnit = unit;
    });
  }

  void _adjustHeight(bool increase) {
    final delta = _heightUnit == HeightUnit.ftIn ? 1.27 : 0.5;
    setState(() {
      _heightCm = (_heightCm + (increase ? delta : -delta)).clamp(100, 230);
    });
  }

  void _adjustWeight(bool increase) {
    final delta = _weightUnit == WeightUnit.kg ? 0.5 : 0.226796;
    setState(() {
      _weightKg = (_weightKg + (increase ? delta : -delta)).clamp(30, 250);
    });
  }

  Future<void> _openHeightDial() async {
    double local = _heightCm;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModal) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Fine tune height',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 6),
                  Text('${local.toStringAsFixed(1)} cm'),
                  Slider(
                    min: 100,
                    max: 230,
                    divisions: 260,
                    value: local,
                    onChanged: (value) => setModal(() => local = value),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () {
                          setState(() => _heightCm = local);
                          Navigator.pop(context);
                        },
                        child: const Text('Apply'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openWeightDial() async {
    double local = _weightKg;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModal) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Fine tune weight',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 6),
                  Text('${local.toStringAsFixed(1)} kg'),
                  Slider(
                    min: 30,
                    max: 250,
                    divisions: 440,
                    value: local,
                    onChanged: (value) => setModal(() => local = value),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () {
                          setState(() => _weightKg = local);
                          Navigator.pop(context);
                        },
                        child: const Text('Apply'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _saveCurrentRecord() {
    final record = BmiRecord(
      timestamp: DateTime.now(),
      bmi: _bmi,
      status: _status,
      heightCm: _heightCm,
      weightKg: _weightKg,
      age: _age,
      gender: _gender.name,
    );
    setState(() {
      _history = <BmiRecord>[record, ..._history].take(50).toList();
      _xp += 10;
    });
    _saveHistory();
    _saveGameState();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Result saved. +10 XP earned')),
    );
  }

  void _completeDailyCheckIn() {
    final today = DateTime.now();
    final marker =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    if (_lastCheckIn == marker) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You already checked in today.')),
      );
      return;
    }
    setState(() {
      _lastCheckIn = marker;
      _streak += 1;
      _xp += 15;
    });
    _saveGameState();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Daily check-in complete. +15 XP')),
    );
  }

  void _claimQuest(String quest) {
    if (quest == 'hydration' && _hydrationQuest >= 1) {
      setState(() {
        _xp += 20;
        _hydrationQuest = 0;
      });
      _saveGameState();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hydration quest claimed. +20 XP')),
      );
      return;
    }
    if (quest == 'steps' && _stepsQuest >= 1) {
      setState(() {
        _xp += 20;
        _stepsQuest = 0;
      });
      _saveGameState();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Steps quest claimed. +20 XP')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Quest not complete yet.')),
    );
  }

  void _copySummary() {
    final text = 'BMI ${_bmi.toStringAsFixed(1)} ($_status)\n'
        'Height: $_heightShareText\n'
        'Weight: ${_weightKg.toStringAsFixed(1)} kg (${_weightLb.toStringAsFixed(1)} lb)\n'
        'Ideal range: ${_idealWeightMinKg.toStringAsFixed(1)} - ${_idealWeightMaxKg.toStringAsFixed(1)} kg\n'
        'Water target: ${_waterLiters.toStringAsFixed(1)} L/day\n'
        'Maintenance calories: ${_maintenanceCalories.toStringAsFixed(0)} kcal/day';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Summary copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final statusColor = _statusColor(cs);

    final heightSliderValue = _heightCm;
    final weightSliderValue = _weightKg;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0xFFEAF6FF), Color(0xFFF8FBFE)],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  const AppLogo(size: 56),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('BMI Smart Companion',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            )),
                        Text('Interactive health tracking with game rewards',
                            style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  SvgPicture.asset(
                    'images/person.svg',
                    width: 46,
                    height: 46,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _sectionCard(
                context,
                title: 'Interactive Controls',
                icon: Icons.sports_esports,
                child: Column(
                  children: [
                    _buildGenderRow(),
                    const SizedBox(height: 12),
                    _buildHeightControls(heightSliderValue, theme),
                    const SizedBox(height: 12),
                    _buildWeightControls(weightSliderValue, theme),
                    const SizedBox(height: 12),
                    _buildAgeAndActivity(theme),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildBmiArena(theme, statusColor),
              const SizedBox(height: 16),
              _sectionCard(
                context,
                title: 'Daily Quests',
                icon: Icons.flag_circle,
                child: Column(
                  children: [
                    _questTile(
                      title: 'Hydration Quest',
                      subtitle:
                          'Complete your ${_waterLiters.toStringAsFixed(1)}L target',
                      progress: _hydrationQuest,
                      svgAsset: 'images/weight_arrow.svg',
                      onChanged: (v) {
                        setState(() => _hydrationQuest = v);
                        _saveGameState();
                      },
                      onClaim: () => _claimQuest('hydration'),
                    ),
                    const SizedBox(height: 10),
                    _questTile(
                      title: 'Move Quest',
                      subtitle: 'Hit your step goal and claim XP',
                      progress: _stepsQuest,
                      svgAsset: 'images/pacman.svg',
                      onChanged: (v) {
                        setState(() => _stepsQuest = v);
                        _saveGameState();
                      },
                      onClaim: () => _claimQuest('steps'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _sectionCard(
                context,
                title: 'Health Insights',
                icon: Icons.insights_outlined,
                child: Column(
                  children: [
                    _statTile(
                        'Height (share-ready)', _heightShareText, Icons.height),
                    _statTile(
                        'Ideal weight range',
                        '${_idealWeightMinKg.toStringAsFixed(1)} - ${_idealWeightMaxKg.toStringAsFixed(1)} kg',
                        Icons.monitor_weight_outlined),
                    _statTile('Water target',
                        '${_waterLiters.toStringAsFixed(1)} L/day', Icons.water_drop_outlined),
                    _statTile(
                        'BMR', '${_bmr.toStringAsFixed(0)} kcal/day', Icons.local_fire_department_outlined),
                    _statTile(
                        'Maintenance calories',
                        '${_maintenanceCalories.toStringAsFixed(0)} kcal/day',
                        Icons.bolt_outlined),
                    _statTile('Game level', 'Level $_level | XP $_xp',
                        Icons.workspace_premium_outlined),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _sectionCard(
                context,
                title: 'Recent History',
                icon: Icons.history,
                child: _history.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: Text('No saved records yet.'),
                      )
                    : Column(
                        children: _history
                            .take(8)
                            .map((e) => ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  leading: CircleAvatar(
                                    radius: 18,
                                    child: Text(e.bmi.toStringAsFixed(1)),
                                  ),
                                  title: Text(
                                      '${e.status} | ${e.weightKg.toStringAsFixed(1)} kg | ${e.heightCm.toStringAsFixed(1)} cm'),
                                  subtitle: Text(
                                      '${e.timestamp.year}-${e.timestamp.month.toString().padLeft(2, '0')}-${e.timestamp.day.toString().padLeft(2, '0')} ${e.timestamp.hour.toString().padLeft(2, '0')}:${e.timestamp.minute.toString().padLeft(2, '0')}'),
                                ))
                            .toList(),
                      ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionCard(BuildContext context,
      {required String title,
      required IconData icon,
      required Widget child}) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 8),
                Text(title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    )),
              ],
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildGenderRow() {
    return SegmentedButton<Gender>(
      segments: const [
        ButtonSegment(value: Gender.male, icon: Icon(Icons.male), label: Text('Male')),
        ButtonSegment(value: Gender.female, icon: Icon(Icons.female), label: Text('Female')),
        ButtonSegment(value: Gender.other, icon: Icon(Icons.transgender), label: Text('Other')),
      ],
      selected: <Gender>{_gender},
      onSelectionChanged: (Set<Gender> value) {
        setState(() => _gender = value.first);
      },
    );
  }

  Widget _buildHeightControls(double sliderValue, ThemeData theme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SvgPicture.asset('images/user.svg', width: 24, height: 24),
            const SizedBox(width: 8),
            const Text('Height'),
            const Spacer(),
            TextButton(
              onPressed: _openHeightDial,
              child: const Text('Dial'),
            ),
          ],
        ),
        const SizedBox(height: 6),
        SegmentedButton<HeightUnit>(
          segments: const [
            ButtonSegment(value: HeightUnit.cm, label: Text('cm')),
            ButtonSegment(value: HeightUnit.meter, label: Text('m')),
            ButtonSegment(value: HeightUnit.ftIn, label: Text('ft/in')),
          ],
          selected: <HeightUnit>{_heightUnit},
          onSelectionChanged: (Set<HeightUnit> value) =>
              _setHeightUnit(value.first),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton(
              onPressed: () => _adjustHeight(false),
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Expanded(
              child: Center(
                child: Text(_heightDisplay,
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700)),
              ),
            ),
            IconButton(
              onPressed: () => _adjustHeight(true),
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
        Slider(
          min: 100,
          max: 230,
          value: sliderValue,
          divisions: 130,
          label: '${_heightCm.toStringAsFixed(1)} cm',
          onChanged: (double value) {
            setState(() {
              _heightCm = value;
            });
          },
        ),
        Wrap(
          spacing: 8,
          children: [
            ActionChip(
                label: const Text('160 cm'),
                onPressed: () => setState(() => _heightCm = 160)),
            ActionChip(
                label: const Text('170 cm'),
                onPressed: () => setState(() => _heightCm = 170)),
            ActionChip(
                label: const Text('180 cm'),
                onPressed: () => setState(() => _heightCm = 180)),
          ],
        ),
      ],
    ));
  }

  Widget _buildWeightControls(double sliderValue, ThemeData theme) {
    final labelWeight = _weightDisplay;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SvgPicture.asset('images/weight_arrow.svg', width: 22, height: 22),
            const SizedBox(width: 8),
            const Text('Weight'),
            const Spacer(),
            TextButton(
              onPressed: _openWeightDial,
              child: const Text('Dial'),
            ),
          ],
        ),
        const SizedBox(height: 6),
        SegmentedButton<WeightUnit>(
          segments: const [
            ButtonSegment(value: WeightUnit.kg, label: Text('kg')),
            ButtonSegment(value: WeightUnit.lb, label: Text('lb')),
          ],
          selected: <WeightUnit>{_weightUnit},
          onSelectionChanged: (Set<WeightUnit> value) =>
              _setWeightUnit(value.first),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton(
              onPressed: () => _adjustWeight(false),
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Expanded(
              child: Center(
                child: Text(
                  _weightDisplay,
                  style:
                      theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            IconButton(
              onPressed: () => _adjustWeight(true),
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
        Slider(
          min: 30,
          max: 250,
          value: sliderValue,
          divisions: 440,
          label: labelWeight,
          onChanged: (double value) {
            setState(() => _weightKg = value);
          },
        ),
        Wrap(
          spacing: 8,
          children: [
            ActionChip(
                label: const Text('60 kg'),
                onPressed: () => setState(() => _weightKg = 60)),
            ActionChip(
                label: const Text('70 kg'),
                onPressed: () => setState(() => _weightKg = 70)),
            ActionChip(
                label: const Text('80 kg'),
                onPressed: () => setState(() => _weightKg = 80)),
          ],
        ),
      ],
    ));
  }

  Widget _buildAgeAndActivity(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Age'),
            const SizedBox(width: 10),
            Chip(label: Text('$_age years')),
            const Spacer(),
            IconButton(
              onPressed: () => setState(() => _age = max(1, _age - 1)),
              icon: const Icon(Icons.remove_circle_outline),
            ),
            IconButton(
              onPressed: () => setState(() => _age = min(100, _age + 1)),
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<ActivityLevel>(
          initialValue: _activityLevel,
          decoration: const InputDecoration(
            labelText: 'Activity Level',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          items: const [
            DropdownMenuItem(
                value: ActivityLevel.sedentary,
                child: Text('Sedentary (little exercise)')),
            DropdownMenuItem(
                value: ActivityLevel.light,
                child: Text('Light (1-3 days/week)')),
            DropdownMenuItem(
                value: ActivityLevel.moderate,
                child: Text('Moderate (3-5 days/week)')),
            DropdownMenuItem(
                value: ActivityLevel.active,
                child: Text('Active (6-7 days/week)')),
            DropdownMenuItem(
                value: ActivityLevel.athlete,
                child: Text('Athlete (2x/day training)')),
          ],
          onChanged: (ActivityLevel? value) {
            if (value == null) {
              return;
            }
            setState(() => _activityLevel = value);
          },
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.5),
          ),
          child: Row(
            children: [
              SvgPicture.asset('images/pacman.svg', width: 22, height: 22),
              const SizedBox(width: 8),
              Text('Streak: $_streak days  |  XP: $_xp  |  Level: $_level'),
              const Spacer(),
              FilledButton.tonal(
                onPressed: _completeDailyCheckIn,
                child: const Text('Check-in'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBmiArena(ThemeData theme, Color statusColor) {
    return Card(
      color: statusColor.withValues(alpha: 0.1),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('BMI Arena', style: theme.textTheme.titleMedium),
            const SizedBox(height: 10),
            Row(
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: (_healthScore / 100)),
                  duration: const Duration(milliseconds: 500),
                  builder: (context, value, _) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 88,
                          height: 88,
                          child: CircularProgressIndicator(
                            value: value,
                            strokeWidth: 9,
                            backgroundColor: Colors.white,
                          ),
                        ),
                        Text('$_healthScore',
                            style: theme.textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700)),
                      ],
                    );
                  },
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('BMI ${_bmi.toStringAsFixed(1)}  •  $_status',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w700,
                          )),
                      const SizedBox(height: 4),
                      Text(_advice),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: _saveCurrentRecord,
                  icon: const Icon(Icons.bookmark_add_outlined),
                  label: const Text('Save Result'),
                ),
                OutlinedButton.icon(
                  onPressed: _copySummary,
                  icon: const Icon(Icons.copy_all_outlined),
                  label: const Text('Copy Summary'),
                ),
              ],
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
    required String svgAsset,
    required ValueChanged<double> onChanged,
    required VoidCallback onClaim,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surfaceContainerHighest
            .withValues(alpha: 0.4),
      ),
      child: Column(
        children: [
          Row(
            children: [
              SvgPicture.asset(svgAsset, width: 24, height: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text(subtitle),
                  ],
                ),
              ),
              FilledButton.tonal(
                onPressed: onClaim,
                child: const Text('Claim'),
              ),
            ],
          ),
          Slider(
            value: progress,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _statTile(String title, String value, IconData icon) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(value),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Color(0xFF0B6E99), Color(0xFF2AA8D8)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppLogo(size: 100, onDark: true),
              const SizedBox(height: 16),
              Text(
                'BMI Smart Companion',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Built for Anees',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, required this.size, this.onDark = false});

  final double size;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.28),
        color: onDark ? Colors.white12 : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _LogoPainter(isLightBg: !onDark),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  _LogoPainter({required this.isLightBg});

  final bool isLightBg;

  @override
  void paint(Canvas canvas, Size size) {
    final p1 = Paint()..color = const Color(0xFF1E9AC7);
    final p2 = Paint()..color = const Color(0xFF53C0E5);
    final p3 = Paint()
      ..color = isLightBg ? const Color(0xFF0E4B66) : const Color(0xFFBCEBFA);

    final left = size.width * 0.2;
    final top = size.height * 0.2;
    final w = size.width * 0.6;
    final h = size.height * 0.6;

    final slash = Path()
      ..moveTo(left, top + h * 0.15)
      ..lineTo(left + w * 0.5, top)
      ..lineTo(left + w * 0.95, top + h * 0.35)
      ..lineTo(left + w * 0.45, top + h * 0.5)
      ..close();

    final base = Path()
      ..moveTo(left + w * 0.2, top + h * 0.52)
      ..lineTo(left + w * 0.58, top + h * 0.4)
      ..lineTo(left + w, top + h * 0.8)
      ..lineTo(left + w * 0.62, top + h * 0.92)
      ..close();

    final cut = Path()
      ..moveTo(left + w * 0.44, top + h * 0.57)
      ..lineTo(left + w * 0.62, top + h * 0.51)
      ..lineTo(left + w * 0.73, top + h * 0.62)
      ..lineTo(left + w * 0.55, top + h * 0.69)
      ..close();

    canvas.drawPath(slash, p2);
    canvas.drawPath(base, p1);
    canvas.drawPath(cut, p3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BmiRecord {
  BmiRecord({
    required this.timestamp,
    required this.bmi,
    required this.status,
    required this.heightCm,
    required this.weightKg,
    required this.age,
    required this.gender,
  });

  final DateTime timestamp;
  final double bmi;
  final String status;
  final double heightCm;
  final double weightKg;
  final int age;
  final String gender;

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'bmi': bmi,
        'status': status,
        'heightCm': heightCm,
        'weightKg': weightKg,
        'age': age,
        'gender': gender,
      };

  factory BmiRecord.fromJson(Map<String, dynamic> json) {
    return BmiRecord(
      timestamp: DateTime.parse(json['timestamp'] as String),
      bmi: (json['bmi'] as num).toDouble(),
      status: json['status'] as String,
      heightCm: (json['heightCm'] as num).toDouble(),
      weightKg: (json['weightKg'] as num).toDouble(),
      age: (json['age'] as num).toInt(),
      gender: json['gender'] as String,
    );
  }
}
