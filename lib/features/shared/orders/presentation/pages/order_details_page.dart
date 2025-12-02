// lib/features/orders/presentation/pages/order_details_page.dart

import 'package:admin_panel/features/shared/orders/domain/entities/order_item.dart';
import 'package:admin_panel/features/shared/orders/presentation/widgets/order_offer_display_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/theme/colors.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../domain/entities/order.dart';
import '../bloc/orders_bloc.dart';
import '../bloc/orders_event.dart';
import '../bloc/orders_state.dart';
import '../widgets/order_status_chip.dart';
import '../widgets/payment_status_chip.dart';
import '../widgets/order_timeline.dart';

class OrderDetailsPage extends StatelessWidget {
  final String orderId;
  final bool isAdminView;

  const OrderDetailsPage({
    super.key,
    required this.orderId,
    required this.isAdminView,
  });

  @override
  Widget build(BuildContext context) {
    print('order details page, is admin view, $isAdminView');

    return BlocProvider(
      create: (context) {
        final bloc = sl<OrdersBloc>();
        bloc.add(LoadOrderDetails(orderId));
        return bloc;
      },
      child: _OrderDetailsView(isAdminView),
    );
  }
}

class _OrderDetailsView extends StatelessWidget {
  final bool isAdminView;
  const _OrderDetailsView(this.isAdminView);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Print functionality coming soon'),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<OrdersBloc, OrdersState>(
        listener: (context, state) {
          if (state is OrderStatusUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            final bloc = context.read<OrdersBloc>();
            final currentState = bloc.state;
            if (currentState is OrderDetailsLoaded) {
              bloc.add(LoadOrderDetails(currentState.order.id));
            }
          }

          if (state is OrderCancelled) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.orange,
              ),
            );
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          if (state is OrdersLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is OrderDetailsLoaded) {
            return _buildOrderDetails(context, state.order, isAdminView);
          }

          if (state is OrdersError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 80, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading order',
                    style: AppTextStyles.getH3(context),
                  ),
                  const SizedBox(height: 8),
                  Text(state.message),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildOrderDetails(
    BuildContext context,
    Order order,
    bool isAdminView,
  ) {
    final isWideScreen = MediaQuery.of(context).size.width >= 900;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: isWideScreen
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _buildMainContent(context, order)),
                const SizedBox(width: 24),
                Expanded(child: _buildSidebar(context, order, isAdminView)),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMainContent(context, order),
                const SizedBox(height: 24),
                _buildSidebar(context, order, isAdminView),
              ],
            ),
    );
  }

  Widget _buildMainContent(BuildContext context, Order order) {
    // Separate regular items from offer items
    final regularItems = <OrderItemEntity>[];
    final offerGroups = <String, List<OrderItemEntity>>{};
    final processedItems = <String>{};

    // Group items by offer
    for (final item in order.items) {
      if (processedItems.contains(item.id)) continue;

      if (item.offerId != null && item.offerType != null) {
        // Part of an offer - group by offerId + offerType
        final groupKey = '${item.offerType}_${item.offerId}';
        offerGroups.putIfAbsent(groupKey, () => []);
        offerGroups[groupKey]!.add(item);
        processedItems.add(item.id);
      } else {
        // Regular item (no offer)
        regularItems.add(item);
        processedItems.add(item.id);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Applied Offer Display - Enhanced
        if (order.appliedOfferId != null) ...[
          const SizedBox(height: 24),
          OrderOfferDisplayWidget(
            offerDetails: order.offerDetails,
            discountAmount: order.discountAmount,
          ),
        ],
        // Order Header Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.orderNumber,
                            style: AppTextStyles.getH3(
                              context,
                            ).copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Placed on ${DateFormat('MMMM dd, yyyy - hh:mm a').format(order.createdAt)}',
                            style: AppTextStyles.getBodyMedium(
                              context,
                            ).copyWith(color: AppColors.grey600),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'EGP${order.totalAmount.toStringAsFixed(2)}',
                      style: AppTextStyles.getH2(context).copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    OrderStatusChip(status: order.status),
                    const SizedBox(width: 12),
                    PaymentStatusChip(paymentStatus: order.paymentStatus),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Customer Information
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Customer Information',
                  style: AppTextStyles.getH4(
                    context,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  icon: Icons.person_outline,
                  label: 'Name',
                  value: order.customerName ?? 'N/A',
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: order.customerEmail ?? 'N/A',
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  value: order.customerPhone ?? 'N/A',
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Shipping Address
        if (order.shippingAddress != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Shipping Address',
                    style: AppTextStyles.getH4(
                      context,
                    ).copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    icon: Icons.person_outline,
                    label: 'Recipient',
                    value: order.shippingAddress!.fullName,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    icon: Icons.phone_outlined,
                    label: 'Phone',
                    value: order.shippingAddress!.phoneNumber,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    icon: Icons.location_on_outlined,
                    label: 'Address',
                    value: order.shippingAddress!.fullAddress,
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: 24),

        // Order Items Section - WITH OFFER GROUPING
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Items',
                  style: AppTextStyles.getH4(
                    context,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Display offer groups first
                if (offerGroups.isNotEmpty) ...[
                  ...offerGroups.entries.map((entry) {
                    final items = entry.value;
                    final firstItem = items.first;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildOfferGroupCard(
                        context,
                        items,
                        firstItem.offerType!,
                        order.offerDetails,
                      ),
                    );
                  }),
                  if (regularItems.isNotEmpty) const Divider(height: 32),
                ],

                // Then display regular items
                if (regularItems.isNotEmpty)
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: regularItems.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 24),
                    itemBuilder: (context, index) {
                      final item = regularItems[index];
                      return _buildRegularItem(context, item);
                    },
                  ),

                // Price summary at the bottom
                const Divider(height: 32),
                _buildPriceRow('Subtotal', order.subtotal),
                const SizedBox(height: 8),
                _buildPriceRow('Tax', order.taxAmount),
                const SizedBox(height: 8),
                _buildPriceRow('Shipping', order.shippingAmount),
                if (order.offerDetails != null)
                  if (order.offerDetails!['offers'] != null &&
                      (order.offerDetails!['offers'] as List).isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ...(order.offerDetails!['offers'] as List).map((offer) {
                      if (offer['discount_amount'] > 0) {
                        return _buildPriceRow(
                          offer['offer_title'],
                          -offer['discount_amount'],
                          color: AppColors.success,
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                  ],
                const Divider(height: 24),
                _buildPriceRow('Total', order.totalAmount, isTotal: true),
              ],
            ),
          ),
        ),

        if (order.notes != null && order.notes!.isNotEmpty) ...[
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Notes',
                    style: AppTextStyles.getH4(
                      context,
                    ).copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    order.notes!,
                    style: AppTextStyles.getBodyMedium(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  // Build offer group card (similar to mobile app)
  Widget _buildOfferGroupCard(
    BuildContext context,
    List<OrderItemEntity> items,
    String offerType,
    Map<String, dynamic>? orderOfferDetails,
  ) {
    // Calculate original total from items
    final originalTotal = items.fold<double>(
      0,
      (sum, item) => sum + (item.unitPrice * item.quantity),
    );

    // Get the actual discount for this specific offer from metadata
    double discountAmount = 0;

    if (orderOfferDetails != null && orderOfferDetails['offers'] != null) {
      final offers = orderOfferDetails['offers'] as List;

      try {
        // Find the matching offer by ID
        final matchingOffer = offers.firstWhere(
          (offer) => offer['offer_id'] == items.first.offerId,
        );

        // Get the discount amount that was applied to this offer
        discountAmount =
            (matchingOffer['discount_amount'] as num?)?.toDouble() ?? 0;
      } catch (e) {
        // Offer not found, calculate from items as fallback
        final calculatedTotal = items.fold<double>(
          0,
          (sum, item) => sum + item.totalPrice,
        );
        discountAmount = originalTotal - calculatedTotal;
      }
    } else {
      // Fallback: calculate from items
      final calculatedTotal = items.fold<double>(
        0,
        (sum, item) => sum + item.totalPrice,
      );
      discountAmount = originalTotal - calculatedTotal;
    }

    // Calculate final price after discount
    final finalTotal = originalTotal - discountAmount;
    final savings = discountAmount;

    // Get offer styling
    Color badgeColor;
    IconData icon;
    String label;

    switch (offerType.toLowerCase()) {
      case 'bundle':
        badgeColor = AppColors.info;
        icon = Icons.inventory_2;
        label = 'Bundle Deal';
        break;
      case 'bogo':
        badgeColor = AppColors.success;
        icon = Icons.card_giftcard;
        label = 'BOGO Offer';
        break;
      case 'free_item':
        badgeColor = AppColors.success;
        icon = Icons.redeem;
        label = 'Free Gift';
        break;
      case 'discount':
        badgeColor = AppColors.accent;
        icon = Icons.discount;
        label = 'Discount Offer';
        break;
      case 'min_purchase':
      case 'minpurchase':
        badgeColor = AppColors.secondary;
        icon = Icons.shopping_cart;
        label = 'Min Purchase Offer';
        break;
      default:
        badgeColor = AppColors.primary;
        icon = Icons.local_offer;
        label = 'Special Offer';
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: badgeColor.withValues(alpha: 0.3), width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Offer Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  badgeColor.withValues(alpha: 0.15),
                  badgeColor.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: AppTextStyles.bodyLargeLight.copyWith(
                          color: badgeColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${items.length} items included',
                        style: AppTextStyles.bodySmallLight.copyWith(
                          color: AppColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (savings > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.savings,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Saved EGP ${savings.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Items in the offer
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 16),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _buildOfferItem(context, item);
                  },
                ),

                const Divider(height: 24),

                // Offer Price Summary
                if (offerType == 'bundle')
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.grey50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        if (savings > 0) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Original Price',
                                style: AppTextStyles.bodyMediumLight,
                              ),
                              Text(
                                'EGP ${originalTotal.toStringAsFixed(2)}',
                                style: AppTextStyles.bodyMediumLight.copyWith(
                                  decoration: TextDecoration.lineThrough,
                                  color: AppColors.grey500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'You Saved',
                                style: AppTextStyles.bodyMediumLight.copyWith(
                                  color: AppColors.success,
                                ),
                              ),
                              Text(
                                '-EGP ${savings.toStringAsFixed(2)}',
                                style: AppTextStyles.bodyMediumLight.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 16),
                        ],
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              offerType == 'bundle'
                                  ? 'Bundle Price'
                                  : 'Offer Total',
                              style: AppTextStyles.bodyLargeLight.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'EGP ${finalTotal.toStringAsFixed(2)}',
                              style: AppTextStyles.bodyLargeLight.copyWith(
                                color: badgeColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build item within offer group
  Widget _buildOfferItem(BuildContext context, OrderItemEntity item) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: item.isFreeItem
                ? AppColors.success.withValues(alpha: 0.1)
                : AppColors.grey200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: item.productImage != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item.productImage!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        item.isFreeItem ? Icons.card_giftcard : Icons.image,
                        color: item.isFreeItem
                            ? AppColors.success
                            : AppColors.grey400,
                      );
                    },
                  ),
                )
              : Icon(
                  item.isFreeItem ? Icons.card_giftcard : Icons.shopping_basket,
                  color: item.isFreeItem
                      ? AppColors.success
                      : AppColors.grey400,
                ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.getName('en'),
                      style: AppTextStyles.bodyMediumLight.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (item.isFreeItem)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'FREE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Qty: ${item.quantity.toInt()}${item.isFreeItem ? '' : ' × EGP ${item.unitPrice.toStringAsFixed(2)}'}',
                style: AppTextStyles.bodySmallLight.copyWith(
                  color: AppColors.grey600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          item.isFreeItem
              ? 'FREE'
              : 'EGP ${item.totalPrice.toStringAsFixed(2)}',
          style: AppTextStyles.bodyMediumLight.copyWith(
            fontWeight: FontWeight.bold,
            color: item.isFreeItem ? AppColors.success : AppColors.textDark,
          ),
        ),
      ],
    );
  }

  // Regular item (no offer)
  Widget _buildRegularItem(BuildContext context, OrderItemEntity item) {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.grey200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: item.productImage != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item.productImage!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.image);
                    },
                  ),
                )
              : const Icon(Icons.shopping_basket),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.getName('en'),
                style: AppTextStyles.bodyMediumLight.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Qty: ${item.quantity.toInt()}',
                style: AppTextStyles.bodySmallLight.copyWith(
                  color: AppColors.grey600,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('EGP${item.unitPrice.toStringAsFixed(2)}'),
            Text(
              'EGP${item.totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSidebar(BuildContext context, Order order, bool isAdminView) {
    return Column(
      children: [
        // Order Timeline
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: OrderTimeline(currentStatus: order.status),
          ),
        ),

        const SizedBox(height: 24),

        // Actions
        if (order.status != 'delivered' &&
            order.status != 'cancelled' &&
            !isAdminView)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Actions',
                    style: AppTextStyles.getH4(
                      context,
                    ).copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Confirm Order
                  if (order.canBeConfirmed)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _updateOrderStatus(context, order.id, 'confirmed'),
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Confirm Order'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.info,
                        ),
                      ),
                    ),

                  // Start Preparing
                  if (order.canBePrepared) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _updateOrderStatus(context, order.id, 'preparing'),
                        icon: const Icon(Icons.kitchen),
                        label: const Text('Start Preparing'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                      ),
                    ),
                  ],

                  // Assign Driver & Ship
                  if (order.canBeShipped) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _showMarkAsShippedDialog(context, order.id),
                        icon: const Icon(Icons.local_shipping),
                        label: const Text('Assign Driver & Ship'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                        ),
                      ),
                    ),
                  ],

                  // Mark as Delivered
                  if (order.canBeDelivered) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _updateOrderStatus(context, order.id, 'delivered'),
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Mark as Delivered'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                        ),
                      ),
                    ),
                  ],

                  // Payment Status
                  if (order.paymentStatus == 'pending') ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _updatePaymentStatus(context, order.id, 'paid'),
                        icon: const Icon(Icons.payment),
                        label: const Text('Mark as Paid'),
                      ),
                    ),
                  ],

                  // Cancel Button
                  if (order.canBeCancelled) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showCancelDialog(context, order.id),
                        icon: const Icon(Icons.cancel),
                        label: const Text('Cancel Order'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.grey600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.grey600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(
    String label,
    double amount, {
    bool isTotal = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          'EGP${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: color ?? (isTotal ? AppColors.primary : null),
          ),
        ),
      ],
    );
  }

  void _updateOrderStatus(BuildContext context, String orderId, String status) {
    context.read<OrdersBloc>().add(
      UpdateOrderStatusEvent(orderId: orderId, status: status),
    );
  }

  void _updatePaymentStatus(
    BuildContext context,
    String orderId,
    String paymentStatus,
  ) {
    context.read<OrdersBloc>().add(
      UpdatePaymentStatusEvent(orderId: orderId, paymentStatus: paymentStatus),
    );
  }

  void _showCancelDialog(BuildContext context, String orderId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: AppColors.warning),
            SizedBox(width: 8),
            Text('Cancel Order'),
          ],
        ),
        content: const Text(
          'Are you sure you want to cancel this order? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('No, Keep Order'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<OrdersBloc>().add(CancelOrderEvent(orderId));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Yes, Cancel Order'),
          ),
        ],
      ),
    );
  }

  void _showMarkAsShippedDialog(BuildContext context, String orderId) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      // Get merchandiser ID
      final merchandiserResponse = await Supabase.instance.client
          .from('merchandisers')
          .select('id')
          .eq('profile_id', user.id)
          .single();

      final merchandiserId = merchandiserResponse['id'] as String;

      // Get available drivers
      final driversResponse = await Supabase.instance.client
          .from('drivers')
          .select('''
          id,
          vehicle_type,
          vehicle_number,
          profiles:profile_id(full_name)
        ''')
          .eq('merchandiser_id', merchandiserId)
          .eq('is_active', true)
          .eq('is_available', true);

      if (driversResponse.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'No available drivers. Please ensure drivers are active and available.',
              ),
              backgroundColor: AppColors.warning,
            ),
          );
        }
        return;
      }

      final drivers = driversResponse as List;
      String? selectedDriverId;
      final notesController = TextEditingController();

      if (context.mounted) {
        await showDialog(
          context: context,
          builder: (dialogContext) => BlocProvider(
            create: (context) => sl<OrdersBloc>(),
            child: StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  title: const Text('Assign Driver'),
                  content: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 400,
                      maxHeight: MediaQuery.of(context).size.height * 0.6,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Choose a driver to deliver this order:'),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            initialValue: selectedDriverId,
                            decoration: const InputDecoration(
                              labelText: 'Select Driver',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            items: drivers.map((driver) {
                              final driverId = driver['id'] as String;
                              final profiles =
                                  driver['profiles'] as Map<String, dynamic>?;
                              final driverName =
                                  profiles?['full_name'] as String? ??
                                  'Unknown Driver';
                              final vehicleType =
                                  driver['vehicle_type'] as String?;

                              return DropdownMenuItem(
                                value: driverId,
                                child: Text.rich(
                                  TextSpan(
                                    text: driverName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    children: [
                                      if (vehicleType != null)
                                        TextSpan(
                                          text: '\nVehicle: $vehicleType',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.grey600,
                                          ),
                                        ),
                                    ],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (value) =>
                                setState(() => selectedDriverId = value),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: notesController,
                            decoration: const InputDecoration(
                              labelText: 'Notes (Optional)',
                              hintText: 'Special delivery instructions...',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: selectedDriverId == null
                          ? null
                          : () async {
                              try {
                                // Check if order is already assigned
                                final existingAssignment = await Supabase
                                    .instance
                                    .client
                                    .from('order_assignments')
                                    .select('id')
                                    .eq('order_id', orderId)
                                    .maybeSingle();

                                if (existingAssignment != null) {
                                  if (dialogContext.mounted) {
                                    Navigator.pop(dialogContext);
                                  }
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'This order is already assigned to a driver',
                                        ),
                                        backgroundColor: AppColors.warning,
                                      ),
                                    );
                                  }
                                  return;
                                }

                                // Create assignment first
                                await Supabase.instance.client
                                    .from('order_assignments')
                                    .insert({
                                      'order_id': orderId,
                                      'driver_id': selectedDriverId,
                                      'assigned_by': user.id,
                                      'notes':
                                          notesController.text.trim().isNotEmpty
                                          ? notesController.text.trim()
                                          : null,
                                      'delivery_status': 'assigned',
                                    });

                                // THEN update order status to on_the_way
                                await Supabase.instance.client
                                    .from('orders')
                                    .update({
                                      'status': 'on_the_way',
                                      'updated_at': DateTime.now()
                                          .toIso8601String(),
                                    })
                                    .eq('id', orderId);

                                if (dialogContext.mounted) {
                                  Navigator.pop(dialogContext);
                                }

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Order assigned to driver successfully',
                                      ),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );

                                  // Reload order details
                                  context.read<OrdersBloc>().add(
                                    LoadOrderDetails(orderId),
                                  );
                                }
                              } catch (e) {
                                if (dialogContext.mounted) {
                                  Navigator.pop(dialogContext);
                                }
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: ${e.toString()}'),
                                      backgroundColor: AppColors.error,
                                    ),
                                  );
                                }
                              }
                            },
                      child: const Text('Assign & Ship'),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      }

      notesController.dispose();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
