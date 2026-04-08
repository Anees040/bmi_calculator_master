/// Animation and transition utilities
library animations;

import 'package:flutter/material.dart';

/// Fade in transition
class FadeInTransition extends StatefulWidget {
  const FadeInTransition({
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.delay = Duration.zero,
    super.key,
  });

  final Widget child;
  final Duration duration;
  final Duration delay;

  @override
  State<FadeInTransition> createState() => _FadeInTransitionState();
}

class _FadeInTransitionState extends State<FadeInTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _fadeAnimation, child: widget.child);
  }
}

/// Scale in transition
class ScaleInTransition extends StatefulWidget {
  const ScaleInTransition({
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.beginScale = 0.8,
    super.key,
  });

  final Widget child;
  final Duration duration;
  final double beginScale;

  @override
  State<ScaleInTransition> createState() => _ScaleInTransitionState();
}

class _ScaleInTransitionState extends State<ScaleInTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _scaleAnimation = Tween<double>(begin: widget.beginScale, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _scaleAnimation, child: widget.child);
  }
}

/// Slide in from left transition
class SlideInTransition extends StatefulWidget {
  const SlideInTransition({
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.direction = SlideDirection.fromLeft,
    super.key,
  });

  final Widget child;
  final Duration duration;
  final SlideDirection direction;

  @override
  State<SlideInTransition> createState() => _SlideInTransitionState();
}

enum SlideDirection { fromLeft, fromRight, fromTop, fromBottom }

class _SlideInTransitionState extends State<SlideInTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    final begin = switch (widget.direction) {
      SlideDirection.fromLeft => const Offset(-1.0, 0.0),
      SlideDirection.fromRight => const Offset(1.0, 0.0),
      SlideDirection.fromTop => const Offset(0.0, -1.0),
      SlideDirection.fromBottom => const Offset(0.0, 1.0),
    };

    _slideAnimation = Tween<Offset>(begin: begin, end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(position: _slideAnimation, child: widget.child);
  }
}
