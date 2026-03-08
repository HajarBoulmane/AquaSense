// screens/settings_screen.dart

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../utils/lang.dart';
import '../services/firebase_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _critical = 20;
  double _warning  = 40;
  bool _smsAlerts         = true;
  bool _emailReports      = true;
  bool _pushNotifs        = true;
  bool _aiPredictions     = true;
  bool _weatherIntegration = false;

  // Auto-save debounce
  void _autoSave() {
    FirebaseService().saveSettings(
      criticalThreshold: _critical.round(),
      warningThreshold:  _warning.round(),
      language:          langNotifier.lang,
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = LangProvider.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: R.maxW(context)),
        child: ListView(
          padding: EdgeInsets.all(R.pad(context)),
          children: [

            // ── Alert Thresholds ──────────────────────────────
            _section(lang.t('alertThresholds'), [
              _sliderRow(lang.t('critThreshold'), _critical, 5, 60, AquaColors.danger,
                (v) { setState(() => _critical = v); _autoSave(); }),
              _sliderRow(lang.t('warnThreshold'), _warning, 10, 80, AquaColors.warn,
                (v) { setState(() => _warning = v); _autoSave(); }),
            ]),
            const SizedBox(height: 14),

            // ── Notifications ─────────────────────────────────
            _section(lang.t('notifications'), [
              _toggleRow(lang.t('smsAlerts'),   lang.t('smsDesc'),   _smsAlerts,
                (v) { setState(() => _smsAlerts = v); _autoSave(); }),
              _toggleRow(lang.t('emailReports'), lang.t('emailDesc'), _emailReports,
                (v) { setState(() => _emailReports = v); _autoSave(); }),
              _toggleRow(lang.t('pushNotifs'),   lang.t('pushDesc'),  _pushNotifs,
                (v) { setState(() => _pushNotifs = v); _autoSave(); }),
            ]),
            const SizedBox(height: 14),

            // ── Language ──────────────────────────────────────
            _section(lang.t('language'), [
              const SizedBox(height: 6),
              Row(children: [
                _langChip('🇬🇧', 'English', 'en', lang),
                const SizedBox(width: 10),
                _langChip('🇫🇷', 'Français', 'fr', lang),
                const SizedBox(width: 10),
                _langChip('🇲🇦', 'العربية', 'ar', lang),
              ]),
              const SizedBox(height: 6),
            ]),
            const SizedBox(height: 14),

            // ── AI & Data ─────────────────────────────────────
            _section(lang.t('aiData'), [
              _toggleRow(lang.t('aiPred'),    lang.t('aiPredDesc'),      _aiPredictions,
                (v) { setState(() => _aiPredictions = v); _autoSave(); }),
              _toggleRow(lang.t('weatherInt'), lang.t('weatherIntDesc'), _weatherIntegration,
                (v) { setState(() => _weatherIntegration = v); _autoSave(); }),
              _toggleRow(lang.t('firebaseSync'), lang.t('firebaseSyncDesc'), true, null),
            ]),
          ],
        ),
      ),
    );
  }

  // ── Language chip ────────────────────────────────────
  Widget _langChip(String flag, String label, String code, LangNotifier lang) {
    final active = lang.lang == code;
    return Expanded(child: GestureDetector(
      onTap: () {
        langNotifier.setLang(code);
        _autoSave();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? AquaColors.accent.withOpacity(0.15) : AquaColors.surface2,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active ? AquaColors.accent : AquaColors.border,
            width: active ? 2 : 1),
        ),
        child: Column(children: [
          Text(flag, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w600,
            color: active ? AquaColors.accent : AquaColors.muted)),
        ]),
      ),
    ));
  }

  Widget _section(String title, List<Widget> children) => Container(
    padding: EdgeInsets.all(R.pad(context)),
    decoration: BoxDecoration(
      color: AquaColors.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AquaColors.border)),
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
        Text('${value.round()}%',
          style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13)),
      ]),
      Slider(value: value, min: min, max: max,
        activeColor: color, inactiveColor: AquaColors.border,
        onChanged: onChanged),
    ]);

  Widget _toggleRow(String title, String subtitle, bool value,
      ValueChanged<bool>? onChanged) =>
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 13)),
          Text(subtitle, style: TextStyle(fontSize: 11, color: AquaColors.muted)),
        ])),
        Switch(value: value, activeColor: AquaColors.accent, onChanged: onChanged),
      ]),
    );
}