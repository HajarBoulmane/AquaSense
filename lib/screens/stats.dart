import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/water_model.dart';
import '../services/firebase_service.dart';

class StatsScreen extends StatelessWidget {
  final FirebaseService service;
  const StatsScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<WaterSource>>(
      stream: service.watchWaterSources(),
      builder: (context, snap) {
        final sources = snap.data ?? [];
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _LevelDistributionChart(sources: sources),
            const SizedBox(height: 20),
            _SourceStatusTable(sources: sources),
          ],
        );
      },
    );
  }
}

class _LevelDistributionChart extends StatelessWidget {
  final List<WaterSource> sources;
  const _LevelDistributionChart({required this.sources});

  @override
  Widget build(BuildContext context) {
    final critical = sources.where((s) => s.levelPercent < 20).length;
    final low = sources.where((s) => s.levelPercent >= 20 && s.levelPercent < 50).length;
    final good = sources.where((s) => s.levelPercent >= 50).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1F38),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Répartition des niveaux',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: good.toDouble(),
                    color: Colors.green,
                    title: 'Bon\n$good',
                    titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  PieChartSectionData(
                    value: low.toDouble(),
                    color: Colors.orange,
                    title: 'Bas\n$low',
                    titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  PieChartSectionData(
                    value: critical.toDouble(),
                    color: Colors.red,
                    title: 'Critique\n$critical',
                    titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceStatusTable extends StatelessWidget {
  final List<WaterSource> sources;
  const _SourceStatusTable({required this.sources});

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
          const Text(
            'Toutes les sources',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...sources.map((s) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(s.name, style: const TextStyle(color: Colors.white70)),
                ),
                Text(
                  '${s.levelPercent.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: s.levelPercent < 20
                        ? Colors.red
                        : s.levelPercent < 50
                        ? Colors.orange
                        : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}