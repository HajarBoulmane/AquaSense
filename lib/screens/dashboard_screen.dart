// screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../models/sensor_model.dart';
import '../widgets/stat_card.dart';
import '../widgets/sensor_list_tile.dart';
import 'main_shell.dart';
import 'sensor_detail_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sensors = SensorsProvider.of(context)?.sensors ?? [];

    final totalVol  = sensors.fold(0.0, (a, s) => a + s.volumeM3);
    final online    = sensors.where((s) => s.online).length;
    final critical  = sensors.where((s) => s.status == SensorStatus.critical).length;
    final warned    = sensors.where((s) => s.status == SensorStatus.warning).length;

    return RefreshIndicator(
      color: AquaColors.accent,
      backgroundColor: AquaColors.surface,
      onRefresh: () async => await Future.delayed(const Duration(seconds: 1)),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ── Stats grid ──────────────────────────────────────
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.6,
            children: [
              StatCard(label: '💧 Total Water',     value: '${totalVol.round()} m³', color: AquaColors.accent),
              StatCard(label: '📡 Sensors Online',  value: '$online/${sensors.length}', color: AquaColors.accent2),
              StatCard(label: '🚨 Critical Wells',  value: '$critical', color: AquaColors.danger),
              StatCard(label: '⚠️ Warnings',        value: '$warned',   color: AquaColors.warn),
            ],
          ),
          const SizedBox(height: 16),

          // ── Level history chart ──────────────────────────────
          if (sensors.isNotEmpty) ...[
            _AquaCard(
              title: '📈 Level Overview',
              child: SizedBox(
                height: 180,
                child: BarChart(
                  BarChartData(
                    barGroups: sensors.asMap().entries.map((e) {
                      final s = e.value;
                      final color = s.status == SensorStatus.critical
                          ? AquaColors.danger
                          : s.status == SensorStatus.warning
                              ? AquaColors.warn
                              : AquaColors.accent2;
                      return BarChartGroupData(x: e.key, barRods: [
                        BarChartRodData(
                          toY: s.levelPct,
                          color: color,
                          width: 14,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ]);
                    }).toList(),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, _) => Text('${v.round()}%',
                            style: TextStyle(fontSize: 9, color: AquaColors.muted)),
                          reservedSize: 32,
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, _) {
                            final i = v.toInt();
                            if (i >= sensors.length) return const SizedBox();
                            final name = sensors[i].name;
                            return Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                name.length > 8 ? '${name.substring(0,7)}…' : name,
                                style: TextStyle(fontSize: 8, color: AquaColors.muted),
                              ),
                            );
                          },
                          reservedSize: 28,
                        ),
                      ),
                      rightTitles:  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles:    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    gridData:   FlGridData(
                      getDrawingHorizontalLine: (_) =>
                        FlLine(color: AquaColors.border, strokeWidth: 1),
                    ),
                    maxY: 100,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── All sensors list ─────────────────────────────────
          _AquaCard(
            title: '🗂️ All Monitored Points',
            liveTag: true,
            child: sensors.isEmpty
              ? _emptyState()
              : Column(
                  children: sensors.map((s) => SensorListTile(
                    sensor: s,
                    onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => SensorDetailScreen(sensor: s))),
                  )).toList(),
                ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() => Padding(
    padding: const EdgeInsets.all(32),
    child: Column(children: [
      Text('📡', style: TextStyle(fontSize: 40)),
      const SizedBox(height: 8),
      Text('Connecting to Firebase…',
        style: TextStyle(color: AquaColors.muted, fontSize: 13)),
    ]),
  );
}

// ── Reusable card ─────────────────────────────────────────────
class _AquaCard extends StatelessWidget {
  final String title;
  final Widget child;
  final bool liveTag;

  const _AquaCard({required this.title, required this.child, this.liveTag = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AquaColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AquaColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14))),
          if (liveTag)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AquaColors.accent2.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AquaColors.accent2.withOpacity(0.3)),
              ),
              child: Text('● LIVE',
                style: TextStyle(fontSize: 10, color: AquaColors.accent2, fontWeight: FontWeight.w700)),
            ),
        ]),
        const SizedBox(height: 14),
        child,
      ]),
    );
  }
}
