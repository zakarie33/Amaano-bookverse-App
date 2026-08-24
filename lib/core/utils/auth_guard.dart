import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../widgets/login_required_sheet.dart';

/// Runs [action] only when the user is logged in; otherwise shows login/register sheet.
void requireLogin(BuildContext context, VoidCallback action) {
  final auth = context.read<AuthService>();
  if (auth.isLoggedIn) {
    action();
  } else {
    showLoginRequiredDialog(context);
  }
}

/// Returns true when logged in; otherwise shows login/register sheet and returns false.
bool ensureLoggedIn(BuildContext context) {
  final auth = context.read<AuthService>();
  if (auth.isLoggedIn) return true;
  showLoginRequiredDialog(context);
  return false;
}
