// screens/predictions_screen.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../models/sensor_model.dart';
import 'main_shell.dart';

class PredictionsScreen extends StatelessWidget {
  const PredictionsScreen({super.key});

  static const _colors = [
    Color(0xFF00B4FF), Color(0xFFFF3B5C), Color(0xFFFFB830),
    Color(0xFF00FFC8), Color(0xFFFF6B35), Color(0xFFA78BFA),
  ];

  @override
  Widget build(BuildContext context) {
    final sensors = SensorsProvider.of(context)?.sensors ?? [];
    final sorted  = [...sensors]..sort((a, b) => a.levelPct.compareTo(b.levelPct));

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: R.maxW(context)),
        child: ListView(
          padding: EdgeInsets.all(R.pad(context)),
          children: [
        // ── Insights ─────────────────────────────────────────
        Container(
          padding: EdgeInsets.all(R.pad(context)),
          decoration: BoxDecoration(
            color: AquaColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AquaColors.border),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('🤖 Predictive Analytics Engine',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 14),
            ...sorted.map((s) => _InsightCard(sensor: s)),
          ]),
        ),
        const SizedBox(height: 16),

        // ── 30-day forecast chart ─────────────────────────────
        Container(
          padding: EdgeInsets.all(R.pad(context)),
          decoration: BoxDecoration(
            color: AquaColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AquaColors.border),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('📅 30-Day Forecast',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 14),
            SizedBox(
              height: 200,
              child: LineChart(LineChartData(
                lineBarsData: sorted.asMap().entries.map((e) {
                  final s = e.value;
                  final color = _colors[e.key % _colors.length];
                  return LineChartBarData(
                    spots: List.generate(30, (j) {
                      final decline = s.status == SensorStatus.critical ? 1.6
                          : s.status == SensorStatus.warning ? 0.8 : 0.25;
                      return FlSpot(j.toDouble(), (s.levelPct - j * decline).clamp(0, 100));
                    }),
                    isCurved: true,
                    color: color,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                    dashArray: [5, 3],
                  );
                }).toList(),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(sideTitles: SideTitles(
                    showTitles: true,
                    interval: 5,
                    getTitlesWidget: (v, _) => Text('+${v.round()}d',
                      style: TextStyle(fontSize: 9, color: AquaColors.muted)),
                  )),
                  leftTitles: AxisTitles(sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, _) => Text('${v.round()}%',
                      style: TextStyle(fontSize: 9, color: AquaColors.muted)),
                    reservedSize: 32,
                  )),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  getDrawingHorizontalLine: (_) =>
                    FlLine(color: AquaColors.border, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
              )),
            ),
          ]),
        ),
        const SizedBox(height: 16),

        // ── Shortage probability bars ─────────────────────────
        Container(
          padding: EdgeInsets.all(R.pad(context)),
          decoration: BoxDecoration(
            color: AquaColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AquaColors.border),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('🎯 Shortage Probability',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 14),
            ...sorted.map((s) {
              final prob  = (100 - s.levelPct).clamp(0, 100);
              final color = prob > 70 ? AquaColors.danger
                  : prob > 40 ? AquaColors.warn : AquaColors.accent2;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(s.name, style: const TextStyle(fontSize: 12)),
                    Text('${prob.round()}%',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
                  ]),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: prob / 100,
                      backgroundColor: AquaColors.border,
                      valueColor: AlwaysStoppedAnimation(color),
                      minHeight: 8,
                    ),
                  ),
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

class _InsightCard extends StatelessWidget {
  final SensorModel sensor;
  const _InsightCard({required this.sensor});

  @override
  Widget build(BuildContext context) {
    final bad  = sensor.status == SensorStatus.critical;
    final med  = sensor.status == SensorStatus.warning;
    final color = sensor.status.color;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          bad ? '⚠️ Shortage Risk — ${sensor.name}'
              : med ? '📉 Declining — ${sensor.name}'
              : '✅ Stable — ${sensor.name}',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: color),
        ),
        const SizedBox(height: 6),
        Text(
          '${sensor.location} · Current: ${sensor.levelPct.round()}% (${sensor.volumeM3.round()} m³). '
          '${bad ? 'Estimated ${sensor.daysLeft} days until depletion. Immediate action required.'
            : med ? 'Declining. Will reach critical in ~${sensor.daysLeft * 2} days.'
            : 'Sufficient for ~${sensor.daysLeft} days at current usage.'}',
          style: TextStyle(fontSize: 12, color: AquaColors.muted),
        ),
        const SizedBox(height: 8),
        // Confidence bar
        Row(children: [
          Text('Confidence', style: TextStyle(fontSize: 11, color: AquaColors.muted)),
          const SizedBox(width: 8),
          Expanded(child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: 0.82,
              backgroundColor: AquaColors.border,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          )),
          const SizedBox(width: 8),
          Text('82%', style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w700)),
        ]),
      ]),
    );
  }
}