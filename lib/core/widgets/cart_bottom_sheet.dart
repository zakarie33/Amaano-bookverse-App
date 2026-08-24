import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../utils/auth_guard.dart';
import '../../features/cart/cart_provider.dart';
import '../../features/cart/screens/checkout_screen.dart';

void showCartBottomSheet(BuildContext context) {
  requireLogin(context, () {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _CartBottomSheet(),
    );
  });
}

class _CartBottomSheet extends StatelessWidget {
  const _CartBottomSheet();

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final currency = NumberFormat.simpleCurrency();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.72,
      ),
      decoration: const BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.tortillaAlt,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
            child: Row(
              children: [
                const Icon(Icons.shopping_cart_rounded, color: AppColors.espresso),
                const SizedBox(width: 8),
                Text(
                  'Your cart (${cart.itemCount})',
                  style: const TextStyle(
                    color: AppColors.espresso,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: AppColors.espressoSoft),
                ),
              ],
            ),
          ),
          if (cart.items.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              child: Column(
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 56,
                    color: AppColors.caramel.withValues(alpha: 0.6),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Your cart is empty',
                    style: TextStyle(
                      color: AppColors.espresso,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Browse books and tap the cart icon to add titles.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textOnCardMuted, height: 1.4),
                  ),
                ],
              ),
            )
          else ...[
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                itemCount: cart.items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final line = cart.items[index];
                  final item = line.content;
                  return Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.tortillaAlt.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            width: 52,
                            height: 72,
                            child: item.coverUrl != null && item.coverUrl!.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: item.coverUrl!,
                                    fit: BoxFit.cover,
                                  )
                                : ColoredBox(
                                    color: AppColors.espressoSoft.withValues(alpha: 0.3),
                                    child: const Icon(Icons.menu_book_rounded,
                                        color: AppColors.caramel),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.espresso,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                currency.format(line.lineTotal),
                                style: const TextStyle(
                                  color: AppColors.caramelDark,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => cart.removeItem(item.id),
                          icon: const Icon(Icons.delete_outline_rounded,
                              color: AppColors.espressoSoft),
                          tooltip: 'Remove',
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: BoxDecoration(
                color: AppColors.tortillaAlt.withValues(alpha: 0.5),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Subtotal',
                          style: TextStyle(
                            color: AppColors.espresso,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          currency.format(cart.subtotal),
                          style: const TextStyle(
                            color: AppColors.espresso,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.of(context).pushNamed(CheckoutScreen.routeName);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.caramel,
                          foregroundColor: AppColors.espressoDeep,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Checkout',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
