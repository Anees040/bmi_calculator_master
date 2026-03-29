import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    required this.size,
    this.onDark = false,
  });

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
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: CustomPaint(painter: _LogoPainter(isLightBg: !onDark)),
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
      ..color = isLightBg ? const Color(0xFF0E4B66) : const Color(0xFFC2F2FF);

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
