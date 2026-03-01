import 'package:flutter/material.dart';
import '../models/water_model.dart';
import '../services/firebase_service.dart';

class AlertsScreen extends StatelessWidget {
  final FirebaseService service;
  const AlertsScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<WaterAlert>>(
      stream: service.watchAlerts(),
      builder: (context, snap) {
        final alerts = snap.data ?? [];
        if (alerts.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 60),
                SizedBox(height: 12),
                Text('Aucune alerte', style: TextStyle(color: Colors.white54)),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: alerts.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) => _AlertTile(alert: alerts[i], service: service),
        );
      },
    );
  }
}

class _AlertTile extends StatelessWidget {
  final WaterAlert alert;
  final FirebaseService service;

  const _AlertTile({required this.alert, required this.service});

  Color get _color {
    switch (alert.level) {
      case AlertLevel.critical:
        return Colors.red;
      case AlertLevel.warning:
        return Colors.orange;
      case AlertLevel.info:
        return const Color(0xFF00B4D8);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(alert.id),
      onDismissed: (_) => service.markAlertRead(alert.id),
      background: Container(
        color: Colors.green,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.check, color: Colors.white),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: alert.isRead
              ? const Color(0xFF0D1F38)
              : _color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: alert.isRead ? Colors.white12 : _color.withOpacity(0.4),
          ),
        ),
        child: Row(
          children: [
            Icon(
              alert.level == AlertLevel.critical
                  ? Icons.error
                  : alert.level == AlertLevel.warning
                  ? Icons.warning_amber
                  : Icons.info_outline,
              color: _color,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.message,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(alert.timestamp),
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (!alert.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}