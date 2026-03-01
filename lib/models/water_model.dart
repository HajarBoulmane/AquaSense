class WaterSource {
  final String id;
  final String name;
  final String type; // 'well' | 'reservoir'
  final double levelPercent;   // 0–100
  final double capacityLiters;
  final DateTime lastUpdated;
  final bool isCritical;

  WaterSource({
    required this.id,
    required this.name,
    required this.type,
    required this.levelPercent,
    required this.capacityLiters,
    required this.lastUpdated,
    this.isCritical = false,
  });

  factory WaterSource.fromMap(Map<String, dynamic> map) {
    return WaterSource(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      type: map['type'] ?? 'well',
      levelPercent: (map['levelPercent'] ?? 0).toDouble(),
      capacityLiters: (map['capacityLiters'] ?? 0).toDouble(),
      lastUpdated: DateTime.parse(map['lastUpdated']),
      isCritical: map['isCritical'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'type': type,
    'levelPercent': levelPercent,
    'capacityLiters': capacityLiters,
    'lastUpdated': lastUpdated.toIso8601String(),
    'isCritical': isCritical,
  };
}

class WaterAlert {
  final String id;
  final String sourceId;
  final String message;
  final AlertLevel level;
  final DateTime timestamp;
  final bool isRead;

  WaterAlert({
    required this.id,
    required this.sourceId,
    required this.message,
    required this.level,
    required this.timestamp,
    this.isRead = false,
  });
}

enum AlertLevel { info, warning, critical }

class WeatherPrediction {
  final DateTime date;
  final double rainfallMm;
  final double temperatureC;
  final double droughtRisk; // 0–1

  WeatherPrediction({
    required this.date,
    required this.rainfallMm,
    required this.temperatureC,
    required this.droughtRisk,
  });
}