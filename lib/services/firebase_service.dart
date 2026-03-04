// services/firebase_service.dart

import 'package:firebase_database/firebase_database.dart';
import '../models/sensor_model.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final _db = FirebaseDatabase.instance;

  // ── Stream of all sensors (live updates) ──────────────────
  Stream<List<SensorModel>> sensorsStream() {
    return _db.ref('sensors').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      return data.entries
          .map((e) => SensorModel.fromMap(e.key as String, e.value as Map))
          .toList()
        ..sort((a, b) => a.levelPct.compareTo(b.levelPct));
    });
  }

  // ── Save settings ──────────────────────────────────────────
  Future<void> saveSettings({
    required int criticalThreshold,
    required int warningThreshold,
    required String language,
  }) async {
    await _db.ref('settings').set({
      'thresholds': {
        'critical': criticalThreshold,
        'warning':  warningThreshold,
      },
      'language':  language,
      'updatedAt': DateTime.now().millisecondsSinceEpoch ~/ 1000,
    });
  }

  // ── Push notification to Firebase ─────────────────────────
  Future<void> notifyAuthorities(String message) async {
    await _db.ref('notifications').push().set({
      'message':      message,
      'sentAt':       DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'type':         'authority',
      'acknowledged': false,
    });
  }
}
