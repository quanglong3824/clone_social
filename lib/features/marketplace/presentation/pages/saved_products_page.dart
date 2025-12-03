import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/marketplace_provider.dart';
import '../widgets/product_card.dart';
import 'package:clone_social/features/auth/presentation/providers/auth_provider.dart';

class SavedProductsPage extends StatelessWidget {
  const SavedProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final marketplaceProvider = context.watch<MarketplaceProvider>();
    final currentUser = context.read<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Đã lưu')),
      body: marketplaceProvider.savedProducts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('Chưa có sản phẩm đã lưu'),
                  const SizedBox(height: 8),
                  Text(
                    'Nhấn vào biểu tượng bookmark để lưu sản phẩm',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.7,
              ),
              itemCount: marketplaceProvider.savedProducts.length,
              itemBuilder: (context, index) {
                final product = marketplaceProvider.savedProducts[index];
                return ProductCard(
                  product: product,
                  onTap: () => context.push('/marketplace/product/${product.id}'),
                  onSave: currentUser != null
                      ? () => marketplaceProvider.toggleSaveProduct(product.id, currentUser.id)
                      : null,
                  isSaved: true,
                );
              },
            ),
    );
  }
}
