import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/onboarding_options.dart';
import '../../../core/storage/preferences_service.dart';
import '../../../core/widgets/app_button.dart';
import 'login_screen.dart';

/// Post-registration interests screen — saved locally until the user logs in.
class CompleteProfileInterestsScreen extends StatefulWidget {
  const CompleteProfileInterestsScreen({super.key});

  static const String routeName = '/complete-profile-interests';

  @override
  State<CompleteProfileInterestsScreen> createState() =>
      _CompleteProfileInterestsScreenState();
}

class _CompleteProfileInterestsScreenState
    extends State<CompleteProfileInterestsScreen> {
  final Set<String> _bookInterests = {};
  final Set<String> _usagePreferences = {};
  bool _saving = false;

  Future<void> _continue({bool skip = false}) async {
    setState(() => _saving = true);
    try {
      if (!skip) {
        await PreferencesService().savePendingProfileInterests(
          bookInterests: _bookInterests.toList(),
          usagePreferences: _usagePreferences.toList(),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }

    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      LoginScreen.routeName,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.espresso, AppColors.espressoDark],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Complete Your BookVerse Profile',
                      style: GoogleFonts.poppins(
                        color: AppColors.tortilla,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the interests that match your reading and research interests.',
                      style: GoogleFonts.poppins(
                        color: AppColors.mutedText,
                        fontSize: 14,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  children: [
                    _SectionTitle('Book interests'),
                    _InterestChipWrap(
                      options: OnboardingOptions.bookInterests,
                      selected: _bookInterests,
                      onToggle: (value) => setState(() {
                        if (_bookInterests.contains(value)) {
                          _bookInterests.remove(value);
                        } else {
                          _bookInterests.add(value);
                        }
                      }),
                    ),
                    const SizedBox(height: 22),
                    _SectionTitle('How you use BookVerse'),
                    _InterestChipWrap(
                      options: OnboardingOptions.registrationUsagePreferences,
                      selected: _usagePreferences,
                      onToggle: (value) => setState(() {
                        if (_usagePreferences.contains(value)) {
                          _usagePreferences.remove(value);
                        } else {
                          _usagePreferences.add(value);
                        }
                      }),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                child: TextButton(
                  onPressed: _saving ? null : () => _continue(skip: true),
                  child: Text(
                    'Skip for now',
                    style: GoogleFonts.poppins(
                      color: AppColors.mutedText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: AppButton(
                  label: 'Continue to BookVerse',
                  loading: _saving,
                  onPressed: _saving ? null : () => _continue(),
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
        style: GoogleFonts.poppins(
          color: AppColors.tortilla,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
    );
  }
}

class _InterestChipWrap extends StatelessWidget {
  const _InterestChipWrap({
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
            (label) => _InterestChip(
              label: label,
              selected: selected.contains(label),
              onTap: () => onToggle(label),
            ),
          )
          .toList(),
    );
  }
}

class _InterestChip extends StatelessWidget {
  const _InterestChip({
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
          style: GoogleFonts.poppins(
            color: selected ? AppColors.espressoDeep : AppColors.espresso,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
