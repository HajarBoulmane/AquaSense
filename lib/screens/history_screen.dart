// screens/history_screen.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../utils/lang.dart';
import '../models/sensor_model.dart';
import 'main_shell.dart';
import 'dart:math';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final Map<String, List<double>> _history = {};
  bool _seeded = false;

  static const _colors = [
    Color(0xFF00B4FF), Color(0xFFFF3B5C), Color(0xFFFFB830),
    Color(0xFF00FFC8), Color(0xFFFF6B35), Color(0xFFA78BFA),
  ];

  // Seed 30 fake historical points per sensor so chart is visible immediately
  void _seedHistory(List<SensorModel> sensors) {
    if (_seeded) return;
    _seeded = true;
    final rng = Random();
    for (final s in sensors) {
      if (_history.containsKey(s.id)) continue;
      final points = <double>[];
      double level = (s.levelPct + rng.nextDouble() * 20 - 10).clamp(5, 100);
      for (int i = 0; i < 30; i++) {
        level = (level + rng.nextDouble() * 4 - 2).clamp(5, 100);
        points.add(level);
      }
      // Last point is current real value
      points.add(s.levelPct);
      _history[s.id] = points;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang    = LangProvider.of(context);
    final sensors = SensorsProvider.of(context)?.sensors ?? [];

    if (sensors.isNotEmpty) _seedHistory(sensors);

    // Accumulate live updates on top of seeded history
    for (final s in sensors) {
      _history.putIfAbsent(s.id, () => []);
      final hist = _history[s.id]!;
      if (hist.isEmpty || hist.last != s.levelPct) {
        hist.add(s.levelPct);
        if (hist.length > 60) hist.removeAt(0);
      }
    }

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: R.maxW(context)),
        child: ListView(
          padding: EdgeInsets.all(R.pad(context)),
          children: [

            // ── Water Level Trend chart ─────────────────────
            Container(
              padding: EdgeInsets.all(R.pad(context)),
              decoration: BoxDecoration(
                color: AquaColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AquaColors.border)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text('📈 ${lang.t("trend")}',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AquaColors.accent2.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AquaColors.accent2.withOpacity(0.3))),
                    child: const Text('● LIVE',
                      style: TextStyle(fontSize: 10, color: AquaColors.accent2,
                        fontWeight: FontWeight.w700)),
                  ),
                ]),
                const SizedBox(height: 14),
                SizedBox(
                  height: R.chartH(context),
                  child: sensors.isEmpty
                    ? Center(child: Text(lang.t('connecting'),
                        style: TextStyle(color: AquaColors.muted)))
                    : LineChart(LineChartData(
                        lineBarsData: sensors.asMap().entries.map((e) {
                          final s    = e.value;
                          final hist = _history[s.id] ?? [s.levelPct];
                          final color = _colors[e.key % _colors.length];
                          return LineChartBarData(
                            spots: hist.asMap().entries
                              .map((p) => FlSpot(p.key.toDouble(), p.value))
                              .toList(),
                            isCurved: true,
                            color: color,
                            barWidth: 2,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true, color: color.withOpacity(0.05)),
                          );
                        }).toList(),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, _) => Text('${v.round()}%',
                              style: TextStyle(fontSize: 9, color: AquaColors.muted)),
                            reservedSize: 32,
                          )),
                          bottomTitles: AxisTitles(sideTitles: SideTitles(
                            showTitles: true, interval: 5,
                            getTitlesWidget: (v, _) => Text('-${(30 - v.round()).abs()}d',
                              style: TextStyle(fontSize: 9, color: AquaColors.muted)),
                          )),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: FlGridData(
                          getDrawingHorizontalLine: (_) =>
                            FlLine(color: AquaColors.border, strokeWidth: 1)),
                        borderData: FlBorderData(show: false),
                        minY: 0, maxY: 100,
                      )),
                ),
                const SizedBox(height: 12),
                // Legend
                Wrap(spacing: 12, runSpacing: 6,
                  children: sensors.asMap().entries.map((e) {
                    final color = _colors[e.key % _colors.length];
                    return Row(mainAxisSize: MainAxisSize.min, children: [
                      Container(width: 12, height: 3,
                        decoration: BoxDecoration(
                          color: color, borderRadius: BorderRadius.circular(2))),
                      const SizedBox(width: 5),
                      Text(e.value.name,
                        style: TextStyle(fontSize: 10, color: AquaColors.muted)),
                    ]);
                  }).toList()),
              ]),
            ),
            const SizedBox(height: 16),

            // ── Event log ───────────────────────────────────
            Container(
              padding: EdgeInsets.all(R.pad(context)),
              decoration: BoxDecoration(
                color: AquaColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AquaColors.border)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('📋 ${lang.t("eventLog")}',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 12),
                ...sensors.map((s) {
                  final color = s.status.color;
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: AquaColors.border))),
                    child: Row(children: [
                      Container(width: 8, height: 8,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
                      const SizedBox(width: 10),
                      Expanded(child: Text(s.name,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
                      Text('${s.levelPct.round()}%',
                        style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w700)),
                      const SizedBox(width: 14),
                      Text(s.timeSince,
                        style: TextStyle(fontSize: 11, color: AquaColors.muted)),
                    ]),
                  );
                }),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}