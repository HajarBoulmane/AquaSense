// models/sensor_model.dart

class SensorModel {
  final String id;
  final String name;
  final String type;       // well | reservoir | tank
  final String location;
  final double? lat;
  final double? lon;
  final double levelPct;
  final double volumeM3;
  final double capacityM3;
  final double? tempC;
  final double? ph;
  final bool online;
  final int lastTs;        // Unix timestamp

  const SensorModel({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    this.lat,
    this.lon,
    required this.levelPct,
    required this.volumeM3,
    required this.capacityM3,
    this.tempC,
    this.ph,
    required this.online,
    required this.lastTs,
  });

  factory SensorModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return SensorModel(
      id:         id,
      name:       map['name']     as String? ?? id,
      type:       map['type']     as String? ?? 'well',
      location:   map['location'] as String? ?? '—',
      lat:        (map['lat']  as num?)?.toDouble(),
      lon:        (map['lon']  as num?)?.toDouble(),
      levelPct:   (map['level_pct']  as num?)?.toDouble() ?? 0,
      volumeM3:   (map['volume_m3']  as num?)?.toDouble() ?? 0,
      capacityM3: (map['capacity_m3'] as num?)?.toDouble() ?? 400,
      tempC:      (map['temp_c'] as num?)?.toDouble(),
      ph:         (map['ph']    as num?)?.toDouble(),
      online:     map['online'] as bool? ?? false,
      lastTs:     (map['last_ts'] as num?)?.toInt() ?? 0,
    );
  }

  SensorStatus get status {
    if (!online) return SensorStatus.offline;
    if (levelPct <= 20) return SensorStatus.critical;
    if (levelPct <= 40) return SensorStatus.warning;
    return SensorStatus.ok;
  }

  int get daysLeft {
    final vol = volumeM3 > 0 ? volumeM3 : (levelPct / 100) * capacityM3;
    return (vol / 34).round().clamp(1, 999);
  }

  String get timeSince {
    final secs = (DateTime.now().millisecondsSinceEpoch / 1000 - lastTs).round();
    if (secs < 60)   return 'just now';
    if (secs < 3600) return '${(secs / 60).floor()}m ago';
    return '${(secs / 3600).floor()}h ago';
  }
}

enum SensorStatus { ok, warning, critical, offline }
