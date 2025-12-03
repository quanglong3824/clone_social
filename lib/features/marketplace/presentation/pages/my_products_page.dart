import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/marketplace_provider.dart';
import '../widgets/product_card.dart';
import 'package:clone_social/features/auth/presentation/providers/auth_provider.dart';

class MyProductsPage extends StatelessWidget {
  const MyProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final marketplaceProvider = context.watch<MarketplaceProvider>();
    final currentUser = context.read<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Sản phẩm của tôi')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/marketplace/create'),
        child: const Icon(Icons.add),
      ),
      body: marketplaceProvider.myProducts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('Bạn chưa đăng bán sản phẩm nào'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.push('/marketplace/create'),
                    child: const Text('Đăng bán ngay'),
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
              itemCount: marketplaceProvider.myProducts.length,
              itemBuilder: (context, index) {
                final product = marketplaceProvider.myProducts[index];
                return ProductCard(
                  product: product,
                  onTap: () => context.push('/marketplace/product/${product.id}'),
                );
              },
            ),
    );
  }
}
