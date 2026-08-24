import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/auth_flow_config.dart';
import '../../../core/constants/legal_content.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_input.dart';
import '../../../core/widgets/legal_sheet.dart';
import 'complete_profile_interests_screen.dart';
import 'login_screen.dart';
import 'verify_method_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  static const String routeName = '/register';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _privacyChecked = false;
  bool _termsChecked = false;
  String? _agreementError;

  @override
  void initState() {
    super.initState();
    for (final c in [
      _nameController,
      _emailController,
      _phoneController,
      _passwordController,
      _confirmController,
    ]) {
      c.addListener(_onFieldChanged);
    }
  }

  void _onFieldChanged() => setState(() {});

  @override
  void dispose() {
    for (final c in [
      _nameController,
      _emailController,
      _phoneController,
      _passwordController,
      _confirmController,
    ]) {
      c
        ..removeListener(_onFieldChanged)
        ..dispose();
    }
    super.dispose();
  }

  bool get _isFormReady {
    return _privacyChecked &&
        _termsChecked &&
        FormValidators.fullName(_nameController.text) == null &&
        FormValidators.email(_emailController.text) == null &&
        FormValidators.phone(_phoneController.text) == null &&
        FormValidators.isPasswordStrong(_passwordController.text) &&
        FormValidators.confirmPassword(
              _confirmController.text,
              _passwordController.text,
            ) ==
            null;
  }

  bool _validateAgreements() {
    final error = FormValidators.agreements(
      privacyAccepted: _privacyChecked,
      termsAccepted: _termsChecked,
    );
    setState(() => _agreementError = error);
    return error == null;
  }

  Future<void> _submit() async {
    final formValid = _formKey.currentState!.validate();
    final agreementsValid = _validateAgreements();
    if (!formValid || !agreementsValid) return;

    final auth = context.read<AuthService>();
    final phone = _phoneController.text.trim().replaceAll(RegExp(r'\s+'), '');
    final result = await auth.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: phone,
      password: _passwordController.text,
      privacyAgreed: _privacyChecked,
      termsAgreed: _termsChecked,
    );
    if (!mounted) return;

    if (result != null && result.success) {
      // TODO: Verification temporarily disabled until SMS/API verification is added.
      if (!AuthFlowConfig.verificationRequired) {
        Navigator.of(context).pushReplacementNamed(
          CompleteProfileInterestsScreen.routeName,
        );
        return;
      }

      Navigator.of(context).pushReplacementNamed(
        VerifyMethodScreen.routeName,
        arguments: {
          'email': _emailController.text.trim(),
          'phone': phone,
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.lastError ?? 'Registration failed'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final passwordRules =
        FormValidators.passwordRequirements(_passwordController.text);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.tortilla,
        title: const Text('Create account'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.espresso, AppColors.espressoDark],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppInput(
                    controller: _nameController,
                    label: 'Full name',
                    hint: 'First Last',
                    prefixIcon: Icons.person_outline,
                    textInputAction: TextInputAction.next,
                    validator: FormValidators.fullName,
                  ),
                  const SizedBox(height: 16),
                  AppInput(
                    controller: _emailController,
                    label: 'Email',
                    hint: 'you@example.com',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    textInputAction: TextInputAction.next,
                    validator: FormValidators.email,
                  ),
                  const SizedBox(height: 16),
                  AppInput(
                    controller: _phoneController,
                    label: 'Phone number',
                    hint: '+252 61 000 0000',
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_outlined,
                    textInputAction: TextInputAction.next,
                    validator: FormValidators.phone,
                  ),
                  const SizedBox(height: 16),
                  AppInput(
                    controller: _passwordController,
                    label: 'Password',
                    obscureText: true,
                    showVisibilityToggle: true,
                    prefixIcon: Icons.lock_outline,
                    textInputAction: TextInputAction.next,
                    validator: FormValidators.password,
                  ),
                  if (_passwordController.text.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _PasswordRequirementsList(rules: passwordRules),
                  ],
                  const SizedBox(height: 16),
                  AppInput(
                    controller: _confirmController,
                    label: 'Confirm password',
                    obscureText: true,
                    showVisibilityToggle: true,
                    prefixIcon: Icons.lock_outline,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) {
                      if (_isFormReady && !auth.isLoading) _submit();
                    },
                    validator: (v) => FormValidators.confirmPassword(
                      v,
                      _passwordController.text,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _AgreementCheckbox(
                    value: _privacyChecked,
                    onChanged: (v) => setState(() {
                      _privacyChecked = v ?? false;
                      _agreementError = null;
                    }),
                    label: 'I agree to the ',
                    linkText: 'Privacy Policy',
                    onLinkTap: () => showLegalSheet(
                      context,
                      title: LegalContent.privacyPolicyTitle,
                      body: LegalContent.privacyPolicyBody,
                    ),
                  ),
                  _AgreementCheckbox(
                    value: _termsChecked,
                    onChanged: (v) => setState(() {
                      _termsChecked = v ?? false;
                      _agreementError = null;
                    }),
                    label: 'I agree to the ',
                    linkText: 'Terms and Conditions',
                    onLinkTap: () => showLegalSheet(
                      context,
                      title: LegalContent.termsTitle,
                      body: LegalContent.termsBody,
                    ),
                  ),
                  if (_agreementError != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _agreementError!,
                      style: const TextStyle(
                        color: AppColors.danger,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  AppButton(
                    label: 'Create Account',
                    loading: auth.isLoading,
                    onPressed: _isFormReady && !auth.isLoading ? _submit : null,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account? ',
                        style: TextStyle(color: AppColors.mutedText),
                      ),
                      TextButton(
                        onPressed: auth.isLoading
                            ? null
                            : () => Navigator.of(context)
                                .pushReplacementNamed(LoginScreen.routeName),
                        child: const Text(
                          'Log in',
                          style: TextStyle(
                            color: AppColors.caramel,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PasswordRequirementsList extends StatelessWidget {
  const _PasswordRequirementsList({required this.rules});

  final List<PasswordRequirement> rules;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.espressoSoft.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.espressoLight.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Password must include:',
            style: TextStyle(
              color: AppColors.mutedText,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...rules.map(
            (rule) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(
                    rule.met ? Icons.check_circle : Icons.circle_outlined,
                    size: 16,
                    color: rule.met ? AppColors.success : AppColors.muted,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      rule.label,
                      style: TextStyle(
                        color: rule.met
                            ? AppColors.tortilla
                            : AppColors.mutedText,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AgreementCheckbox extends StatelessWidget {
  const _AgreementCheckbox({
    required this.value,
    required this.onChanged,
    required this.label,
    required this.linkText,
    required this.onLinkTap,
  });

  final bool value;
  final ValueChanged<bool?> onChanged;
  final String label;
  final String linkText;
  final VoidCallback onLinkTap;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.caramel,
      checkColor: AppColors.espressoDeep,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      title: RichText(
        text: TextSpan(
          style: const TextStyle(color: AppColors.mutedText, fontSize: 14),
          children: [
            TextSpan(text: label),
            TextSpan(
              text: linkText,
              style: const TextStyle(
                color: AppColors.caramel,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()..onTap = onLinkTap,
            ),
          ],
        ),
      ),
    );
  }
}
