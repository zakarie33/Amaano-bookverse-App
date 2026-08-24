import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/cart_order_model.dart';

class OrderProcessTimeline extends StatelessWidget {
  const OrderProcessTimeline({super.key, required this.order});

  final CartOrderModel order;

  @override
  Widget build(BuildContext context) {
    final status = order.status.toLowerCase();
    final step3Label = status == 'rejected'
        ? 'Rejected'
        : status == 'approved'
            ? 'Approved'
            : 'Approved / Rejected';
    final steps = [
      _StepData('Payment Submitted', true, false),
      _StepData(
        'Waiting Admin Review',
        status == 'pending' || status == 'approved' || status == 'rejected',
        status == 'pending',
      ),
      _StepData(
        step3Label,
        status == 'approved' || status == 'rejected',
        false,
        isError: status == 'rejected',
        isSuccess: status == 'approved',
      ),
      _StepData(
        'Library Access',
        status == 'approved',
        false,
        isSuccess: status == 'approved',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          _TimelineRow(
            step: steps[i],
            index: i + 1,
            isLast: i == steps.length - 1,
          ),
        ],
        if (order.isRejected &&
            order.adminNote != null &&
            order.adminNote!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.danger.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Admin note: ${order.adminNote}',
              style: const TextStyle(color: AppColors.danger, height: 1.4),
            ),
          ),
        ],
        if (order.isApproved) ...[
          const SizedBox(height: 4),
          Text(
            'Your books are available in your library.',
            style: TextStyle(
              color: AppColors.success.withValues(alpha: 0.9),
              fontSize: 13,
            ),
          ),
        ],
      ],
    );
  }
}

class _StepData {
  const _StepData(
    this.label,
    this.active,
    this.current, {
    this.isError = false,
    this.isSuccess = false,
  });

  final String label;
  final bool active;
  final bool current;
  final bool isError;
  final bool isSuccess;
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.step,
    required this.index,
    required this.isLast,
  });

  final _StepData step;
  final int index;
  final bool isLast;

  Color get _dotColor {
    if (step.isError) return AppColors.danger;
    if (step.isSuccess || step.current) return AppColors.caramel;
    if (step.active) return AppColors.caramelDark;
    return AppColors.tortillaAlt;
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: step.active
                      ? _dotColor.withValues(alpha: 0.2)
                      : AppColors.tortillaAlt,
                  shape: BoxShape.circle,
                  border: Border.all(color: _dotColor, width: 2),
                ),
                child: Text(
                  '$index',
                  style: TextStyle(
                    color: step.active
                        ? AppColors.espresso
                        : AppColors.textOnCardMuted,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: step.active
                        ? AppColors.caramel.withValues(alpha: 0.5)
                        : AppColors.tortillaAlt,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Text(
                step.label,
                style: TextStyle(
                  color: step.active
                      ? AppColors.espresso
                      : AppColors.textOnCardMuted,
                  fontWeight:
                      step.current ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
