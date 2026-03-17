import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProxyAILogo extends StatelessWidget {
  final double size;
  final bool showGlow;

  const ProxyAILogo({super.key, this.size = 48, this.showGlow = true});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (showGlow)
            Container(
              width: size * 1.4,
              height: size * 1.4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.25),
                    blurRadius: size * 0.5,
                    spreadRadius: 0,
                  ),
                ],
              ),
            ),
          CustomPaint(
            size: Size(size, size),
            painter: _ProxyAILogoPainter(),
          ),
        ],
      ),
    );
  }
}

class _ProxyAILogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.38;

    final stroke = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(Offset(cx, cy), r, stroke);

    final path = Path();
    path.moveTo(cx - r * 0.5, cy);
    path.lineTo(cx, cy - r * 0.4);
    path.lineTo(cx + r * 0.5, cy);
    path.lineTo(cx, cy + r * 0.4);
    path.close();

    final fill = Paint()
      ..color = AppColors.accent.withOpacity(0.35)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
