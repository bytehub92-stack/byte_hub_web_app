// lib/features/shared/presentation/pages/customers_page.dart

import 'package:admin_panel/core/constants/app_constants.dart';
import 'package:admin_panel/core/theme/text_styles.dart';
import 'package:admin_panel/features/merchandisers/chats/presentation/pages/customer_chat_page.dart';
import 'package:admin_panel/features/shared/orders/presentation/pages/customer_orders_page.dart';
import 'package:admin_panel/features/shared/shared_feature/presentation/bloc/customer/customer_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/di/injection_container.dart';
import '../bloc/customer/customer_bloc.dart';
import '../bloc/customer/customer_event.dart';

class CustomersPage extends StatelessWidget {
  final String merchandiserId;
  final bool isAdminView;

  const CustomersPage({
    super.key,
    required this.merchandiserId,
    this.isAdminView = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<CustomerBloc>()..add(LoadCustomersByMerchandiser(merchandiserId)),
      child: Scaffold(
        body: BlocConsumer<CustomerBloc, CustomerState>(
          listener: (context, state) {
            if (state is CustomerStatusUpdated) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
              // Reload customers

              context.read<CustomerBloc>().add(
                    LoadCustomersByMerchandiser(merchandiserId),
                  );
            }
          },
          builder: (context, state) {
            if (state is CustomerLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is CustomerError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<CustomerBloc>().add(
                              LoadCustomersByMerchandiser(merchandiserId),
                            );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            if (state is CustomersLoaded) {
              if (state.customers.isEmpty) {
                return const Center(child: Text('No customers found'));
              }
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        const Text('Customers'),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: () {
                            context.read<CustomerBloc>().add(
                                  LoadCustomersByMerchandiser(merchandiserId),
                                );
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(
                        AppConstants.defaultPadding,
                      ),
                      itemCount: state.customers.length,
                      itemBuilder: (context, index) {
                        final customer = state.customers[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: CircleAvatar(
                              radius: 30,
                              backgroundImage: customer.avatarUrl != null
                                  ? NetworkImage(customer.avatarUrl!)
                                  : null,
                              child: customer.avatarUrl == null
                                  ? const Icon(Icons.person, size: 30)
                                  : null,
                            ),
                            title: Text(
                              customer.fullName,
                              style: AppTextStyles.getH4(context),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                Text(customer.email),
                                if (customer.phoneNumber != null)
                                  Text(customer.phoneNumber!),
                                const SizedBox(height: 4),
                                Text('Orders: ${customer.totalOrders}'),
                                Row(
                                  children: [
                                    Icon(
                                      customer.isActive
                                          ? Icons.check_circle
                                          : Icons.cancel,
                                      size: 16,
                                      color: customer.isActive
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      customer.isActive ? 'Active' : 'Inactive',
                                      style: TextStyle(
                                        color: customer.isActive
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton<String>(
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'view_orders',
                                  child: ListTile(
                                    leading: Icon(Icons.receipt_long),
                                    title: Text('View Orders'),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                                if (isAdminView == false)
                                  const PopupMenuItem(
                                    value: 'chat',
                                    child: ListTile(
                                      leading: Icon(Icons.chat_bubble_outline),
                                      title: Text('Chat'),
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                if (isAdminView == false)
                                  PopupMenuItem(
                                    value: 'toggle_status',
                                    child: ListTile(
                                      leading: Icon(
                                        customer.isActive
                                            ? Icons.block
                                            : Icons.check_circle,
                                      ),
                                      title: Text(
                                        customer.isActive
                                            ? 'Deactivate'
                                            : 'Activate',
                                      ),
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                              ],
                              onSelected: (value) {
                                switch (value) {
                                  case 'view_orders':
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            CustomerOrdersPage(
                                          customerId: customer.id,
                                          merchandiserId: merchandiserId,
                                          customerName: customer.fullName,
                                          isAdminView: isAdminView,
                                        ),
                                      ),
                                    );
                                    break;
                                  case 'chat':
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CustomerChatPage(
                                          merchandiserId: merchandiserId,
                                          customerProfileId: customer.id,
                                          customerName: customer.fullName,
                                          customerAvatar: customer.avatarUrl,
                                        ),
                                      ),
                                    );
                                    break;
                                  case 'toggle_status':
                                    context.read<CustomerBloc>().add(
                                          ToggleCustomerStatusEvent(
                                            customer.id,
                                            !customer.isActive,
                                          ),
                                        );
                                    break;
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}
