import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/water_model.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // ── Water Sources ──────────────────────────────────────────────

  Stream<List<WaterSource>> watchWaterSources() {
    return _db.collection('water_sources').snapshots().map(
          (snap) => snap.docs
          .map((d) => WaterSource.fromMap({...d.data(), 'id': d.id}))
          .toList(),
    );
  }

  Future<void> updateWaterLevel(String sourceId, double levelPercent) async {
    await _db.collection('water_sources').doc(sourceId).update({
      'levelPercent': levelPercent,
      'lastUpdated': DateTime.now().toIso8601String(),
      'isCritical': levelPercent < 20,
    });

    if (levelPercent < 20) {
      await _sendCriticalAlert(sourceId, levelPercent);
    }
  }

  // ── Alerts ─────────────────────────────────────────────────────

  Stream<List<WaterAlert>> watchAlerts() {
    return _db
        .collection('alerts')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs.map((d) {
      final data = d.data();
      return WaterAlert(
        id: d.id,
        sourceId: data['sourceId'] ?? '',
        message: data['message'] ?? '',
        level: AlertLevel.values.firstWhere(
              (e) => e.name == data['level'],
          orElse: () => AlertLevel.info,
        ),
        timestamp: DateTime.parse(data['timestamp']),
        isRead: data['isRead'] ?? false,
      );
    }).toList());
  }

  Future<void> markAlertRead(String alertId) async {
    await _db.collection('alerts').doc(alertId).update({'isRead': true});
  }

  Future<void> _sendCriticalAlert(String sourceId, double level) async {
    await _db.collection('alerts').add({
      'sourceId': sourceId,
      'message': 'Niveau critique : ${level.toStringAsFixed(1)}%',
      'level': AlertLevel.critical.name,
      'timestamp': DateTime.now().toIso8601String(),
      'isRead': false,
    });
  }

  // ── Push Notifications ─────────────────────────────────────────

  Future<void> initNotifications() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);
    final token = await _messaging.getToken();
    if (token != null) {
      await _db.collection('fcm_tokens').doc(token).set({
        'token': token,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    FirebaseMessaging.onMessage.listen((message) {
      // Handle foreground messages — show in-app snackbar
    });
  }

  // ── Weather Predictions (mock — replace with real API) ─────────

  Future<List<WeatherPrediction>> fetchWeatherPredictions() async {
    // Replace with actual weather API call (e.g. Open-Meteo)
    return List.generate(7, (i) {
      final random = i * 0.1;
      return WeatherPrediction(
        date: DateTime.now().add(Duration(days: i)),
        rainfallMm: (10 - i * 1.2).clamp(0, 30),
        temperatureC: 28 + i * 0.5,
        droughtRisk: (random + 0.1).clamp(0, 1),
      );
    });
  }
}