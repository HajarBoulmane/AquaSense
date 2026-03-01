import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/water_model.dart';
import '../services/firebase_service.dart';
import 'alerts.dart';
import 'stats.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirebaseService _service = FirebaseService();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _service.initNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1628),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF0077B6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.water_drop, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'AquaSense',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          StreamBuilder<List<WaterAlert>>(
            stream: _service.watchAlerts(),
            builder: (context, snap) {
              final unread = snap.data?.where((a) => !a.isRead).length ?? 0;
              return Badge(
                isLabelVisible: unread > 0,
                label: Text('$unread'),
                child: IconButton(
                  icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                  onPressed: () => setState(() => _selectedIndex = 1),
                ),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _HomeTab(service: _service),
          AlertsScreen(service: _service),
          StatsScreen(service: _service),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF0D1F38),
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Tableau de bord',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: 'Alertes',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Statistiques',
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  final FirebaseService service;
  const _HomeTab({required this.service});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<WaterSource>>(
      stream: service.watchWaterSources(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final sources = snap.data ?? [];
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SummaryCards(sources: sources),
            const SizedBox(height: 20),
            const Text(
              'Sources d\'eau',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...sources.map((s) => _WaterSourceCard(source: s, service: service)),
            const SizedBox(height: 20),
            _PredictionCard(service: service),
          ],
        );
      },
    );
  }
}

class _SummaryCards extends StatelessWidget {
  final List<WaterSource> sources;
  const _SummaryCards({required this.sources});

  @override
  Widget build(BuildContext context) {
    final avg = sources.isEmpty
        ? 0.0
        : sources.map((s) => s.levelPercent).reduce((a, b) => a + b) /
        sources.length;
    final critical = sources.where((s) => s.isCritical).length;

    return Row(
      children: [
        Expanded(
          child: _InfoCard(
            title: 'Niveau moyen',
            value: '${avg.toStringAsFixed(0)}%',
            icon: Icons.water,
            color: avg < 30
                ? Colors.red
                : avg < 60
                ? Colors.orange
                : Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _InfoCard(
            title: 'Sites critiques',
            value: '$critical',
            icon: Icons.warning_amber,
            color: critical > 0 ? Colors.red : Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _InfoCard(
            title: 'Sites actifs',
            value: '${sources.length}',
            icon: Icons.sensors,
            color: const Color(0xFF0077B6),
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _InfoCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1F38),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _WaterSourceCard extends StatelessWidget {
  final WaterSource source;
  final FirebaseService service;

  const _WaterSourceCard({required this.source, required this.service});

  Color get _levelColor {
    if (source.levelPercent < 20) return Colors.red;
    if (source.levelPercent < 50) return Colors.orange;
    return const Color(0xFF00B4D8);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1F38),
        borderRadius: BorderRadius.circular(16),
        border: source.isCritical
            ? Border.all(color: Colors.red.withOpacity(0.6))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                source.type == 'well' ? Icons.opacity : Icons.water_damage,
                color: _levelColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  source.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (source.isCritical)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.red),
                  ),
                  child: const Text(
                    'CRITIQUE',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              Text(
                '${source.levelPercent.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: _levelColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: source.levelPercent / 100,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(_levelColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Capacité : ${(source.capacityLiters / 1000).toStringAsFixed(0)} m³  •  Mis à jour : ${_formatTime(source.lastUpdated)}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'il y a ${diff.inHours} h';
    return 'il y a ${diff.inDays} j';
  }
}

class _PredictionCard extends StatefulWidget {
  final FirebaseService service;
  const _PredictionCard({required this.service});

  @override
  State<_PredictionCard> createState() => _PredictionCardState();
}

class _PredictionCardState extends State<_PredictionCard> {
  List<WeatherPrediction> _predictions = [];

  @override
  void initState() {
    super.initState();
    widget.service.fetchWeatherPredictions().then((p) {
      setState(() => _predictions = p);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1F38),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.psychology, color: Color(0xFF00B4D8)),
              SizedBox(width: 8),
              Text(
                'Prédictions IA – 7 jours',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_predictions.isEmpty)
            const Center(child: CircularProgressIndicator())
          else
            SizedBox(
              height: 160,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barGroups: _predictions.asMap().entries.map((e) {
                    final risk = e.value.droughtRisk;
                    return BarChartGroupData(
                      x: e.key,
                      barRods: [
                        BarChartRodData(
                          toY: risk,
                          color: risk > 0.6
                              ? Colors.red
                              : risk > 0.3
                              ? Colors.orange
                              : const Color(0xFF00B4D8),
                          width: 18,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (val, _) {
                          final days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
                          return Text(
                            days[val.toInt() % 7],
                            style: const TextStyle(color: Colors.white54, fontSize: 11),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  maxY: 1.0,
                ),
              ),
            ),
          const SizedBox(height: 8),
          const Text(
            'Risque de sécheresse (0 = faible, 1 = critique)',
            style: TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ],
      ),
    );
  }
}