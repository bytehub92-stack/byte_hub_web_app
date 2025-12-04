// lib/features/admin/presentation/pages/admin_dashboard_page.dart

import 'package:admin_panel/features/shared/auth/presentation/bloc/auth_bloc.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_management/presentation/bloc/admin_stats_bloc/admin_stats_bloc.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_management/presentation/bloc/admin_stats_bloc/admin_stats_event.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_management/presentation/bloc/admin_stats_bloc/admin_stats_state.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_management/presentation/widgets/admin_custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../core/theme/colors.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../shared/shared_feature/presentation/widgets/stat_card.dart';
import 'admin_merchandiser_management_page.dart';
import 'admin_settings_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardOverview(),
    const AdminMerchandiserManagementPage(),
    const AdminSettingsPage(),
  ];

  final List<NavigationDestination> _destinations = [
    const NavigationDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard),
      label: 'Dashboard',
    ),
    const NavigationDestination(
      icon: Icon(Icons.store_outlined),
      selectedIcon: Icon(Icons.store),
      label: 'Merchandisers',
    ),
    const NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width >= 1200;
    return BlocProvider.value(
      value: sl<AuthBloc>(),
      child: Scaffold(
        appBar: AdminCustomAppBar(),
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
            Expanded(child: _pages[_selectedIndex]),
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
    );
  }
}

class DashboardOverview extends StatelessWidget {
  const DashboardOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AdminStatsBloc>()..add(LoadAdminStats()),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Dashboard Overview', style: AppTextStyles.getH2(context)),
                BlocBuilder<AdminStatsBloc, AdminStatsState>(
                  builder: (context, state) {
                    if (state is AdminStatsLoading) {
                      return const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      );
                    }
                    return IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () {
                        context.read<AdminStatsBloc>().add(LoadAdminStats());
                      },
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: BlocBuilder<AdminStatsBloc, AdminStatsState>(
                builder: (context, state) {
                  if (state is AdminStatsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is AdminStatsError) {
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
                          Text(
                            'Error: ${state.message}',
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<AdminStatsBloc>().add(
                                LoadAdminStats(),
                              );
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is AdminStatsLoaded) {
                    return GridView.count(
                      crossAxisCount: MediaQuery.of(context).size.width < 600
                          ? 2
                          : 4,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        StatCard(
                          title: 'Total Merchandisers',
                          value: '${state.stats.totalMerchandisers}',
                          icon: Icons.store,
                          color: AppColors.warning,
                        ),
                        StatCard(
                          title: 'Total Customers',
                          value: '${state.stats.totalCustomers}',
                          icon: Icons.people,
                          color: AppColors.primary,
                        ),
                        StatCard(
                          title: 'Total Categories',
                          value: '${state.stats.totalCategories}',
                          icon: Icons.category,
                          color: AppColors.secondary,
                        ),
                        StatCard(
                          title: 'Total Products',
                          value: '${state.stats.totalProducts}',
                          icon: Icons.inventory,
                          color: AppColors.info,
                        ),
                      ],
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
