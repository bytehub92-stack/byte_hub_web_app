// lib/features/delivery/presentation/pages/delivery_management_page.dart

import 'package:admin_panel/core/widgets/platform_refresh_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/theme/colors.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../domain/entities/driver.dart';
import '../../domain/entities/order_assignment.dart';
import '../bloc/delivery_bloc.dart';
import '../bloc/delivery_event.dart';
import '../bloc/delivery_state.dart';
import '../widgets/delivery_status_chip.dart';
import '../widgets/merchandiser_code_widget.dart';
import 'assign_order_dialog.dart';

class DeliveryManagementPage extends StatefulWidget {
  const DeliveryManagementPage({super.key});

  @override
  State<DeliveryManagementPage> createState() => _DeliveryManagementPageState();
}

class _DeliveryManagementPageState extends State<DeliveryManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _merchandiserId;
  String? _merchandiserCode;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMerchandiserData();
  }

  Future<void> _loadMerchandiserData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final response = await Supabase.instance.client
          .from('merchandisers')
          .select('id, merchandiser_code')
          .eq('profile_id', user.id)
          .single();

      setState(() {
        _merchandiserId = response['id'] as String;
        _merchandiserCode = response['merchandiser_code'] as String;
      });

      if (_merchandiserId != null && mounted) {
        context.read<DeliveryBloc>().add(LoadDrivers(_merchandiserId!));
        context.read<DeliveryBloc>().add(
          LoadOrderAssignments(
            merchandiserId: _merchandiserId!,
            onlyActive: true,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Drivers', icon: Icon(Icons.people)),
            Tab(text: 'Active Deliveries', icon: Icon(Icons.local_shipping)),
            Tab(text: 'Registration', icon: Icon(Icons.qr_code)),
          ],
        ),
      ),
      body: _merchandiserId == null
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _DriversTab(merchandiserId: _merchandiserId!),
                _ActiveDeliveriesTab(merchandiserId: _merchandiserId!),
                _RegistrationTab(merchandiserCode: _merchandiserCode ?? ''),
              ],
            ),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton.extended(
              onPressed: () {
                if (_merchandiserId != null) {
                  showDialog(
                    context: context,
                    builder: (context) => BlocProvider.value(
                      value: context.read<DeliveryBloc>(),
                      child: AssignOrderDialog(
                        merchandiserId: _merchandiserId!,
                      ),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Assign Order'),
            )
          : null,
    );
  }
}

// ==================== Drivers Tab ====================

// ==================== Drivers Tab (FIXED) ====================

class _DriversTab extends StatefulWidget {
  final String merchandiserId;

  const _DriversTab({required this.merchandiserId});

  @override
  State<_DriversTab> createState() => _DriversTabState();
}

class _DriversTabState extends State<_DriversTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<Driver>? _cachedDrivers;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDrivers();
  }

  void _loadDrivers() {
    context.read<DeliveryBloc>().add(LoadDrivers(widget.merchandiserId));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocListener<DeliveryBloc, DeliveryState>(
      // 🔥 UPDATED: Also listen to OrderUnassigned and OrderAssigned
      listenWhen: (previous, current) {
        return current is DriversLoaded ||
            current is OrderUnassigned || // ✅ Added
            current is OrderAssigned || // ✅ Added
            (current is DeliveryLoading &&
                previous is! OrderAssignmentsLoaded) ||
            (current is DeliveryError && previous is DriversLoaded);
      },
      listener: (context, state) {
        if (state is DeliveryLoading) {
          setState(() {
            _isLoading = true;
            _errorMessage = null;
          });
        } else if (state is DriversLoaded) {
          setState(() {
            _cachedDrivers = state.drivers;
            _isLoading = false;
            _errorMessage = null;
          });
        } else if (state is OrderUnassigned || state is OrderAssigned) {
          // 🔥 NEW: Reload drivers when order is assigned/unassigned
          // This updates driver availability status
          _loadDrivers();
        } else if (state is DeliveryError) {
          setState(() {
            _isLoading = false;
            _errorMessage = state.message;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading && _cachedDrivers == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _cachedDrivers == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text('Error', style: AppTextStyles.getH4(context)),
            const SizedBox(height: 8),
            Text(_errorMessage!),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadDrivers,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_cachedDrivers == null || _cachedDrivers!.isEmpty) {
      return _buildEmptyState();
    }

    return PlatformRefreshWrapper(
      onRefresh: () async => _loadDrivers(),
      child: ListView.separated(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        itemCount: _cachedDrivers!.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          return _buildDriverCard(_cachedDrivers![index]);
        },
      ),
    );
  }

  // ... rest of the implementation remains the same

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delivery_dining, size: 80, color: AppColors.grey400),
            const SizedBox(height: 16),
            Text('No Drivers Yet', style: AppTextStyles.getH3(context)),
            const SizedBox(height: 8),
            Text(
              'Share your registration code with drivers so they can join your team',
              style: AppTextStyles.getBodyMedium(context),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverCard(Driver driver) {
    // ... existing implementation
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    driver.fullName[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 24,
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
                        driver.fullName,
                        style: AppTextStyles.getH4(context),
                      ),
                      if (driver.phoneNumber != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.phone,
                              size: 14,
                              color: AppColors.grey600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              driver.phoneNumber!,
                              style: AppTextStyles.getBodySmall(context),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: driver.isAvailable
                            ? AppColors.success.withValues(alpha: 0.1)
                            : AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            driver.isAvailable
                                ? Icons.check_circle
                                : Icons.local_shipping,
                            size: 12,
                            color: driver.isAvailable
                                ? AppColors.success
                                : AppColors.warning,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            driver.isAvailable ? 'Available' : 'On Delivery',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: driver.isAvailable
                                  ? AppColors.success
                                  : AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!driver.isActive) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Inactive',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            if (driver.vehicleType != null) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.motorcycle,
                    size: 20,
                    color: AppColors.grey600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    driver.vehicleInfo,
                    style: AppTextStyles.getBodyMedium(context),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ==================== Active Deliveries Tab ====================

class _ActiveDeliveriesTab extends StatefulWidget {
  final String merchandiserId;

  const _ActiveDeliveriesTab({required this.merchandiserId});

  @override
  State<_ActiveDeliveriesTab> createState() => _ActiveDeliveriesTabState();
}

class _ActiveDeliveriesTabState extends State<_ActiveDeliveriesTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // Cache the last loaded assignments state
  List<OrderAssignment>? _cachedAssignments;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }

  void _loadAssignments() {
    context.read<DeliveryBloc>().add(
      LoadOrderAssignments(
        merchandiserId: widget.merchandiserId,
        onlyActive: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocListener<DeliveryBloc, DeliveryState>(
      // Only listen to assignment-related states
      listenWhen: (previous, current) {
        return current is OrderAssignmentsLoaded ||
            current is OrderAssigned ||
            current is OrderUnassigned ||
            (current is DeliveryLoading && previous is! DriversLoaded) ||
            (current is DeliveryError && previous is OrderAssignmentsLoaded);
      },
      listener: (context, state) {
        if (state is DeliveryLoading) {
          setState(() {
            _isLoading = true;
            _errorMessage = null;
          });
        } else if (state is OrderAssignmentsLoaded) {
          setState(() {
            _cachedAssignments = state.assignments;
            _isLoading = false;
            _errorMessage = null;
          });
        } else if (state is OrderAssigned) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success,
            ),
          );
          _loadAssignments();
        } else if (state is OrderUnassigned) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success,
            ),
          );
          _loadAssignments();
        } else if (state is DeliveryError) {
          setState(() {
            _isLoading = false;
            _errorMessage = state.message;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading && _cachedAssignments == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _cachedAssignments == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text('Error', style: AppTextStyles.getH4(context)),
            const SizedBox(height: 8),
            Text(_errorMessage!),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadAssignments,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_cachedAssignments == null || _cachedAssignments!.isEmpty) {
      return _buildEmptyState();
    }

    return PlatformRefreshWrapper(
      onRefresh: () async => _loadAssignments(),
      child: ListView.separated(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        itemCount: _cachedAssignments!.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          return _buildAssignmentCard(_cachedAssignments![index]);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 80, color: AppColors.grey400),
            const SizedBox(height: 16),
            Text('No Active Deliveries', style: AppTextStyles.getH3(context)),
            const SizedBox(height: 8),
            Text(
              'Assign orders to drivers to track deliveries here',
              style: AppTextStyles.getBodyMedium(context),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentCard(OrderAssignment assignment) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    assignment.orderNumber ?? 'Order',
                    style: AppTextStyles.getH4(context),
                  ),
                ),
                DeliveryStatusChip(status: assignment.deliveryStatus),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),

            // Driver Info
            Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.delivery_dining, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        assignment.driverName ?? 'Unknown Driver',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      if (assignment.driverPhone != null)
                        Text(
                          assignment.driverPhone!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.grey600,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Customer Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        assignment.customerName ?? 'N/A',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (assignment.customerPhone != null)
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 16),
                        const SizedBox(width: 8),
                        Text(assignment.customerPhone!),
                      ],
                    ),
                  const SizedBox(height: 4),
                  if (assignment.customerAddress != null)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on, size: 16),
                        const SizedBox(width: 8),
                        Expanded(child: Text(assignment.customerAddress!)),
                      ],
                    ),
                  if (assignment.orderAmount != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.attach_money, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'EGP ${assignment.orderAmount!.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            if (assignment.notes != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
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
                        assignment.notes!,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Actions
            if (!assignment.isCompleted &&
                assignment.orderStatus != 'delivered') ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showUnassignDialog(assignment.orderId);
                  },
                  icon: const Icon(Icons.cancel),
                  label: const Text('Unassign Order'),
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
    );
  }

  void _showUnassignDialog(String orderId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: AppColors.warning),
            SizedBox(width: 8),
            Text('Unassign Order'),
          ],
        ),
        content: const Text(
          'Are you sure you want to unassign this order? The driver will no longer see this delivery.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<DeliveryBloc>().add(UnassignOrder(orderId));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Unassign'),
          ),
        ],
      ),
    );
  }
}

// ==================== Registration Tab ====================

class _RegistrationTab extends StatelessWidget {
  final String merchandiserCode;

  const _RegistrationTab({required this.merchandiserCode});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MerchandiserCodeWidget(code: merchandiserCode),
          const SizedBox(height: 24),

          // Instructions Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How to Add Drivers',
                    style: AppTextStyles.getH4(context),
                  ),
                  const SizedBox(height: 16),
                  _buildInstructionStep(
                    '1',
                    'Share the Code',
                    'Give your registration code to drivers who will work for you',
                  ),
                  const SizedBox(height: 12),
                  _buildInstructionStep(
                    '2',
                    'Driver Downloads App',
                    'Drivers need to download the Driver app and sign in with Google',
                  ),
                  const SizedBox(height: 12),
                  _buildInstructionStep(
                    '3',
                    'Driver Enters Code',
                    'After signing in, drivers enter your code to register',
                  ),
                  const SizedBox(height: 12),
                  _buildInstructionStep(
                    '4',
                    'Start Assigning',
                    'Once registered, you can assign orders to your drivers',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(
    String number,
    String title,
    String description,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(color: AppColors.grey600, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
