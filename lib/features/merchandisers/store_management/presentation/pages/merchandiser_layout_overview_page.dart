import 'package:admin_panel/core/constants/app_constants.dart';
import 'package:admin_panel/core/di/injection_container.dart';
import 'package:admin_panel/core/error/exceptions.dart';
import 'package:admin_panel/core/theme/colors.dart';
import 'package:admin_panel/core/theme/text_styles.dart';
import 'package:admin_panel/features/shared/auth/presentation/bloc/auth_bloc.dart';
import 'package:admin_panel/features/merchandisers/chats/presentation/bloc/chat_bloc.dart';
import 'package:admin_panel/features/merchandisers/chats/presentation/bloc/chat_event.dart';
import 'package:admin_panel/features/merchandisers/chats/presentation/pages/chats_page.dart';
import 'package:admin_panel/features/merchandisers/delivery/presentation/bloc/delivery_bloc.dart';
import 'package:admin_panel/features/merchandisers/delivery/presentation/pages/delivery_management_page.dart';
import 'package:admin_panel/features/merchandisers/store_management/presentation/pages/merchandiser_categories_page.dart';
import 'package:admin_panel/features/merchandisers/store_management/presentation/pages/settings_page.dart';
import 'package:admin_panel/features/merchandisers/store_management/presentation/widgets/merchandiser_custom_app_bar.dart';
import 'package:admin_panel/features/shared/notifications/presentation/bloc/notification_bloc.dart';
import 'package:admin_panel/features/shared/notifications/presentation/bloc/notification_event.dart';
import 'package:admin_panel/features/shared/notifications/presentation/bloc/notification_state.dart';
import 'package:admin_panel/features/shared/notifications/presentation/widgets/notification_overlay.dart';
import 'package:admin_panel/features/shared/orders/presentation/pages/orders_page.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/entities/merchandiser_stats.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/repositories/merchandiser_stats_repository.dart';
import 'package:admin_panel/features/shared/shared_feature/presentation/pages/customers_page.dart';
import 'package:admin_panel/features/shared/shared_feature/presentation/widgets/merchandiser_stats_grid.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MerchandiserLayoutPage extends StatefulWidget {
  const MerchandiserLayoutPage({super.key});

  @override
  State<MerchandiserLayoutPage> createState() => _MerchandiserLayoutPageState();
}

class _MerchandiserLayoutPageState extends State<MerchandiserLayoutPage> {
  int _selectedIndex = 0;
  String? _merchandiserId;
  String? _profileId;
  bool _hasInitializedNotifications = false;

  final List<NavigationDestination> _destinations = [
    const NavigationDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard),
      label: 'Overview',
    ),
    const NavigationDestination(
      icon: Icon(Icons.category_outlined),
      selectedIcon: Icon(Icons.category),
      label: 'Categories',
    ),
    const NavigationDestination(
      icon: Icon(Icons.receipt_long_outlined),
      selectedIcon: Icon(Icons.receipt_long),
      label: 'Orders',
    ),
    const NavigationDestination(
      icon: Icon(Icons.motorcycle_outlined),
      selectedIcon: Icon(Icons.motorcycle),
      label: 'Delivery Tracking',
    ),
    const NavigationDestination(
      icon: Icon(Icons.people_outlined),
      selectedIcon: Icon(Icons.people),
      label: 'Customers',
    ),
    const NavigationDestination(
      icon: Icon(Icons.chat_bubble_outline),
      selectedIcon: Icon(Icons.chat_bubble),
      label: 'Chats',
    ),
    const NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: 'Settings',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadMerchandiserData();
  }

  Future<void> _loadMerchandiserData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final merchandiserResponse = await Supabase.instance.client
          .from('merchandisers')
          .select('id, profile_id')
          .eq('profile_id', user.id)
          .single();

      setState(() {
        _merchandiserId = merchandiserResponse['id'] as String;
        _profileId = merchandiserResponse['profile_id'] as String;
      });

      // ✅ Trigger a rebuild so didChangeDependencies can initialize notifications
    } catch (e) {
      debugPrint('Error loading merchandiser data: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // ✅ Initialize notifications after the widget tree is built and BLoC is available
    if (_profileId != null && !_hasInitializedNotifications) {
      _hasInitializedNotifications = true;

      // Use addPostFrameCallback to ensure the BLoC is fully available
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          try {
            context.read<NotificationBloc>()
              ..add(LoadNotifications(userId: _profileId!))
              ..add(SubscribeToNotifications(userId: _profileId!));

            debugPrint(
                '✅ Notification subscription initialized for user: $_profileId');
          } catch (e) {
            debugPrint('❌ Error initializing notifications: $e');
          }
        }
      });
    }
  }

  @override
  void dispose() {
    // ✅ Unsubscribe when disposing
    if (_profileId != null) {
      try {
        context.read<NotificationBloc>().add(
              UnsubscribeFromNotifications(),
            );
      } catch (e) {
        debugPrint('Error unsubscribing from notifications: $e');
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width >= 1200;

    final pages = [
      const MerchandiserOverview(),
      const MerchandiserCategoriesPage(),
      if (_merchandiserId != null)
        OrdersPage(merchandiserId: _merchandiserId!)
      else
        const Center(child: CircularProgressIndicator()),
      BlocProvider(
        create: (context) => sl<DeliveryBloc>(),
        child: const DeliveryManagementPage(),
      ),
      if (_merchandiserId != null)
        CustomersPage(merchandiserId: _merchandiserId!),
      if (_merchandiserId != null)
        BlocProvider(
          create: (context) => sl<ChatBloc>()
            ..add(LoadChatPreviews(merchandiserId: _merchandiserId!))
            ..add(const SubscribeToGlobalMessages()),
          child: ChatsPage(merchandiserId: _merchandiserId!),
        )
      else
        const Center(child: CircularProgressIndicator()),
      const MerchandiserSettingsPage(),
    ];

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<AuthBloc>()),
        BlocProvider(create: (context) => sl<NotificationBloc>(), lazy: false),
      ],
      child: BlocListener<NotificationBloc, NotificationState>(
        listener: (context, state) {
          // ✅ Show overlay when new notification arrives
          if (state is NotificationLoaded &&
              state.showOverlay &&
              state.latestNotification != null) {
            NotificationOverlay.show(
              context,
              state.latestNotification!,
              merchandiserId: _merchandiserId,
            );
          }
        },
        child: Scaffold(
          appBar: MerchandiserCustomAppBar(),
          body: Row(
            children: [
              if (isWideScreen)
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  labelType: NavigationRailLabelType.all,
                  destinations: _destinations
                      .map(
                        (dest) => NavigationRailDestination(
                          icon: dest.icon,
                          selectedIcon: dest.selectedIcon,
                          label: Text(dest.label),
                        ),
                      )
                      .toList(),
                ),
              Expanded(child: pages[_selectedIndex]),
            ],
          ),
          bottomNavigationBar: isWideScreen
              ? null
              : NavigationBar(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  destinations: _destinations,
                ),
        ),
      ),
    );
  }
}

class MerchandiserOverview extends StatefulWidget {
  const MerchandiserOverview({super.key});

  @override
  State<MerchandiserOverview> createState() => _MerchandiserOverviewState();
}

class _MerchandiserOverviewState extends State<MerchandiserOverview> {
  MerchandiserStats? _stats;
  Map<String, dynamic>? _merchandiserData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('Not authenticated');

      // Get merchandiser data
      final merchandiserResponse = await Supabase.instance.client
          .from('merchandisers')
          .select('*')
          .eq('profile_id', user.id)
          .single();

      // Get stats using shared repository
      final repository = sl<MerchandiserStatsRepository>();
      final stats = await repository.getStats(merchandiserResponse['id']);

      setState(() {
        _merchandiserData = merchandiserResponse;
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      throw ServerException(message: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Welcome back!', style: AppTextStyles.getH2(context)),
                    Text(
                      _merchandiserData?['business_name']?['en'] ?? 'Business',
                      style: AppTextStyles.getH4(
                        context,
                      ).copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _stats != null
                ? MerchandiserStatsGrid(stats: _stats!, isLoading: _isLoading)
                : const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }
}
