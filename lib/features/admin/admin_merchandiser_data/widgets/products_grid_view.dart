import 'package:admin_panel/features/shared/shared_feature/domain/entities/product.dart';
import 'package:flutter/material.dart';
import 'admin_product_card.dart';

class ProductsGridView extends StatelessWidget {
  final List<Product> products;
  final bool isLoading;
  final bool hasMore;
  final VoidCallback? onLoadMore;
  final Function(Product)? onProductTap;

  const ProductsGridView({
    super.key,
    required this.products,
    this.isLoading = false,
    this.hasMore = false,
    this.onLoadMore,
    this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (!isLoading &&
            hasMore &&
            scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          onLoadMore?.call();
        }
        return false;
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _getCrossAxisCount(context),
          childAspectRatio: 0.9,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: products.length + (isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == products.length) {
            // Loading indicator at the end
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final product = products[index];
          return AdminProductCard(
            product: product,
            onTap: () => onProductTap?.call(product),
          );
        },
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 5;
    if (width > 900) return 4;
    if (width > 600) return 3;
    return 2;
  }
}
