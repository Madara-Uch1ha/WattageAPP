import 'dart:async';
import 'package:flutter/material.dart';
import '../services/battery_service.dart';
import '../theme/app_theme.dart';
import '../widgets/wattage_gauge.dart';
import '../widgets/stat_card.dart';
import '../widgets/live_chart.dart';
import '../widgets/nothing_glyph_bar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _batteryService = BatteryService.instance;
  late BatteryData _data;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _data = _batteryService.currentData;
    _subscription = _batteryService.batteryStream.listen((data) {
      if (mounted) {
        setState(() {
          _data = data;
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Color _tempColor(double temp) {
    if (temp < 36) return AppColors.neonGreen;
    if (temp < 40) return AppColors.neonAmber;
    return AppColors.neonRed;
  }

  Color _getTierColor(double wattage, bool isCharging) {
    if (!isCharging) return AppColors.cyberCyan;
    if (wattage >= 38.0) return AppColors.cyberLime;
    if (wattage >= 22.0) return AppColors.neonGreen;
    if (wattage >= 10.0) return AppColors.cyberCyan;
    return AppColors.textMuted;
  }

  @override
  Widget build(BuildContext context) {
    final tierColor = _getTierColor(_data.wattage, _data.isCharging);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header with Nothing aesthetic
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF14141B),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('⚡', style: TextStyle(fontSize: 14)),
                        SizedBox(width: 6),
                        Text(
                          'WATTAGE',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  _NothingStatusPill(data: _data),
                ],
              ),
              const SizedBox(height: 16),

              // Super Fast Charge / Drain Banner
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFF14141B),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: tierColor.withValues(alpha: 0.35)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: tierColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: tierColor, blurRadius: 6),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _data.speedTier,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: tierColor,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Main Adaptive Dynamic Cyber Gauge
              WattageGauge(
                wattage: _data.wattage,
                isCharging: _data.isCharging,
              ),
              const SizedBox(height: 12),

              // Authentic Nothing Phone (4a) Dot-Matrix Glyph Bar
              NothingDotMatrixGlyphBar(
                wattage: _data.wattage,
                isCharging: _data.isCharging,
                totalDots: 24,
              ),
              const SizedBox(height: 14),

              // Time Estimator & Session Peak Banner (Clean dark glass)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF14141B),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      _data.isCharging ? Icons.hourglass_top_rounded : Icons.timelapse_rounded,
                      size: 20,
                      color: tierColor,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _data.isCharging ? 'ESTIMATED CHARGE TIME' : 'ESTIMATED BATTERY RUNTIME',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textMuted,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _data.timeRemainingEstimate,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: tierColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_data.isCharging) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.cyberLime.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.cyberLime.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'PEAK',
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.textMuted),
                            ),
                            Text(
                              '${_batteryService.peakWattage.toStringAsFixed(1)}W',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.cyberLime,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2x2 Glowing Pop Stat Grid (Now clean Apple dark glass, no muddy gradients!)
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'VOLTAGE',
                      value: _data.voltageV.toStringAsFixed(2),
                      unit: 'V',
                      icon: Icons.electric_bolt_rounded,
                      valueColor: AppColors.cyberCyan,
                      caption: 'Cell Potential',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      label: 'CURRENT',
                      value: _data.currentAbsMa.toStringAsFixed(0),
                      unit: 'mA',
                      icon: Icons.waves_rounded,
                      valueColor: AppColors.electricPurple,
                      caption: _data.isCharging ? 'Inflow Rate' : 'Outflow Rate',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'TEMP',
                      value: _data.temperatureC.toStringAsFixed(1),
                      unit: '°C',
                      icon: Icons.thermostat_rounded,
                      valueColor: _tempColor(_data.temperatureC),
                      caption: _data.temperatureC < 38 ? 'Optimal Thermal' : 'Warm State',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      label: 'CHARGE',
                      value: '${_data.batteryPct}',
                      unit: '%',
                      icon: Icons.battery_charging_full_rounded,
                      valueColor: _data.batteryPct > 20 ? AppColors.neonGreen : AppColors.neonRed,
                      caption: _data.isFull ? '100% Saturated' : '${100 - _data.batteryPct}% Remaining',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Realtime Power Curve Chart
              LiveWattageChart(
                dataPoints: _batteryService.wattageHistory,
                maxPoints: BatteryService.maxHistory,
                label: 'Realtime Power Curve',
                color: _data.isCharging ? AppColors.neonGreen : AppColors.cyberCyan,
              ),
              const SizedBox(height: 12),

              // Current Amperage Stream Chart (Now with dynamic scale - 487 mA fits perfectly inside!)
              LiveWattageChart(
                dataPoints: _batteryService.currentHistory,
                maxPoints: BatteryService.maxHistory,
                label: 'Current Amperage Stream',
                color: AppColors.electricPurple,
              ),

              // Extra padding at bottom for seamless scrolling above navigation bar
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _NothingStatusPill extends StatelessWidget {
  final BatteryData data;

  const _NothingStatusPill({required this.data});

  @override
  Widget build(BuildContext context) {
    final isChg = data.isCharging;
    final color = isChg ? AppColors.neonGreen : AppColors.cyberCyan;

    final label = isChg
        ? 'CHARGING (+${data.currentAbsMa.toStringAsFixed(0)} mA)'
        : 'DISCHARGING (-${data.currentAbsMa.toStringAsFixed(0)} mA)';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF14141B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: color, blurRadius: 4),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
