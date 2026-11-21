import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'package:flutter/services.dart';

class BatteryData {
  final int voltageMv;
  final double voltageV;
  final double currentMa;
  final double currentAbsMa;
  final double currentAvgMa;
  final double temperatureC;
  final int batteryPct;
  final bool isCharging;
  final bool isFull;
  final String plugType;
  final String health;
  final String technology;
  final double chargeCounterMah;
  final double energyCounterMwh;
  final double wattage;
  final int timestamp;

  BatteryData({
    required this.voltageMv,
    required this.voltageV,
    required this.currentMa,
    required this.currentAbsMa,
    required this.currentAvgMa,
    required this.temperatureC,
    required this.batteryPct,
    required this.isCharging,
    required this.isFull,
    required this.plugType,
    required this.health,
    required this.technology,
    required this.chargeCounterMah,
    required this.energyCounterMwh,
    required this.wattage,
    required this.timestamp,
  });

  factory BatteryData.fromMap(Map<dynamic, dynamic> map, double calculatedAvgMa) {
    final vMv = (map['voltageMv'] as int?) ?? 4200;
    final vV = (map['voltageV'] as num?)?.toDouble() ?? (vMv / 1000.0);
    final cMa = (map['currentMa'] as num?)?.toDouble() ?? 0.0;
    final cAbsMa = (map['currentAbsMa'] as num?)?.toDouble() ?? cMa.abs();
    
    // Hardware average or smoothed fallback
    final hwAvgMa = (map['currentAvgMa'] as num?)?.toDouble() ?? 0.0;
    final finalAvgMa = (hwAvgMa != 0.0) ? hwAvgMa : calculatedAvgMa;

    final tempC = (map['temperatureC'] as num?)?.toDouble() ?? 32.0;
    final bPct = (map['batteryPct'] as int?) ?? 50;
    final isChg = (map['isCharging'] as bool?) ?? false;
    final isFl = (map['isFull'] as bool?) ?? false;
    final pType = (map['plugType'] as String?) ?? (isChg ? 'USB' : 'Battery');

    // Health fallback
    var hStr = (map['health'] as String?) ?? 'Unknown';
    if (hStr == 'Unknown' || hStr.isEmpty) {
      if (tempC > 45) {
        hStr = 'Warm State';
      } else if (vV > 3.0 && vV < 4.5) {
        hStr = 'Good';
      } else {
        hStr = 'Good';
      }
    }

    // Technology fallback
    var tech = (map['technology'] as String?) ?? 'Unknown';
    if (tech == 'Unknown' || tech.isEmpty) {
      tech = 'Li-Ion Dual-Cell';
    }

    // Charge counter fallback (Nothing 4a typical 5,400 mAh)
    var chgCounter = (map['chargeCounterMah'] as num?)?.toDouble() ?? -1.0;
    if (chgCounter <= 0) {
      chgCounter = (bPct / 100.0) * 5400.0;
    }

    // Stored Energy fallback: E(mWh) = Q(mAh) * V(V)
    var energyMwh = (map['energyCounterMwh'] as num?)?.toDouble() ?? -1.0;
    if (energyMwh <= 0) {
      energyMwh = chgCounter * vV;
    }

    final calculatedWattage = vV * (cAbsMa / 1000.0);

    return BatteryData(
      voltageMv: vMv,
      voltageV: vV,
      currentMa: cMa,
      currentAbsMa: cAbsMa,
      currentAvgMa: finalAvgMa,
      temperatureC: tempC,
      batteryPct: bPct,
      isCharging: isChg,
      isFull: isFl,
      plugType: pType,
      health: hStr,
      technology: tech,
      chargeCounterMah: chgCounter,
      energyCounterMwh: energyMwh,
      wattage: calculatedWattage,
      timestamp: (map['timestamp'] as int?) ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  factory BatteryData.empty() => BatteryData.initial();

  factory BatteryData.initial() {
    return BatteryData(
      voltageMv: 4200,
      voltageV: 4.20,
      currentMa: -450.0,
      currentAbsMa: 450.0,
      currentAvgMa: 450.0,
      temperatureC: 33.0,
      batteryPct: 90,
      isCharging: false,
      isFull: false,
      plugType: 'Battery',
      health: 'Good',
      technology: 'Li-Ion Dual-Cell',
      chargeCounterMah: 4860.0,
      energyCounterMwh: 20412.0,
      wattage: 1.89,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  String get chargingStatusText {
    if (isFull) return 'Full';
    if (isCharging) return 'Charging';
    return 'Discharging';
  }

  String get speedTier {
    if (!isCharging) return 'DISCHARGING';
    if (wattage >= 38.0) return '50W PPS ULTRA CHARGE';
    if (wattage >= 25.0) return 'SUPER FAST PPS';
    if (wattage >= 15.0) return 'PD FAST CHARGE';
    if (wattage >= 5.0) return 'STANDARD CHARGE';
    return 'TRICKLE CHARGE';
  }

  String get timeRemainingEstimate {
    if (wattage <= 0.05) return 'Estimating...';

    if (isCharging) {
      if (isFull || batteryPct >= 100) return 'Battery Full';
      // Remaining mAh to 100%
      final remainingMah = (100 - batteryPct) / 100.0 * 5400.0;
      final chargeCurrentA = currentAbsMa / 1000.0;
      if (chargeCurrentA <= 0.05) return 'Estimating...';
      final hours = remainingMah / 1000.0 / chargeCurrentA;
      final totalMinutes = (hours * 60).round().clamp(1, 300);
      
      final h = totalMinutes ~/ 60;
      final m = totalMinutes % 60;
      if (h > 0) {
        return '$h h $m m to full';
      }
      return '$m mins to 100%';
    } else {
      // Discharging: runtime remaining
      final usableMah = (batteryPct / 100.0) * 5400.0;
      final drainCurrentA = currentAbsMa / 1000.0;
      if (drainCurrentA <= 0.01) return 'Estimating...';
      final hours = usableMah / 1000.0 / drainCurrentA;
      final totalMinutes = (hours * 60).round().clamp(5, 4320); // up to 72h

      final h = totalMinutes ~/ 60;
      final m = totalMinutes % 60;
      return '$h h $m m remaining';
    }
  }
}

class BatteryService {
  // Singleton Pattern
  static final BatteryService instance = BatteryService._internal();
  factory BatteryService() => instance;

  static const _methodChannel = MethodChannel('com.wattageapp/battery');
  static const _eventChannel = EventChannel('com.wattageapp/battery_stream');

  // Shared stream controller that never disconnects
  final StreamController<BatteryData> _controller = StreamController<BatteryData>.broadcast();
  Stream<BatteryData> get batteryStream => _controller.stream;

  // Global live state
  BatteryData currentData = BatteryData.initial();

  // Persistent rolling history queues (60 samples = 60s)
  final Queue<double> wattageHistory = Queue<double>();
  final Queue<double> currentHistory = Queue<double>();
  final Queue<double> tempHistory = Queue<double>();
  static const int maxHistory = 60;

  // Rolling window for calculating moving average current
  final List<double> _recentCurrentSamples = [];

  // Session Statistics
  double peakWattage = 0.0;
  double sessionEnergyInjectedWh = 0.0;
  bool _wasCharging = false;
  int _lastTickMillis = DateTime.now().millisecondsSinceEpoch;

  BatteryService._internal() {
    _initPermanentStream();
  }

  void _initPermanentStream() {
    // Immediate initial sync
    getBatteryInfo().then((data) {
      _handleNewData(data);
    }).catchError((_) {});

    // Listen to native EventChannel permanently
    _eventChannel.receiveBroadcastStream().listen((event) {
      if (event is Map) {
        // Calculate rolling 15-sample average current
        final double smoothedAvg = _calculateSmoothedAverage();
        final data = BatteryData.fromMap(event, smoothedAvg);
        _handleNewData(data);
      }
    }, onError: (e) {
      // Graceful fallback
    });
  }

  void _handleNewData(BatteryData data) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final deltaSeconds = max(0.5, (now - _lastTickMillis) / 1000.0);
    _lastTickMillis = now;

    // Session transitions
    if (data.isCharging && !_wasCharging) {
      // Started charging session: reset session peak & energy counter
      peakWattage = data.wattage;
      sessionEnergyInjectedWh = 0.0;
    } else if (data.isCharging) {
      if (data.wattage > peakWattage) {
        peakWattage = data.wattage;
      }
      // Integrate power over time: Wh = Watts * (seconds / 3600)
      sessionEnergyInjectedWh += data.wattage * (deltaSeconds / 3600.0);
    }
    _wasCharging = data.isCharging;

    // Rolling sample tracking for moving average
    _recentCurrentSamples.add(data.currentAbsMa);
    if (_recentCurrentSamples.length > 15) {
      _recentCurrentSamples.removeAt(0);
    }

    currentData = data;

    // Update global persistent 60s history
    wattageHistory.addLast(data.wattage);
    currentHistory.addLast(data.currentAbsMa);
    tempHistory.addLast(data.temperatureC);

    while (wattageHistory.length > maxHistory) {
      wattageHistory.removeFirst();
    }
    while (currentHistory.length > maxHistory) {
      currentHistory.removeFirst();
    }
    while (tempHistory.length > maxHistory) {
      tempHistory.removeFirst();
    }

    _controller.add(data);
  }

  double _calculateSmoothedAverage() {
    if (_recentCurrentSamples.isEmpty) return currentData.currentAbsMa;
    final sum = _recentCurrentSamples.reduce((a, b) => a + b);
    return sum / _recentCurrentSamples.length;
  }

  Future<BatteryData> getBatteryInfo() async {
    final result = await _methodChannel.invokeMethod('getBatteryInfo');
    return BatteryData.fromMap(
      Map<dynamic, dynamic>.from(result),
      _calculateSmoothedAverage(),
    );
  }
}
