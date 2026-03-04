// screens/alerts_screen.dart

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/sensor_model.dart';
import '../services/firebase_service.dart';
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

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Stats
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8, mainAxisSpacing: 8,
          childAspectRatio: 1.2,
          children: [
            StatCard(label: '🔴 Critical', value: '${alerts.where((a)=>a.type=='danger').length}', color: AquaColors.danger),
            StatCard(label: '🟡 Warnings', value: '${alerts.where((a)=>a.type=='warn').length}',   color: AquaColors.warn),
            StatCard(label: '🔵 Info',     value: '0',                                              color: AquaColors.accent),
            StatCard(label: '✅ Normal',   value: '${sensors.where((s)=>s.status==SensorStatus.ok).length}', color: AquaColors.accent2),
          ],
        ),
        const SizedBox(height: 16),

        // Alert feed
        if (alerts.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AquaColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AquaColors.border),
            ),
            child: Column(children: [
              const Text('✅', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 8),
              Text('All sensors normal', style: TextStyle(color: AquaColors.muted)),
            ]),
          )
        else
          ...alerts.map((a) => _AlertCard(alert: a)),
      ],
    );
  }
}

class _Alert {
  final String type, icon, title, body, time;
  final SensorModel sensor;
  _Alert({required this.type, required this.icon, required this.title,
          required this.body, required this.time, required this.sensor});
}

class _AlertCard extends StatefulWidget {
  final _Alert alert;
  const _AlertCard({required this.alert});
  @override State<_AlertCard> createState() => _AlertCardState();
}

class _AlertCardState extends State<_AlertCard> {
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();
    final color = widget.alert.type == 'danger' ? AquaColors.danger : AquaColors.warn;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(widget.alert.icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.alert.title,
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: color)),
          const SizedBox(height: 4),
          Text(widget.alert.body, style: TextStyle(fontSize: 12, color: AquaColors.muted)),
          const SizedBox(height: 4),
          Text('🕐 ${widget.alert.time}', style: TextStyle(fontSize: 11, color: AquaColors.muted)),
          const SizedBox(height: 10),
          Row(children: [
            _actionBtn('Acknowledge', AquaColors.accent,
              () => setState(() => _dismissed = true)),
            const SizedBox(width: 8),
            _actionBtn('Notify Authorities', AquaColors.warn, () async {
              await FirebaseService().notifyAuthorities(widget.alert.title);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('📤 Authorities notified!')));
              }
            }),
          ]),
        ])),
      ]),
    );
  }

  Widget _actionBtn(String label, Color color, VoidCallback onTap) =>
    GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w700)),
      ),
    );
}
