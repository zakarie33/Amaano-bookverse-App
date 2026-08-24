import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/onboarding_options.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/widgets/app_button.dart';
import 'login_screen.dart';

class OnboardingTokensScreen extends StatefulWidget {
  const OnboardingTokensScreen({super.key});

  static const String routeName = '/onboarding';

  @override
  State<OnboardingTokensScreen> createState() => _OnboardingTokensScreenState();
}

class _OnboardingTokensScreenState extends State<OnboardingTokensScreen> {
  final Set<String> _bookInterests = {};
  final Set<String> _readingPreferences = {};
  final Set<String> _researchInterests = {};
  String? _academicLevel;

  Future<void> _submit() async {
    if (_bookInterests.isEmpty ||
        _readingPreferences.isEmpty ||
        _academicLevel == null ||
        _researchInterests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please complete all sections: book interests, usage preferences, academic level, and research topics.',
          ),
        ),
      );
      return;
    }

    final auth = context.read<AuthService>();
    if (!auth.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Session expired. Please verify your email again before continuing.',
          ),
          backgroundColor: AppColors.danger,
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
      return;
    }

    final ok = await auth.submitOnboarding(
      bookInterests: _bookInterests.toList(),
      readingPreferences: _readingPreferences.toList(),
      academicLevel: _academicLevel!,
      researchInterests: _researchInterests.toList(),
    );
    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your account is ready. Please log in to continue.'),
          backgroundColor: AppColors.success,
        ),
      );
      await auth.logout();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        LoginScreen.routeName,
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.lastError ?? 'Could not save preferences'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.espresso, AppColors.espressoDark],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Complete Your BookVerse Profile',
                      style: TextStyle(
                        color: AppColors.tortilla,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tap the pills that match your reading and research interests.',
                      style: TextStyle(color: AppColors.mutedText, height: 1.4),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  children: [
                    _SectionTitle('Book interests'),
                    _TokenWrap(
                      options: OnboardingOptions.bookInterests,
                      selected: _bookInterests,
                      onToggle: (v) => setState(() {
                        if (_bookInterests.contains(v)) {
                          _bookInterests.remove(v);
                        } else {
                          _bookInterests.add(v);
                        }
                      }),
                    ),
                    const SizedBox(height: 20),
                    _SectionTitle('How you use BookVerse'),
                    _TokenWrap(
                      options: OnboardingOptions.readingPreferences,
                      selected: _readingPreferences,
                      onToggle: (v) => setState(() {
                        if (_readingPreferences.contains(v)) {
                          _readingPreferences.remove(v);
                        } else {
                          _readingPreferences.add(v);
                        }
                      }),
                    ),
                    const SizedBox(height: 20),
                    _SectionTitle('Academic level'),
                    _TokenWrap(
                      options: OnboardingOptions.academicLevels,
                      selected: _academicLevel != null ? {_academicLevel!} : {},
                      onToggle: (v) => setState(() {
                        _academicLevel = _academicLevel == v ? null : v;
                      }),
                    ),
                    const SizedBox(height: 20),
                    _SectionTitle('Research interests'),
                    _TokenWrap(
                      options: OnboardingOptions.researchInterests,
                      selected: _researchInterests,
                      onToggle: (v) => setState(() {
                        if (_researchInterests.contains(v)) {
                          _researchInterests.remove(v);
                        } else {
                          _researchInterests.add(v);
                        }
                      }),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: AppButton(
                  label: 'Continue to BookVerse',
                  loading: auth.isLoading,
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.tortilla,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
    );
  }
}

class _TokenWrap extends StatelessWidget {
  const _TokenWrap({
    required this.options,
    required this.selected,
    required this.onToggle,
  });

  final List<String> options;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options
          .map(
            (label) => _OnboardingToken(
              label: label,
              selected: selected.contains(label),
              onTap: () => onToggle(label),
            ),
          )
          .toList(),
    );
  }
}

class _OnboardingToken extends StatelessWidget {
  const _OnboardingToken({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? AppColors.caramel : AppColors.tortilla,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.caramel : AppColors.softBorder,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.caramel.withValues(alpha: 0.22),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.espressoDeep : AppColors.espresso,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
