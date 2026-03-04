// screens/map_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../theme/app_theme.dart';
import '../models/sensor_model.dart';
import '../widgets/stat_card.dart';
import 'main_shell.dart';
import 'sensor_detail_screen.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sensors = SensorsProvider.of(context)?.sensors ?? [];
    final withCoords = sensors.where((s) => s.lat != null && s.lon != null).toList();

    return Column(children: [
      // ── Map ──────────────────────────────────────────────────
      Expanded(
        flex: 3,
        child: FlutterMap(
          options: MapOptions(
initialCenter: LatLng(31.5, -7.0),            initialZoom: 5.5,
            minZoom: 4,
            maxZoom: 14,
          ),
          children: [
            // OpenStreetMap tiles
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.aquasense.app',
            ),

            // Sensor markers
            MarkerLayer(
              markers: withCoords.map((s) {
                final color = s.status.color;
                final pct   = s.levelPct.round();
                return Marker(
                  point: LatLng(s.lat!, s.lon!),
                  width: 70,
                  height: 80,
                  child: GestureDetector(
                    onTap: () => _showSensorPopup(context, s),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Pin head
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(color: color, width: 3),
                            boxShadow: [
                              BoxShadow(color: color.withOpacity(0.5), blurRadius: 12),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('💧', style: TextStyle(fontSize: 16)),
                              Text('$pct%',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: color,
                                )),
                            ],
                          ),
                        ),
                        // Pin stem
                        Container(width: 3, height: 10, color: color),
                        // Pin dot
                        Container(
                          width: 8, height: 4,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),

      // ── Stats below map ───────────────────────────────────────
      Container(
        color: AquaColors.bg,
        padding: const EdgeInsets.all(12),
        child: GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.3,
          children: [
            StatCard(label: '📡 Online',  value: '${sensors.where((s) => s.online).length}',  color: AquaColors.accent),
            StatCard(label: '⚡ Offline', value: '${sensors.where((s) => !s.online).length}', color: AquaColors.warn),
            StatCard(label: '🚨 Critical',value: '${sensors.where((s) => s.status == SensorStatus.critical).length}', color: AquaColors.danger),
            StatCard(label: '🌍 Total',   value: '${sensors.length}', color: AquaColors.accent2),
          ],
        ),
      ),
    ]);
  }

  void _showSensorPopup(BuildContext context, SensorModel s) {
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
            _infoBox('Level',  '${s.levelPct.round()}%', color),
            const SizedBox(width: 10),
            _infoBox('Volume', '${s.volumeM3.round()} m³', AquaColors.accent),
            const SizedBox(width: 10),
            _infoBox('Temp',   s.tempC != null ? '${s.tempC!.toStringAsFixed(1)}°C' : '—', AquaColors.warn),
            const SizedBox(width: 10),
            _infoBox('pH',     s.ph != null ? s.ph!.toStringAsFixed(1) : '—', AquaColors.accent2),
          ]),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AquaColors.accent,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(context,
                  MaterialPageRoute(builder: (_) => SensorDetailScreen(sensor: s)));
              },
              child: const Text('View Details →', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _infoBox(String label, String val, Color color) {
    return Expanded(child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AquaColors.surface2,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(children: [
        Text(label, style: TextStyle(fontSize: 10, color: AquaColors.muted)),
        const SizedBox(height: 4),
        Text(val, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
      ]),
    ));
  }
}
