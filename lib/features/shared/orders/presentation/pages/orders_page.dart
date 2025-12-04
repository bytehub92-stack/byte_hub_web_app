// lib/features/orders/presentation/pages/orders_page.dart
import 'package:admin_panel/core/widgets/platform_refresh_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../core/constants/app_constants.dart';
import '../bloc/orders_bloc.dart';
import '../bloc/orders_event.dart';
import '../bloc/orders_state.dart';
import '../widgets/order_card.dart';
import '../widgets/order_filters.dart';
import 'order_details_page.dart';

class OrdersPage extends StatelessWidget {
  final String merchandiserId;
  final bool isAdminView;

  const OrdersPage({
    super.key,
    required this.merchandiserId,
    this.isAdminView = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<OrdersBloc>()
            ..add(LoadMerchandiserOrders(merchandiserId: merchandiserId)),
      child: _OrdersView(
        merchandiserId: merchandiserId,
        isAdminView: isAdminView,
      ),
    );
  }
}

class _OrdersView extends StatefulWidget {
  final String merchandiserId;
  final bool isAdminView;

  const _OrdersView({required this.merchandiserId, required this.isAdminView});

  @override
  State<_OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<_OrdersView> {
  String? _selectedStatus;
  String? _selectedPaymentStatus;
  bool _showFilters = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        actions: [
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_list_off : Icons.filter_list,
            ),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
            tooltip: 'Filters',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshOrders,
            tooltip: 'Refresh',
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
            _refreshOrders();
          }

          if (state is OrderCancelled) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.orange,
              ),
            );
            _refreshOrders();
          }

          if (state is OrdersError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is OrdersLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Get filters from current state
          String? appliedStatusFilter;
          String? appliedPaymentFilter;

          if (state is OrdersLoaded) {
            appliedStatusFilter = state.appliedStatusFilter;
            appliedPaymentFilter = state.appliedPaymentFilter;
          } else if (state is OrdersEmpty) {
            appliedStatusFilter = state.appliedStatusFilter;
            appliedPaymentFilter = state.appliedPaymentFilter;
          }

          // Build the main content
          return Row(
            children: [
              // Filters Sidebar (Desktop/Tablet)
              if (_showFilters && MediaQuery.of(context).size.width >= 900)
                SizedBox(
                  width: 300,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: OrderFilters(
                      selectedStatus: _selectedStatus,
                      selectedPaymentStatus: _selectedPaymentStatus,
                      onStatusChanged: (status) {
                        setState(() => _selectedStatus = status);
                        _applyFilters();
                      },
                      onPaymentStatusChanged: (paymentStatus) {
                        setState(() => _selectedPaymentStatus = paymentStatus);
                        _applyFilters();
                      },
                      onClearFilters: () {
                        setState(() {
                          _selectedStatus = null;
                          _selectedPaymentStatus = null;
                        });
                        _refreshOrders();
                      },
                    ),
                  ),
                ),

              // Main Content Area
              Expanded(
                child: Column(
                  children: [
                    // Filters for Mobile
                    if (_showFilters && MediaQuery.of(context).size.width < 900)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: OrderFilters(
                          selectedStatus: _selectedStatus,
                          selectedPaymentStatus: _selectedPaymentStatus,
                          onStatusChanged: (status) {
                            setState(() => _selectedStatus = status);
                            _applyFilters();
                          },
                          onPaymentStatusChanged: (paymentStatus) {
                            setState(
                              () => _selectedPaymentStatus = paymentStatus,
                            );
                            _applyFilters();
                          },
                          onClearFilters: () {
                            setState(() {
                              _selectedStatus = null;
                              _selectedPaymentStatus = null;
                            });
                            _refreshOrders();
                          },
                        ),
                      ),

                    // Orders Count Header
                    if (state is OrdersLoaded)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.defaultPadding,
                          vertical: 12,
                        ),
                        color: Theme.of(context).cardColor,
                        child: Row(
                          children: [
                            const Icon(Icons.receipt_long, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              '${state.orders.length} Orders',
                              style: AppTextStyles.getBodyMedium(
                                context,
                              ).copyWith(fontWeight: FontWeight.w600),
                            ),
                            if (appliedStatusFilter != null ||
                                appliedPaymentFilter != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Filtered',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                    // Content based on state
                    Expanded(child: _buildContent(state)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(OrdersState state) {
    if (state is OrdersEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text('No orders found', style: AppTextStyles.getH3(context)),
            const SizedBox(height: 8),
            Text(
              _selectedStatus != null || _selectedPaymentStatus != null
                  ? 'No orders match the selected filters'
                  : 'Orders will appear here when customers place them',
              style: AppTextStyles.getBodyMedium(
                context,
              ).copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            if (_selectedStatus != null || _selectedPaymentStatus != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedStatus = null;
                    _selectedPaymentStatus = null;
                  });
                  _refreshOrders();
                },
                icon: const Icon(Icons.clear),
                label: const Text('Clear Filters'),
              ),
            ],
          ],
        ),
      );
    }

    if (state is OrdersLoaded) {
      return PlatformRefreshWrapper(
        onRefresh: () async => _refreshOrders(),
        child: ListView.builder(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          itemCount: state.orders.length,
          itemBuilder: (context, index) {
            final order = state.orders[index];
            return OrderCard(
              order: order,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderDetailsPage(
                      orderId: order.id,
                      isAdminView: widget.isAdminView,
                    ),
                  ),
                );
              },
            );
          },
        ),
      );
    }

    if (state is OrdersError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error loading orders', style: AppTextStyles.getH3(context)),
            const SizedBox(height: 8),
            Text(
              state.message,
              style: AppTextStyles.getBodyMedium(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshOrders,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  void _refreshOrders() {
    context.read<OrdersBloc>().add(
      LoadMerchandiserOrders(
        merchandiserId: widget.merchandiserId,
        status: _selectedStatus,
        paymentStatus: _selectedPaymentStatus,
      ),
    );
  }

  void _applyFilters() {
    _refreshOrders();
  }
}
