import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/whatsapp_coming_soon_dialog.dart';
import 'verify_code_screen.dart';

// TODO: Verification temporarily disabled until SMS/API verification is added.
// This screen remains registered in app routes but is not used in login/register flow.

class VerifyMethodScreen extends StatefulWidget {
  const VerifyMethodScreen({super.key, this.email, this.phone});

  final String? email;
  final String? phone;

  static const String routeName = '/verify-method';

  @override
  State<VerifyMethodScreen> createState() => _VerifyMethodScreenState();
}

class _VerifyMethodScreenState extends State<VerifyMethodScreen> {
  late String _email;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      _email = args['email']?.toString() ?? widget.email ?? '';
    } else {
      _email = widget.email ?? '';
    }
  }

  void _goToEmailVerification() {
    Navigator.of(context).pushReplacementNamed(
      VerifyCodeScreen.routeName,
      arguments: VerifyCodeArgs(
        email: _email,
        method: VerificationMethod.email,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.espresso, AppColors.espressoDark],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                Text(
                  'Verify Your Account',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.tortilla,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Choose how you want to receive your verification code.',
                  style: TextStyle(color: AppColors.mutedText, height: 1.4),
                ),
                const SizedBox(height: 32),
                _MethodCard(
                  icon: Icons.email_outlined,
                  title: 'Email Code',
                  subtitle: 'We will send a 6-digit code to $_email',
                  enabled: true,
                  onTap: _goToEmailVerification,
                ),
                const SizedBox(height: 16),
                _MethodCard(
                  icon: Icons.chat_outlined,
                  title: 'WhatsApp Code',
                  subtitle: 'Coming soon — use email verification for now',
                  enabled: false,
                  badge: 'Coming soon',
                  onTap: () => showWhatsAppComingSoonDialog(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MethodCard extends StatelessWidget {
  const _MethodCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.enabled = true,
    this.badge,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool enabled;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled
          ? AppColors.tortilla
          : AppColors.tortilla.withValues(alpha: 0.72),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(icon, size: 36, color: AppColors.espresso),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: AppColors.textOnCard,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (badge != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.caramel.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              badge!,
                              style: const TextStyle(
                                color: AppColors.espresso,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textOnCardMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.espressoSoft),
            ],
          ),
        ),
      ),
    );
  }
}

enum VerificationMethod { email, whatsapp }

class VerifyCodeArgs {
  const VerifyCodeArgs({
    required this.email,
    this.phone,
    this.method = VerificationMethod.email,
  });

  final String email;
  final String? phone;
  final VerificationMethod method;
}
