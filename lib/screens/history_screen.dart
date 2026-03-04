// screens/history_screen.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../models/sensor_model.dart';
import 'main_shell.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // In-memory history accumulated from Firebase live updates
  final Map<String, List<double>> _history = {};

  static const _colors = [
    Color(0xFF00B4FF), Color(0xFFFF3B5C), Color(0xFFFFB830),
    Color(0xFF00FFC8), Color(0xFFFF6B35), Color(0xFFA78BFA),
  ];

  @override
  Widget build(BuildContext context) {
    final sensors = SensorsProvider.of(context)?.sensors ?? [];

    // Accumulate history
    for (final s in sensors) {
      _history.putIfAbsent(s.id, () => []);
      _history[s.id]!.add(s.levelPct);
      if (_history[s.id]!.length > 60) _history[s.id]!.removeAt(0);
    }

    final maxLen = _history.values.fold(0, (a, v) => a > v.length ? a : v.length);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Chart
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AquaColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AquaColors.border),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('📈 Water Level Trend',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 14),
            SizedBox(
              height: 220,
              child: maxLen < 2
                ? Center(child: Text('Accumulating data…',
                    style: TextStyle(color: AquaColors.muted)))
                : LineChart(LineChartData(
                    lineBarsData: sensors.asMap().entries.map((e) {
                      final s     = e.value;
                      final hist  = _history[s.id] ?? [];
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
                          show: true,
                          color: color.withOpacity(0.05),
                        ),
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
                        showTitles: true,
                        getTitlesWidget: (v, _) => Text('${v.round()}',
                          style: TextStyle(fontSize: 9, color: AquaColors.muted)),
                      )),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(
                      getDrawingHorizontalLine: (_) =>
                        FlLine(color: AquaColors.border, strokeWidth: 1),
                    ),
                    borderData: FlBorderData(show: false),
                    minY: 0, maxY: 100,
                  )),
            ),
          ]),
        ),
        const SizedBox(height: 16),

        // Event log
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AquaColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AquaColors.border),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('📋 Event Log',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 10),
            ...sensors.map((s) {
              final color = s.status.color;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(children: [
                  Expanded(child: Text(s.name, style: const TextStyle(fontSize: 12))),
                  Text('${s.levelPct.round()}%',
                    style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 12),
                  Text(s.timeSince,
                    style: TextStyle(fontSize: 11, color: AquaColors.muted)),
                ]),
              );
            }),
          ]),
        ),
      ],
    );
  }
}
