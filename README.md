# ⚡ WattageApp (for Nothing Phone 4a)

<p align="center">
  <img src="https://img.shields.io/badge/Platform-Android%2014+-3DDC84?style=for-the-badge&logo=android&logoColor=white" alt="Android">
  <img src="https://img.shields.io/badge/Nothing_OS-4.1+-000000?style=for-the-badge&logo=nothing&logoColor=white" alt="Nothing OS">
  <img src="https://img.shields.io/badge/Framework-Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Root_Required-NO-00FF7F?style=for-the-badge" alt="No Root">
  <img src="https://img.shields.io/badge/License-MIT-blue?style=for-the-badge" alt="License">
</p>

An AMOLED-optimized Android system & charging wattage telemetry monitor built specifically for the **Nothing Phone (4a)**. Features real-time power calculations ($P = V \times I$), an authentic in-app **Dot-Matrix Glyph Bar**, adaptive dynamic scaling, and zero third-party telemetry bloat.

---

## 📥 Download & Install

Get the latest installable `.apk` directly from GitHub Releases:

👉 **[Download Latest APK from Releases](https://github.com/Madara-Uch1ha/WattageAPP/releases)**

### Installation:
1. Download `app-release.apk` onto your Nothing Phone (4a).
2. Open your device's file manager (**Files by Google**), tap the downloaded `.apk`, and select **Install**.
3. If prompted, grant permission to *"Install unknown apps"*.

---

## ✨ Features

### 1. ⚡ Live Charging Wattage Dashboard
* **Real Instantaneous Wattage ($P = V \times I$)**: Calculated directly from Android's hardware `BatteryManager` registers.
* **Adaptive Dynamic Scale**:
  * **Charging Mode**: Full `0 – 50W` scale (supporting the Nothing Phone 4a's 50W PPS fast charge protocol).
  * **Discharging Mode**: Automatically adapts to a sensitive `0 – 8W` scale, ensuring typical 1.0W – 3.5W drain is clearly visible and readable.
* **Authentic 4a Dot-Matrix Glyph Bar**:
  * 24-segment square LED array modeled after the Nothing Phone (4a)'s rear glyph matrix.
  * Illuminates pixel-by-pixel with live energy flow and accelerates pulse frequency as wattage rises.
* **Time Estimator**:
  * **Charging**: Calculates estimated minutes to 80% (battery health target) and 100% full.
  * **Discharging**: Calculates real-time battery runtime remaining based on active drain.
* **Session Peak Tracker**: Logs the maximum wattage achieved and total Watt-hours ($Wh$) pumped into the cell during each charge session.
* **Dual Live Scrolling Charts**: Real-time 60-second historical curves for power ($W$) and current flow ($mA$).

### 2. 📊 System Telemetry
* **CPU Load Dynamics**: Instantaneous CPU utilization parsed from Linux `/proc/stat`.
* **RAM Memory Heap**: Real-time physical memory telemetry (total, used, free).
* **UFS Storage Tracker**: Internal flash storage utilization.
* **Thermal Sensors**: Live chassis and battery thermal monitoring.

### 3. 🔋 Cell Diagnostics & Battery Health
* **Cell Integrity & Chemistry**: Terminal voltage analysis ($4.2\text{V} - 4.4\text{V}$ nominal range) and dual-cell packaging validation.
* **Real Stored Energy ($mWh$)**: Accurately calculated via instantaneous cell potential and capacity.
* **Smoothed Moving Average**: Rolling 15-sample hardware current baseline.
* **Thermal Trend Curve**: History of temperature fluctuations over time.

### 4. ⚙️ Configuration & Battery Guard
* **Keep Screen Active**: Prevent display sleep while benchmarking chargers and cables.
* **Thermal Units**: Toggle between Celsius (°C) and Fahrenheit (°F).
* **Nothing OS Charging Tips**: Best practices for preserving dual-cell battery health.

---

## 🔒 100% Native Architecture (Zero Third-Party Bloat)

To ensure maximum performance and zero background battery drain, WattageApp uses **no third-party monitoring dependencies**:

| Component | Technology |
|---|---|
| **UI Framework** | Flutter 3.44+ (AOT compiled to native ARM64) |
| **Native Bridge** | Kotlin platform channel (`MainActivity.kt`) |
| **Battery & Wattage** | Native `android.os.BatteryManager` (`CURRENT_NOW`, `EXTRA_VOLTAGE`, `EXTRA_TEMPERATURE`) |
| **Glyph Styling** | Modeled after official Nothing Developer Programme guidelines (`com.nothing.ketchum`) |
| **CPU Telemetry** | Linux `/proc/stat` kernel parsing |
| **Memory Telemetry** | Android `ActivityManager.MemoryInfo` |
| **Storage Telemetry** | Android `android.os.StatFs` |

---

## 🔨 Building from Source

### Prerequisites
* Flutter SDK (3.24.0 or newer)
* Android SDK (API 34+ / Android 14+)
* Java 17+

### Steps
1. Clone the repository:
   ```bash
   git clone https://github.com/Madara-Uch1ha/WattageAPP.git
   cd WattageAPP
   ```

2. Fetch dependencies:
   ```bash
   flutter pub get
   ```

3. Build the release APK:
   ```bash
   flutter build apk --release
   ```

4. The compiled APK will be output to:
   ```
   build/app/outputs/flutter-apk/app-release.apk
   ```

---

## 📄 License
This project is open-source under the [MIT License](LICENSE).
