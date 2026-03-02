import 'dart:math';
import 'package:flutter/material.dart';

// ─── Entry point (remove if you already have main.dart) ───────────────────────
void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AquaSense',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF03080F),
        fontFamily: 'DMSans',
      ),
      home: const DashboardScreen(),
    );
  }
}

// ─── Colors ───────────────────────────────────────────────────────────────────
class AqColors {
  static const bg       = Color(0xFF03080F);
  static const surface  = Color(0xFF080F1A);
  static const surface2 = Color(0xFF0D1829);
  static const cyan     = Color(0xFF00C8FF);
  static const cyanDim  = Color(0x2600C8FF);
  static const cyanGlow = Color(0x5900C8FF);
  static const amber    = Color(0xFFFFAB00);
  static const red      = Color(0xFFFF3B5C);
  static const green    = Color(0xFF00E676);
  static const textPri  = Color(0xFFE0F2FF);
  static const textDim  = Color(0x80A0D2F0);
  static const border   = Color(0x1F00B4FF);
}

// ─── Dashboard Screen ─────────────────────────────────────────────────────────
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  int _navIndex = 0;
  late AnimationController _waveCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _gaugeCtrl;
  late Animation<double> _gaugeAnim;

  final double _level = 0.70;

  @override
  void initState() {
    super.initState();
    _waveCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 6))
      ..repeat(reverse: true);
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _gaugeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..forward();
    _gaugeAnim = CurvedAnimation(parent: _gaugeCtrl, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _waveCtrl.dispose();
    _pulseCtrl.dispose();
    _gaugeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AqColors.bg,
      body: Stack(
        children: [
          // Animated water bg
          _WaterBackground(animation: _waveCtrl),
          SafeArea(
            child: Column(
              children: [
                _buildStatusBar(),
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      children: [
                        _buildGaugeCard(),
                        const SizedBox(height: 10),
                        _buildMetricChips(),
                        const SizedBox(height: 10),
                        _buildAlertCard(),
                        const SizedBox(height: 10),
                        _buildPredictionCard(),
                        const SizedBox(height: 10),
                        _buildSensorsGrid(),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
                _buildBottomNav(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Status bar ──────────────────────────────────────────────────────────────
  Widget _buildStatusBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('09:41', style: _mono(11, AqColors.textDim)),
          Text('AQS_NET  ●●●●◌', style: _mono(11, AqColors.textDim)),
        ],
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          // Logo
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AqColors.cyanDim,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AqColors.cyan, width: 1),
            ),
            child: const Center(child: Text('💧', style: TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('AQUASENSE', style: _mono(16, AqColors.cyan, bold: true)),
              Text('IoT Water Monitor · Casablanca Grid',
                  style: _body(10, AqColors.textDim)),
            ],
          ),
          const Spacer(),
          // Bell
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (_, __) => Stack(
              children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: AqColors.surface2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AqColors.border),
                  ),
                  child: const Center(child: Text('🔔', style: TextStyle(fontSize: 17))),
                ),
                Positioned(
                  top: 7, right: 7,
                  child: Container(
                    width: 9, height: 9,
                    decoration: BoxDecoration(
                      color: AqColors.red.withOpacity(
                          0.6 + 0.4 * _pulseCtrl.value),
                      shape: BoxShape.circle,
                      border: Border.all(color: AqColors.bg, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Gauge card ──────────────────────────────────────────────────────────────
  Widget _buildGaugeCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AqColors.surface2,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AqColors.border),
        ),
        padding: const EdgeInsets.all(20),
        child: Stack(
          children: [
            // Glow top-right
            Positioned(
              top: -20, right: -20,
              child: Container(
                width: 120, height: 120,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    AqColors.cyanGlow,
                    Colors.transparent,
                  ]),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('// RESERVOIR STATUS', style: _mono(10, AqColors.textDim)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Animated gauge
                    AnimatedBuilder(
                      animation: _gaugeAnim,
                      builder: (_, __) => SizedBox(
                        width: 90, height: 90,
                        child: CustomPaint(
                          painter: _GaugePainter(_level * _gaugeAnim.value),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${(_level * _gaugeAnim.value * 100).round()}%',
                                  style: _mono(17, AqColors.cyan, bold: true),
                                ),
                                Text('LEVEL', style: _mono(8, AqColors.textDim)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: _body(20, AqColors.textPri, bold: true),
                              children: const [
                                TextSpan(text: 'Réservoir '),
                                TextSpan(
                                  text: 'Ain Chok',
                                  style: TextStyle(color: AqColors.cyan),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Capacity: 50,000 m³ · Last sync 2m ago',
                            style: _body(11, AqColors.textDim),
                          ),
                          const SizedBox(height: 10),
                          AnimatedBuilder(
                            animation: _pulseCtrl,
                            builder: (_, __) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AqColors.green.withOpacity(0.10),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AqColors.green.withOpacity(
                                      0.3 + 0.2 * _pulseCtrl.value),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6, height: 6,
                                    decoration: BoxDecoration(
                                      color: AqColors.green.withOpacity(
                                          0.6 + 0.4 * _pulseCtrl.value),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text('NOMINAL', style: _mono(10, AqColors.green)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Metric chips ────────────────────────────────────────────────────────────
  Widget _buildMetricChips() {
    final chips = [
      _ChipData('📊', '+2.1%', '24h Δ', AqColors.cyan, false, false),
      _ChipData('⚡', 'HIGH',  'Demand', AqColors.amber, true, false),
      _ChipData('📉', '−5 days', 'Forecast', AqColors.red, false, true),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: chips.map((c) {
          Color borderCol = c.isCrit
              ? AqColors.red.withOpacity(0.3)
              : c.isWarn
              ? AqColors.amber.withOpacity(0.3)
              : AqColors.border;
          Color bgCol = c.isCrit
              ? AqColors.red.withOpacity(0.05)
              : c.isWarn
              ? AqColors.amber.withOpacity(0.05)
              : AqColors.surface2;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: chips.last == c ? 0 : 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: bgCol,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderCol),
              ),
              child: Column(
                children: [
                  Text(c.icon, style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 4),
                  Text(c.value, style: _mono(13, c.color, bold: true)),
                  const SizedBox(height: 2),
                  Text(c.label,
                      style: _mono(9, AqColors.textDim),
                      textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Alert card ──────────────────────────────────────────────────────────────
  Widget _buildAlertCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AnimatedBuilder(
        animation: _pulseCtrl,
        builder: (_, __) => Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AqColors.red.withOpacity(0.06),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AqColors.red.withOpacity(
                  0.3 + 0.3 * _pulseCtrl.value),
            ),
            boxShadow: [
              BoxShadow(
                color: AqColors.red.withOpacity(0.05 * _pulseCtrl.value),
                blurRadius: 20,
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('⚠️', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PÉNURIE RISK — SECTOR 4',
                        style: _mono(12, AqColors.red, bold: true)),
                    const SizedBox(height: 4),
                    Text(
                      'Quartier Hay Mohammadi · Pressure drop detected · Potential supply cut in 48h',
                      style: _body(11, AqColors.textDim),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text('08:12', style: _mono(10, AqColors.textDim)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Prediction card ─────────────────────────────────────────────────────────
  Widget _buildPredictionCard() {
    final forecast = [
      _ForecastDay('MON', 0.72, AqColors.cyan),
      _ForecastDay('TUE', 0.55, AqColors.amber),
      _ForecastDay('WED', 0.38, const Color(0xFFFF7043)),
      _ForecastDay('THU', 0.20, AqColors.red),
      _ForecastDay('FRI', 0.10, AqColors.red),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AqColors.surface2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AqColors.border),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('// AI FORECAST', style: _mono(10, AqColors.textDim)),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AqColors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AqColors.amber.withOpacity(0.3)),
                  ),
                  child: Text('ML MODEL v2.4',
                      style: _mono(9, AqColors.amber)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...forecast.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                      width: 28,
                      child: Text(f.day,
                          style: _mono(10, AqColors.textDim))),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _gaugeAnim,
                      builder: (_, __) => Stack(
                        children: [
                          Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: f.pct * _gaugeAnim.value,
                            child: Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: f.color,
                                borderRadius: BorderRadius.circular(3),
                                boxShadow: [
                                  BoxShadow(
                                    color: f.color.withOpacity(0.5),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 36,
                    child: Text(
                      '${(f.pct * 100).round()}%',
                      style: _mono(10, f.color),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  // ── Sensors grid ────────────────────────────────────────────────────────────
  Widget _buildSensorsGrid() {
    final sensors = [
      _SensorData('🌡️', 'Temperature', '22.4°C'),
      _SensorData('⚗️', 'pH Level', '7.2'),
      _SensorData('💧', 'Flow Rate', '4.2 L/s'),
      _SensorData('🔬', 'Turbidity', '1.8 NTU'),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('// LIVE SENSORS', style: _mono(10, AqColors.textDim)),
          const SizedBox(height: 8),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 2.4,
            children: sensors
                .map((s) => Container(
              decoration: BoxDecoration(
                color: AqColors.surface2,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AqColors.border),
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Text(s.icon,
                      style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(s.name,
                          style: _body(10, AqColors.textDim)),
                      Text(s.reading,
                          style: _mono(13, AqColors.textPri,
                              bold: true)),
                    ],
                  ),
                ],
              ),
            ))
                .toList(),
          ),
        ],
      ),
    );
  }

  // ── Bottom nav ──────────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    const items = [
      ('🏠', 'Dashboard'),
      ('🔔', 'Alerts'),
      ('📈', 'Stats'),
      ('🗺️', 'Map'),
    ];
    return Container(
      decoration: const BoxDecoration(
        color: AqColors.surface,
        border: Border(top: BorderSide(color: AqColors.border)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final active = i == _navIndex;
          return GestureDetector(
            onTap: () => setState(() => _navIndex = i),
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  items[i].$1,
                  style: TextStyle(
                    fontSize: 22,
                    shadows: active
                        ? [
                      const Shadow(
                        color: AqColors.cyan,
                        blurRadius: 12,
                      )
                    ]
                        : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  items[i].$2.toUpperCase(),
                  style: _mono(
                    8,
                    active ? AqColors.cyan : AqColors.textDim,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ── Text helpers ─────────────────────────────────────────────────────────────
  TextStyle _mono(double size, Color color, {bool bold = false}) => TextStyle(
    fontFamily: 'monospace',
    fontSize: size,
    color: color,
    fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
    letterSpacing: 0.4,
  );

  TextStyle _body(double size, Color color, {bool bold = false}) => TextStyle(
    fontSize: size,
    color: color,
    fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
  );
}

// ─── Wave background painter ──────────────────────────────────────────────────
class _WaterBackground extends StatelessWidget {
  final Animation<double> animation;
  const _WaterBackground({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) => CustomPaint(
        size: MediaQuery.of(context).size,
        painter: _WavePainter(animation.value),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final double t;
  _WavePainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    // Bottom radial glow
    final grad = Paint()
      ..shader = RadialGradient(
        center: Alignment.bottomCenter,
        radius: 0.8,
        colors: [
          const Color(0xFF003B80).withOpacity(0.18),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), grad);

    // Wave 1
    _drawWave(canvas, size, t, 0.05, const Color(0xFF0064B4), 0.07);
    // Wave 2
    _drawWave(canvas, size, 1 - t, 0.04, const Color(0xFF003C8F), 0.04);
  }

  void _drawWave(Canvas canvas, Size size, double t, double amp,
      Color color, double opacity) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    final path = Path();
    final h = size.height;
    final w = size.width;

    path.moveTo(0, h);
    for (double x = 0; x <= w; x++) {
      final y = h * 0.88 +
          sin((x / w * 2 * pi) + t * 2 * pi) * h * amp -
          t * h * 0.015;
      path.lineTo(x, y);
    }
    path.lineTo(w, h);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WavePainter old) => old.t != t;
}

// ─── Gauge painter ────────────────────────────────────────────────────────────
class _GaugePainter extends CustomPainter {
  final double value; // 0.0 – 1.0
  _GaugePainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;

    // Track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AqColors.cyan.withOpacity(0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6,
    );

    // Fill arc
    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..shader = const SweepGradient(
        startAngle: -pi / 2,
        endAngle: 3 * pi / 2,
        colors: [AqColors.cyan, Color(0xFF00FFE7)],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      -pi / 2,
      2 * pi * value,
      false,
      paint,
    );

    // Glow layer
    canvas.drawArc(
      rect,
      -pi / 2,
      2 * pi * value,
      false,
      Paint()
        ..color = AqColors.cyan.withOpacity(0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
  }

  @override
  bool shouldRepaint(_GaugePainter old) => old.value != value;
}

// ─── Data models ──────────────────────────────────────────────────────────────
class _ChipData {
  final String icon, value, label;
  final Color color;
  final bool isWarn, isCrit;
  _ChipData(this.icon, this.value, this.label, this.color,
      this.isWarn, this.isCrit);
}

class _ForecastDay {
  final String day;
  final double pct;
  final Color color;
  _ForecastDay(this.day, this.pct, this.color);
}

class _SensorData {
  final String icon, name, reading;
  _SensorData(this.icon, this.name, this.reading);
}
