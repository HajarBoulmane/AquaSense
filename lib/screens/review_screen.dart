import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/firebase_service.dart';

class ReviewScreen extends StatefulWidget {
const ReviewScreen({super.key});
  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int _stars = 0;
  final _commentCtrl = TextEditingController();
  String _category = 'General';
  bool _submitting = false;

  final _categories = ['General', 'UI/UX', 'Performance', 'Features', 'Bug Report'];

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AquaColors.bg,
      appBar: AppBar(
        backgroundColor: AquaColors.surface,
        title: const Text('⭐ Rate AquaSense'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AquaColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AquaColors.border),
            ),
            child: Column(
              children: [
                const Text('💧', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 8),
                const Text(
                  'How was your experience?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your feedback helps us improve AquaSense',
                  style: TextStyle(fontSize: 13, color: AquaColors.muted),
                ),
                const SizedBox(height: 20),

                // Star rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (i) => GestureDetector(
                      onTap: () => setState(() => _stars = i + 1),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(
                          i < _stars ? Icons.star : Icons.star_border,
                          size: 40,
                          color: i < _stars
                              ? const Color(0xFFFFB830)
                              : AquaColors.muted,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _stars == 0
                      ? 'Tap to rate'
                      : _stars == 1
                          ? '😞 Poor'
                          : _stars == 2
                              ? '😐 Fair'
                              : _stars == 3
                                  ? '🙂 Good'
                                  : _stars == 4
                                      ? '😊 Very Good'
                                      : '🤩 Excellent!',
                  style: TextStyle(
                    fontSize: 14,
                    color: _stars > 0
                        ? const Color(0xFFFFB830)
                        : AquaColors.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Category
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AquaColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AquaColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '📂 Category',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _categories.map((cat) {
                    final active = cat == _category;
                    return GestureDetector(
                      onTap: () => setState(() => _category = cat),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: active
                              ? AquaColors.accent.withOpacity(0.15)
                              : AquaColors.surface2,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: active
                                ? AquaColors.accent
                                : AquaColors.border,
                          ),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 12,
                            color: active ? AquaColors.accent : AquaColors.muted,
                            fontWeight:
                                active ? FontWeight.w700 : FontWeight.w400,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Comment
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AquaColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AquaColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '💬 Comment (optional)',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _commentCtrl,
                  maxLines: 4,
                  maxLength: 300,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Tell us what you think...',
                    hintStyle: TextStyle(
                      color: AquaColors.muted,
                      fontSize: 13,
                    ),
                    filled: true,
                    fillColor: AquaColors.surface2,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AquaColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AquaColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AquaColors.accent),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AquaColors.accent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: (_stars == 0 || _submitting) ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : const Text(
                      '📤 Submit Review',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
            ),
          ),
          if (_stars == 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Please select a star rating before submitting.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AquaColors.muted),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    await FirebaseService().submitReview(
      stars: _stars,
      category: _category,
      comment: _commentCtrl.text.trim(),
    );
    setState(() => _submitting = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('🎉 Thank you for your review!'),
          backgroundColor: AquaColors.accent2.withOpacity(0.9),
        ),
      );
      Navigator.pop(context);
    }
  }
}