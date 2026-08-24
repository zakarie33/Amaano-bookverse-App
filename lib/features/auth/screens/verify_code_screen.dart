import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/widgets/app_button.dart';
import 'onboarding_tokens_screen.dart';
import 'verify_method_screen.dart';

class VerifyCodeScreen extends StatefulWidget {
  const VerifyCodeScreen({super.key, this.args});

  final VerifyCodeArgs? args;

  static const String routeName = '/verify';

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final _codeController = TextEditingController();
  late VerifyCodeArgs _args;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    if (widget.args != null) {
      _args = widget.args!;
    } else if (routeArgs is VerifyCodeArgs) {
      _args = routeArgs;
    } else if (routeArgs is Map) {
      _args = VerifyCodeArgs(
        email: routeArgs['email']?.toString() ?? '',
        phone: routeArgs['phone']?.toString(),
        method: VerificationMethod.email,
      );
    } else if (routeArgs is String) {
      _args = VerifyCodeArgs(email: routeArgs);
    } else {
      _args = const VerifyCodeArgs(email: '');
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final code = _codeController.text.trim();
    if (code.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the 6-digit verification code')),
      );
      return;
    }

    final auth = context.read<AuthService>();
    final ok = await auth.verifyEmailCode(email: _args.email, code: code);
    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email verified. Complete your profile to continue.'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pushNamedAndRemoveUntil(
        OnboardingTokensScreen.routeName,
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.lastError ?? 'Verification failed'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  Future<void> _resend() async {
    final auth = context.read<AuthService>();
    final ok = await auth.resendEmailCode(_args.email);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Verification code sent again' : auth.lastError ?? 'Could not resend',
        ),
        backgroundColor: ok ? AppColors.success : AppColors.danger,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final target = _args.method == VerificationMethod.whatsapp
        ? (_args.phone ?? _args.email)
        : _args.email;

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
                const SizedBox(height: 24),
                Text(
                  'Verify your email',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.tortilla,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Enter the 6-digit code sent to $target',
                  style: const TextStyle(color: AppColors.mutedText),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.tortilla,
                    fontSize: 28,
                    letterSpacing: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  decoration: InputDecoration(
                    hintText: '000000',
                    hintStyle: TextStyle(
                      color: AppColors.muted.withValues(alpha: 0.5),
                      letterSpacing: 12,
                    ),
                    filled: true,
                    fillColor: AppColors.espressoSoft.withValues(alpha: 0.35),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const Spacer(),
                AppButton(
                  label: 'Verify',
                  loading: auth.isLoading,
                  onPressed: _submit,
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: auth.isLoading ? null : _resend,
                  child: const Text(
                    'Resend code',
                    style: TextStyle(color: AppColors.caramel),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed(
                      VerifyMethodScreen.routeName,
                      arguments: {
                        'email': _args.email,
                        'phone': _args.phone,
                      },
                    );
                  },
                  child: const Text(
                    'Change verification method',
                    style: TextStyle(color: AppColors.mutedText),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
