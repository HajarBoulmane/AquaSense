// screens/weather_screen.dart

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});
  @override State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String _selectedCity = 'Casablanca';

  final _cities = const [
    {'name': 'Casablanca',  'lat': 33.57, 'lon': -7.59,  'region': 'Casablanca-Settat',  'type': 'coastal'},
    {'name': 'Marrakech',   'lat': 31.63, 'lon': -7.98,  'region': 'Marrakech-Safi',     'type': 'semiarid'},
    {'name': 'Rabat',       'lat': 34.01, 'lon': -6.83,  'region': 'Rabat-Salé-Kénitra', 'type': 'coastal'},
    {'name': 'Fès',         'lat': 34.02, 'lon': -5.01,  'region': 'Fès-Meknès',         'type': 'semiarid'},
    {'name': 'Agadir',      'lat': 30.43, 'lon': -9.60,  'region': 'Souss-Massa',        'type': 'coastal'},
    {'name': 'Ouarzazate',  'lat': 30.93, 'lon': -6.94,  'region': 'Drâa-Tafilalet',     'type': 'desert'},
    {'name': 'Laâyoune',    'lat': 27.15, 'lon': -13.20, 'region': 'Laâyoune-Sakia',     'type': 'desert'},
    {'name': 'Dakhla',      'lat': 23.68, 'lon': -15.96, 'region': 'Dakhla-Oued Dahab',  'type': 'desert'},
    {'name': 'Tanger',      'lat': 35.76, 'lon': -5.83,  'region': 'Tanger-Tétouan',     'type': 'coastal'},
    {'name': 'Ifrane',      'lat': 33.52, 'lon': -5.11,  'region': 'Fès-Meknès',         'type': 'mountain'},
  ];

  Map<String, dynamic> _getSimulatedWeather(String type) {
    switch (type) {
      case 'desert':   return {'base': 34, 'rains': [0,0,0,0.2,0,0,0],   'icons': ['☀️','☀️','☀️','🌤️','☀️','☀️','☀️']};
      case 'coastal':  return {'base': 22, 'rains': [0,2,8,0,3,18,4],   'icons': ['🌤️','⛅','🌦️','☀️','⛅','🌧️','⛅']};
      case 'mountain': return {'base': 14, 'rains': [2,10,22,5,0,3,8],  'icons': ['⛅','🌦️','🌧️','⛅','☀️','🌤️','⛅']};
      default:         return {'base': 26, 'rains': [0,1,5,0,2,10,2],   'icons': ['☀️','🌤️','⛅','☀️','🌤️','🌦️','🌤️']};
    }
  }

  @override
  Widget build(BuildContext context) {
    final city    = _cities.firstWhere((c) => c['name'] == _selectedCity);
    final weather = _getSimulatedWeather(city['type'] as String);
    final rains   = (weather['rains'] as List).cast<num>();
    final icons   = (weather['icons'] as List).cast<String>();
    final base    = weather['base'] as int;
    final total   = rains.fold(0.0, (a, b) => a + b);
    final days    = ['TODAY','MON','TUE','WED','THU','FRI','SAT'];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // City selector
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AquaColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AquaColors.border),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('🌦️ $_selectedCity, Morocco',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            Text(city['region'] as String,
              style: TextStyle(fontSize: 12, color: AquaColors.muted)),
            const SizedBox(height: 14),

            // City chips
            Wrap(spacing: 8, runSpacing: 8,
              children: _cities.map((c) {
                final name = c['name'] as String;
                final active = name == _selectedCity;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCity = name),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: active ? AquaColors.accent.withOpacity(0.15) : AquaColors.surface2,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: active ? AquaColors.accent : AquaColors.border),
                    ),
                    child: Text(name,
                      style: TextStyle(
                        fontSize: 12,
                        color: active ? AquaColors.accent : AquaColors.muted,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                      )),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // 7-day forecast row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(7, (i) {
                  final temp = base + (i == 0 ? 0 : (i % 3 - 1) * 2);
                  return Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: i == 0
                        ? AquaColors.accent.withOpacity(0.1)
                        : AquaColors.surface2,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: i == 0 ? AquaColors.accent : AquaColors.border),
                    ),
                    child: Column(children: [
                      Text(days[i],
                        style: TextStyle(
                          fontSize: 10,
                          color: i == 0 ? AquaColors.accent : AquaColors.muted,
                          fontWeight: FontWeight.w700,
                        )),
                      const SizedBox(height: 6),
                      Text(icons[i], style: const TextStyle(fontSize: 22)),
                      const SizedBox(height: 6),
                      Text('$temp°C',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text('💧 ${rains[i]}mm',
                        style: TextStyle(fontSize: 10, color: AquaColors.accent)),
                    ]),
                  );
                }),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 16),

        // Water impact card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AquaColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AquaColors.accent.withOpacity(0.2)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('💧 Impact on Water Resources',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 10),
            Text(
              '7-day forecast for $_selectedCity: ${total.toStringAsFixed(1)}mm total rainfall. '
              'Estimated groundwater recharge: ~${(total * 1.8).round()} m³ across monitored wells.',
              style: TextStyle(fontSize: 13, color: AquaColors.muted, height: 1.5),
            ),
          ]),
        ),
      ],
    );
  }
}
