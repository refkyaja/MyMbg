import 'dart:math';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final Widget nextScreen;

  const SplashScreen({super.key, required this.nextScreen});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ── Controllers ────────────────────────────────────────────────────────────
  late AnimationController _circleCtrl;
  late AnimationController _utensilCtrl;
  late AnimationController _rippleCtrl;
  late AnimationController _sparkleCtrl;
  late AnimationController _textCtrl;
  late AnimationController _loadingCtrl;
  late AnimationController _versionCtrl;
  late AnimationController _exitCtrl;

  // ── Animations ─────────────────────────────────────────────────────────────
  late Animation<double> _circleScale;

  late Animation<Offset> _forkOffset;
  late Animation<double> _forkAngle;
  late Animation<double> _forkOpacity;

  late Animation<Offset> _spoonOffset;
  late Animation<double> _spoonAngle;
  late Animation<double> _spoonOpacity;

  late Animation<double> _rippleScale;
  late Animation<double> _rippleOpacity;

  late Animation<double> _sparkleProgress;

  late Animation<double> _textFlipAngle;
  late Animation<double> _textOpacity;
  late Animation<double> _textTranslateY;

  late Animation<double> _loadingOpacity;

  late Animation<double> _versionOpacity;
  late Animation<Offset> _versionSlide;

  late Animation<double> _exitOpacity;
  late Animation<double> _exitScale;

  bool _showSplash = true;

  // Sparkle particle config
  final List<_Sparkle> _sparkles = [
    _Sparkle(color: const Color(0xFFFDE047), size: 12, tx: -70, ty: -50), // yellow
    _Sparkle(color: Colors.white, size: 10, tx: 60, ty: -45),
    _Sparkle(color: const Color(0xFFBBF7D0), size: 14, tx: -45, ty: 60),  // green-200
    _Sparkle(color: const Color(0xFFFACC15), size: 12, tx: 55, ty: 55),   // yellow-400
    _Sparkle(color: Colors.white, size: 8, tx: 0, ty: -80),
  ];

  @override
  void initState() {
    super.initState();
    _buildControllers();
    _buildAnimations();
    _startSequence();
  }

  void _buildControllers() {
    _circleCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _utensilCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _rippleCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _sparkleCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _textCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _loadingCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _versionCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _exitCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
  }

  void _buildAnimations() {
    // 1. Circle pop
    _circleScale = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 0.0, end: 1.1)
              .chain(CurveTween(curve: Curves.elasticOut)),
          weight: 60),
      TweenSequenceItem(
          tween: Tween(begin: 1.1, end: 1.0), weight: 40),
    ]).animate(_circleCtrl);

    // 2. Fork – swoop from top-left
    final utensilCurve = CurveTween(curve: Curves.easeOutBack);
    _forkOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _utensilCtrl, curve: const Interval(0, 0.1)));
    _forkOffset = TweenSequence<Offset>([
      TweenSequenceItem(
          tween: Tween(begin: const Offset(-1.4, -1.2), end: const Offset(0.07, 0.0))
              .chain(utensilCurve),
          weight: 60),
      TweenSequenceItem(
          tween: Tween(begin: const Offset(0.07, 0.0), end: const Offset(-0.03, 0.0)),
          weight: 20),
      TweenSequenceItem(
          tween: Tween(begin: const Offset(-0.03, 0.0), end: Offset.zero),
          weight: 20),
    ]).animate(_utensilCtrl);
    _forkAngle = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: -pi / 3, end: pi / 10).chain(utensilCurve),
          weight: 60),
      TweenSequenceItem(
          tween: Tween(begin: pi / 10, end: -pi / 36), weight: 20),
      TweenSequenceItem(
          tween: Tween(begin: -pi / 36, end: 0.0), weight: 20),
    ]).animate(_utensilCtrl);

    // 3. Spoon – swoop from top-right
    _spoonOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _utensilCtrl, curve: const Interval(0, 0.1)));
    _spoonOffset = TweenSequence<Offset>([
      TweenSequenceItem(
          tween: Tween(begin: const Offset(1.4, -1.2), end: const Offset(-0.07, 0.0))
              .chain(utensilCurve),
          weight: 60),
      TweenSequenceItem(
          tween: Tween(begin: const Offset(-0.07, 0.0), end: const Offset(0.03, 0.0)),
          weight: 20),
      TweenSequenceItem(
          tween: Tween(begin: const Offset(0.03, 0.0), end: Offset.zero),
          weight: 20),
    ]).animate(_utensilCtrl);
    _spoonAngle = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: pi / 3, end: -pi / 10).chain(utensilCurve),
          weight: 60),
      TweenSequenceItem(
          tween: Tween(begin: -pi / 10, end: pi / 36), weight: 20),
      TweenSequenceItem(
          tween: Tween(begin: pi / 36, end: 0.0), weight: 20),
    ]).animate(_utensilCtrl);

    // 4. Ripple
    _rippleScale = Tween<double>(begin: 0.8, end: 2.5).animate(
        CurvedAnimation(parent: _rippleCtrl, curve: Curves.easeOut));
    _rippleOpacity = Tween<double>(begin: 0.8, end: 0.0).animate(
        CurvedAnimation(parent: _rippleCtrl, curve: Curves.easeOut));

    // 5. Sparkles
    _sparkleProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _sparkleCtrl, curve: Curves.easeOut));

    // 6. Text flip-up
    _textFlipAngle = Tween<double>(begin: pi / 2, end: 0.0).animate(
        CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutBack));
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _textCtrl, curve: const Interval(0, 0.3)));
    _textTranslateY = Tween<double>(begin: 10.0, end: -15.0).animate(
        CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutBack));

    // 7. Loading dots
    _loadingOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _loadingCtrl, curve: Curves.easeOut));

    // 8. Version text
    _versionOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _versionCtrl, curve: Curves.easeOut));
    _versionSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(CurvedAnimation(parent: _versionCtrl, curve: Curves.easeOut));

    // 9. Exit
    _exitOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(parent: _exitCtrl, curve: Curves.easeInOut));
    _exitScale = Tween<double>(begin: 1.0, end: 1.1).animate(
        CurvedAnimation(parent: _exitCtrl, curve: Curves.easeInOut));
  }

  Future<void> _startSequence() async {
    // delay 300ms → circle pop
    await Future.delayed(const Duration(milliseconds: 300));
    _circleCtrl.forward();

    // delay 800ms → fork + spoon swoop
    await Future.delayed(const Duration(milliseconds: 500));
    _utensilCtrl.forward();

    // delay 1500ms → ripple + sparkles
    await Future.delayed(const Duration(milliseconds: 700));
    _rippleCtrl.forward();
    _sparkleCtrl.forward();

    // delay 2200ms → text
    await Future.delayed(const Duration(milliseconds: 700));
    _textCtrl.forward();

    // delay 3400ms → loading dots
    await Future.delayed(const Duration(milliseconds: 1200));
    _loadingCtrl.forward();
    _versionCtrl.forward();

    // delay 5500ms total → exit
    await Future.delayed(const Duration(milliseconds: 2100));
    _exitCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      setState(() => _showSplash = false);
    }
  }

  @override
  void dispose() {
    _circleCtrl.dispose();
    _utensilCtrl.dispose();
    _rippleCtrl.dispose();
    _sparkleCtrl.dispose();
    _textCtrl.dispose();
    _loadingCtrl.dispose();
    _versionCtrl.dispose();
    _exitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_showSplash) return widget.nextScreen;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _circleCtrl,
        _utensilCtrl,
        _rippleCtrl,
        _sparkleCtrl,
        _textCtrl,
        _loadingCtrl,
        _versionCtrl,
        _exitCtrl,
      ]),
      builder: (context, _) {
        return Opacity(
          opacity: _exitOpacity.value,
          child: Transform.scale(
            scale: _exitScale.value,
            child: Scaffold(
              body: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF10b981), Color(0xFF047857)],
                  ),
                ),
                child: Stack(
                  children: [
                    // ── Center content ──────────────────────────────────────
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Logo area
                          SizedBox(
                            width: 192,
                            height: 192,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Ripple ring
                                Transform.scale(
                                  scale: _rippleScale.value,
                                  child: Opacity(
                                    opacity: _rippleOpacity.value,
                                    child: Container(
                                      width: 160,
                                      height: 160,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: const Color(0xFF6EE7B7),
                                          width: 8,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // White circle background
                                Transform.scale(
                                  scale: _circleScale.value,
                                  child: Container(
                                    width: 160,
                                    height: 160,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 40,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Sparkles
                                ..._sparkles.map((s) => _buildSparkle(s)),

                                // Fork (left)
                                Opacity(
                                  opacity: _forkOpacity.value,
                                  child: Transform.translate(
                                    offset: _forkOffset.value * 80,
                                    child: Transform.rotate(
                                      angle: _forkAngle.value,
                                      child: _ForkIcon(),
                                    ),
                                  ),
                                ),

                                // Spoon (right)
                                Opacity(
                                  opacity: _spoonOpacity.value,
                                  child: Transform.translate(
                                    offset: _spoonOffset.value * 80,
                                    child: Transform.rotate(
                                      angle: _spoonAngle.value,
                                      child: _SpoonIcon(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 8),

                          // App name text – flip up
                          Opacity(
                            opacity: _textOpacity.value,
                            child: Transform(
                              alignment: Alignment.bottomCenter,
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.001)
                                ..rotateX(_textFlipAngle.value)
                                ..translate(0.0, _textTranslateY.value),
                              child: const Text(
                                'MyMbg',
                                style: TextStyle(
                                  fontSize: 64,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -1,
                                  shadows: [
                                    Shadow(
                                      color: Color(0x33000000),
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Loading dots
                          Opacity(
                            opacity: _loadingOpacity.value,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                _BouncingDot(delay: Duration(milliseconds: 3400)),
                                SizedBox(width: 8),
                                _BouncingDot(delay: Duration(milliseconds: 3600)),
                                SizedBox(width: 8),
                                _BouncingDot(delay: Duration(milliseconds: 3800)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Version text at bottom ──────────────────────────────
                    Positioned(
                      bottom: 32,
                      left: 0,
                      right: 0,
                      child: FadeTransition(
                        opacity: _versionOpacity,
                        child: SlideTransition(
                          position: _versionSlide,
                          child: const Text(
                            'V1.0.0',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0x99D1FAE5),
                              letterSpacing: 3.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSparkle(_Sparkle s) {
    final p = _sparkleProgress.value;
    final dx = s.tx * p;
    final dy = s.ty * p;
    final opacity = p < 0.7 ? 1.0 : (1.0 - (p - 0.7) / 0.3);
    final scale = p < 0.1 ? p / 0.1 : 1.0;

    return Transform.translate(
      offset: Offset(dx, dy),
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: Transform.scale(
          scale: scale,
          child: Container(
            width: s.size,
            height: s.size,
            decoration: BoxDecoration(
              color: s.color,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Fork SVG-equivalent widget ────────────────────────────────────────────────
class _ForkIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: CustomPaint(painter: _ForkPainter()),
    );
  }
}

class _ForkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF059669)
      ..style = PaintingStyle.fill;

    final scale = size.width / 24;
    final path = Path();
    // M8.2 2H6.8v6H4.6V2H3.2v6c0 2 1.4 3.7 3.3 4v10h1.4V12c1.9-.3 3.3-2 3.3-4V2H9.6v6H8.2V2z
    path.moveTo(8.2 * scale, 2 * scale);
    path.lineTo(6.8 * scale, 2 * scale);
    path.lineTo(6.8 * scale, 8 * scale);
    path.lineTo(4.6 * scale, 8 * scale);
    path.lineTo(4.6 * scale, 2 * scale);
    path.lineTo(3.2 * scale, 2 * scale);
    path.lineTo(3.2 * scale, 8 * scale);
    path.cubicTo(3.2 * scale, 10 * scale, 4.6 * scale, 11.7 * scale,
        6.5 * scale, 12 * scale);
    path.lineTo(6.5 * scale, 22 * scale);
    path.lineTo(7.9 * scale, 22 * scale);
    path.lineTo(7.9 * scale, 12 * scale);
    path.cubicTo(9.8 * scale, 11.7 * scale, 11.2 * scale, 10 * scale,
        11.2 * scale, 8 * scale);
    path.lineTo(11.2 * scale, 2 * scale);
    path.lineTo(9.6 * scale, 2 * scale);
    path.lineTo(9.6 * scale, 8 * scale);
    path.lineTo(8.2 * scale, 8 * scale);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Spoon SVG-equivalent widget ───────────────────────────────────────────────
class _SpoonIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: CustomPaint(painter: _SpoonPainter()),
    );
  }
}

class _SpoonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF059669)
      ..style = PaintingStyle.fill;

    final scale = size.width / 24;
    // M17.5 2c-2.8 0-4.5 2.5-4.5 5.5 0 2.4 1.3 4.4 3.3 5.2V22h1.4v-9.3c2-.8 3.3-2.8 3.3-5.2 0-3-1.7-5.5-4.5-5.5z
    final path = Path();
    path.moveTo(17.5 * scale, 2 * scale);
    path.cubicTo(14.7 * scale, 2 * scale, 13 * scale, 4.5 * scale,
        13 * scale, 7.5 * scale);
    path.cubicTo(13 * scale, 9.9 * scale, 14.3 * scale, 11.9 * scale,
        16.3 * scale, 12.7 * scale);
    path.lineTo(16.3 * scale, 22 * scale);
    path.lineTo(17.7 * scale, 22 * scale);
    path.lineTo(17.7 * scale, 12.7 * scale);
    path.cubicTo(19.7 * scale, 11.9 * scale, 21 * scale, 9.9 * scale,
        21 * scale, 7.5 * scale);
    path.cubicTo(21 * scale, 4.5 * scale, 19.3 * scale, 2 * scale,
        17.5 * scale, 2 * scale);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Bouncing dot ─────────────────────────────────────────────────────────────
class _BouncingDot extends StatefulWidget {
  final Duration delay;
  const _BouncingDot({required this.delay});

  @override
  State<_BouncingDot> createState() => _BouncingDotState();
}

class _BouncingDotState extends State<_BouncingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _bounce;

  @override
  void initState() {
    super.initState();
    // Satu siklus = naik (600ms) lalu turun kembali (600ms)
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    // begin = 0 (posisi normal), end = -8 (naik 8px)
    _bounce = Tween<double>(begin: 0.0, end: -8.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: Curves.easeInOut,
      ),
    );
    // Tunda sesuai stagger masing-masing titik, lalu loop naik-turun
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Transform.translate(
        offset: Offset(0, _bounce.value),
        child: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                  color: Color(0x1A000000), blurRadius: 5, offset: Offset(0, 2))
            ],
          ),
        ),
      ),
    );
  }
}

// ── Sparkle data model ────────────────────────────────────────────────────────
class _Sparkle {
  final Color color;
  final double size;
  final double tx;
  final double ty;
  const _Sparkle(
      {required this.color,
      required this.size,
      required this.tx,
      required this.ty});
}
