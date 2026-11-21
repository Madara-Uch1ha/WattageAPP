import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class WattageGauge extends StatefulWidget {
  final double wattage;
  final double maxWattage;
  final bool isCharging;

  const WattageGauge({
    super.key,
    required this.wattage,
    this.maxWattage = 50.0,
    required this.isCharging,
  });

  @override
  State<WattageGauge> createState() => _WattageGaugeState();
}

class _WattageGaugeState extends State<WattageGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // Dynamic colors for charging vs discharging
  Color _getActiveColor(double w, bool isChg) {
    if (!isChg) {
      if (w >= 3.5) return AppColors.neonAmber; // High drain
      return AppColors.cyberCyan;                // Normal drain
    }
    if (w >= 38.0) return AppColors.cyberLime;  // 50W PPS Ultra
    if (w >= 22.0) return AppColors.neonGreen;  // Fast charge
    if (w >= 10.0) return AppColors.cyberCyan;   // Standard charge
    return AppColors.cyberCyan;
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic Adaptive Max Scale:
    // If charging: up to 50W (Nothing 4a PPS capacity)
    // If discharging: scale is 8.0W (so 1.8W fills 22.5% of the gauge!)
    final effectiveMaxWattage = widget.isCharging ? 50.0 : 8.0;
    final activeColor = _getActiveColor(widget.wattage, widget.isCharging);

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          tween: Tween<double>(begin: 0, end: widget.wattage),
          builder: (context, animatedWattage, child) {
            final progress = (animatedWattage / effectiveMaxWattage).clamp(0.0, 1.0);

            return SizedBox(
              width: 250,
              height: 250,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Ambient pulse glow
                  Container(
                    width: 190,
                    height: 190,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: activeColor.withValues(
                            alpha: widget.isCharging
                                ? (0.16 + 0.08 * sin(_animController.value * 2 * pi))
                                : 0.08,
                          ),
                          blurRadius: 36,
                          spreadRadius: 6,
                        ),
                      ],
                    ),
                  ),

                  // Custom Painter with Nothing dot-matrix ticks and adaptive gradient arc
                  CustomPaint(
                    size: const Size(250, 250),
                    painter: _CyberGaugePainter(
                      progress: progress,
                      color: activeColor,
                      isCharging: widget.isCharging,
                      animValue: _animController.value,
                    ),
                  ),

                  // Center Numerical Display
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        animatedWattage.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 58,
                          fontWeight: FontWeight.w900,
                          color: activeColor,
                          letterSpacing: -1.5,
                          height: 1,
                          shadows: [
                            Shadow(
                              color: activeColor.withValues(alpha: 0.5),
                              blurRadius: 16,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Mode badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: activeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: activeColor.withValues(alpha: 0.35),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          widget.isCharging ? 'WATTS INFLOW' : 'WATTS DRAIN',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: activeColor,
                            letterSpacing: 2.0,
                          ),
                        ),
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
}

class _CyberGaugePainter extends CustomPainter {
  final double progress;
  final Color color;
  final bool isCharging;
  final double animValue;

  _CyberGaugePainter({
    required this.progress,
    required this.color,
    required this.isCharging,
    required this.animValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 16;

    const startAngle = 0.75 * pi;
    const sweepAngle = 1.5 * pi;

    // 1. Background Track Arc (Dark Tech)
    final bgPaint = Paint()
      ..color = const Color(0xFF191924)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      bgPaint,
    );

    // 2. Segmented Dot-Matrix Ticks
    const totalTicks = 32;
    for (int i = 0; i <= totalTicks; i++) {
      final tickAngle = startAngle + (sweepAngle * i / totalTicks);
      final isMajor = i % 8 == 0;
      final tickFraction = i / totalTicks;
      final isPassed = tickFraction <= progress;

      final innerR = radius - (isMajor ? 16 : 10);
      final outerR = radius - 4;

      final startPt = Offset(
        center.dx + innerR * cos(tickAngle),
        center.dy + innerR * sin(tickAngle),
      );
      final endPt = Offset(
        center.dx + outerR * cos(tickAngle),
        center.dy + outerR * sin(tickAngle),
      );

      final tickColor = isPassed
          ? color.withValues(alpha: isMajor ? 0.95 : 0.65)
          : const Color(0xFF242432);

      final tickPaint = Paint()
        ..color = tickColor
        ..strokeWidth = isMajor ? 2.5 : 1.4
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(startPt, endPt, tickPaint);
    }

    // 3. Glowing Progress Arc
    if (progress > 0.01) {
      final activeSweep = sweepAngle * progress;

      // Glow Underlay
      final glowPaint = Paint()
        ..color = color.withValues(alpha: isCharging ? 0.35 : 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 20
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        activeSweep,
        false,
        glowPaint,
      );

      // Clean Gradient Arc (no hardcoded mismatched colors!)
      final progressShader = SweepGradient(
        center: Alignment.center,
        startAngle: startAngle,
        endAngle: startAngle + sweepAngle,
        colors: [
          color.withValues(alpha: 0.4),
          color,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

      final activePaint = Paint()
        ..shader = progressShader
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        activeSweep,
        false,
        activePaint,
      );

      // 4. Moving Energy Photon Head
      final headAngle = startAngle + activeSweep;
      final headPoint = Offset(
        center.dx + radius * cos(headAngle),
        center.dy + radius * sin(headAngle),
      );

      final photonGlow = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

      canvas.drawCircle(headPoint, 6, photonGlow);

      final photonCore = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      canvas.drawCircle(headPoint, 3.2, photonCore);
    }

    // 5. Orbital Particle when charging
    if (isCharging) {
      final orbitAngle = (animValue * 2 * pi);
      final orbitR = radius + 11;
      final orbitPoint = Offset(
        center.dx + orbitR * cos(orbitAngle),
        center.dy + orbitR * sin(orbitAngle),
      );

      final orbitDot = Paint()
        ..color = color.withValues(alpha: 0.85)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      canvas.drawCircle(orbitPoint, 2.8, orbitDot);
    }
  }

  @override
  bool shouldRepaint(covariant _CyberGaugePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.isCharging != isCharging ||
        oldDelegate.animValue != animValue;
  }
}
