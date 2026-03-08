// screens/alerts_screen.dart

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../models/sensor_model.dart';
import '../widgets/stat_card.dart';
import 'main_shell.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sensors = SensorsProvider.of(context)?.sensors ?? [];

    final alerts = <_Alert>[];
    for (final s in sensors) {
      if (!s.online) {
        alerts.add(_Alert(
          type: 'danger', icon: '⚡',
          title: 'Sensor Offline: ${s.name}',
          body: 'Last level: ${s.levelPct.round()}%. Manual check needed.',
          time: s.timeSince, sensor: s,
        ));
      } else if (s.status == SensorStatus.critical) {
        alerts.add(_Alert(
          type: 'danger', icon: '🚨',
          title: 'CRITICAL: ${s.name} — ${s.levelPct.round()}%',
          body: 'Below 20% threshold. ~${s.daysLeft} days to depletion.',
          time: s.timeSince, sensor: s,
        ));
      } else if (s.status == SensorStatus.warning) {
        alerts.add(_Alert(
          type: 'warn', icon: '⚠️',
          title: 'Warning: ${s.name} — ${s.levelPct.round()}%',
          body: 'Below 40% threshold. Monitor closely.',
          time: s.timeSince, sensor: s,
        ));
      }
    }

    final critCount  = alerts.where((a) => a.type == 'danger').length;
    final warnCount  = alerts.where((a) => a.type == 'warn').length;
    final normalCount = sensors.where((s) => s.status == SensorStatus.ok).length;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: R.maxW(context)),
        child: ListView(
          padding: EdgeInsets.all(R.pad(context)),
          children: [

            // ── Stats ───────────────────────────────────────────
            GridView.count(
              crossAxisCount: R.statCols(context),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10, mainAxisSpacing: 10,
              childAspectRatio: R.isDesktop(context) ? 1.8 : 1.5,
              children: [
                StatCard(label: '🔴 Critical', value: '$critCount',  color: AquaColors.danger),
                StatCard(label: '🟡 Warnings', value: '$warnCount',  color: AquaColors.warn),
                StatCard(label: '🔵 Info',     value: '0',           color: AquaColors.accent),
                StatCard(label: '✅ Normal',   value: '$normalCount', color: AquaColors.accent2),
              ],
            ),
            const SizedBox(height: 18),

            // ── Alert feed ───────────────────────────────────────
            if (alerts.isEmpty)
              Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: AquaColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AquaColors.border),
                ),
                child: Column(children: [
                  const Text('✅', style: TextStyle(fontSize: 40)),
                  const SizedBox(height: 10),
                  Text('All sensors normal',
                    style: TextStyle(color: AquaColors.muted, fontSize: 14)),
                ]),
              )
            else
              ...alerts.map((a) => _AlertCard(alert: a)),
          ],
        ),
      ),
    );
  }
}

// ── Data model ────────────────────────────────────────────
class _Alert {
  final String type, icon, title, body, time;
  final SensorModel sensor;
  const _Alert({
    required this.type, required this.icon, required this.title,
    required this.body, required this.time, required this.sensor,
  });
}

// ── Alert card widget ─────────────────────────────────────
class _AlertCard extends StatelessWidget {
  final _Alert alert;
  const _AlertCard({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    final isDanger = alert.type == 'danger';
    final color    = isDanger ? AquaColors.danger : AquaColors.warn;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(alert.icon, style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(alert.title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(alert.body,
            style: TextStyle(fontSize: 12, color: AquaColors.muted, height: 1.5)),
          const SizedBox(height: 6),
          Text(alert.time,
            style: TextStyle(fontSize: 10, color: AquaColors.muted)),
        ])),
      ]),
    );
  }
}