import 'package:flutter/services.dart';

class DeviceStats {
  final double cpuUsage;
  final double totalRamMb;
  final double availRamMb;
  final double usedRamMb;
  final double ramUsagePct;
  final double totalStorageGb;
  final double freeStorageGb;
  final double usedStorageGb;
  final double storageUsagePct;
  final String brand;
  final String model;
  final String device;
  final String androidVersion;
  final int sdkInt;

  DeviceStats({
    required this.cpuUsage,
    required this.totalRamMb,
    required this.availRamMb,
    required this.usedRamMb,
    required this.ramUsagePct,
    required this.totalStorageGb,
    required this.freeStorageGb,
    required this.usedStorageGb,
    required this.storageUsagePct,
    required this.brand,
    required this.model,
    required this.device,
    required this.androidVersion,
    required this.sdkInt,
  });

  factory DeviceStats.fromMap(Map<dynamic, dynamic> map) {
    return DeviceStats(
      cpuUsage: (map['cpuUsage'] as num?)?.toDouble() ?? -1.0,
      totalRamMb: (map['totalRamMb'] as num?)?.toDouble() ?? 0.0,
      availRamMb: (map['availRamMb'] as num?)?.toDouble() ?? 0.0,
      usedRamMb: (map['usedRamMb'] as num?)?.toDouble() ?? 0.0,
      ramUsagePct: (map['ramUsagePct'] as num?)?.toDouble() ?? 0.0,
      totalStorageGb: (map['totalStorageGb'] as num?)?.toDouble() ?? 0.0,
      freeStorageGb: (map['freeStorageGb'] as num?)?.toDouble() ?? 0.0,
      usedStorageGb: (map['usedStorageGb'] as num?)?.toDouble() ?? 0.0,
      storageUsagePct: (map['storageUsagePct'] as num?)?.toDouble() ?? 0.0,
      brand: (map['brand'] as String?) ?? 'Unknown',
      model: (map['model'] as String?) ?? 'Unknown',
      device: (map['device'] as String?) ?? 'Unknown',
      androidVersion: (map['androidVersion'] as String?) ?? 'Unknown',
      sdkInt: (map['sdkInt'] as int?) ?? 0,
    );
  }

  factory DeviceStats.empty() {
    return DeviceStats(
      cpuUsage: 0,
      totalRamMb: 0,
      availRamMb: 0,
      usedRamMb: 0,
      ramUsagePct: 0,
      totalStorageGb: 0,
      freeStorageGb: 0,
      usedStorageGb: 0,
      storageUsagePct: 0,
      brand: '',
      model: '',
      device: '',
      androidVersion: '',
      sdkInt: 0,
    );
  }
}

class DeviceService {
  static const _channel = MethodChannel('com.wattageapp/device');

  Future<DeviceStats> getDeviceStats() async {
    final result = await _channel.invokeMethod('getDeviceStats');
    return DeviceStats.fromMap(Map<dynamic, dynamic>.from(result));
  }
}
