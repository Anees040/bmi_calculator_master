import 'package:flutter/material.dart';
import 'package:bmi_calculator/features/bmi/domain/bmi_models.dart';

/// Settings and Preferences page for BMI Calculator app.
/// 
/// Provides user interface for configuring:
/// - Measurement units (height and weight)
/// - Notification preferences and scheduling
/// - App appearance and theme options
/// 
/// All preferences are persisted locally using SharedPreferences.
class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.initialPreferences,
    required this.onPreferencesChanged,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  final AppPreferences initialPreferences;
  final ValueChanged<AppPreferences> onPreferencesChanged;
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

/// State class for [SettingsPage].
/// 
/// Manages user preferences for:
/// - Height unit selection (cm, m, ft)
/// - Weight unit selection (kg, lb)
/// - Notification enable/disable toggle
/// - Daily reminder scheduling
/// - Theme and appearance settings
class _SettingsPageState extends State<SettingsPage> {
  /// Currently selected height measurement unit
  late HeightUnit _selectedHeightUnit;
  
  /// Currently selected weight measurement unit
  late WeightUnit _selectedWeightUnit;
  
  /// Whether notifications are enabled
  late bool _enableNotifications;
  
  /// Whether daily reminder is active
  late bool _dailyReminder;
  
  /// Hour of day for daily reminder (0-23)
  late int _reminderHour;

  @override
  void initState() {
    super.initState();
    final prefs = widget.initialPreferences;
    _selectedHeightUnit = prefs.heightUnit;
    _selectedWeightUnit = prefs.weightUnit;
    _enableNotifications = prefs.notificationsEnabled;
    _dailyReminder = prefs.dailyReminderEnabled;
    _reminderHour = prefs.reminderHour;
  }

  void _emitPreferences() {
    widget.onPreferencesChanged(
      AppPreferences(
        heightUnit: _selectedHeightUnit,
        weightUnit: _selectedWeightUnit,
        notificationsEnabled: _enableNotifications,
        dailyReminderEnabled: _dailyReminder,
        reminderHour: _reminderHour,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Preferences'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Measurement Units Section
          _SectionHeader('Measurement Units', Icons.straighten),
          const SizedBox(height: 12),
          _SettingCard(
            title: 'Height Unit',
            subtitle: 'Choose your preferred height measurement',
            child: SegmentedButton<HeightUnit>(
              segments: const [
                ButtonSegment(value: HeightUnit.cm, label: Text('Centimeter')),
                ButtonSegment(value: HeightUnit.meter, label: Text('Meter')),
                ButtonSegment(value: HeightUnit.ftIn, label: Text('Feet')),
              ],
              selected: {_selectedHeightUnit},
              onSelectionChanged: (Set<HeightUnit> newSelection) {
                setState(() => _selectedHeightUnit = newSelection.first);
                _emitPreferences();
              },
            ),
          ),
          const SizedBox(height: 12),
          _SettingCard(
            title: 'Weight Unit',
            subtitle: 'Choose your preferred weight measurement',
            child: SegmentedButton<WeightUnit>(
              segments: const [
                ButtonSegment(value: WeightUnit.kg, label: Text('Kilogram')),
                ButtonSegment(value: WeightUnit.lb, label: Text('Pound')),
              ],
              selected: {_selectedWeightUnit},
              onSelectionChanged: (Set<WeightUnit> newSelection) {
                setState(() => _selectedWeightUnit = newSelection.first);
                _emitPreferences();
              },
            ),
          ),
          const SizedBox(height: 24),
          // Notifications Section
          _SectionHeader('Notifications', Icons.notifications),
          const SizedBox(height: 12),
          _SwitchTile(
            title: 'Enable Notifications',
            subtitle: 'Receive app notifications and reminders',
            value: _enableNotifications,
            onChanged: (value) {
              setState(() => _enableNotifications = value);
              _emitPreferences();
            },
          ),
          const SizedBox(height: 12),
          if (_enableNotifications)
            _SwitchTile(
              title: 'Daily Reminder',
              subtitle: 'Get daily reminder to log your BMI',
              value: _dailyReminder,
              onChanged: (value) {
                setState(() => _dailyReminder = value);
                _emitPreferences();
              },
            ),
          if (_enableNotifications && _dailyReminder) ...[
            const SizedBox(height: 12),
            _SettingCard(
              title: 'Reminder Time',
              subtitle: 'Receive reminder at ${_reminderHour.toString().padLeft(2, '0')}:00',
              child: Slider(
                value: _reminderHour.toDouble(),
                min: 0,
                max: 23,
                divisions: 23,
                label: '${_reminderHour.toString().padLeft(2, '0')}:00',
                onChanged: (value) {
                  setState(() => _reminderHour = value.toInt());
                  _emitPreferences();
                },
              ),
            ),
          ],
          const SizedBox(height: 24),
          // Appearance Section
          _SectionHeader('Appearance', Icons.palette),
          const SizedBox(height: 12),
          _SwitchTile(
            title: 'Dark Mode',
            subtitle: 'Use dark theme for better visibility',
            value: widget.isDarkMode,
            onChanged: (_) => widget.onThemeToggle(),
          ),
          const SizedBox(height: 24),
          // About Section
          _SectionHeader('About', Icons.info),
          const SizedBox(height: 12),
          _SettingCard(
            title: 'App Version',
            subtitle: '1.0.0',
            child: const SizedBox.shrink(),
          ),
          const SizedBox(height: 12),
          _SettingCard(
            title: 'Developer',
            subtitle: 'BMI Smart Companion Team',
            child: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title, this.icon);

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _SettingCard extends StatelessWidget {
  const _SettingCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return Card(
      color: scheme.surfaceContainerHighest.withValues(alpha: isDark ? 0.3 : 0.5),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return Card(
      color: scheme.surfaceContainerHighest.withValues(alpha: isDark ? 0.3 : 0.5),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Switch(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}
