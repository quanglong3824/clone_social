import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:clone_social/core/themes/app_theme.dart';
import 'package:clone_social/features/auth/presentation/providers/auth_provider.dart';
import '../providers/marketplace_provider.dart';
import '../../domain/entities/product_entity.dart';
import '../widgets/product_card.dart';

class MarketplacePage extends StatefulWidget {
  const MarketplacePage({super.key});

  @override
  State<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentUser = context.read<AuthProvider>().currentUser;
      if (currentUser != null) {
        context.read<MarketplaceProvider>().init(currentUser.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final marketplaceProvider = context.watch<MarketplaceProvider>();
    final currentUser = context.read<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/marketplace/search'),
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_outline),
            onPressed: () => context.push('/marketplace/saved'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/marketplace/create'),
        backgroundColor: AppTheme.primaryBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Đăng bán', style: TextStyle(color: Colors.white)),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (currentUser != null) {
            context.read<MarketplaceProvider>().init(currentUser.id);
          }
        },
        child: CustomScrollView(
          slivers: [
            // Quick actions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.sell,
                        label: 'Bán',
                        color: AppTheme.primaryBlue,
                        onTap: () => context.push('/marketplace/create'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.inventory_2,
                        label: 'Sản phẩm của tôi',
                        color: Colors.green,
                        onTap: () => context.push('/marketplace/my-products'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Categories
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Danh mục',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: ProductCategories.categories.length,
                      itemBuilder: (context, index) {
                        final category = ProductCategories.categories[index];
                        final isSelected = marketplaceProvider.selectedCategory == category['id'];
                        return _CategoryItem(
                          name: category['name'] as String,
                          iconName: category['icon'] as String,
                          isSelected: isSelected,
                          onTap: () {
                            marketplaceProvider.setCategory(
                              isSelected ? null : category['id'] as String,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SliverToBoxAdapter(child: Divider(height: 24)),

            // Products header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      marketplaceProvider.selectedCategory != null
                          ? ProductCategories.getCategoryName(marketplaceProvider.selectedCategory!)
                          : 'Tất cả sản phẩm',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    if (marketplaceProvider.selectedCategory != null)
                      TextButton(
                        onPressed: () => marketplaceProvider.setCategory(null),
                        child: const Text('Xem tất cả'),
                      ),
                  ],
                ),
              ),
            ),

            // Products grid
            if (marketplaceProvider.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (marketplaceProvider.products.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.storefront, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      const Text('Chưa có sản phẩm nào'),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => context.push('/marketplace/create'),
                        child: const Text('Đăng bán ngay'),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(12),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.7,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = marketplaceProvider.products[index];
                      return ProductCard(
                        product: product,
                        onTap: () => context.push('/marketplace/product/${product.id}'),
                        onSave: currentUser != null
                            ? () => marketplaceProvider.toggleSaveProduct(product.id, currentUser.id)
                            : null,
                        isSaved: currentUser != null && product.isSavedBy(currentUser.id),
                      );
                    },
                    childCount: marketplaceProvider.products.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final String name;
  final String iconName;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.name,
    required this.iconName,
    required this.isSelected,
    required this.onTap,
  });

  IconData _getIcon() {
    switch (iconName) {
      case 'directions_car': return Icons.directions_car;
      case 'phone_android': return Icons.phone_android;
      case 'home': return Icons.home;
      case 'checkroom': return Icons.checkroom;
      case 'chair': return Icons.chair;
      case 'pets': return Icons.pets;
      case 'sports_soccer': return Icons.sports_soccer;
      case 'menu_book': return Icons.menu_book;
      case 'toys': return Icons.toys;
      default: return Icons.more_horiz;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 80,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryBlue.withOpacity(0.1) : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: isSelected ? Border.all(color: AppTheme.primaryBlue, width: 2) : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getIcon(),
                size: 32,
                color: isSelected ? AppTheme.primaryBlue : Colors.grey[700],
              ),
              const SizedBox(height: 8),
              Text(
                name,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppTheme.primaryBlue : Colors.grey[700],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
