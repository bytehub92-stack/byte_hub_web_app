// lib/core/widgets/platform_refresh_wrapper.dart

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// A wrapper that conditionally uses RefreshIndicator on mobile
/// and a regular scrollable widget on web
class PlatformRefreshWrapper extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  const PlatformRefreshWrapper({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    // On web, just return the child without RefreshIndicator
    if (kIsWeb) {
      return child;
    }

    // On mobile, wrap with RefreshIndicator
    return RefreshIndicator(onRefresh: onRefresh, child: child);
  }
}

// Usage Example:
// PlatformRefreshWrapper(
//   onRefresh: () async {
//     context.read<OrdersBloc>().add(LoadOrders());
//   },
//   child: ListView.builder(...),
// )
