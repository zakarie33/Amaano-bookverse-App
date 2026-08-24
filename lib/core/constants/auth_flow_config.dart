/// Central switch for email/SMS verification gating in the Flutter app.
///
/// TODO: Verification temporarily disabled until SMS/API verification is added.
class AuthFlowConfig {
  AuthFlowConfig._();

  /// When `false`, login and registration skip verify-method / verify-code screens.
  static const bool verificationRequired = false;
}
