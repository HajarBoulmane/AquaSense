// screens/map_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../theme/app_theme.dart';
import '../models/sensor_model.dart';
import '../utils/responsive.dart';
import '../utils/lang.dart';
import 'main_shell.dart';
import 'sensor_detail_screen.dart';


class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang    = LangProvider.of(context);
    final sensors = SensorsProvider.of(context)?.sensors ?? [];
    final withCoords = sensors.where((s) => s.lat != null && s.lon != null).toList();

    // Desktop: map left, sensor list right
    if (R.isDesktop(context)) {
      return Row(children: [
        // Map — takes 65% of width
        Expanded(flex: 65, child: _buildMap(context, withCoords, lang)),
        // Sensor list — takes 35%
        Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: AquaColors.border))),
          child: _buildSensorList(context, sensors, lang),
        ),
      ]);
    }

    // Mobile/tablet: map on top, stats below
    return Column(children: [
      Expanded(flex: 3, child: _buildMap(context, withCoords, lang)),
      _buildStatsBar(context, sensors, lang),
    ]);
  }

  // ── Map widget ─────────────────────────────────────────
  Widget _buildMap(BuildContext ctx, List<SensorModel> sensors, LangNotifier lang) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(31.5, -7.0),
        initialZoom: 5.5,
        minZoom: 4,
        maxZoom: 14,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.aquasense.app',
        ),
        MarkerLayer(
          markers: sensors.map((s) {
            final color = s.status.color;
            return Marker(
              point: LatLng(s.lat!, s.lon!),
              width: 70, height: 80,
              child: GestureDetector(
                onTap: () => _showPopup(ctx, s, lang),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: color, width: 3),
                      boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 12)],
                    ),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Text('💧', style: TextStyle(fontSize: 14)),
                      Text('${s.levelPct.round()}%',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: color)),
                    ]),
                  ),
                  Container(width: 3, height: 8, color: color),
                  Container(width: 8, height: 4,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4))),
                ]),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Desktop sensor list panel ──────────────────────────
  Widget _buildSensorList(BuildContext ctx, List<SensorModel> sensors, LangNotifier lang) {
    return SizedBox(
      width: 320,
      child: Column(children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AquaColors.surface,
            border: Border(bottom: BorderSide(color: AquaColors.border))),
          child: Row(children: [
            const Text('📍', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(lang.t('allPoints'),
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AquaColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AquaColors.accent.withOpacity(0.3))),
              child: Text('${sensors.length}',
                style: const TextStyle(fontSize: 12, color: AquaColors.accent, fontWeight: FontWeight.w700)),
            ),
          ]),
        ),
        // Sensor tiles
        Expanded(child: ListView.builder(
          itemCount: sensors.length,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemBuilder: (_, i) {
            final s = sensors[i];
            final color = s.status.color;
            return GestureDetector(
              onTap: () => Navigator.push(ctx,
                MaterialPageRoute(builder: (_) => SensorDetailScreen(sensor: s))),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AquaColors.surface2,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AquaColors.border)),
                child: Row(children: [
                  Container(width: 10, height: 10,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: color,
                      boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 4)])),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(s.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    Text(s.location, style: TextStyle(fontSize: 11, color: AquaColors.muted)),
                  ])),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text('${s.levelPct.round()}%',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
                    Text(s.online ? lang.t('online') : lang.t('offline'),
                      style: TextStyle(fontSize: 10, color: AquaColors.muted)),
                  ]),
                ]),
              ),
            );
          },
        )),
      ]),
    );
  }

  // ── Mobile stats bar ───────────────────────────────────
  Widget _buildStatsBar(BuildContext ctx, List<SensorModel> sensors, LangNotifier lang) {
    final online   = sensors.where((s) => s.online).length;
    final offline  = sensors.where((s) => !s.online).length;
    final critical = sensors.where((s) => s.status == SensorStatus.critical).length;

    return Container(
      color: AquaColors.bg,
      padding: const EdgeInsets.all(12),
      child: Row(children: [
        _statChip('📡 ${lang.t("online")}',  '$online',   AquaColors.accent2),
        const SizedBox(width: 8),
        _statChip('⚡ ${lang.t("offline")}', '$offline',  AquaColors.warn),
        const SizedBox(width: 8),
        _statChip('🚨 ${lang.t("critical")}','$critical', AquaColors.danger),
        const SizedBox(width: 8),
        _statChip('🌍 Total',                '${sensors.length}', AquaColors.accent),
      ]),
    );
  }

  Widget _statChip(String label, String value, Color color) {
    return Expanded(child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.25))),
      child: Column(children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
        Text(label,  style: TextStyle(fontSize: 9, color: AquaColors.muted)),
      ]),
    ));
  }

  // ── Sensor popup ───────────────────────────────────────
  void _showPopup(BuildContext context, SensorModel s, LangNotifier lang) {
    final color = s.status.color;
    showModalBottomSheet(
      context: context,
      backgroundColor: AquaColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            Container(width: 10, height: 10,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
            const SizedBox(width: 10),
            Text(s.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          ]),
          const SizedBox(height: 4),
          Text('📍 ${s.location} · ${s.type}',
            style: TextStyle(fontSize: 12, color: AquaColors.muted)),
          const SizedBox(height: 16),
          Row(children: [
            _infoBox(lang.t('waterLevel'), '${s.levelPct.round()}%', color),
            const SizedBox(width: 10),
            _infoBox(lang.t('volume'),   '${s.volumeM3.round()} m³', AquaColors.accent),
            const SizedBox(width: 10),
            _infoBox(lang.t('temp'),     s.tempC != null ? '${s.tempC!.toStringAsFixed(1)}°C' : '—', AquaColors.warn),
            const SizedBox(width: 10),
            _infoBox('pH',              s.ph != null ? s.ph!.toStringAsFixed(1) : '—', AquaColors.accent2),
          ]),
          const SizedBox(height: 14),
          SizedBox(width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AquaColors.accent,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(context,
                  MaterialPageRoute(builder: (_) => SensorDetailScreen(sensor: s)));
              },
              child: Text(lang.t('viewDetails'),
                style: const TextStyle(fontWeight: FontWeight.w700)),
            )),
        ]),
      ),
    );
  }

  Widget _infoBox(String label, String val, Color color) =>
    Expanded(child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AquaColors.surface2, borderRadius: BorderRadius.circular(10)),
      child: Column(children: [
        Text(label, style: TextStyle(fontSize: 10, color: AquaColors.muted)),
        const SizedBox(height: 4),
        Text(val, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color)),
      ]),
    ));
}