// screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../models/sensor_model.dart';
import '../widgets/stat_card.dart';
import '../widgets/sensor_list_tile.dart';
import '../utils/responsive.dart';
import 'main_shell.dart';
import 'sensor_detail_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sensors  = SensorsProvider.of(context)?.sensors ?? [];
    final totalVol = sensors.fold(0.0, (a, s) => a + s.volumeM3);
    final online   = sensors.where((s) => s.online).length;
    final critical = sensors.where((s) => s.status == SensorStatus.critical).length;
    final warned   = sensors.where((s) => s.status == SensorStatus.warning).length;

    return PageWrapper(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Stats grid — 4 cols on desktop, 2 on mobile ────────
        ResponsiveGrid(
          columns: R.statCols(context),
          childAspect: R.isDesktop(context) ? 1.8 : 1.55,
          children: [
            StatCard(label: '💧 Total Water',    value: '${totalVol.round()} m³', color: AquaColors.accent),
            StatCard(label: '📡 Sensors Online', value: '$online/${sensors.length}', color: AquaColors.accent2),
            StatCard(label: '🚨 Critical Wells', value: '$critical', color: AquaColors.danger),
            StatCard(label: '⚠️ Warnings',       value: '$warned', color: AquaColors.warn),
          ],
        ),
        const SizedBox(height: 18),

        // ── Chart + List — side-by-side on desktop ─────────────
        if (sensors.isNotEmpty)
          R.useTwoCols(context)
              ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(flex: 3, child: _chartCard(context, sensors)),
                  const SizedBox(width: 18),
                  Expanded(flex: 2, child: _listCard(context, sensors)),
                ])
              : Column(children: [
                  _chartCard(context, sensors),
                  const SizedBox(height: 16),
                  _listCard(context, sensors),
                ]),

        if (sensors.isEmpty) ...[
          const SizedBox(height: 18),
          _emptyState(),
        ],
      ]),
    );
  }

  Widget _chartCard(BuildContext context, List<SensorModel> sensors) {
    return AquaCard(
      title: '📈 Level Overview',
      child: SizedBox(
        height: R.chartH(context),
        child: BarChart(BarChartData(
          barGroups: sensors.asMap().entries.map((e) {
            final s = e.value;
            final color = s.status == SensorStatus.critical
                ? AquaColors.danger
                : s.status == SensorStatus.warning
                    ? AquaColors.warn : AquaColors.accent2;
            return BarChartGroupData(x: e.key, barRods: [
              BarChartRodData(
                toY: s.levelPct, color: color, width: 14,
                borderRadius: BorderRadius.circular(4)),
            ]);
          }).toList(),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) => Text('${v.round()}%',
                style: TextStyle(fontSize: 9, color: AquaColors.muted)),
              reservedSize: 32,
            )),
            bottomTitles: AxisTitles(sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) {
                final i = v.toInt();
                if (i >= sensors.length) return const SizedBox();
                final name = sensors[i].name;
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    name.length > 8 ? '${name.substring(0, 7)}…' : name,
                    style: TextStyle(fontSize: 8, color: AquaColors.muted)));
              },
              reservedSize: 28,
            )),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            getDrawingHorizontalLine: (_) =>
                FlLine(color: AquaColors.border, strokeWidth: 1)),
          maxY: 100,
        )),
      ),
    );
  }

  Widget _listCard(BuildContext context, List<SensorModel> sensors) {
    return AquaCard(
      title: '🗂️ All Monitored Points',
      liveTag: true,
      child: Column(
        children: sensors.map((s) => SensorListTile(
          sensor: s,
          onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => SensorDetailScreen(sensor: s))),
        )).toList(),
      ),
    );
  }

  Widget _emptyState() => Container(
    padding: const EdgeInsets.all(40),
    decoration: BoxDecoration(
      color: AquaColors.surface, borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AquaColors.border)),
    child: Center(child: Column(children: [
      const Text('📡', style: TextStyle(fontSize: 40)),
      const SizedBox(height: 10),
      Text('Connecting to Firebase…',
        style: TextStyle(color: AquaColors.muted, fontSize: 13)),
    ])),
  );
}

// ── Reusable AquaCard — exported for other screens ───────
class AquaCard extends StatelessWidget {
  final String title;
  final Widget child;
  final bool liveTag;

  const AquaCard({super.key, required this.title, required this.child,
    this.liveTag = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(R.isDesktop(context) ? 20 : 16),
      decoration: BoxDecoration(
        color: AquaColors.surface, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AquaColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(title, style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: R.isDesktop(context) ? 15 : 14))),
          if (liveTag)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AquaColors.accent2.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AquaColors.accent2.withOpacity(0.3))),
              child: Text('● LIVE', style: TextStyle(
                fontSize: 10, color: AquaColors.accent2, fontWeight: FontWeight.w700))),
        ]),
        const SizedBox(height: 14),
        child,
      ]),
    );
  }
}