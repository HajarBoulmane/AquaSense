// widgets/sensor_list_tile.dart

import 'package:flutter/material.dart';
import '../models/sensor_model.dart';
import '../theme/app_theme.dart';

class SensorListTile extends StatelessWidget {
  final SensorModel sensor;
  final VoidCallback? onTap;

  const SensorListTile({super.key, required this.sensor, this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = sensor.status.color;
    final pct   = sensor.levelPct.round();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AquaColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AquaColors.border),
        ),
        child: Row(children: [
          // Status dot
          Container(
            width: 10, height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 6)],
            ),
          ),
          const SizedBox(width: 12),

          // Name + location
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(sensor.name,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 2),
              Text('📍 ${sensor.location} · ${sensor.type}',
                style: TextStyle(fontSize: 11, color: AquaColors.muted)),
            ],
          )),

          // Progress bar + pct
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('$pct%',
              style: TextStyle(
                fontWeight: FontWeight.w800, fontSize: 15, color: color)),
            const SizedBox(height: 4),
            SizedBox(
              width: 80, height: 5,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: pct / 100,
                  backgroundColor: AquaColors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ),
            const SizedBox(height: 3),
            Text(sensor.timeSince,
              style: TextStyle(fontSize: 10, color: AquaColors.muted)),
          ]),
        ]),
      ),
    );
  }
}
