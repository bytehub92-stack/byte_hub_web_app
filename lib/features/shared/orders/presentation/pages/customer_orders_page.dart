// lib/features/orders/presentation/pages/customer_orders_page.dart

import 'package:admin_panel/core/widgets/platform_refresh_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/theme/text_styles.dart';
import '../bloc/orders_bloc.dart';
import '../bloc/orders_event.dart';
import '../bloc/orders_state.dart';
import '../widgets/order_card.dart';
import 'order_details_page.dart';

class CustomerOrdersPage extends StatelessWidget {
  final String customerId;
  final String? merchandiserId;
  final String customerName;
  final bool isAdminView;

  const CustomerOrdersPage({
    super.key,
    required this.customerId,
    this.merchandiserId,
    required this.customerName,
    required this.isAdminView,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = sl<OrdersBloc>();
        bloc.add(
          LoadCustomerOrders(
            customerId: customerId,
            merchandiserId: merchandiserId,
          ),
        );
        return bloc;
      },
      child: Scaffold(
        appBar: AppBar(title: Text('$customerName\'s Orders')),
        body: BlocBuilder<OrdersBloc, OrdersState>(
          builder: (context, state) {
            if (state is OrdersLoading) {
              return const Center(child: CircularProgressIndicator());
            }

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
                    Text(
                      'No orders found',
                      style: AppTextStyles.getH3(context),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This customer hasn\'t placed any orders yet',
                      style: AppTextStyles.getBodyMedium(
                        context,
                      ).copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }

            if (state is OrdersLoaded) {
              return PlatformRefreshWrapper(
                onRefresh: () async {
                  context.read<OrdersBloc>().add(
                    LoadCustomerOrders(
                      customerId: customerId,
                      merchandiserId: merchandiserId,
                    ),
                  );
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
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
                              isAdminView: isAdminView,
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
                    const Icon(
                      Icons.error_outline,
                      size: 80,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text('Error', style: AppTextStyles.getH3(context)),
                    const SizedBox(height: 8),
                    Text(state.message),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
