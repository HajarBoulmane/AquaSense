// screens/settings_screen.dart

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../services/firebase_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _critical = 20;
  double _warning  = 40;
  String _lang     = 'en';
  bool _smsAlerts  = true;
  bool _emailReports = true;
  bool _pushNotifs = true;
  bool _aiPredictions = true;
  bool _weatherIntegration = false;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: R.maxW(context)),
        child: ListView(
          padding: EdgeInsets.all(R.pad(context)),
      children: [

        // ── Thresholds ─────────────────────────────────────────
        _section('🔔 Alert Thresholds', [
          _sliderRow('Critical threshold', _critical, 5, 60, AquaColors.danger,
            (v) => setState(() => _critical = v)),
          _sliderRow('Warning threshold', _warning, 10, 80, AquaColors.warn,
            (v) => setState(() => _warning = v)),
        ]),
        const SizedBox(height: 14),

        // ── Notifications ───────────────────────────────────────
        _section('📡 Notifications', [
          _toggleRow('SMS Alerts',        'SMS on critical events',      _smsAlerts,         (v) => setState(() => _smsAlerts = v)),
          _toggleRow('Email Reports',     'Daily summary to authorities', _emailReports,      (v) => setState(() => _emailReports = v)),
          _toggleRow('Push Notifications','In-app alerts',               _pushNotifs,        (v) => setState(() => _pushNotifs = v)),
        ]),
        const SizedBox(height: 14),

        // ── Language ────────────────────────────────────────────
        _section('🌍 Language', [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: DropdownButton<String>(
              value: _lang,
              dropdownColor: AquaColors.surface2,
              isExpanded: true,
              underline: Container(height: 1, color: AquaColors.border),
              items: const [
                DropdownMenuItem(value: 'en', child: Text('🇬🇧 English')),
                DropdownMenuItem(value: 'fr', child: Text('🇫🇷 Français')),
                DropdownMenuItem(value: 'ar', child: Text('🇲🇦 العربية')),
              ],
              onChanged: (v) => setState(() => _lang = v!),
            ),
          ),
        ]),
        const SizedBox(height: 14),

        // ── AI & Data ───────────────────────────────────────────
        _section('🤖 AI & Data', [
          _toggleRow('AI Predictions',      'Forecasting from sensor data', _aiPredictions,      (v) => setState(() => _aiPredictions = v)),
          _toggleRow('Weather Integration', 'OpenWeatherMap',               _weatherIntegration, (v) => setState(() => _weatherIntegration = v)),
          _toggleRow('Firebase Sync',       'Real-time RTDB',               true,                null),
        ]),
        const SizedBox(height: 14),

        // ── Firebase info ────────────────────────────────────────
        _section('🔥 Firebase', [
          _infoRow('Project',  'aquasense-58345'),
          _infoRow('Region',   'europe-west1'),
          _infoRow('Status',   '● Connected'),
        ]),
        const SizedBox(height: 24),

        // Save button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AquaColors.accent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _saving ? null : _save,
            child: _saving
              ? const SizedBox(width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
              : const Text('💾 Save Settings to Firebase',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          ),
        ),
        ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await FirebaseService().saveSettings(
      criticalThreshold: _critical.round(),
      warningThreshold:  _warning.round(),
      language:          _lang,
    );
    setState(() => _saving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✅ Settings saved to Firebase!'),
          backgroundColor: AquaColors.accent2.withOpacity(0.9),
        ),
      );
    }
  }

  Widget _section(String title, List<Widget> children) => Container(
    padding: EdgeInsets.all(R.pad(context)),
    decoration: BoxDecoration(
      color: AquaColors.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AquaColors.border),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
      const SizedBox(height: 12),
      ...children,
    ]),
  );

  Widget _sliderRow(String label, double value, double min, double max,
      Color color, ValueChanged<double> onChanged) =>
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(fontSize: 13)),
        Text('${value.round()}%', style: TextStyle(color: color, fontWeight: FontWeight.w700)),
      ]),
      Slider(
        value: value, min: min, max: max,
        activeColor: color,
        inactiveColor: AquaColors.border,
        onChanged: onChanged,
      ),
    ]);

  Widget _toggleRow(String title, String subtitle, bool value,
      ValueChanged<bool>? onChanged) =>
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,    style: const TextStyle(fontSize: 13)),
          Text(subtitle, style: TextStyle(fontSize: 11, color: AquaColors.muted)),
        ])),
        Switch(
          value: value,
          activeColor: AquaColors.accent,
          onChanged: onChanged,
        ),
      ]),
    );

  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: TextStyle(fontSize: 12, color: AquaColors.muted)),
      Text(value,  style: TextStyle(fontSize: 12, color: AquaColors.accent, fontWeight: FontWeight.w600)),
    ]),
  );
}