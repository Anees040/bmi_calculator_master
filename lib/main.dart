import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  double _heightCm = 170;
  double _weightKg = 70;
  int _age = 25;
  Gender _gender = Gender.male;
  HeightUnit _heightUnit = HeightUnit.cm;
  WeightUnit _weightUnit = WeightUnit.kg;
  ActivityLevel _activityLevel = ActivityLevel.moderate;

  final TextEditingController _heightPrimaryController = TextEditingController();
  final TextEditingController _heightSecondaryController =
      TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  List<BmiRecord> _history = <BmiRecord>[];

  @override
  void initState() {
    super.initState();
    _syncControllers();
    _loadHistory();
  }

  @override
  void dispose() {
    _heightPrimaryController.dispose();
    _heightSecondaryController.dispose();
    _weightController.dispose();
    super.dispose();
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

  String get _heightShareText {
    final totalInches = (_heightCm / 2.54);
    final ft = totalInches ~/ 12;
    final inch = (totalInches - (ft * 12)).round();
    return '${_heightCm.toStringAsFixed(1)} cm | ${_heightM.toStringAsFixed(2)} m | ${ft}ft ${inch}in';
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

  void _syncControllers() {
    if (_heightUnit == HeightUnit.cm) {
      _heightPrimaryController.text = _heightCm.toStringAsFixed(1);
      _heightSecondaryController.text = '';
    } else if (_heightUnit == HeightUnit.meter) {
      _heightPrimaryController.text = _heightM.toStringAsFixed(2);
      _heightSecondaryController.text = '';
    } else {
      final totalInches = _heightCm / 2.54;
      final ft = totalInches ~/ 12;
      final inch = totalInches - (ft * 12);
      _heightPrimaryController.text = '$ft';
      _heightSecondaryController.text = inch.toStringAsFixed(1);
    }

    if (_weightUnit == WeightUnit.kg) {
      _weightController.text = _weightKg.toStringAsFixed(1);
    } else {
      _weightController.text = _weightLb.toStringAsFixed(1);
    }
  }

  void _setHeightUnit(HeightUnit unit) {
    setState(() {
      _heightUnit = unit;
      _syncControllers();
    });
  }

  void _setWeightUnit(WeightUnit unit) {
    setState(() {
      _weightUnit = unit;
      _syncControllers();
    });
  }

  void _applyHeightInput() {
    final primary = double.tryParse(_heightPrimaryController.text.trim());
    final secondary =
        double.tryParse(_heightSecondaryController.text.trim()) ?? 0;

    if (primary == null || primary <= 0) {
      return;
    }

    double cm;
    if (_heightUnit == HeightUnit.cm) {
      cm = primary;
    } else if (_heightUnit == HeightUnit.meter) {
      cm = primary * 100;
    } else {
      cm = ((primary * 12) + secondary) * 2.54;
    }

    setState(() {
      _heightCm = cm.clamp(100, 230);
      _syncControllers();
    });
  }

  void _applyWeightInput() {
    final parsed = double.tryParse(_weightController.text.trim());
    if (parsed == null || parsed <= 0) {
      return;
    }

    final kg = _weightUnit == WeightUnit.kg ? parsed : parsed / 2.2046226218;
    setState(() {
      _weightKg = kg.clamp(30, 250);
      _syncControllers();
    });
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
    });
    _saveHistory();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Result saved in history')),
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
                  const AppLogo(size: 52),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('BMI Smart Companion',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            )),
                        Text('Fast, precise, and easy to share',
                            style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _sectionCard(
                context,
                title: 'Exact Inputs',
                icon: Icons.tune,
                child: Column(
                  children: [
                    _buildGenderRow(),
                    const SizedBox(height: 12),
                    _buildHeightControls(heightSliderValue),
                    const SizedBox(height: 12),
                    _buildWeightControls(weightSliderValue),
                    const SizedBox(height: 12),
                    _buildAgeAndActivity(),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Card(
                color: statusColor.withValues(alpha: 0.1),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your BMI', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        _bmi.toStringAsFixed(1),
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        _status,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(_advice),
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
        ButtonSegment(value: Gender.male, label: Text('Male')),
        ButtonSegment(value: Gender.female, label: Text('Female')),
        ButtonSegment(value: Gender.other, label: Text('Other')),
      ],
      selected: <Gender>{_gender},
      onSelectionChanged: (Set<Gender> value) {
        setState(() => _gender = value.first);
      },
    );
  }

  Widget _buildHeightControls(double sliderValue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Height'),
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
            Expanded(
              child: TextField(
                controller: _heightPrimaryController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: _heightUnit == HeightUnit.ftIn
                      ? 'Feet'
                      : (_heightUnit == HeightUnit.cm ? 'Height (cm)' : 'Height (m)'),
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            if (_heightUnit == HeightUnit.ftIn) ...[
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _heightSecondaryController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Inches',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
            ],
            const SizedBox(width: 8),
            IconButton.filledTonal(
              onPressed: _applyHeightInput,
              icon: const Icon(Icons.check),
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
              _syncControllers();
            });
          },
        ),
      ],
    );
  }

  Widget _buildWeightControls(double sliderValue) {
    final labelWeight = _weightUnit == WeightUnit.kg
        ? '${_weightKg.toStringAsFixed(1)} kg'
        : '${_weightLb.toStringAsFixed(1)} lb';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Weight'),
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
            Expanded(
              child: TextField(
                controller: _weightController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: _weightUnit == WeightUnit.kg
                      ? 'Weight (kg)'
                      : 'Weight (lb)',
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              onPressed: _applyWeightInput,
              icon: const Icon(Icons.check),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  _weightKg = max(30, _weightKg - 0.5);
                  _syncControllers();
                });
              },
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Expanded(
              child: Slider(
                min: 30,
                max: 250,
                value: sliderValue,
                divisions: 440,
                label: labelWeight,
                onChanged: (double value) {
                  setState(() {
                    _weightKg = value;
                    _syncControllers();
                  });
                },
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _weightKg = min(250, _weightKg + 0.5);
                  _syncControllers();
                });
              },
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAgeAndActivity() {
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
      ],
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
