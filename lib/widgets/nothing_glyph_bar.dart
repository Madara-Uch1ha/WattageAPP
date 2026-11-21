import 'dart:math';
import 'package:material_ui/material_ui.dart';
import '../theme/app_theme.dart';

class NothingDotMatrixGlyphBar extends StatefulWidget {
  final double wattage;
  final bool isCharging;
  final int totalDots;

  const NothingDotMatrixGlyphBar({
    super.key,
    required this.wattage,
    required this.isCharging,
    this.totalDots = 24,
  });

  @override
  State<NothingDotMatrixGlyphBar> createState() => _NothingDotMatrixGlyphBarState();
}

class _NothingDotMatrixGlyphBarState extends State<NothingDotMatrixGlyphBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant NothingDotMatrixGlyphBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Faster pulse animation as wattage increases!
    if (widget.isCharging) {
      final double speedMultiplier = (widget.wattage / 12.0).clamp(1.0, 4.0);
      final int ms = (1600 / speedMultiplier).round().clamp(350, 1600);
      if (_pulseController.duration?.inMilliseconds != ms) {
        _pulseController.duration = Duration(milliseconds: ms);
        _pulseController.repeat();
      }
    } else {
      if (_pulseController.duration?.inMilliseconds != 2400) {
        _pulseController.duration = const Duration(milliseconds: 2400);
        _pulseController.repeat();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.isCharging
        ? (widget.wattage >= 35.0 ? AppColors.cyberLime : AppColors.neonGreen)
        : AppColors.cyberCyan;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF14141B),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'NOTHING 4a GLYPH MATRIX',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.0,
                  color: AppColors.textMuted.withValues(alpha: 0.9),
                ),
              ),
              const Spacer(),
              Text(
                widget.isCharging
                    ? '${(widget.wattage).toStringAsFixed(1)}W ENERGY FLOW'
                    : 'PASSIVE DRAIN',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: activeColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // The Dot-Matrix LED array
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final animVal = _pulseController.value;

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(widget.totalDots, (index) {
                  final double dotProgress = index / (widget.totalDots - 1);

                  // Cascade wave formula
                  double dotBrightness;
                  if (widget.isCharging) {
                    final wavePos = animVal;
                    final dist = (dotProgress - wavePos).abs();
                    final wrappedDist = min(dist, 1.0 - dist);
                    dotBrightness = (1.0 - (wrappedDist * 3.5)).clamp(0.12, 1.0);

                    // Illuminate baseline according to wattage percentage
                    final activeFraction = (widget.wattage / 50.0).clamp(0.15, 1.0);
                    if (dotProgress <= activeFraction) {
                      dotBrightness = max(dotBrightness, 0.55);
                    }
                  } else {
                    // Subtle breathing pulse on discharge
                    final breath = (sin(animVal * 2 * pi) + 1.0) / 2.0;
                    dotBrightness = 0.15 + (breath * 0.35);
                  }

                  final isLit = dotBrightness > 0.45;

                  return Container(
                    width: 7,
                    height: 14,
                    decoration: BoxDecoration(
                      color: isLit
                          ? activeColor.withValues(alpha: dotBrightness)
                          : const Color(0xFF22222E),
                      borderRadius: BorderRadius.circular(2.5),
                      boxShadow: isLit
                          ? [
                              BoxShadow(
                                color: activeColor.withValues(alpha: dotBrightness * 0.6),
                                blurRadius: 5,
                                spreadRadius: 0.5,
                              ),
                            ]
                          : null,
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }
}
