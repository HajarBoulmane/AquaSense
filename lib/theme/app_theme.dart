// theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:aqua_sense/models/sensor_model.dart';

export 'package:aqua_sense/models/sensor_model.dart';

class AquaColors {
  static const bg       = Color(0xFF0A1628);
  static const surface  = Color(0xFF0F1F38);
  static const surface2 = Color(0xFF162033);
  static const border   = Color(0xFF1E3050);
  static const accent   = Color(0xFF00B4FF);
  static const accent2  = Color(0xFF00FFC8);
  static const warn     = Color(0xFFFFB830);
  static const danger   = Color(0xFFFF3B5C);
  static const muted    = Color(0xFF5A7A9A);
  static const ok       = Color(0xFF00FFC8);
}

extension SensorStatusColor on SensorStatus {
  Color get color {
    switch (this) {
      case SensorStatus.ok:       return AquaColors.ok;
      case SensorStatus.warning:  return AquaColors.warn;
      case SensorStatus.critical: return AquaColors.danger;
      case SensorStatus.offline:  return AquaColors.muted;
    }
  }

  String get label {
    switch (this) {
      case SensorStatus.ok:       return 'Normal';
      case SensorStatus.warning:  return 'Warning';
      case SensorStatus.critical: return 'Critical';
      case SensorStatus.offline:  return 'Offline';
    }
  }

  IconData get icon {
    switch (this) {
      case SensorStatus.ok:       return Icons.check_circle;
      case SensorStatus.warning:  return Icons.warning_amber;
      case SensorStatus.critical: return Icons.crisis_alert;
      case SensorStatus.offline:  return Icons.wifi_off;
    }
  }
}