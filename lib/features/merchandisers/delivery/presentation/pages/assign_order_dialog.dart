// lib/features/delivery/presentation/pages/assign_order_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/theme/colors.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../shared/orders/domain/entities/order.dart';
import '../../domain/entities/driver.dart';
import '../bloc/delivery_bloc.dart';
import '../bloc/delivery_event.dart';
import '../bloc/delivery_state.dart';

class AssignOrderDialog extends StatefulWidget {
  final String merchandiserId;

  const AssignOrderDialog({super.key, required this.merchandiserId});

  @override
  State<AssignOrderDialog> createState() => _AssignOrderDialogState();
}

class _AssignOrderDialogState extends State<AssignOrderDialog> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  String? _selectedOrderId;
  String? _selectedDriverId;
  List<Order> _availableOrders = [];
  List<Driver> _availableDrivers = [];
  bool _isLoadingOrders = false;

  @override
  void initState() {
    super.initState();
    _loadAvailableOrders();
    context.read<DeliveryBloc>().add(LoadDrivers(widget.merchandiserId));
  }

  Future<void> _loadAvailableOrders() async {
    setState(() {
      _isLoadingOrders = true;
    });

    try {
      // Get orders that are ready to be shipped (status = on_the_way or preparing)
      // and not already assigned
      final ordersResponse = await Supabase.instance.client
          .from('orders')
          .select('''
            *,
            profiles!orders_customer_user_id_fkey(full_name, phone_number)
          ''')
          .eq('merchandiser_id', widget.merchandiserId)
          .inFilter('status', ['preparing', 'confirmed'])
          .order('created_at', ascending: false);

      // Get assigned order IDs
      final assignedOrdersResponse = await Supabase.instance.client
          .from('order_assignments')
          .select('order_id');

      final assignedOrderIds = (assignedOrdersResponse as List)
          .map((a) => a['order_id'] as String)
          .toSet();

      // Filter out already assigned orders
      final availableOrders = (ordersResponse as List).where((order) {
        return !assignedOrderIds.contains(order['id']);
      }).toList();

      setState(() {
        _availableOrders = availableOrders
            .map((json) => _parseOrder(json as Map<String, dynamic>))
            .toList();
        _isLoadingOrders = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingOrders = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading orders: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Order _parseOrder(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      customerUserId: json['customer_user_id'] as String,
      merchandiserId: json['merchandiser_id'] as String,
      orderNumber: json['order_number'] as String,
      totalAmount: _parseDouble(json['total_amount']),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      subtotal: _parseDouble(json['subtotal'] ?? 0),
      taxAmount: _parseDouble(json['tax_amount'] ?? 0),
      shippingAmount: _parseDouble(json['shipping_amount'] ?? 0),
      discountAmount: _parseDouble(json['discount_amount'] ?? 0),
      paymentStatus: json['payment_status'] as String? ?? 'pending',
      updatedAt: DateTime.parse(json['updated_at'] as String),
      customerName: json['profiles']?['full_name'] as String?,
      customerPhone: json['profiles']?['phone_number'] as String?,
    );
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DeliveryBloc, DeliveryState>(
      listener: (context, state) {
        if (state is DriversLoaded) {
          setState(() {
            _availableDrivers = state.drivers
                .where((d) => d.isActive && d.isAvailable)
                .toList();
          });
        }
      },
      child: Dialog(
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Assign Order to Driver',
                    style: AppTextStyles.getH3(context),
                  ),
                  const SizedBox(height: 24),

                  // Select Order
                  if (_isLoadingOrders)
                    const Center(child: CircularProgressIndicator())
                  else if (_availableOrders.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'No orders available for assignment. Orders must be in "Confirmed" or "Preparing" status.',
                              style: AppTextStyles.getBodySmall(context),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    DropdownButtonFormField<String>(
                      initialValue: _selectedOrderId,
                      decoration: const InputDecoration(
                        labelText: 'Select Order *',
                        prefixIcon: Icon(Icons.receipt_long),
                      ),
                      items: _availableOrders.map((order) {
                        return DropdownMenuItem(
                          value: order.id,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                order.orderNumber,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${order.customerName ?? "Unknown"} - EGP ${order.totalAmount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.grey600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedOrderId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select an order';
                        }
                        return null;
                      },
                    ),
                  const SizedBox(height: 16),

                  // Select Driver
                  if (_availableDrivers.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: AppColors.error,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'No available drivers. Please add drivers or make them available first.',
                              style: AppTextStyles.getBodySmall(context),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    DropdownButtonFormField<String>(
                      initialValue: _selectedDriverId,
                      decoration: const InputDecoration(
                        labelText: 'Select Driver *',
                        prefixIcon: Icon(Icons.delivery_dining),
                      ),
                      items: _availableDrivers.map((driver) {
                        return DropdownMenuItem(
                          value: driver.id,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                driver.fullName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (driver.vehicleType != null)
                                Text(
                                  driver.vehicleInfo,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.grey600,
                                  ),
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDriverId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a driver';
                        }
                        return null;
                      },
                    ),
                  const SizedBox(height: 16),

                  // Notes
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes (Optional)',
                      prefixIcon: Icon(Icons.note),
                      hintText: 'Any special instructions...',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),

                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed:
                            _availableOrders.isEmpty ||
                                _availableDrivers.isEmpty
                            ? null
                            : _submitForm,
                        child: const Text('Assign Order'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final user = Supabase.instance.client.auth.currentUser;
        if (user == null) return;

        context.read<DeliveryBloc>().add(
          AssignOrderToDriver(
            orderId: _selectedOrderId!,
            driverId: _selectedDriverId!,
            assignedBy: user.id,
            notes: _notesController.text.trim().isNotEmpty
                ? _notesController.text.trim()
                : null,
          ),
        );
        Navigator.pop(context);
      } catch (e) {
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
