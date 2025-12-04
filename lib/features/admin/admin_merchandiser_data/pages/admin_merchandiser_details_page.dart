import 'package:admin_panel/features/admin/admin_merchandiser_data/pages/admin_merchandiser_categories_page.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_data/pages/admin_merchandiser_overview_page.dart';
import 'package:admin_panel/features/shared/orders/presentation/pages/orders_page.dart';
import 'package:admin_panel/features/shared/shared_feature/presentation/pages/customers_page.dart';
import 'package:flutter/material.dart';
import '../../admin_merchandiser_management/domain/entities/merchandiser.dart';

class AdminMerchandiserDetailPage extends StatefulWidget {
  final Merchandiser merchandiser;

  const AdminMerchandiserDetailPage({super.key, required this.merchandiser});

  @override
  State<AdminMerchandiserDetailPage> createState() =>
      _AdminMerchandiserDetailPageState();
}

class _AdminMerchandiserDetailPageState
    extends State<AdminMerchandiserDetailPage> {
  int _selectedIndex = 0;

  late final List<Widget> _pages = [
    AdminMerchandiserOverviewPage(merchandiser: widget.merchandiser),
    CustomersPage(merchandiserId: widget.merchandiser.id, isAdminView: true),
    OrdersPage(merchandiserId: widget.merchandiser.id), // Add this
    AdminMerchandiserCategoriesPage(
      merchandiserId: widget.merchandiser.id,
      merchandiserName: widget.merchandiser.businessName['en']!,
    ),
  ];

  final List<NavigationDestination> _destinations = [
    const NavigationDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard),
      label: 'Dashboard',
    ),
    const NavigationDestination(
      icon: Icon(Icons.people_outlined),
      selectedIcon: Icon(Icons.people),
      label: 'Customers',
    ),
    const NavigationDestination(
      icon: Icon(Icons.receipt_long_outlined),
      selectedIcon: Icon(Icons.receipt_long),
      label: 'Orders',
    ),
    const NavigationDestination(
      icon: Icon(Icons.category_outlined),
      selectedIcon: Icon(Icons.category),
      label: 'Categories',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width >= 1200;
    return Scaffold(
      appBar: AppBar(title: Text(widget.merchandiser.businessName['en']!)),
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
    );
  }
}
