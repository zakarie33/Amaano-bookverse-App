import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/auth_guard.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/content_card.dart';
import '../cart_provider.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  static const String routeName = '/cart';

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final currency = NumberFormat.simpleCurrency();

    return Scaffold(
      backgroundColor: AppColors.espresso,
      appBar: AppBar(
        title: const Text('Your cart'),
        backgroundColor: AppColors.espressoDeep,
        foregroundColor: AppColors.tortilla,
        elevation: 0,
      ),
      body: cart.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 64,
                    color: AppColors.muted.withValues(alpha: 0.6),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Your cart is empty',
                    style: TextStyle(
                      color: AppColors.mutedText,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return Stack(
                        children: [
                          ContentCard(item: item.content, compact: true),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () => cart.updateQuantity(
                                    item.content.id,
                                    item.quantity - 1,
                                  ),
                                  icon: const Icon(
                                    Icons.remove_circle_outline,
                                    color: AppColors.espresso,
                                  ),
                                ),
                                Text(
                                  '${item.quantity}',
                                  style: const TextStyle(
                                    color: AppColors.textOnCard,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => cart.updateQuantity(
                                    item.content.id,
                                    item.quantity + 1,
                                  ),
                                  icon: const Icon(
                                    Icons.add_circle_outline,
                                    color: AppColors.espresso,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: AppColors.espressoDeep,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Subtotal',
                            style: TextStyle(color: AppColors.mutedText),
                          ),
                          Text(
                            currency.format(cart.subtotal),
                            style: const TextStyle(
                              color: AppColors.tortilla,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      AppButton(
                        label: 'Checkout',
                        onPressed: () => requireLogin(
                          context,
                          () => Navigator.of(context).pushNamed(
                            CheckoutScreen.routeName,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
