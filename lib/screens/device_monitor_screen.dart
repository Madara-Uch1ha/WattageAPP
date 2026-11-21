import 'dart:async';
import 'package:material_ui/material_ui.dart';
import '../services/device_service.dart';
import '../services/battery_service.dart';
import '../theme/app_theme.dart';
import '../widgets/stat_card.dart';

class DeviceMonitorScreen extends StatefulWidget {
  const DeviceMonitorScreen({super.key});

  @override
  State<DeviceMonitorScreen> createState() => _DeviceMonitorScreenState();
}

class _DeviceMonitorScreenState extends State<DeviceMonitorScreen> {
  final _deviceService = DeviceService();
  final _batteryService = BatteryService.instance;
  DeviceStats _stats = DeviceStats.empty();
  late BatteryData _batteryData;
  Timer? _timer;
  StreamSubscription? _batterySub;

  @override
  void initState() {
    super.initState();
    _batteryData = _batteryService.currentData;
    _fetchStats();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => _fetchStats());
    _batterySub = _batteryService.batteryStream.listen((data) {
      if (mounted) setState(() => _batteryData = data);
    });
  }

  Future<void> _fetchStats() async {
    try {
      final stats = await _deviceService.getDeviceStats();
      if (mounted) setState(() => _stats = stats);
    } catch (_) {}
  }

  @override
  void dispose() {
    _timer?.cancel();
    _batterySub?.cancel();
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
              // Title
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
                        Text('📊', style: TextStyle(fontSize: 14)),
                        SizedBox(width: 6),
                        Text(
                          'HARDWARE PULSE',
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
              const SizedBox(height: 6),
              Text(
                _stats.brand.isNotEmpty
                    ? '${_stats.brand.toUpperCase()} ${_stats.model} • ANDROID ${_stats.androidVersion}'
                    : 'DETECTING SOC ENVIRONMENT...',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 20),

              // CPU Usage Bar
              WideStatCard(
                label: 'CPU LOAD DYNAMICS',
                value: _stats.cpuUsage >= 0
                    ? '${_stats.cpuUsage.toStringAsFixed(1)}%'
                    : 'READING KERNEL...',
                icon: Icons.memory_rounded,
                color: _cpuColor(_stats.cpuUsage),
                progress: _stats.cpuUsage >= 0 ? _stats.cpuUsage / 100 : null,
              ),
              const SizedBox(height: 10),

              // RAM Usage Bar
              WideStatCard(
                label: 'PHYSICAL MEMORY (RAM)',
                value: '${_stats.usedRamMb.toStringAsFixed(0)} MB',
                subtitle: '/ ${_stats.totalRamMb.toStringAsFixed(0)} MB',
                icon: Icons.developer_board_rounded,
                color: AppColors.cyberCyan,
                progress: _stats.ramUsagePct / 100,
              ),
              const SizedBox(height: 10),

              // Storage Usage Bar
              WideStatCard(
                label: 'UFS INTERNAL STORAGE',
                value: '${_stats.usedStorageGb.toStringAsFixed(1)} GB',
                subtitle: '/ ${_stats.totalStorageGb.toStringAsFixed(1)} GB',
                icon: Icons.storage_rounded,
                color: AppColors.neonAmber,
                progress: _stats.storageUsagePct / 100,
              ),
              const SizedBox(height: 10),

              // Battery Temperature Bar
              WideStatCard(
                label: 'CHASSIS / BATTERY THERMAL',
                value: '${_batteryData.temperatureC.toStringAsFixed(1)}°C',
                subtitle: _batteryData.temperatureC < 38 ? 'Nominal' : 'Warm',
                icon: Icons.thermostat_rounded,
                color: _tempColor(_batteryData.temperatureC),
                progress: (_batteryData.temperatureC / 50.0).clamp(0.0, 1.0),
              ),
              const SizedBox(height: 24),

              // Quick Telemetry Cards
              const Text(
                'SYSTEM TELEMETRY',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMuted,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'OS VERSION',
                      value: 'Android ${_stats.androidVersion}',
                      icon: Icons.android_rounded,
                      valueColor: AppColors.neonGreen,
                      caption: 'API Level ${_stats.sdkInt}',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      label: 'DEVICE CODE',
                      value: _stats.device.toUpperCase(),
                      icon: Icons.fingerprint_rounded,
                      valueColor: AppColors.cyberCyan,
                      caption: 'Snapdragon SoC',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'FREE MEMORY',
                      value: _stats.availRamMb.toStringAsFixed(0),
                      unit: 'MB',
                      icon: Icons.speed_rounded,
                      valueColor: AppColors.cyberLime,
                      caption: 'Available Heap',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      label: 'AVAILABLE DISK',
                      value: _stats.freeStorageGb.toStringAsFixed(1),
                      unit: 'GB',
                      icon: Icons.disc_full_rounded,
                      valueColor: AppColors.neonAmber,
                      caption: 'Free Capacity',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _cpuColor(double usage) {
    if (usage < 35) return AppColors.neonGreen;
    if (usage < 70) return AppColors.neonAmber;
    return AppColors.neonRed;
  }

  Color _tempColor(double temp) {
    if (temp < 36) return AppColors.neonGreen;
    if (temp < 41) return AppColors.neonAmber;
    return AppColors.neonRed;
  }
}
