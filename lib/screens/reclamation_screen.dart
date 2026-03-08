// screens/reclamation_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';

class ReclamationScreen extends StatefulWidget {
  const ReclamationScreen({super.key});

  @override
  State<ReclamationScreen> createState() => _ReclamationScreenState();
}

class _ReclamationScreenState extends State<ReclamationScreen> {
  final _nameCtrl        = TextEditingController();
  final _phoneCtrl       = TextEditingController();
  final _addressCtrl     = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  String _problemType = 'No Water / Water Cut';
  String _urgency     = 'Medium';
  String _contact     = 'Phone';
  bool   _submitting  = false;

  final _problemTypes = [
    'No Water / Water Cut',
    'Water Leak',
    'Low Pressure',
    'Dirty / Contaminated Water',
    'Bad Smell or Taste',
    'Damaged Pipe',
    'Other',
  ];

  final _urgencyLevels = ['Low', 'Medium', 'Urgent'];
  final _contactMethods = ['Phone', 'Email', 'WhatsApp'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = R.isDesktop(context);

    return Scaffold(
      backgroundColor: AquaColors.bg,
      appBar: AppBar(
        backgroundColor: AquaColors.surface,
        title: const Text('🚨 Submit Reclamation'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isDesktop ? 780 : double.infinity),
          child: ListView(
            padding: EdgeInsets.all(isDesktop ? 32 : 20),
            children: [

              // ── Header ──────────────────────────────────────
              _card(
                child: Column(children: [
                  const Text('💧', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 8),
                  const Text('Report a Water Problem',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text("Fill in the form and we'll follow up as soon as possible",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: AquaColors.muted)),
                ]),
              ),
              const SizedBox(height: 16),

              // ── Personal Info ────────────────────────────────
              _section(
                title: '👤 Personal Information',
                child: isDesktop
                    ? Row(children: [
                        Expanded(child: _field(ctrl: _nameCtrl,  label: 'Full Name',    hint: 'sara el mansouri')),
                        const SizedBox(width: 16),
                        Expanded(child: _field(ctrl: _phoneCtrl, label: 'Phone Number', hint: '+212 6XX XXX XXX', keyboard: TextInputType.phone)),
                      ])
                    : Column(children: [
                        _field(ctrl: _nameCtrl,  label: 'Full Name',    hint: 'sara el mansouri'),
                        const SizedBox(height: 12),
                        _field(ctrl: _phoneCtrl, label: 'Phone Number', hint: '+212 6XX XXX XXX', keyboard: TextInputType.phone),
                      ]),
              ),
              const SizedBox(height: 16),

              // ── Location ─────────────────────────────────────
              _section(
                title: '📍 Location',
                child: _field(
                  ctrl: _addressCtrl,
                  label: 'Street Address / Neighborhood',
                  hint: 'e.g. Rue Ibn Battouta, Hay Mohammadi, Casablanca',
                  maxLines: 2,
                ),
              ),
              const SizedBox(height: 16),

              // ── Problem Type ──────────────────────────────────
              _section(
                title: '🔧 Type of Problem',
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _problemTypes.map((type) {
                    final active = type == _problemType;
                    return GestureDetector(
                      onTap: () => setState(() => _problemType = type),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: active
                              ? AquaColors.accent.withOpacity(0.15)
                              : AquaColors.surface2,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: active ? AquaColors.accent : AquaColors.border),
                        ),
                        child: Text(type,
                          style: TextStyle(
                            fontSize: 12,
                            color: active ? AquaColors.accent : AquaColors.muted,
                            fontWeight: active ? FontWeight.w700 : FontWeight.w400)),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // ── Description ───────────────────────────────────
              _section(
                title: '📝 Description',
                child: _field(
                  ctrl: _descriptionCtrl,
                  label: 'Describe the problem in detail',
                  hint: 'e.g. There has been no water since yesterday morning in our building...',
                  maxLines: 5,
                  maxLength: 500,
                ),
              ),
              const SizedBox(height: 16),

              // ── Urgency + Contact — side by side on desktop ───
              isDesktop
                  ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Expanded(child: _section(
                        title: '⚡ Urgency Level',
                        child: _chipGroup(
                          options: _urgencyLevels,
                          selected: _urgency,
                          activeColor: _urgencyColor(_urgency),
                          onSelect: (v) => setState(() => _urgency = v),
                        ),
                      )),
                      const SizedBox(width: 16),
                      Expanded(child: _section(
                        title: '📞 Preferred Contact',
                        child: _chipGroup(
                          options: _contactMethods,
                          selected: _contact,
                          activeColor: AquaColors.accent2,
                          onSelect: (v) => setState(() => _contact = v),
                        ),
                      )),
                    ])
                  : Column(children: [
                      _section(
                        title: '⚡ Urgency Level',
                        child: _chipGroup(
                          options: _urgencyLevels,
                          selected: _urgency,
                          activeColor: _urgencyColor(_urgency),
                          onSelect: (v) => setState(() => _urgency = v),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _section(
                        title: '📞 Preferred Contact',
                        child: _chipGroup(
                          options: _contactMethods,
                          selected: _contact,
                          activeColor: AquaColors.accent2,
                          onSelect: (v) => setState(() => _contact = v),
                        ),
                      ),
                    ]),
              const SizedBox(height: 28),

              // ── Submit ────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AquaColors.accent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                      : const Text('📤 Submit Reclamation',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────

  Widget _card({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AquaColors.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AquaColors.border),
    ),
    child: child,
  );

  Widget _section({required String title, required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AquaColors.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AquaColors.border),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
      const SizedBox(height: 12),
      child,
    ]),
  );

  Widget _field({
    required TextEditingController ctrl,
    required String label,
    required String hint,
    int maxLines  = 1,
    int? maxLength,
    TextInputType keyboard = TextInputType.text,
  }) =>
    TextField(
      controller: ctrl,
      maxLines:   maxLines,
      maxLength:  maxLength,
      keyboardType: keyboard,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        hintText:  hint,
        labelStyle: TextStyle(color: AquaColors.muted, fontSize: 13),
        hintStyle:  TextStyle(color: AquaColors.muted, fontSize: 12),
        filled:     true,
        fillColor:  AquaColors.surface2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AquaColors.border)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AquaColors.border)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AquaColors.accent)),
      ),
    );

  Widget _chipGroup({
    required List<String> options,
    required String selected,
    required Color activeColor,
    required void Function(String) onSelect,
  }) =>
    Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final active = opt == selected;
        return GestureDetector(
          onTap: () => onSelect(opt),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: active ? activeColor.withOpacity(0.15) : AquaColors.surface2,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: active ? activeColor : AquaColors.border),
            ),
            child: Text(opt,
              style: TextStyle(
                fontSize: 12,
                color: active ? activeColor : AquaColors.muted,
                fontWeight: active ? FontWeight.w700 : FontWeight.w400)),
          ),
        );
      }).toList(),
    );

  Color _urgencyColor(String u) => u == 'Urgent'
      ? AquaColors.danger
      : u == 'Medium'
          ? AquaColors.warn
          : AquaColors.accent2;

  // ── Firebase submit ───────────────────────────────────────
  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty ||
        _phoneCtrl.text.trim().isEmpty ||
        _addressCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('⚠️ Please fill in name, phone and address.'),
        backgroundColor: AquaColors.warn,
      ));
      return;
    }

    setState(() => _submitting = true);

    final user = FirebaseAuth.instance.currentUser;
    await FirebaseDatabase.instance.ref('reclamations').push().set({
      'name':        _nameCtrl.text.trim(),
      'phone':       _phoneCtrl.text.trim(),
      'address':     _addressCtrl.text.trim(),
      'problemType': _problemType,
      'description': _descriptionCtrl.text.trim(),
      'urgency':     _urgency,
      'contact':     _contact,
      'email':       user?.email ?? 'anonymous',
      'userId':      user?.uid ?? '',
      'userName':    user?.displayName ?? 'Unknown',
      'status':      'pending',
      'timestamp':   DateTime.now().toIso8601String(),
    });

    setState(() => _submitting = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('✅ Reclamation submitted successfully!'),
        backgroundColor: AquaColors.accent2.withOpacity(0.9),
      ));
      Navigator.pop(context);
    }
  }
}