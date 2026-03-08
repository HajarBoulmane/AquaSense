import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'main_shell.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ─── Password Strength Logic ─────────────────────────────────────────────────

enum PasswordStrength { empty, weak, fair, good, strong }

class PasswordValidator {
  static bool hasMinLength(String p) => p.length >= 8;
  static bool hasUppercase(String p) => p.contains(RegExp(r'[A-Z]'));
  static bool hasLowercase(String p) => p.contains(RegExp(r'[a-z]'));
  static bool hasDigit(String p) => p.contains(RegExp(r'[0-9]'));
  static bool hasSpecial(String p) => p.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-+=\[\]\\\/`~;]'));

  static PasswordStrength evaluate(String p) {
    if (p.isEmpty) return PasswordStrength.empty;
    int score = 0;
    if (hasMinLength(p)) score++;
    if (hasUppercase(p)) score++;
    if (hasLowercase(p)) score++;
    if (hasDigit(p)) score++;
    if (hasSpecial(p)) score++;
    if (score <= 1) return PasswordStrength.weak;
    if (score == 2) return PasswordStrength.fair;
    if (score == 3) return PasswordStrength.good;
    return PasswordStrength.strong;
  }

  static bool isAcceptable(String p) {
    return hasMinLength(p) && hasUppercase(p) && hasLowercase(p) && hasDigit(p);
  }

  static String label(PasswordStrength s) {
    switch (s) {
      case PasswordStrength.empty: return '';
      case PasswordStrength.weak: return 'Weak';
      case PasswordStrength.fair: return 'Fair';
      case PasswordStrength.good: return 'Good';
      case PasswordStrength.strong: return 'Strong';
    }
  }

  static Color color(PasswordStrength s) {
    switch (s) {
      case PasswordStrength.empty: return Colors.transparent;
      case PasswordStrength.weak: return const Color(0xFFFF3B5C);
      case PasswordStrength.fair: return const Color(0xFFFF9500);
      case PasswordStrength.good: return const Color(0xFFFFD60A);
      case PasswordStrength.strong: return const Color(0xFF30D158);
    }
  }

  static double ratio(PasswordStrength s) {
    switch (s) {
      case PasswordStrength.empty: return 0;
      case PasswordStrength.weak: return 0.25;
      case PasswordStrength.fair: return 0.5;
      case PasswordStrength.good: return 0.75;
      case PasswordStrength.strong: return 1.0;
    }
  }
}

// ─── Main Screen ─────────────────────────────────────────────────────────────

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  bool _isLogin = true;
  bool _isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _registerNameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerConfirmPasswordController = TextEditingController();

  bool _loginPasswordVisible = false;
  bool _registerPasswordVisible = false;
  bool _registerConfirmPasswordVisible = false;

  // Password strength state
  PasswordStrength _passwordStrength = PasswordStrength.empty;

  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _registerPasswordController.addListener(() {
      setState(() {
        _passwordStrength = PasswordValidator.evaluate(_registerPasswordController.text);
      });
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerNameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmPasswordController.dispose();
    super.dispose();
  }

  void _toggleForm() => setState(() => _isLogin = !_isLogin);

  Future<void> _login() async {
    final email = _loginEmailController.text.trim();
    final password = _loginPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackbar("Please enter email and password");
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainShell()));
    } on FirebaseAuthException catch (e) {
      String message = "Login failed";
      if (e.code == 'user-not-found') message = "No account found with this email";
      else if (e.code == 'wrong-password') message = "Wrong password";
      else if (e.code == 'invalid-email') message = "Invalid email address";
      else if (e.code == 'invalid-credential') message = "Invalid email or password";
      if (!mounted) return;
      _showSnackbar(message, isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      await _auth.signInWithPopup(GoogleAuthProvider());
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainShell()));
    } catch (_) {
      if (!mounted) return;
      _showSnackbar("Google sign-in failed", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _register() async {
    final email = _registerEmailController.text.trim();
    final password = _registerPasswordController.text.trim();
    final confirm = _registerConfirmPasswordController.text.trim();
    final name = _registerNameController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnackbar("Please fill all fields");
      return;
    }

    // ── Password strength gate ──────────────────────────────────────────────
    if (!PasswordValidator.isAcceptable(password)) {
      _showSnackbar("Password does not meet security requirements", isError: true);
      return;
    }

    if (password != confirm) {
      _showSnackbar("Passwords do not match", isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await credential.user?.updateDisplayName(name);
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainShell()));
    } on FirebaseAuthException catch (e) {
      String message = "Registration failed";
      if (e.code == 'email-already-in-use') message = "Email already in use";
      else if (e.code == 'weak-password') message = "Password must be at least 8 characters";
      else if (e.code == 'invalid-email') message = "Invalid email address";
      if (!mounted) return;
      _showSnackbar(message, isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? const Color(0xFFFF3B5C) : null,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 600;

    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: isDesktop ? 420 : double.infinity),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 0 : 28.0,
                        vertical: 40,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildLogo(),
                          const SizedBox(height: 36),
                          _buildToggleTabs(),
                          const SizedBox(height: 28),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            transitionBuilder: (child, animation) => FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.05, 0),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            ),
                            child: _isLogin
                                ? _buildLoginForm(key: const ValueKey('login'))
                                : _buildRegisterForm(key: const ValueKey('register')),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator(color: Color(0xFF00D4FF))),
            ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) => CustomPaint(
        size: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
        painter: _WavePainter(_waveController.value),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(children: [
      Container(
        width: 72, height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF00D4FF), Color(0xFF0077B6)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(color: const Color(0xFF00D4FF).withOpacity(0.35), blurRadius: 24, spreadRadius: 2),
          ],
        ),
        child: const Icon(Icons.water_drop, color: Colors.white, size: 36),
      ),
      const SizedBox(height: 14),
      const Text('AquaSense',
          style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
      const SizedBox(height: 4),
      Text('Smart Water Monitoring',
          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13, letterSpacing: 0.5)),
    ]);
  }

  Widget _buildToggleTabs() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(children: [
        _buildTab('Login', _isLogin, () { if (!_isLogin) _toggleForm(); }),
        _buildTab('Register', !_isLogin, () { if (_isLogin) _toggleForm(); }),
      ]),
    );
  }

  Widget _buildTab(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: active
                ? const LinearGradient(
                    colors: [Color(0xFF00D4FF), Color(0xFF0077B6)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight)
                : null,
            boxShadow: active
                ? [BoxShadow(color: const Color(0xFF00D4FF).withOpacity(0.25), blurRadius: 10)]
                : null,
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(
                  color: active ? Colors.white : Colors.white.withOpacity(0.4),
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 14, letterSpacing: 0.3,
                )),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm({Key? key}) {
    return _FormCard(
      key: key,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _SectionTitle('Welcome Back'),
        const SizedBox(height: 4),
        _subTitle('Sign in to monitor your water systems'),
        const SizedBox(height: 28),
        _AquaTextField(
          controller: _loginEmailController,
          label: 'Email Address', hint: 'you@example.com',
          icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _AquaTextField(
          controller: _loginPasswordController,
          label: 'Password', hint: '••••••••',
          icon: Icons.lock_outline,
          obscureText: !_loginPasswordVisible,
          suffixIcon: _visibilityToggle(
            _loginPasswordVisible,
            () => setState(() => _loginPasswordVisible = !_loginPasswordVisible),
          ),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Forgot Password?',
                style: TextStyle(color: Color(0xFF00D4FF), fontSize: 13)),
          ),
        ),
        const SizedBox(height: 24),
        _AquaButton(label: 'Sign In', onPressed: _login),
        const SizedBox(height: 20),
        const _OrDivider(),
        const SizedBox(height: 20),
        _SocialButton(label: 'Sign in with Google', icon: Icons.login, onPressed: _signInWithGoogle),
      ]),
    );
  }

  Widget _buildRegisterForm({Key? key}) {
    final p = _registerPasswordController.text;
    return _FormCard(
      key: key,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _SectionTitle('Create Account'),
        const SizedBox(height: 4),
        _subTitle('Start monitoring your water quality today'),
        const SizedBox(height: 28),
        _AquaTextField(
          controller: _registerNameController,
          label: 'Full Name', hint: 'John Doe', icon: Icons.person_outline,
        ),
        const SizedBox(height: 16),
        _AquaTextField(
          controller: _registerEmailController,
          label: 'Email Address', hint: 'you@example.com',
          icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _AquaTextField(
          controller: _registerPasswordController,
          label: 'Password', hint: '••••••••',
          icon: Icons.lock_outline,
          obscureText: !_registerPasswordVisible,
          suffixIcon: _visibilityToggle(
            _registerPasswordVisible,
            () => setState(() => _registerPasswordVisible = !_registerPasswordVisible),
          ),
        ),
        // ── Strength meter ──────────────────────────────────────────────────
        if (_passwordStrength != PasswordStrength.empty) ...[
          const SizedBox(height: 10),
          _PasswordStrengthMeter(strength: _passwordStrength),
        ],
        // ── Requirements checklist ──────────────────────────────────────────
        const SizedBox(height: 12),
        _PasswordRequirements(password: p),
        const SizedBox(height: 16),
        _AquaTextField(
          controller: _registerConfirmPasswordController,
          label: 'Confirm Password', hint: '••••••••',
          icon: Icons.lock_outline,
          obscureText: !_registerConfirmPasswordVisible,
          suffixIcon: _visibilityToggle(
            _registerConfirmPasswordVisible,
            () => setState(() => _registerConfirmPasswordVisible = !_registerConfirmPasswordVisible),
          ),
        ),
        const SizedBox(height: 10),
        Row(children: [
          Icon(Icons.info_outline, color: Colors.white.withOpacity(0.3), size: 13),
          const SizedBox(width: 6),
          Expanded(
            child: Text('By registering, you agree to our Terms & Privacy Policy.',
                style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11)),
          ),
        ]),
        const SizedBox(height: 26),
        _AquaButton(label: 'Create Account', onPressed: _register),
      ]),
    );
  }

  Widget _subTitle(String text) =>
      Text(text, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13));

  Widget _visibilityToggle(bool visible, VoidCallback onTap) => IconButton(
        icon: Icon(
          visible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: Colors.white38, size: 20,
        ),
        onPressed: onTap,
      );
}

// ─── Password Strength Meter ─────────────────────────────────────────────────

class _PasswordStrengthMeter extends StatelessWidget {
  final PasswordStrength strength;
  const _PasswordStrengthMeter({required this.strength});

  @override
  Widget build(BuildContext context) {
    final color = PasswordValidator.color(strength);
    final ratio = PasswordValidator.ratio(strength);
    final label = PasswordValidator.label(strength);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Password strength',
            style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 11.5)),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Text(label,
              key: ValueKey(label),
              style: TextStyle(color: color, fontSize: 11.5, fontWeight: FontWeight.w600)),
        ),
      ]),
      const SizedBox(height: 6),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(
          height: 4,
          child: Stack(children: [
            Container(color: Colors.white.withOpacity(0.08)),
            AnimatedFractionallySizedBox(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOut,
              widthFactor: ratio,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: color,
                  boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 6)],
                ),
              ),
            ),
          ]),
        ),
      ),
    ]);
  }
}

// ─── Password Requirements Checklist ─────────────────────────────────────────

class _PasswordRequirements extends StatelessWidget {
  final String password;
  const _PasswordRequirements({required this.password});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Requirements',
            style: TextStyle(
                color: Colors.white.withOpacity(0.4), fontSize: 11, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        _Req('At least 8 characters', PasswordValidator.hasMinLength(password)),
        _Req('Uppercase letter (A–Z)', PasswordValidator.hasUppercase(password)),
        _Req('Lowercase letter (a–z)', PasswordValidator.hasLowercase(password)),
        _Req('Number (0–9)', PasswordValidator.hasDigit(password)),
        _Req('Special character (!@#\$…)', PasswordValidator.hasSpecial(password), required: false),
      ]),
    );
  }
}

class _Req extends StatelessWidget {
  final String label;
  final bool met;
  final bool required;
  const _Req(this.label, this.met, {this.required = true});

  @override
  Widget build(BuildContext context) {
    final color = met
        ? const Color(0xFF30D158)
        : required
            ? Colors.white.withOpacity(0.3)
            : Colors.white.withOpacity(0.2);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            met ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            key: ValueKey(met),
            color: color,
            size: 14,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label + (required ? '' : '  (optional +)'),
          style: TextStyle(color: color, fontSize: 12),
        ),
      ]),
    );
  }
}

// ─── Reusable Widgets ────────────────────────────────────────────────────────

class _FormCard extends StatelessWidget {
  final Widget child;
  const _FormCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1F38).withOpacity(0.85),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 32, offset: const Offset(0, 12)),
        ],
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(
            color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: 0.3));
  }
}

class _AquaTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label, hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? suffixIcon;

  const _AquaTextField({
    required this.controller, required this.label, required this.hint, required this.icon,
    this.obscureText = false, this.keyboardType = TextInputType.text, this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: TextStyle(
              color: Colors.white.withOpacity(0.65), fontSize: 12.5,
              fontWeight: FontWeight.w500, letterSpacing: 0.4)),
      const SizedBox(height: 8),
      TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        cursorColor: const Color(0xFF00D4FF),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 14),
          prefixIcon: Icon(icon, color: Colors.white38, size: 20),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF00D4FF), width: 1.5),
          ),
        ),
      ),
    ]);
  }
}

class _AquaButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _AquaButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF00D4FF), Color(0xFF0077B6)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF00D4FF).withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6)),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: Text(label,
              style: const TextStyle(
                  color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: Divider(color: Colors.white.withOpacity(0.1), thickness: 1)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text('OR',
            style: TextStyle(
                color: Colors.white.withOpacity(0.3), fontSize: 12, fontWeight: FontWeight.w500)),
      ),
      Expanded(child: Divider(color: Colors.white.withOpacity(0.1), thickness: 1)),
    ]);
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  const _SocialButton({required this.label, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, height: 50,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white70, size: 22),
        label: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.white.withOpacity(0.15)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          backgroundColor: Colors.white.withOpacity(0.04),
        ),
      ),
    );
  }
}

// ─── Wave Background Painter ─────────────────────────────────────────────────

class _WavePainter extends CustomPainter {
  final double animValue;
  _WavePainter(this.animValue);

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF0A1628), Color(0xFF071020)],
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    _drawWave(canvas, size, 0.72, const Color(0xFF00D4FF), 0.04, 0);
    _drawWave(canvas, size, 0.78, const Color(0xFF0077B6), 0.035, 0.3);
    _drawWave(canvas, size, 0.84, const Color(0xFF023E6B), 0.03, 0.6);

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [const Color(0xFF00D4FF).withOpacity(0.15), Colors.transparent],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.85, size.height * 0.1),
        radius: size.width * 0.45,
      ));
    canvas.drawCircle(
        Offset(size.width * 0.85, size.height * 0.1), size.width * 0.45, glowPaint);
  }

  void _drawWave(Canvas canvas, Size size, double yRatio, Color color, double opacity, double phaseOffset) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);

    final yBase = size.height * yRatio;
    final amplitude = size.height * 0.025;
    final phase = (animValue + phaseOffset) * 2 * math.pi;

    for (double x = 0; x <= size.width; x++) {
      final y = yBase + amplitude * math.sin((x / size.width * 2 * math.pi) + phase);
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WavePainter old) => old.animValue != animValue;
}