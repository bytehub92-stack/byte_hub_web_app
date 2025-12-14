// lib/features/delivery/presentation/pages/driver_details_page.dart

import 'package:admin_panel/core/widgets/platform_refresh_wrapper.dart';
import 'package:admin_panel/features/shared/orders/domain/entities/order.dart';
import 'package:admin_panel/features/shared/orders/presentation/pages/order_details_page.dart';
import 'package:admin_panel/features/shared/orders/presentation/widgets/order_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/colors.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../domain/entities/driver.dart';
import '../../domain/entities/order_assignment.dart';
import '../bloc/delivery_bloc.dart';
import '../bloc/delivery_event.dart';
import '../bloc/delivery_state.dart';
import '../widgets/driver_statistics_card.dart';

class DriverDetailsPage extends StatefulWidget {
  final Driver driver;

  const DriverDetailsPage({super.key, required this.driver});

  @override
  State<DriverDetailsPage> createState() => _DriverDetailsPageState();
}

class _DriverDetailsPageState extends State<DriverDetailsPage> {
  String _selectedFilter = 'all'; // all, active, completed

  @override
  void initState() {
    super.initState();
    _loadDriverOrders();
  }

  void _loadDriverOrders() {
    context.read<DeliveryBloc>().add(
          LoadOrderAssignments(
            merchandiserId: widget.driver.merchandiserId,
            driverId: widget.driver.id,
            onlyActive: _selectedFilter == 'active',
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Details'),
      ),
      body: Column(
        children: [
          // Driver Info Header
          _buildDriverHeader(),

          // Filter Tabs
          _buildFilterTabs(),

          // Orders List
          Expanded(
            child: BlocBuilder<DeliveryBloc, DeliveryState>(
              builder: (context, state) {
                if (state is DeliveryLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is DeliveryError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 16),
                        Text('Error', style: AppTextStyles.getH4(context)),
                        const SizedBox(height: 8),
                        Text(state.message),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _loadDriverOrders,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is OrderAssignmentsLoaded) {
                  final filteredAssignments = _filterAssignments(
                    state.assignments,
                  );

                  if (filteredAssignments.isEmpty) {
                    return _buildEmptyState();
                  }

                  return PlatformRefreshWrapper(
                    onRefresh: () async => _loadDriverOrders(),
                    child: ListView.separated(
                      padding:
                          const EdgeInsets.all(AppConstants.defaultPadding),
                      itemCount: filteredAssignments.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        return _buildOrderAssignmentCard(
                          filteredAssignments[index],
                        );
                      },
                    ),
                  );
                }

                return _buildEmptyState();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverHeader() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primary,
                child: Text(
                  widget.driver.fullName[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.driver.fullName,
                      style: AppTextStyles.getH3(context),
                    ),
                    const SizedBox(height: 4),
                    if (widget.driver.phoneNumber != null) ...[
                      Row(
                        children: [
                          const Icon(
                            Icons.phone,
                            size: 16,
                            color: AppColors.grey600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.driver.phoneNumber!,
                            style: AppTextStyles.getBodyMedium(context),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 4),
                    if (widget.driver.vehicleType != null) ...[
                      Row(
                        children: [
                          const Icon(
                            Icons.motorcycle,
                            size: 16,
                            color: AppColors.grey600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.driver.vehicleInfo,
                            style: AppTextStyles.getBodySmall(context),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: widget.driver.isAvailable
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.driver.isAvailable
                          ? Icons.check_circle
                          : Icons.local_shipping,
                      size: 14,
                      color: widget.driver.isAvailable
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.driver.isAvailable ? 'Available' : 'On Delivery',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: widget.driver.isAvailable
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DriverStatisticsCard(driver: widget.driver),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: 12,
      ),
      child: Row(
        children: [
          _buildFilterChip('All', 'all'),
          const SizedBox(width: 8),
          _buildFilterChip('Active', 'active'),
          const SizedBox(width: 8),
          _buildFilterChip('Completed', 'completed'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() => _selectedFilter = value);
          _loadDriverOrders();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.grey100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.grey700,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  List<OrderAssignment> _filterAssignments(List<OrderAssignment> assignments) {
    switch (_selectedFilter) {
      case 'active':
        return assignments
            .where((a) => !a.isCompleted && a.orderStatus != 'delivered')
            .toList();
      case 'completed':
        return assignments
            .where((a) => a.isCompleted || a.orderStatus == 'delivered')
            .toList();
      default:
        return assignments;
    }
  }

  Widget _buildOrderAssignmentCard(OrderAssignment assignment) {
    // Convert OrderAssignment to Order for the OrderCard
    final order = Order(
      id: assignment.orderId,
      customerUserId: '', // Not needed for display
      merchandiserId: widget.driver.merchandiserId,
      orderNumber: assignment.orderNumber ?? 'N/A',
      totalAmount: assignment.orderAmount ?? 0.0,
      status: assignment.orderStatus ?? 'unknown',
      createdAt: assignment.assignedAt,
      subtotal: assignment.orderAmount ?? 0.0,
      taxAmount: 0.0,
      shippingAmount: 0.0,
      discountAmount: 0.0,
      paymentStatus: assignment.paymentStatus ?? 'pending',
      updatedAt: assignment.assignedAt,
      customerName: assignment.customerName,
      customerPhone: assignment.customerPhone,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Delivery Status Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getDeliveryStatusColor(assignment.deliveryStatus)
                .withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getDeliveryStatusIcon(assignment.deliveryStatus),
                size: 14,
                color: _getDeliveryStatusColor(assignment.deliveryStatus),
              ),
              const SizedBox(width: 4),
              Text(
                _getDeliveryStatusLabel(assignment.deliveryStatus),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _getDeliveryStatusColor(assignment.deliveryStatus),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Order Card
        OrderCard(
          order: order,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderDetailsPage(
                  orderId: order.id,
                  isAdminView: false,
                ),
              ),
            );
          },
        ),
        if (assignment.notes != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.note, size: 16, color: AppColors.warning),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Note: ${assignment.notes!}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 80,
              color: AppColors.grey400,
            ),
            const SizedBox(height: 16),
            Text(
              _selectedFilter == 'all'
                  ? 'No Orders Yet'
                  : _selectedFilter == 'active'
                      ? 'No Active Deliveries'
                      : 'No Completed Deliveries',
              style: AppTextStyles.getH3(context),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedFilter == 'all'
                  ? 'This driver hasn\'t been assigned any orders yet'
                  : _selectedFilter == 'active'
                      ? 'This driver has no active deliveries'
                      : 'This driver hasn\'t completed any deliveries yet',
              style: AppTextStyles.getBodyMedium(context),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getDeliveryStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'assigned':
        return AppColors.info;
      case 'picked_up':
        return AppColors.warning;
      case 'on_the_way':
        return AppColors.primary;
      case 'delivered':
        return AppColors.success;
      case 'failed':
        return AppColors.error;
      default:
        return AppColors.grey600;
    }
  }

  IconData _getDeliveryStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'assigned':
        return Icons.assignment;
      case 'picked_up':
        return Icons.inventory;
      case 'on_the_way':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.check_circle;
      case 'failed':
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  String _getDeliveryStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'assigned':
        return 'Assigned';
      case 'picked_up':
        return 'Picked Up';
      case 'on_the_way':
        return 'On the Way';
      case 'delivered':
        return 'Delivered';
      case 'failed':
        return 'Failed';
      default:
        return status;
    }
  }
}
