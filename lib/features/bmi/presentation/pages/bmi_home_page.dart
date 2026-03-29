import 'dart:math';

import 'package:bmi_calculator/features/bmi/data/local_store.dart';
import 'package:bmi_calculator/features/bmi/domain/bmi_models.dart';
import 'package:bmi_calculator/features/bmi/domain/health_metrics.dart';
import 'package:bmi_calculator/features/bmi/presentation/widgets/app_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

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

class _BmiHomePageState extends State<BmiHomePage> {
  final LocalStore _store = LocalStore();

  double _heightCm = 170;
  double _weightKg = 70;
  int _age = 24;
  Gender _gender = Gender.male;
  HeightUnit _heightUnit = HeightUnit.cm;
  WeightUnit _weightUnit = WeightUnit.kg;
  ActivityLevel _activityLevel = ActivityLevel.moderate;

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
    _loadState();
  }

  Future<void> _loadState() async {
    final history = await _store.loadHistory();
    final game = await _store.loadGameState();
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
    });
  }

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

  void _setHeightUnit(HeightUnit unit) => setState(() => _heightUnit = unit);

  void _setWeightUnit(WeightUnit unit) => setState(() => _weightUnit = unit);

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

  void _adjustHeight(bool increase) {
    final step = _heightUnit == HeightUnit.ftIn ? 1.27 : 0.5;
    setState(() {
      _heightCm = (_heightCm + (increase ? step : -step)).clamp(100, 230);
    });
  }

  void _adjustWeight(bool increase) {
    final step = _weightUnit == WeightUnit.kg ? 0.5 : 0.226796;
    setState(() {
      _weightKg = (_weightKg + (increase ? step : -step)).clamp(30, 250);
    });
  }

  Future<void> _openDial({required bool forHeight}) async {
    double local = forHeight ? _heightCm : _weightKg;
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
                  Text(
                    forHeight ? 'Fine tune height' : 'Fine tune weight',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(forHeight
                      ? '${local.toStringAsFixed(1)} cm'
                      : '${local.toStringAsFixed(1)} kg'),
                  Slider(
                    min: forHeight ? 100 : 30,
                    max: forHeight ? 230 : 250,
                    divisions: forHeight ? 260 : 440,
                    value: local,
                    onChanged: (v) => setModal(() => local = v),
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
                          setState(() {
                            if (forHeight) {
                              _heightCm = local;
                            } else {
                              _weightKg = local;
                            }
                          });
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

  void _copySummary() {
    final text = 'BMI ${_metrics.bmi.toStringAsFixed(1)} (${_metrics.status})\n'
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Record saved. +10 XP')),
    );
  }

  void _dailyCheckIn() {
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
    final statusColor = _statusColor(scheme);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [Color(0xFF0A1120), Color(0xFF152640), Color(0xFF1A1230)]
                : const [Color(0xFFEFF8FF), Color(0xFFF8FFF9), Color(0xFFF4F3FF)],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                title: Row(
                  children: [
                    const AppLogo(size: 40),
                    const SizedBox(width: 10),
                    const Text('BMI Smart Companion'),
                    const Spacer(),
                    IconButton(
                      onPressed: widget.onToggleTheme,
                      icon: Icon(
                        widget.mode == ThemeMode.dark
                            ? Icons.light_mode
                            : Icons.dark_mode,
                      ),
                    ),
                  ],
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(14),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _heroArena(statusColor),
                    const SizedBox(height: 14),
                    _measurementDeck(),
                    const SizedBox(height: 14),
                    _questDeck(),
                    const SizedBox(height: 14),
                    _insightsDeck(),
                    const SizedBox(height: 14),
                    _historyDeck(),
                    const SizedBox(height: 30),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _heroArena(Color statusColor) {
    return Card(
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
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
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
                  Text('BMI ${_metrics.bmi.toStringAsFixed(1)} • ${_metrics.status}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w800,
                          )),
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

  Widget _measurementDeck() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _sectionHeader('Interactive Body Controls', 'images/person.svg'),
            const SizedBox(height: 12),
            _genderToggle(),
            const SizedBox(height: 10),
            _heightControl(),
            const SizedBox(height: 12),
            _weightControl(),
            const SizedBox(height: 12),
            _ageActivityControl(),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, String iconAsset) {
    return Row(
      children: [
        SvgPicture.asset(iconAsset, width: 24, height: 24),
        const SizedBox(width: 8),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }

  Widget _genderToggle() {
    return SegmentedButton<Gender>(
      segments: const [
        ButtonSegment(value: Gender.male, icon: Icon(Icons.male), label: Text('Male')),
        ButtonSegment(value: Gender.female, icon: Icon(Icons.female), label: Text('Female')),
        ButtonSegment(value: Gender.other, icon: Icon(Icons.transgender), label: Text('Other')),
      ],
      selected: <Gender>{_gender},
      onSelectionChanged: (value) => setState(() => _gender = value.first),
    );
  }

  Widget _heightControl() {
    return _meterCard(
      title: 'Height',
      valueText: _heightDisplay,
      onMinus: () => _adjustHeight(false),
      onPlus: () => _adjustHeight(true),
      onDial: () => _openDial(forHeight: true),
      unitSwitch: SegmentedButton<HeightUnit>(
        segments: const [
          ButtonSegment(value: HeightUnit.cm, label: Text('cm')),
          ButtonSegment(value: HeightUnit.meter, label: Text('m')),
          ButtonSegment(value: HeightUnit.ftIn, label: Text('ft/in')),
        ],
        selected: <HeightUnit>{_heightUnit},
        onSelectionChanged: (v) => _setHeightUnit(v.first),
      ),
      slider: Slider(
        min: 100,
        max: 230,
        value: _heightCm,
        divisions: 260,
        onChanged: (v) => setState(() => _heightCm = v),
      ),
      chips: Wrap(
        spacing: 8,
        children: [
          ActionChip(
            label: const Text('160 cm'),
            onPressed: () => setState(() => _heightCm = 160),
          ),
          ActionChip(
            label: const Text('170 cm'),
            onPressed: () => setState(() => _heightCm = 170),
          ),
          ActionChip(
            label: const Text('180 cm'),
            onPressed: () => setState(() => _heightCm = 180),
          ),
        ],
      ),
    );
  }

  Widget _weightControl() {
    return _meterCard(
      title: 'Weight',
      valueText: _weightDisplay,
      onMinus: () => _adjustWeight(false),
      onPlus: () => _adjustWeight(true),
      onDial: () => _openDial(forHeight: false),
      unitSwitch: SegmentedButton<WeightUnit>(
        segments: const [
          ButtonSegment(value: WeightUnit.kg, label: Text('kg')),
          ButtonSegment(value: WeightUnit.lb, label: Text('lb')),
        ],
        selected: <WeightUnit>{_weightUnit},
        onSelectionChanged: (v) => _setWeightUnit(v.first),
      ),
      slider: Slider(
        min: 30,
        max: 250,
        value: _weightKg,
        divisions: 440,
        onChanged: (v) => setState(() => _weightKg = v),
      ),
      chips: Wrap(
        spacing: 8,
        children: [
          ActionChip(
            label: const Text('60 kg'),
            onPressed: () => setState(() => _weightKg = 60),
          ),
          ActionChip(
            label: const Text('70 kg'),
            onPressed: () => setState(() => _weightKg = 70),
          ),
          ActionChip(
            label: const Text('80 kg'),
            onPressed: () => setState(() => _weightKg = 80),
          ),
        ],
      ),
    );
  }

  Widget _meterCard({
    required String title,
    required String valueText,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
    required VoidCallback onDial,
    required Widget unitSwitch,
    required Widget slider,
    required Widget chips,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color:
            Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              TextButton.icon(
                onPressed: onDial,
                icon: const Icon(Icons.tune),
                label: const Text('Dial'),
              ),
            ],
          ),
          unitSwitch,
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(onPressed: onMinus, icon: const Icon(Icons.remove_circle_outline)),
              Expanded(
                child: Center(
                  child: Text(
                    valueText,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
              ),
              IconButton(onPressed: onPlus, icon: const Icon(Icons.add_circle_outline)),
            ],
          ),
          slider,
          chips,
        ],
      ),
    );
  }

  Widget _ageActivityControl() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color:
            Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text('Age: $_age', style: Theme.of(context).textTheme.titleMedium),
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
          const SizedBox(height: 6),
          DropdownButtonFormField<ActivityLevel>(
            initialValue: _activityLevel,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Activity level',
            ),
            items: const [
              DropdownMenuItem(
                value: ActivityLevel.sedentary,
                child: Text('Sedentary (little exercise)'),
              ),
              DropdownMenuItem(
                value: ActivityLevel.light,
                child: Text('Light (1-3 days/week)'),
              ),
              DropdownMenuItem(
                value: ActivityLevel.moderate,
                child: Text('Moderate (3-5 days/week)'),
              ),
              DropdownMenuItem(
                value: ActivityLevel.active,
                child: Text('Active (6-7 days/week)'),
              ),
              DropdownMenuItem(
                value: ActivityLevel.athlete,
                child: Text('Athlete (2x/day training)'),
              ),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() => _activityLevel = value);
            },
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              SvgPicture.asset('images/pacman.svg', width: 24, height: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Streak $_streak days • XP $_xp • Level ${_metrics.level}'),
              ),
              FilledButton.tonal(
                onPressed: _dailyCheckIn,
                child: const Text('Check-in'),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _questDeck() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader('Gamification Quests', 'images/pacman.svg'),
            const SizedBox(height: 10),
            _questTile(
              title: 'Hydration Quest',
              subtitle: 'Complete ${_metrics.waterLiters.toStringAsFixed(1)}L target',
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color:
            Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
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
              FilledButton.tonal(onPressed: onClaim, child: const Text('Claim')),
            ],
          ),
          Slider(value: progress, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _insightsDeck() {
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
      _InsightItem('Level', '${_metrics.level} (XP $_xp)', Icons.workspace_premium),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader('Health Insights', 'images/weight_arrow.svg'),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.45,
              ),
              itemBuilder: (context, index) {
                final it = items[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                      .withValues(alpha: 0.4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(it.icon, size: 18),
                      const SizedBox(height: 8),
                      Text(it.title,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(it.value, maxLines: 3, overflow: TextOverflow.ellipsis),
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

  Widget _historyDeck() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader('Recent Results', 'images/user.svg'),
            const SizedBox(height: 8),
            if (_history.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('No saved history yet.'),
              )
            else
              ..._history.take(8).map((e) => ListTile(
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
                  )),
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
