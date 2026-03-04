// screens/wells_screen.dart

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/sensor_model.dart';
import '../widgets/sensor_list_tile.dart';
import 'main_shell.dart';
import 'sensor_detail_screen.dart';

class WellsScreen extends StatefulWidget {
  const WellsScreen({super.key});
  @override State<WellsScreen> createState() => _WellsScreenState();
}

class _WellsScreenState extends State<WellsScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final all = SensorsProvider.of(context)?.sensors ?? [];
    final sensors = _filter == 'all' ? all
        : all.where((s) => s.type == _filter).toList();

    return Column(children: [
      // Filter chips
      Container(
        color: AquaColors.surface,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            _chip('all',       'All'),
            _chip('well',      '🪣 Wells'),
            _chip('reservoir', '🏊 Reservoirs'),
            _chip('tank',      '🛢 Tanks'),
          ]),
        ),
      ),

      // Sensors list
      Expanded(
        child: sensors.isEmpty
          ? Center(child: Text('No sensors found', style: TextStyle(color: AquaColors.muted)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sensors.length,
              itemBuilder: (_, i) => SensorListTile(
                sensor: sensors[i],
                onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => SensorDetailScreen(sensor: sensors[i]))),
              ),
            ),
      ),
    ]);
  }

  Widget _chip(String value, String label) {
    final active = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? AquaColors.accent.withOpacity(0.15) : AquaColors.surface2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? AquaColors.accent : AquaColors.border),
        ),
        child: Text(label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: active ? FontWeight.w700 : FontWeight.w400,
            color: active ? AquaColors.accent : AquaColors.muted,
          )),
      ),
    );
  }
}
