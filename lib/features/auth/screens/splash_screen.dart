import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/storage/preferences_service.dart';
import '../../home/screens/home_screen.dart';
import '../../onboarding/screens/app_intro_onboarding_screen.dart';

/// Animated coffee-brown splash → intro onboarding (first launch) or Home.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const String routeName = '/';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _enterController;
  late final AnimationController _exitController;
  late final AnimationController _pulseController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _ringScale;
  late final Animation<double> _ringOpacity;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _titleOpacity;
  late final Animation<double> _taglineOpacity;
  late final Animation<double> _dotsOpacity;

  bool _bootstrapStarted = false;
  bool _navigated = false;

  static const _minSplashMs = 2200;

  @override
  void initState() {
    super.initState();

    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _logoScale = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(
        parent: _enterController,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _enterController,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
      ),
    );

    _ringScale = Tween<double>(begin: 0.85, end: 1.12).animate(
      CurvedAnimation(
        parent: _enterController,
        curve: const Interval(0.15, 0.75, curve: Curves.easeOutCubic),
      ),
    );

    _ringOpacity = Tween<double>(begin: 0.0, end: 0.35).animate(
      CurvedAnimation(
        parent: _enterController,
        curve: const Interval(0.15, 0.55, curve: Curves.easeOut),
      ),
    );

    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.22),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _enterController,
        curve: const Interval(0.28, 0.72, curve: Curves.easeOutCubic),
      ),
    );

    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _enterController,
        curve: const Interval(0.28, 0.62, curve: Curves.easeOut),
      ),
    );

    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _enterController,
        curve: const Interval(0.42, 0.78, curve: Curves.easeOut),
      ),
    );

    _dotsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _enterController,
        curve: const Interval(0.55, 0.9, curve: Curves.easeOut),
      ),
    );

    _enterController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_bootstrapStarted) {
      _bootstrapStarted = true;
      _bootstrap();
    }
  }

  Future<void> _bootstrap() async {
    final auth = context.read<AuthService>();
    final started = DateTime.now();

    await Future.wait([
      auth.initialize(),
      Future<void>.delayed(const Duration(milliseconds: _minSplashMs)),
    ]);

    if (!mounted || _navigated) return;

    final elapsed = DateTime.now().difference(started).inMilliseconds;
    if (elapsed < _minSplashMs) {
      await Future<void>.delayed(
        Duration(milliseconds: _minSplashMs - elapsed),
      );
    }

    if (!mounted || _navigated) return;

    if (_enterController.status != AnimationStatus.completed) {
      await _enterController.forward();
    }

    final prefs = PreferencesService();
    final seen = await prefs.hasSeenOnboarding();

    if (!mounted || _navigated) return;
    _navigated = true;

    await _exitController.forward();
    if (!mounted) return;

    final next = seen ? const HomeScreen() : const AppIntroOnboardingScreen();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 650),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, _, _) => next,
        transitionsBuilder: (_, animation, _, child) {
          final curve = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          );
          return FadeTransition(
            opacity: curve,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.97, end: 1.0).animate(curve),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _enterController.dispose();
    _exitController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splashCoffeeMid,
      body: AnimatedBuilder(
        animation: Listenable.merge([_enterController, _exitController]),
        builder: (context, child) {
          final exit = _exitController.value;
          final masterOpacity = (1.0 - exit).clamp(0.0, 1.0);

          return Opacity(
            opacity: masterOpacity,
            child: child,
          );
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            _AnimatedSplashBackground(pulse: _pulseController),
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _enterController,
                    builder: (context, _) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          Opacity(
                            opacity: _ringOpacity.value,
                            child: Transform.scale(
                              scale: _ringScale.value *
                                  (0.96 +
                                      0.04 *
                                          _pulseController.value),
                              child: Container(
                                width: 148,
                                height: 148,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.gold
                                        .withValues(alpha: 0.45),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Opacity(
                            opacity: _logoOpacity.value,
                            child: Transform.scale(
                              scale: _logoScale.value,
                              child: Container(
                                width: 112,
                                height: 112,
                                decoration: BoxDecoration(
                                  color: AppColors.splashCoffeeLight,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black
                                          .withValues(alpha: 0.35),
                                      blurRadius: 28,
                                      offset: const Offset(0, 12),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: AppColors.gold
                                        .withValues(alpha: 0.7),
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.auto_stories_rounded,
                                  size: 52,
                                  color: AppColors.gold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  SlideTransition(
                    position: _titleSlide,
                    child: FadeTransition(
                      opacity: _titleOpacity,
                      child: Text(
                        'Amaano BookVerse',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: AppColors.background,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  FadeTransition(
                    opacity: _taglineOpacity,
                    child: Text(
                      'Stories that stay with you',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.navUnselected,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  FadeTransition(
                    opacity: _dotsOpacity,
                    child: _LoadingDots(pulse: _pulseController),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedSplashBackground extends StatelessWidget {
  const _AnimatedSplashBackground({required this.pulse});

  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulse,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.splashCoffeeDeep,
                Color.lerp(
                  AppColors.splashCoffeeMid,
                  AppColors.splashCoffee,
                  0.4 + pulse.value * 0.2,
                )!,
                Color.lerp(
                  AppColors.splashCoffee,
                  AppColors.splashCoffeeLight,
                  0.25 + pulse.value * 0.15,
                )!,
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -80 + pulse.value * 16,
                right: -40,
                child: _GlowOrb(
                  size: 220,
                  color: AppColors.gold.withValues(alpha: 0.18),
                ),
              ),
              Positioned(
                bottom: -60 - pulse.value * 12,
                left: -30,
                child: _GlowOrb(
                  size: 180,
                  color: AppColors.surface.withValues(alpha: 0.08),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

class _LoadingDots extends StatelessWidget {
  const _LoadingDots({required this.pulse});

  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final phase = (pulse.value + index * 0.22) % 1.0;
        final scale = 0.65 + (phase < 0.5 ? phase : 1.0 - phase) * 0.7;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.gold,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      }),
    );
  }
}
