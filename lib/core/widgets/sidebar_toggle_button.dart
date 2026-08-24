import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Opens the root [Scaffold] navigation drawer.
class SidebarToggleButton extends StatelessWidget {
  const SidebarToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () {
          final scaffold = Scaffold.maybeOf(context);
          if (scaffold?.hasDrawer ?? false) {
            scaffold!.openDrawer();
          }
        },
        borderRadius: BorderRadius.circular(14),
        child: const Padding(
          padding: EdgeInsets.all(10),
          child: Icon(
            Icons.menu_rounded,
            color: AppColors.textPrimary,
            size: 26,
          ),
        ),
      ),
    );
  }
}
