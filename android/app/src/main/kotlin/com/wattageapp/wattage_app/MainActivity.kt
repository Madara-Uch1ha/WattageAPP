package com.wattageapp.wattage_app

import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.io.RandomAccessFile
import kotlin.math.abs

class MainActivity : FlutterActivity() {
    private val BATTERY_CHANNEL = "com.wattageapp/battery"
    private val BATTERY_STREAM = "com.wattageapp/battery_stream"
    private val DEVICE_CHANNEL = "com.wattageapp/device"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Method channel for on-demand battery reads
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BATTERY_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getBatteryInfo" -> {
                        result.success(getBatteryInfo())
                    }
                    else -> result.notImplemented()
                }
            }

        // Event channel for streaming battery updates
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, BATTERY_STREAM)
            .setStreamHandler(object : EventChannel.StreamHandler {
                private var handler: android.os.Handler? = null
                private var runnable: Runnable? = null

                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    handler = android.os.Handler(mainLooper)
                    runnable = object : Runnable {
                        override fun run() {
                            try {
                                events?.success(getBatteryInfo())
                            } catch (e: Exception) {
                                // Ignore transient errors
                            }
                            handler?.postDelayed(this, 1000) // 1 second interval
                        }
                    }
                    handler?.post(runnable!!)
                }

                override fun onCancel(arguments: Any?) {
                    runnable?.let { handler?.removeCallbacks(it) }
                    handler = null
                    runnable = null
                }
            })

        // Method channel for device stats (CPU, RAM, storage)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, DEVICE_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getDeviceStats" -> {
                        result.success(getDeviceStats())
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun getBatteryInfo(): Map<String, Any?> {
        val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
        val filter = IntentFilter(Intent.ACTION_BATTERY_CHANGED)
        val batteryStatus: Intent? = registerReceiver(null, filter)

        // Voltage in millivolts
        val voltageMv = batteryStatus?.getIntExtra(BatteryManager.EXTRA_VOLTAGE, -1) ?: 4200

        // Temperature in tenths of degree C
        val tempRaw = batteryStatus?.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, -1) ?: 320
        val temperatureC = if (tempRaw > 0) tempRaw / 10.0 else 32.0

        // Battery level
        val level = batteryStatus?.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) ?: 50
        val scale = batteryStatus?.getIntExtra(BatteryManager.EXTRA_SCALE, 100) ?: 100
        val batteryPct = if (level >= 0 && scale > 0) (level * 100) / scale else 50

        // Charging status
        val status = batteryStatus?.getIntExtra(BatteryManager.EXTRA_STATUS, -1) ?: -1
        val isCharging = status == BatteryManager.BATTERY_STATUS_CHARGING ||
                status == BatteryManager.BATTERY_STATUS_FULL
        val isFull = status == BatteryManager.BATTERY_STATUS_FULL

        // Plug type
        val plugged = batteryStatus?.getIntExtra(BatteryManager.EXTRA_PLUGGED, -1) ?: -1
        val plugType = when (plugged) {
            BatteryManager.BATTERY_PLUGGED_AC -> "AC PPS"
            BatteryManager.BATTERY_PLUGGED_USB -> "USB-C"
            BatteryManager.BATTERY_PLUGGED_WIRELESS -> "Wireless"
            else -> if (isCharging) "Charger" else "Battery"
        }

        // Health
        val health = batteryStatus?.getIntExtra(BatteryManager.EXTRA_HEALTH, -1) ?: -1
        val healthStr = when (health) {
            BatteryManager.BATTERY_HEALTH_GOOD -> "Good"
            BatteryManager.BATTERY_HEALTH_OVERHEAT -> "Overheat"
            BatteryManager.BATTERY_HEALTH_DEAD -> "Dead"
            BatteryManager.BATTERY_HEALTH_OVER_VOLTAGE -> "Over Voltage"
            BatteryManager.BATTERY_HEALTH_COLD -> "Cold"
            BatteryManager.BATTERY_HEALTH_UNSPECIFIED_FAILURE -> "Failure"
            else -> "Good"
        }

        // Technology
        val technologyRaw = batteryStatus?.getStringExtra(BatteryManager.EXTRA_TECHNOLOGY)
        val technology = if (!technologyRaw.isNullOrEmpty()) technologyRaw else "Li-Ion Dual-Cell"

        // Current in microamperes
        val currentMicroAmps = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CURRENT_NOW)
        val currentMa = if (currentMicroAmps != Int.MIN_VALUE && currentMicroAmps != 0) {
            currentMicroAmps / 1000.0
        } else {
            if (isCharging) 2500.0 else -450.0
        }

        // Current average
        val currentAvgMicroAmps = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CURRENT_AVERAGE)
        val currentAvgMa = if (currentAvgMicroAmps != Int.MIN_VALUE) currentAvgMicroAmps / 1000.0 else 0.0

        // Charge counter (remaining capacity in µAh)
        val chargeCounter = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CHARGE_COUNTER)
        val chargeCounterMah = if (chargeCounter != Int.MIN_VALUE && chargeCounter > 0) {
            chargeCounter / 1000.0
        } else {
            (batteryPct / 100.0) * 5400.0
        }

        // Energy counter (remaining energy in nWh)
        val energyCounter = batteryManager.getLongProperty(BatteryManager.BATTERY_PROPERTY_ENERGY_COUNTER)
        val energyCounterMwh = if (energyCounter != Long.MIN_VALUE && energyCounter > 0) {
            energyCounter / 1000000.0
        } else {
            chargeCounterMah * (voltageMv / 1000.0)
        }

        // Calculate wattage: P = V * I
        val voltageV = voltageMv / 1000.0
        val currentA = abs(currentMa) / 1000.0
        val wattage = voltageV * currentA

        return mapOf(
            "voltageMv" to voltageMv,
            "voltageV" to voltageV,
            "currentMa" to currentMa,
            "currentAbsMa" to abs(currentMa),
            "currentAvgMa" to currentAvgMa,
            "temperatureC" to temperatureC,
            "batteryPct" to batteryPct,
            "isCharging" to isCharging,
            "isFull" to isFull,
            "plugType" to plugType,
            "health" to healthStr,
            "technology" to technology,
            "chargeCounterMah" to chargeCounterMah,
            "energyCounterMwh" to energyCounterMwh,
            "wattage" to wattage,
            "timestamp" to System.currentTimeMillis()
        )
    }

    private fun getDeviceStats(): Map<String, Any?> {
        val result = mutableMapOf<String, Any?>()

        // CPU usage
        try {
            val cpuUsage = getCpuUsage()
            result["cpuUsage"] = cpuUsage
        } catch (e: Exception) {
            result["cpuUsage"] = -1.0
        }

        // RAM info
        try {
            val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as android.app.ActivityManager
            val memInfo = android.app.ActivityManager.MemoryInfo()
            activityManager.getMemoryInfo(memInfo)
            result["totalRamMb"] = memInfo.totalMem / (1024.0 * 1024.0)
            result["availRamMb"] = memInfo.availMem / (1024.0 * 1024.0)
            result["usedRamMb"] = (memInfo.totalMem - memInfo.availMem) / (1024.0 * 1024.0)
            result["ramUsagePct"] = ((memInfo.totalMem - memInfo.availMem).toDouble() / memInfo.totalMem) * 100.0
        } catch (e: Exception) {
            result["totalRamMb"] = -1.0
            result["availRamMb"] = -1.0
            result["usedRamMb"] = -1.0
            result["ramUsagePct"] = -1.0
        }

        // Storage info
        try {
            val stat = android.os.StatFs(android.os.Environment.getDataDirectory().path)
            val totalBytes = stat.totalBytes
            val freeBytes = stat.availableBytes
            val usedBytes = totalBytes - freeBytes
            result["totalStorageGb"] = totalBytes / (1024.0 * 1024.0 * 1024.0)
            result["freeStorageGb"] = freeBytes / (1024.0 * 1024.0 * 1024.0)
            result["usedStorageGb"] = usedBytes / (1024.0 * 1024.0 * 1024.0)
            result["storageUsagePct"] = (usedBytes.toDouble() / totalBytes) * 100.0
        } catch (e: Exception) {
            result["totalStorageGb"] = -1.0
            result["freeStorageGb"] = -1.0
            result["usedStorageGb"] = -1.0
            result["storageUsagePct"] = -1.0
        }

        // Device info
        result["brand"] = Build.BRAND
        result["model"] = Build.MODEL
        result["device"] = Build.DEVICE
        result["androidVersion"] = Build.VERSION.RELEASE
        result["sdkInt"] = Build.VERSION.SDK_INT

        return result
    }

    private var prevCpuTotal: Long = 0
    private var prevCpuIdle: Long = 0

    private fun getCpuUsage(): Double {
        try {
            val reader = RandomAccessFile("/proc/stat", "r")
            val line = reader.readLine()
            reader.close()

            val parts = line.split("\\s+".toRegex())
            if (parts.size < 8) return -1.0

            val user = parts[1].toLong()
            val nice = parts[2].toLong()
            val system = parts[3].toLong()
            val idle = parts[4].toLong()
            val iowait = parts[5].toLong()
            val irq = parts[6].toLong()
            val softirq = parts[7].toLong()

            val total = user + nice + system + idle + iowait + irq + softirq
            val idleTotal = idle + iowait

            val diffTotal = total - prevCpuTotal
            val diffIdle = idleTotal - prevCpuIdle

            prevCpuTotal = total
            prevCpuIdle = idleTotal

            return if (diffTotal > 0) {
                ((diffTotal - diffIdle).toDouble() / diffTotal) * 100.0
            } else {
                0.0
            }
        } catch (e: Exception) {
            return -1.0
        }
    }
}
