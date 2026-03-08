// utils/lang.dart
// ─────────────────────────────────────────────────────────
// Simple app-wide language system. Wrap your app with
// LangProvider and call Lang.of(context).t('key') anywhere.
// ─────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

// ── All translated strings ────────────────────────────────
const _strings = {
  'en': {
    'dashboard':       'Dashboard',
    'mapView':         'Map View',
    'wellsTanks':      'Wells & Tanks',
    'alerts':          'Alerts',
    'aiPredictions':   'AI Predictions',
    'weather':         'Weather',
    'history':         'History',
    'settings':        'Settings',
    'totalWater':      'Total Water',
    'sensorsOnline':   'Sensors Online',
    'criticalWells':   'Critical Wells',
    'warnings':        'Warnings',
    'levelOverview':   'Level Overview',
    'allPoints':       'All Monitored Points',
    'connecting':      'Connecting to Firebase…',
    'critical':        'Critical',
    'warning':         'Warning',
    'normal':          'Normal',
    'offline':         'Offline',
    'online':          'Online',
    'allNormal':       'All sensors normal',
    'waterLevel':      'Water Level',
    'volume':          'Volume',
    'capacity':        'Capacity',
    'daysLeft':        'Days Left',
    'temp':            'Temp',
    'updated':         'Updated',
    'forecast':        '30-Day Depletion Forecast',
    'trend':           'Water Level Trend',
    'eventLog':        'Event Log',
    'accumulatingData':'Accumulating data…',
    'language':        'Language',
    'alertThresholds': 'Alert Thresholds',
    'notifications':   'Notifications',
    'smsAlerts':       'SMS Alerts',
    'smsDesc':         'SMS on critical events',
    'emailReports':    'Email Reports',
    'emailDesc':       'Daily summary to authorities',
    'pushNotifs':      'Push Notifications',
    'pushDesc':        'In-app alerts',
    'aiData':          'AI & Data',
    'aiPred':          'AI Predictions',
    'aiPredDesc':      'Forecasting from sensor data',
    'weatherInt':      'Weather Integration',
    'weatherIntDesc':  'OpenWeatherMap',
    'firebaseSync':    'Firebase Sync',
    'firebaseSyncDesc':'Real-time RTDB',
    'critThreshold':   'Critical threshold',
    'warnThreshold':   'Warning threshold',
    'shortageRisk':    'Shortage Risk',
    'declining':       'Declining',
    'stable':          'Stable',
    'confidence':      'Confidence',
    'shortage30':      '30-Day Forecast',
    'shortageProbability': 'Shortage Probability',
    'viewDetails':     'View Details →',
    'firebaseLive':    '🔥 Firebase Live',
    'moroccoMap':      'Morocco Water Map',
  },
  'fr': {
    'dashboard':       'Tableau de bord',
    'mapView':         'Carte',
    'wellsTanks':      'Puits & Réservoirs',
    'alerts':          'Alertes',
    'aiPredictions':   'Prédictions IA',
    'weather':         'Météo',
    'history':         'Historique',
    'settings':        'Paramètres',
    'totalWater':      'Eau totale',
    'sensorsOnline':   'Capteurs en ligne',
    'criticalWells':   'Puits critiques',
    'warnings':        'Avertissements',
    'levelOverview':   'Aperçu des niveaux',
    'allPoints':       'Tous les points surveillés',
    'connecting':      'Connexion à Firebase…',
    'critical':        'Critique',
    'warning':         'Avertissement',
    'normal':          'Normal',
    'offline':         'Hors ligne',
    'online':          'En ligne',
    'allNormal':       'Tous les capteurs normaux',
    'waterLevel':      'Niveau d\'eau',
    'volume':          'Volume',
    'capacity':        'Capacité',
    'daysLeft':        'Jours restants',
    'temp':            'Temp.',
    'updated':         'Mis à jour',
    'forecast':        'Prévision 30 jours',
    'trend':           'Tendance du niveau d\'eau',
    'eventLog':        'Journal des événements',
    'accumulatingData':'Accumulation de données…',
    'language':        'Langue',
    'alertThresholds': 'Seuils d\'alerte',
    'notifications':   'Notifications',
    'smsAlerts':       'Alertes SMS',
    'smsDesc':         'SMS lors d\'événements critiques',
    'emailReports':    'Rapports e-mail',
    'emailDesc':       'Résumé quotidien aux autorités',
    'pushNotifs':      'Notifications push',
    'pushDesc':        'Alertes dans l\'application',
    'aiData':          'IA & Données',
    'aiPred':          'Prédictions IA',
    'aiPredDesc':      'Prévisions à partir des capteurs',
    'weatherInt':      'Intégration météo',
    'weatherIntDesc':  'OpenWeatherMap',
    'firebaseSync':    'Synchronisation Firebase',
    'firebaseSyncDesc':'Base de données en temps réel',
    'critThreshold':   'Seuil critique',
    'warnThreshold':   'Seuil d\'avertissement',
    'shortageRisk':    'Risque de pénurie',
    'declining':       'En baisse',
    'stable':          'Stable',
    'confidence':      'Confiance',
    'shortage30':      'Prévision 30 jours',
    'shortageProbability': 'Probabilité de pénurie',
    'viewDetails':     'Voir les détails →',
    'firebaseLive':    '🔥 Firebase en direct',
    'moroccoMap':      'Carte de l\'eau au Maroc',
  },
  'ar': {
    'dashboard':       'لوحة القيادة',
    'mapView':         'عرض الخريطة',
    'wellsTanks':      'الآبار والخزانات',
    'alerts':          'التنبيهات',
    'aiPredictions':   'تنبؤات الذكاء الاصطناعي',
    'weather':         'الطقس',
    'history':         'السجل',
    'settings':        'الإعدادات',
    'totalWater':      'إجمالي المياه',
    'sensorsOnline':   'أجهزة الاستشعار المتصلة',
    'criticalWells':   'الآبار الحرجة',
    'warnings':        'التحذيرات',
    'levelOverview':   'نظرة عامة على المستوى',
    'allPoints':       'جميع نقاط المراقبة',
    'connecting':      'جارٍ الاتصال بـ Firebase…',
    'critical':        'حرج',
    'warning':         'تحذير',
    'normal':          'طبيعي',
    'offline':         'غير متصل',
    'online':          'متصل',
    'allNormal':       'جميع أجهزة الاستشعار طبيعية',
    'waterLevel':      'مستوى المياه',
    'volume':          'الحجم',
    'capacity':        'السعة',
    'daysLeft':        'الأيام المتبقية',
    'temp':            'الحرارة',
    'updated':         'تحديث',
    'forecast':        'توقعات 30 يوم',
    'trend':           'اتجاه مستوى المياه',
    'eventLog':        'سجل الأحداث',
    'accumulatingData':'تجميع البيانات…',
    'language':        'اللغة',
    'alertThresholds': 'حدود التنبيه',
    'notifications':   'الإشعارات',
    'smsAlerts':       'تنبيهات SMS',
    'smsDesc':         'رسائل SMS عند الأحداث الحرجة',
    'emailReports':    'تقارير البريد الإلكتروني',
    'emailDesc':       'ملخص يومي للسلطات',
    'pushNotifs':      'إشعارات الدفع',
    'pushDesc':        'تنبيهات داخل التطبيق',
    'aiData':          'الذكاء الاصطناعي والبيانات',
    'aiPred':          'تنبؤات الذكاء الاصطناعي',
    'aiPredDesc':      'التنبؤ من بيانات الاستشعار',
    'weatherInt':      'دمج الطقس',
    'weatherIntDesc':  'OpenWeatherMap',
    'firebaseSync':    'مزامنة Firebase',
    'firebaseSyncDesc':'قاعدة بيانات في الوقت الفعلي',
    'critThreshold':   'الحد الحرج',
    'warnThreshold':   'حد التحذير',
    'shortageRisk':    'خطر النقص',
    'declining':       'في انخفاض',
    'stable':          'مستقر',
    'confidence':      'الثقة',
    'shortage30':      'توقعات 30 يوماً',
    'shortageProbability': 'احتمالية النقص',
    'viewDetails':     'عرض التفاصيل ←',
    'firebaseLive':    '🔥 Firebase مباشر',
    'moroccoMap':      'خريطة المياه في المغرب',
  },
};

// ── Language notifier — holds current language ────────────
class LangNotifier extends ChangeNotifier {
  String _lang = 'en';
  String get lang => _lang;

  void setLang(String l) {
    if (_lang == l) return;
    _lang = l;
    notifyListeners();
  }

  String t(String key) =>
      (_strings[_lang] ?? _strings['en']!)[key] ?? key;

  TextDirection get dir =>
      _lang == 'ar' ? TextDirection.rtl : TextDirection.ltr;
}

// ── Global singleton ──────────────────────────────────────
final langNotifier = LangNotifier();

// ── InheritedWidget wrapper ───────────────────────────────
class LangProvider extends InheritedNotifier<LangNotifier> {
  LangProvider({super.key, required super.child})
      : super(notifier: langNotifier);

  static LangNotifier of(BuildContext context) {
    context.dependOnInheritedWidgetOfExactType<LangProvider>();
    return langNotifier;
  }
}