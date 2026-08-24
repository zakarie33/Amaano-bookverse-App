import 'package:flutter/material.dart';

import '../constants/app_typography.dart';
import '../services/auth_service.dart';
import 'package:provider/provider.dart';

/// Personalized greeting block shown at the top of the home feed.
class HomeGreetingHeader extends StatelessWidget {
  const HomeGreetingHeader({super.key});

  String _firstName(AuthService auth) {
    final name = auth.user?.name.trim();
    if (name == null || name.isEmpty) return 'Reader';
    return name.split(RegExp(r'\s+')).first;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final firstName = _firstName(auth);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hi, $firstName! ☀️', style: AppTypography.greetingTitle),
          const SizedBox(height: 4),
          Text(
            "Let's find your next read.",
            style: AppTypography.greetingSubtitle,
          ),
        ],
      ),
    );
  }
}
