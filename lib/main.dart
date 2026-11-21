import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF070709),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const WattageApp());
}

class WattageApp extends StatelessWidget {
  const WattageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WattageApp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AppShell(),
    );
  }
}
