// screens/main_shell.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
import 'login_screen.dart';
import 'review_screen.dart';
import 'reclamation_screen.dart';   // ← add this


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
    BottomNavigationBarItem(icon: Icon(Icons.dashboard),     label: 'Dashboard'),
    BottomNavigationBarItem(icon: Icon(Icons.map),           label: 'Map'),
    BottomNavigationBarItem(icon: Icon(Icons.water),         label: 'Wells'),
    BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Alerts'),
    BottomNavigationBarItem(icon: Icon(Icons.psychology),    label: 'AI'),
    BottomNavigationBarItem(icon: Icon(Icons.cloud),         label: 'Weather'),
    BottomNavigationBarItem(icon: Icon(Icons.show_chart),    label: 'History'),
    BottomNavigationBarItem(icon: Icon(Icons.settings),      label: 'Settings'),
  ];

  void _showProfileMenu(BuildContext context) {
    final user  = FirebaseAuth.instance.currentUser;
    final name  = user?.displayName ?? 'AquaSense User';
    final email = user?.email ?? '';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0D1F38),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _AvatarWidget(user: user, size: 64),
            const SizedBox(height: 12),
            Text(name,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 4),
            Text(email,
              style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 12)),
            const SizedBox(height: 16),

            // ── Reclamation button inside profile menu ──────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ReclamationScreen()));
                },
                icon: const Icon(Icons.report_problem_outlined, size: 16),
                label: const Text('Report a Problem'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AquaColors.warn.withOpacity(0.15),
                  foregroundColor: AquaColors.warn,
                  elevation: 0,
                  side: BorderSide(color: AquaColors.warn.withOpacity(0.4)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()));
                  }
                },
                icon: const Icon(Icons.logout_rounded, size: 16),
                label: const Text('Sign Out'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFF3B5C),
                  side: const BorderSide(color: Color(0xFFFF3B5C)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user          = FirebaseAuth.instance.currentUser;
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
                    color: AquaColors.danger, shape: BoxShape.circle),
                  child: Text('$criticalCount',
                    style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w800)),
                ),
              ),
            ]),

          // Review button
          IconButton(
            icon: const Icon(Icons.rate_review_outlined),
            color: AquaColors.accent,
            tooltip: 'Leave a Review',
            onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ReviewScreen())),
          ),

          // Reclamation button
          IconButton(
            icon: const Icon(Icons.report_problem_outlined),
            color: AquaColors.warn,
            tooltip: 'Report a Problem',
            onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ReclamationScreen())),
          ),

          // User avatar
          GestureDetector(
            onTap: () => _showProfileMenu(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: _AvatarWidget(user: user, size: 34),
            ),
          ),
        ],
      ),

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

// ── Avatar widget ─────────────────────────────────────────────
class _AvatarWidget extends StatelessWidget {
  final User? user;
  final double size;
  const _AvatarWidget({required this.user, required this.size});

  @override
  Widget build(BuildContext context) {
    final name     = user?.displayName ?? 'A';
    final photoUrl = user?.photoURL;
    final initials = name.trim().split(' ')
        .map((e) => e.isNotEmpty ? e[0] : '')
        .take(2)
        .join()
        .toUpperCase();

    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF00D4FF), Color(0xFF0077B6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: const Color(0xFF00D4FF).withOpacity(0.3), blurRadius: 8),
        ],
      ),
      child: photoUrl != null
          ? ClipOval(child: Image.network(photoUrl, fit: BoxFit.cover))
          : Center(child: Text(initials,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: size * 0.35))),
    );
  }
}

// ── SensorsProvider ───────────────────────────────────────────
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
