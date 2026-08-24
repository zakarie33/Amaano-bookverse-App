import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/cart_order_model.dart';
import '../../../core/services/api_service.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/order_process_timeline.dart';
import '../../library/screens/my_library_screen.dart';

class MyPurchasesScreen extends StatefulWidget {
  const MyPurchasesScreen({super.key});

  static const String routeName = '/my-purchases';

  @override
  State<MyPurchasesScreen> createState() => _MyPurchasesScreenState();
}

class _MyPurchasesScreenState extends State<MyPurchasesScreen> {
  final _api = ApiService();
  bool _loading = true;
  List<CartOrderModel> _orders = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await _api.get(ApiConstants.myPurchases);
      if (data is Map<String, dynamic>) {
        final list = data['cart_orders'];
        if (list is List) {
          _orders = list
              .whereType<Map>()
              .map((e) => CartOrderModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
      }
    } catch (_) {
      _orders = [];
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return AppColors.danger;
      default:
        return AppColors.caramelDark;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.simpleCurrency();

    return Scaffold(
      backgroundColor: AppColors.espresso,
      appBar: AppBar(
        title: const Text('My Purchases'),
        backgroundColor: AppColors.espressoDeep,
        foregroundColor: AppColors.tortilla,
      ),
      body: _loading
          ? const LoadingView()
          : _orders.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'No purchase requests yet.\nCheckout paid books to see your approval process here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.mutedText, height: 1.5),
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  color: AppColors.caramel,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _orders.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final order = _orders[index];
                      final status = order.status;

                      return Card(
                        color: AppColors.cream,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Order #${order.id}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.espresso,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _statusColor(status)
                                          .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      status[0].toUpperCase() +
                                          status.substring(1),
                                      style: TextStyle(
                                        color: _statusColor(status),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${order.itemCount} item(s) · ${currency.format(order.totalAmount)}',
                                style: const TextStyle(
                                    color: AppColors.textOnCardMuted),
                              ),
                              if (order.paymentMethod != null)
                                Text(
                                  'Via ${order.paymentMethod}',
                                  style: const TextStyle(
                                    color: AppColors.textOnCardMuted,
                                    fontSize: 13,
                                  ),
                                ),
                              if (order.transactionId != null)
                                Text(
                                  'Ref: ${order.transactionId}',
                                  style: const TextStyle(
                                    color: AppColors.espresso,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              if (order.fulfillmentType != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  order.fulfillmentType == 'delivery'
                                      ? 'Delivery · ${order.deliveryCity ?? ''}'
                                      : 'Pickup',
                                  style: const TextStyle(
                                    color: AppColors.textOnCardMuted,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 16),
                              OrderProcessTimeline(order: order),
                              if (order.isApproved) ...[
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () => Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) =>
                                            const MyLibraryScreen(),
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.caramel,
                                      foregroundColor: AppColors.espressoDeep,
                                    ),
                                    child: const Text('Open Library'),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
