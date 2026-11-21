import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final IconData icon;
  final Color? valueColor;
  final String? caption;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    required this.icon,
    this.valueColor,
    this.caption,
  });

  @override
  Widget build(BuildContext context) {
    final accent = valueColor ?? AppColors.neonGreen;

    return Container(
      decoration: BoxDecoration(
        // Clean Apple-style frosted dark glass: neutral dark finish, no muddy colored stains
        color: const Color(0xFF14141B),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: accent.withValues(alpha: 0.2), width: 1.0),
                ),
                child: Icon(icon, size: 16, color: accent),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: accent,
                    letterSpacing: -0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 4),
                Text(
                  unit!,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: accent.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ],
          ),
          if (caption != null) ...[
            const SizedBox(height: 3),
            Text(
              caption!,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.45),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class WideStatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color? color;
  final double? progress;
  final Widget? trailing;

  const WideStatCard({
    super.key,
    required this.label,
    required this.value,
    this.subtitle,
    required this.icon,
    this.color,
    this.progress,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.neonGreen;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF14141B),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: c.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: c.withValues(alpha: 0.25), width: 1),
                ),
                child: Icon(icon, size: 20, color: c),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(
                          value,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: c,
                            letterSpacing: -0.5,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(width: 6),
                          Text(
                            subtitle!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
          if (progress != null) ...[
            const SizedBox(height: 14),
            Stack(
              children: [
                Container(
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: progress!.clamp(0.0, 1.0),
                  child: Container(
                    height: 5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          c.withValues(alpha: 0.6),
                          c,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                          color: c.withValues(alpha: 0.4),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
