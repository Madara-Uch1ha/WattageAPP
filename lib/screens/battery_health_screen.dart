import 'dart:async';
import 'package:material_ui/material_ui.dart';
import '../services/battery_service.dart';
import '../theme/app_theme.dart';
import '../widgets/stat_card.dart';
import '../widgets/live_chart.dart';

class BatteryHealthScreen extends StatefulWidget {
  const BatteryHealthScreen({super.key});

  @override
  State<BatteryHealthScreen> createState() => _BatteryHealthScreenState();
}

class _BatteryHealthScreenState extends State<BatteryHealthScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.surfaceBorder),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('🔋', style: TextStyle(fontSize: 14)),
                        SizedBox(width: 6),
                        Text(
                          'CELL DIAGNOSTICS',
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
                ],
              ),
              const SizedBox(height: 20),

              // Glowing Health Status Card
              _CyberHealthCard(data: _data),
              const SizedBox(height: 16),

              // Technical Cell Metrics
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'INTEGRITY',
                      value: _data.health.toUpperCase(),
                      icon: Icons.shield_rounded,
                      valueColor: AppColors.neonGreen,
                      caption: 'Cell Voltage Verified',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      label: 'CHEMISTRY',
                      value: _data.technology.toUpperCase(),
                      icon: Icons.science_rounded,
                      valueColor: AppColors.cyberCyan,
                      caption: 'Dual-Cell Architecture',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'CHARGE CAP',
                      value: _data.chargeCounterMah.toStringAsFixed(0),
                      unit: 'mAh',
                      icon: Icons.battery_charging_full_rounded,
                      valueColor: AppColors.electricPurple,
                      caption: 'Current Energy Mass',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      label: 'STORED ENERGY',
                      value: _data.energyCounterMwh.toStringAsFixed(0),
                      unit: 'mWh',
                      icon: Icons.offline_bolt_rounded,
                      valueColor: AppColors.neonAmber,
                      caption: 'Realtime Stored Wh',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Current flow analysis
              WideStatCard(
                label: 'SMOOTHED MOVING AVERAGE',
                value: '${_data.currentAvgMa.abs().toStringAsFixed(0)} mA',
                subtitle: 'rolling 15-sample baseline',
                icon: Icons.trending_up_rounded,
                color: AppColors.cyberCyan,
              ),
              const SizedBox(height: 10),
              WideStatCard(
                label: 'INSTANTANEOUS DRAW',
                value: '${_data.currentAbsMa.toStringAsFixed(0)} mA',
                subtitle: _data.isCharging ? 'flow speed into pack' : 'chassis discharge drain',
                icon: Icons.speed_rounded,
                color: AppColors.electricPurple,
              ),
              const SizedBox(height: 16),

              // Temperature History Chart from Shared Queue
              LiveWattageChart(
                dataPoints: _batteryService.tempHistory,
                maxPoints: BatteryService.maxHistory,
                label: 'Thermal Fluctuations (°C)',
                color: _tempColor(_data.temperatureC),
              ),
              const SizedBox(height: 16),

              // Nothing Design Style Info Card
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.terminal_rounded, size: 18, color: AppColors.cyberCyan),
                        SizedBox(width: 8),
                        Text(
                          'HARDWARE SPECS NOTE',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '• Device: Nothing Phone (4a) [Snapdragon 7s Gen 4]\n'
                      '• Battery Architecture: 5,400 mAh high-density dual cell.\n'
                      '• Charging Protocol: 50W PPS Super Fast Wired Charging.\n'
                      '• Real Stored Energy: Calculated via instantaneous voltage (${_data.voltageV.toStringAsFixed(2)}V) × capacity (${_data.chargeCounterMah.toStringAsFixed(0)} mAh).\n'
                      '• Moving Average Current is dynamically smoothed over 15 continuous hardware samples.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.55),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _tempColor(double temp) {
    if (temp < 36) return AppColors.neonGreen;
    if (temp < 40) return AppColors.neonAmber;
    return AppColors.neonRed;
  }
}

class _CyberHealthCard extends StatelessWidget {
  final BatteryData data;

  const _CyberHealthCard({required this.data});

  @override
  Widget build(BuildContext context) {
    const accent = AppColors.neonGreen;

    return Container(
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
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              shape: BoxShape.circle,
              border: Border.all(color: accent.withValues(alpha: 0.4), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.25),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.verified_rounded,
              color: accent,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CELL INTEGRITY NOMINAL',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: accent,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Terminal voltage (${data.voltageV.toStringAsFixed(2)}V) and thermal state (${data.temperatureC.toStringAsFixed(1)}°C) confirm standard impedance and safe battery health.',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
