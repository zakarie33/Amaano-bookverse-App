import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../../features/cart/cart_provider.dart';
import 'cart_bottom_sheet.dart';

/// Premium pill cart FAB — sits above bottom nav without blocking cards.
class FloatingCartButton extends StatelessWidget {
  const FloatingCartButton({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final count = cart.itemCount;
    final currency = NumberFormat.simpleCurrency();

    return Material(
      elevation: 8,
      shadowColor: AppColors.espressoDeep.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(28),
      color: AppColors.caramel,
      child: InkWell(
        onTap: () => showCartBottomSheet(context),
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Badge(
                isLabelVisible: count > 0,
                label: Text(
                  count > 99 ? '99+' : '$count',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                backgroundColor: AppColors.espressoDeep,
                child: const Icon(
                  Icons.shopping_cart_rounded,
                  color: AppColors.espressoDeep,
                  size: 22,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 10),
                Text(
                  currency.format(cart.subtotal),
                  style: const TextStyle(
                    color: AppColors.espressoDeep,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ] else ...[
                const SizedBox(width: 8),
                const Text(
                  'Cart',
                  style: TextStyle(
                    color: AppColors.espressoDeep,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
