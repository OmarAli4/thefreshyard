import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/customer.dart';

class OrderCard extends StatelessWidget {
  final CustomerOrder order;

  const OrderCard({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final bool isFulfilled =
        order.fulfillmentStatus.toUpperCase() == 'FULFILLED';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.brandDarkGreen.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.shopping_bag_outlined,
                    color: AppColors.brandDarkGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Order #${order.orderNumber}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.brandDarkGreen,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isFulfilled
                      ? Colors.green[100]
                      : Colors.amber[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  order.fulfillmentStatus,
                  style: TextStyle(
                    color: isFulfilled
                        ? Colors.green[900]
                        : Colors.amber[900],
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (order.itemTitles.isNotEmpty)
            Text(
              order.itemTitles.join(', '),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 13,
              ),
            ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.processedAt.split('T').first,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              Text(
                'LE ${order.totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: AppColors.brandDarkGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
