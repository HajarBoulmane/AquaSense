// screens/sensor_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../models/sensor_model.dart';

class SensorDetailScreen extends StatelessWidget {
  final SensorModel sensor;
  const SensorDetailScreen({super.key, required this.sensor});

  @override
  Widget build(BuildContext context) {
    final color = sensor.status.color;
    final pct   = sensor.levelPct.round();

    return Scaffold(
      backgroundColor: AquaColors.bg,
      appBar: AppBar(
        backgroundColor: AquaColors.surface,
        title: Text(sensor.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ── Status header ─────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Row(children: [
              Icon(sensor.status.icon, color: color, size: 40),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(sensor.name,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                Text('📍 ${sensor.location} · ${sensor.type}',
                  style: TextStyle(fontSize: 12, color: AquaColors.muted)),
                const SizedBox(height: 4),
                Text(sensor.status.label,
                  style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w700)),
              ])),
              Text('$pct%',
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: color)),
            ]),
          ),
          const SizedBox(height: 16),

          // ── Metrics grid ──────────────────────────────────────
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.1,
            children: [
              _MetricBox('Volume',   '${sensor.volumeM3.round()} m³',  AquaColors.accent),
              _MetricBox('Capacity', '${sensor.capacityM3.round()} m³', AquaColors.muted),
              _MetricBox('Days Left','${sensor.daysLeft}d',             AquaColors.warn),
              _MetricBox('Temp',     sensor.tempC != null ? '${sensor.tempC!.toStringAsFixed(1)}°C' : '—', AquaColors.warn),
              _MetricBox('pH',       sensor.ph != null ? sensor.ph!.toStringAsFixed(2) : '—', AquaColors.accent2),
              _MetricBox('Updated',  sensor.timeSince, AquaColors.muted),
            ],
          ),
          const SizedBox(height: 16),

          // ── Level gauge ───────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AquaColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AquaColors.border),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('💧 Water Level',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: pct / 100,
                  backgroundColor: AquaColors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 20,
                ),
              ),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('0%',  style: TextStyle(fontSize: 11, color: AquaColors.muted)),
                Text('$pct%', style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w700)),
                Text('100%', style: TextStyle(fontSize: 11, color: AquaColors.muted)),
              ]),
            ]),
          ),
          const SizedBox(height: 16),

          // ── Mini forecast chart ───────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AquaColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AquaColors.border),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('📉 30-Day Depletion Forecast',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 14),
              SizedBox(
                height: 140,
                child: LineChart(LineChartData(
                  lineBarsData: [LineChartBarData(
                    spots: List.generate(30, (j) {
                      final rate = sensor.status == SensorStatus.critical ? 1.6
                          : sensor.status == SensorStatus.warning ? 0.8 : 0.25;
                      return FlSpot(j.toDouble(), (sensor.levelPct - j * rate).clamp(0, 100));
                    }),
                    isCurved: true,
                    color: color,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, color: color.withOpacity(0.05)),
                    dashArray: [5, 3],
                  )],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(sideTitles: SideTitles(
                      showTitles: true, interval: 5,
                      getTitlesWidget: (v, _) => Text('+${v.round()}d',
                        style: TextStyle(fontSize: 9, color: AquaColors.muted)),
                    )),
                    leftTitles: AxisTitles(sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) => Text('${v.round()}%',
                        style: TextStyle(fontSize: 9, color: AquaColors.muted)),
                      reservedSize: 30,
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
            ]),
          ),
        ],
      ),
    );
  }
}

class _MetricBox extends StatelessWidget {
  final String label, value;
  final Color color;
  const _MetricBox(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AquaColors.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AquaColors.border),
    ),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(label,  style: TextStyle(fontSize: 10, color: AquaColors.muted)),
      const SizedBox(height: 6),
      Text(value,  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: color)),
    ]),
  );
}
