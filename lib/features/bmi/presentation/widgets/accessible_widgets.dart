/// Accessibility and semantic utilities
library a11y;

import 'package:flutter/material.dart';

/// Wrapper for semantically labeled BMI value
class SemanticBMI extends StatelessWidget {
  const SemanticBMI({
    required this.value,
    required this.status,
    super.key,
  });

  final double value;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'BMI $value, $status',
      enabled: true,
      child: Text(value.toStringAsFixed(1)),
    );
  }
}

/// Wrapper for semantically labeled weight value
class SemanticWeight extends StatelessWidget {
  const SemanticWeight({
    required this.value,
    required this.unit,
    super.key,
  });

  final double value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Weight ${value.toStringAsFixed(1)} $unit',
      enabled: true,
      child: Text(value.toStringAsFixed(1)),
    );
  }
}

/// Wrapper for semantically labeled health meter
class SemanticHealthMeter extends StatelessWidget {
  const SemanticHealthMeter({
    required this.progress,
    required this.label,
    super.key,
  });

  final double progress;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      slider: true,
      label: label,
      onIncrease: null,
      onDecrease: null,
      enabled: true,
      child: SizedBox(
        child: LinearProgressIndicator(value: progress),
      ),
    );
  }
}
