import 'package:bmi_calculator/features/bmi/domain/bmi_models.dart';
import 'package:flutter/material.dart';

/// Weekly BMI progress and analytics report page.
/// 
/// Displays comprehensive weekly statistics including:
/// - Average BMI for the week
/// - Weight trend analysis
/// - Daily breakdown with timestamps
/// - Actionable health insights
/// 
/// Data is calculated from the [history] list of BMI records
/// covering the past 7 days.
class WeeklyReportPage extends StatelessWidget {
  /// Creates a [WeeklyReportPage] widget.
  /// 
  /// The [history] parameter must not be null and should contain
  /// BMI records to be analyzed for the weekly report.
  const WeeklyReportPage({required this.history, super.key});

  /// Full history of BMI records used to generate statistics
  final List<BmiRecord> history;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (history.length < 2) {
      return Scaffold(
        appBar: AppBar(title: const Text('Weekly Report')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_today, size: 64, color: scheme.primary.withValues(alpha: 0.6)),
              const SizedBox(height: 16),
              const Text('Not enough data for weekly report', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              const Text('Log at least 2 records to see weekly progress', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    final sorted = List<BmiRecord>.from(history)..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final thisWeek = sorted.where((r) => r.timestamp.isAfter(weekAgo)).toList();

    final avgBmi = thisWeek.isEmpty ? 0.0 : thisWeek.map((r) => r.bmi).reduce((a, b) => a + b) / thisWeek.length;
    final avgWeight = thisWeek.isEmpty ? 0.0 : thisWeek.map((r) => r.weightKg).reduce((a, b) => a + b) / thisWeek.length;
    final startWeight = thisWeek.isEmpty ? sorted.first.weightKg : thisWeek.last.weightKg;
    final endWeight = thisWeek.isEmpty ? sorted.first.weightKg : thisWeek.first.weightKg;
    final change = endWeight - startWeight;

    return Scaffold(
      appBar: AppBar(title: const Text('Weekly Report')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Weekly Summary',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            '${thisWeek.length} records logged this week',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          _MetricCard(
            title: 'Average BMI',
            value: avgBmi.toStringAsFixed(1),
            icon: Icons.calculate,
            color: scheme.primary,
          ),
          const SizedBox(height: 12),
          _MetricCard(
            title: 'Average Weight',
            value: '${avgWeight.toStringAsFixed(1)} kg',
            icon: Icons.monitor_weight,
            color: scheme.secondary,
          ),
          const SizedBox(height: 12),
          _MetricCard(
            title: 'Weight Change',
            value: '${change > 0 ? '+' : ''}${change.toStringAsFixed(1)} kg',
            icon: Icons.trending_down,
            color: change < 0 ? Colors.green : Colors.orange,
          ),
          const SizedBox(height: 24),
          Text(
            'Daily Breakdown',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Card(
            color: scheme.surfaceContainerHighest.withValues(alpha: isDark ? 0.3 : 0.5),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (thisWeek.isEmpty)
                    Text(
                      'No records this week',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                    )
                  else
                    ...thisWeek.map((record) {
                      final dayName = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][record.timestamp.weekday - 1];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$dayName - ${record.timestamp.month}/${record.timestamp.day}',
                                  style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'BMI: ${record.bmi.toStringAsFixed(1)} (${record.status})',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey),
                                ),
                              ],
                            ),
                            Text(
                              '${record.weightKg.toStringAsFixed(1)} kg',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: scheme.primary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withValues(alpha: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.lightbulb, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Weekly Insight',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  change <= 0
                      ? 'Great progress! You\'ve lost ${(-change).toStringAsFixed(1)} kg this week. Keep it up!'
                      : 'You gained ${change.toStringAsFixed(1)} kg this week. Consider increasing your physical activity.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.green),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      color: color.withValues(alpha: isDark ? 0.2 : 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: color),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
