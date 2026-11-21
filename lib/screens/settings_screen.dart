import 'package:material_ui/material_ui.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _keepScreenOn = false;
  bool _useCelsius = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _keepScreenOn = prefs.getBool('keepScreenOn') ?? false;
      _useCelsius = prefs.getBool('useCelsius') ?? true;
    });
    if (_keepScreenOn) {
      WakelockPlus.enable();
    }
  }

  Future<void> _setKeepScreenOn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('keepScreenOn', value);
    setState(() => _keepScreenOn = value);
    if (value) {
      WakelockPlus.enable();
    } else {
      WakelockPlus.disable();
    }
  }

  Future<void> _setUseCelsius(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('useCelsius', value);
    setState(() => _useCelsius = value);
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
                        Text('⚙️', style: TextStyle(fontSize: 14)),
                        SizedBox(width: 6),
                        Text(
                          'CONFIGURATION',
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
              const SizedBox(height: 24),

              _SectionHeader(title: 'DISPLAY & MONITORING'),
              const SizedBox(height: 8),
              _CyberSettingsTile(
                icon: Icons.screen_lock_portrait_rounded,
                title: 'Keep Screen Active',
                subtitle: 'Prevent display sleep during high wattage observation',
                accentColor: AppColors.neonGreen,
                trailing: Switch(
                  value: _keepScreenOn,
                  onChanged: _setKeepScreenOn,
                  activeThumbColor: AppColors.neonGreen,
                  activeTrackColor: AppColors.neonGreen.withValues(alpha: 0.4),
                ),
              ),
              _CyberSettingsTile(
                icon: Icons.thermostat_rounded,
                title: 'Thermal Format',
                subtitle: _useCelsius ? 'Celsius Unit (°C)' : 'Fahrenheit Unit (°F)',
                accentColor: AppColors.neonAmber,
                trailing: Switch(
                  value: _useCelsius,
                  onChanged: _setUseCelsius,
                  activeThumbColor: AppColors.neonAmber,
                  activeTrackColor: AppColors.neonAmber.withValues(alpha: 0.4),
                ),
              ),
              const SizedBox(height: 24),

              _SectionHeader(title: 'DEVICE PROFILE'),
              const SizedBox(height: 8),
              const _CyberSettingsTile(
                icon: Icons.phone_android_rounded,
                title: 'Nothing Phone (4a)',
                subtitle: 'Customized for Nothing OS 4.1 & Android 16',
                accentColor: AppColors.cyberCyan,
              ),
              const _CyberSettingsTile(
                icon: Icons.bolt_rounded,
                title: 'Charging Engine',
                subtitle: '50W Super Fast PPS / 7.5W Reverse Wired Protocol',
                accentColor: AppColors.cyberLime,
              ),
              const _CyberSettingsTile(
                icon: Icons.code_rounded,
                title: 'Architecture',
                subtitle: 'Native Kernel Bridge via Android BatteryManager (0% Root)',
                accentColor: AppColors.electricPurple,
              ),
              const SizedBox(height: 24),

              _SectionHeader(title: 'OPTIMIZATION TIPS'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    _tipRow('⚡', 'Use a 50W+ PPS certified charger to trigger peak wattage curves.'),
                    const SizedBox(height: 12),
                    _tipRow('❄️', 'Charging stays fastest when phone temperature remains under 37°C.'),
                    const SizedBox(height: 12),
                    _tipRow('📈', '80% charge limit prolongs lithium chemistry lifespan significantly.'),
                    const SizedBox(height: 12),
                    _tipRow('💡', 'Screen-off charging speeds up wattage by reducing background display load.'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tipRow(String emoji, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.65),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: AppColors.textMuted,
        letterSpacing: 2.2,
      ),
    );
  }
}

class _CyberSettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final Widget? trailing;

  const _CyberSettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: accentColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
