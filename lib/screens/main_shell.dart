// screens/main_shell.dart

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/firebase_service.dart';
import '../models/sensor_model.dart';

import 'dashboard_screen.dart';
import 'map_screen.dart';
import 'wells_screen.dart';
import 'alerts_screen.dart';
import 'predictions_screen.dart';
import 'weather_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  List<SensorModel> _sensors = [];
  bool _connected = false;

  @override
  void initState() {
    super.initState();
    FirebaseService().sensorsStream().listen((sensors) {
      setState(() {
        _sensors   = sensors;
        _connected = true;
      });
    });
  }

  final _screens = const [
    DashboardScreen(),
    MapScreen(),
    WellsScreen(),
    AlertsScreen(),
    PredictionsScreen(),
    WeatherScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  final _navItems = const [
    BottomNavigationBarItem(icon: Icon(Icons.dashboard),       label: 'Dashboard'),
    BottomNavigationBarItem(icon: Icon(Icons.map),             label: 'Map'),
    BottomNavigationBarItem(icon: Icon(Icons.water),           label: 'Wells'),
    BottomNavigationBarItem(icon: Icon(Icons.notifications),   label: 'Alerts'),
    BottomNavigationBarItem(icon: Icon(Icons.psychology),      label: 'AI'),
    BottomNavigationBarItem(icon: Icon(Icons.cloud),           label: 'Weather'),
    BottomNavigationBarItem(icon: Icon(Icons.show_chart),      label: 'History'),
    BottomNavigationBarItem(icon: Icon(Icons.settings),        label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final criticalCount = _sensors
        .where((s) => s.status == SensorStatus.critical || !s.online)
        .length;

    return Scaffold(
      backgroundColor: AquaColors.bg,
      appBar: AppBar(
        backgroundColor: AquaColors.surface,
        elevation: 0,
        title: Row(children: [
          const Text('💧 ', style: TextStyle(fontSize: 20)),
          RichText(text: const TextSpan(
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            children: [
              TextSpan(text: 'Aqua', style: TextStyle(color: Colors.white)),
              TextSpan(text: 'Sense', style: TextStyle(color: Color(0xFF00B4FF))),
            ],
          )),
        ]),
        actions: [
          // Live indicator
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _connected
                ? AquaColors.accent2.withOpacity(0.15)
                : AquaColors.muted.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _connected ? AquaColors.accent2 : AquaColors.muted,
                width: 1,
              ),
            ),
            child: Row(children: [
              Container(
                width: 6, height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _connected ? AquaColors.accent2 : AquaColors.muted,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                _connected ? '🔥 Firebase Live' : 'Connecting…',
                style: TextStyle(
                  fontSize: 11,
                  color: _connected ? AquaColors.accent2 : AquaColors.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ]),
          ),
          // Alert badge
          if (criticalCount > 0)
            Stack(children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                color: AquaColors.danger,
                onPressed: () => setState(() => _currentIndex = 3),
              ),
              Positioned(
                right: 6, top: 6,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: AquaColors.danger,
                    shape: BoxShape.circle,
                  ),
                  child: Text('$criticalCount',
                    style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w800)),
                ),
              ),
            ]),
          const SizedBox(width: 8),
        ],
      ),

      // Pass sensors down via InheritedWidget pattern (simple approach)
      body: SensorsProvider(
        sensors: _sensors,
        child: _screens[_currentIndex],
      ),

      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          backgroundColor: AquaColors.surface,
          selectedItemColor: AquaColors.accent,
          unselectedItemColor: AquaColors.muted,
          selectedFontSize: 10,
          unselectedFontSize: 10,
          type: BottomNavigationBarType.fixed,
          items: _navItems,
        ),
      ),
    );
  }
}

// ── Simple InheritedWidget to pass sensors down ───────────────
class SensorsProvider extends InheritedWidget {
  final List<SensorModel> sensors;

  const SensorsProvider({
    super.key,
    required this.sensors,
    required super.child,
  });

  static SensorsProvider? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SensorsProvider>();

  @override
  bool updateShouldNotify(SensorsProvider old) => sensors != old.sensors;
}
