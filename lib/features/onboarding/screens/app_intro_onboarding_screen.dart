import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/storage/preferences_service.dart';
import '../../home/screens/home_screen.dart';

class AppIntroOnboardingScreen extends StatefulWidget {
  const AppIntroOnboardingScreen({super.key});

  static const String routeName = '/app-intro';

  @override
  State<AppIntroOnboardingScreen> createState() =>
      _AppIntroOnboardingScreenState();
}

class _AppIntroOnboardingScreenState extends State<AppIntroOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _finishing = false;

  static const _pages = [
    _IntroPageData(
      title: 'Discover Digital Books',
      subtitle:
          'Explore books and audiobooks curated for readers who love to learn.',
      icon: Icons.auto_stories_rounded,
    ),
    _IntroPageData(
      title: 'Learn Anywhere',
      subtitle:
          'Read, listen, save, and continue from your mobile library.',
      icon: Icons.headphones_rounded,
    ),
    _IntroPageData(
      title: 'Access Premium Knowledge',
      subtitle:
          'Buy books, submit payment once, and access approved content anytime.',
      icon: Icons.shopping_bag_outlined,
    ),
  ];

  Future<void> _finishIntro() async {
    if (_finishing) return;
    _finishing = true;
    await PreferencesService().setHasSeenOnboarding(true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 650),
        pageBuilder: (_, _, _) => const HomeScreen(),
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

  Future<void> _nextPage() async {
    if (_finishing) return;

    if (_currentPage < _pages.length - 1) {
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 480),
        curve: Curves.easeInOutCubic,
      );
      return;
    }

    await _finishIntro();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finishing ? null : _finishIntro,
                child: Text(
                  'Skip',
                  style: GoogleFonts.poppins(
                    color: AppColors.primaryBrown,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  return _AnimatedIntroPage(
                    data: _pages[index],
                    pageIndex: index,
                    currentPage: _currentPage,
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeOutCubic,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == i
                        ? AppColors.gold
                        : AppColors.chipInactive.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _finishing ? null : _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBrown,
                    foregroundColor: AppColors.gold,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    isLast ? 'Get Started' : 'Next',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedIntroPage extends StatelessWidget {
  const _AnimatedIntroPage({
    required this.data,
    required this.pageIndex,
    required this.currentPage,
  });

  final _IntroPageData data;
  final int pageIndex;
  final int currentPage;

  @override
  Widget build(BuildContext context) {
    final active = pageIndex == currentPage;
    final distance = (pageIndex - currentPage).abs().clamp(0, 1).toDouble();

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: active ? 0.0 : distance),
      duration: const Duration(milliseconds: 480),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) {
        return Opacity(
          opacity: (1.0 - t * 0.55).clamp(0.45, 1.0),
          child: Transform.translate(
            offset: Offset(0, 28 * t),
            child: Transform.scale(
              scale: (1.0 - t * 0.06).clamp(0.94, 1.0),
              child: child,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(36),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.45),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.textPrimary.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                data.icon,
                size: 64,
                color: AppColors.primaryBrown,
              ),
            ),
            const SizedBox(height: 40),
            Text(
              data.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              data.subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunitoSans(
                fontSize: 15,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IntroPageData {
  const _IntroPageData({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}
