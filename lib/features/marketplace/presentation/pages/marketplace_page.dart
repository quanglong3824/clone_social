import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:clone_social/core/themes/app_theme.dart';
import 'package:clone_social/core/animations/app_animations.dart';
import 'package:clone_social/core/widgets/shimmer_loading.dart';
import 'package:clone_social/features/auth/presentation/providers/auth_provider.dart';
import '../providers/marketplace_provider.dart';
import '../../domain/entities/product_entity.dart';
import '../widgets/product_card.dart';

class MarketplacePage extends StatefulWidget {
  const MarketplacePage({super.key});

  @override
  State<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> with SingleTickerProviderStateMixin {
  late AnimationController _fabController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: AppDurations.slow,
      vsync: this,
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabController,
      curve: AppCurves.spring,
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentUser = context.read<AuthProvider>().currentUser;
      if (currentUser != null) {
        context.read<MarketplaceProvider>().init(currentUser.id);
      }
      _fabController.forward();
    });
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
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
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton.extended(
          onPressed: () => context.push('/marketplace/create'),
          backgroundColor: AppTheme.primaryBlue,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Đăng bán', style: TextStyle(color: Colors.white)),
        ),
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
                    (context, index) => const ProductShimmer(),
                    childCount: 4,
                  ),
                ),
              )
            else if (marketplaceProvider.products.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: SlideIn.fromBottom(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ScaleIn(
                          child: Icon(Icons.storefront, size: 64, color: Colors.grey[400]),
                        ),
                        const SizedBox(height: 16),
                        FadeIn(
                          delay: const Duration(milliseconds: 100),
                          child: const Text('Chưa có sản phẩm nào'),
                        ),
                        const SizedBox(height: 8),
                        SlideIn.fromBottom(
                          delay: const Duration(milliseconds: 150),
                          child: ElevatedButton(
                            onPressed: () => context.push('/marketplace/create'),
                            child: const Text('Đăng bán ngay'),
                          ),
                        ),
                      ],
                    ),
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
                      return AnimatedListItem(
                        index: index,
                        child: ProductCard(
                          product: product,
                          onTap: () => context.push('/marketplace/product/${product.id}'),
                          onSave: currentUser != null
                              ? () => marketplaceProvider.toggleSaveProduct(product.id, currentUser.id)
                              : null,
                          isSaved: currentUser != null && product.isSavedBy(currentUser.id),
                        ),
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

class _ActionButton extends StatefulWidget {
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
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDurations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: Colors.white),
              const SizedBox(width: 8),
              Text(widget.label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryItem extends StatefulWidget {
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

  @override
  State<_CategoryItem> createState() => _CategoryItemState();
}

class _CategoryItemState extends State<_CategoryItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDurations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  IconData _getIcon() {
    switch (widget.iconName) {
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
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onTap();
        },
        onTapCancel: () => _controller.reverse(),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: AppDurations.fast,
            width: 80,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: widget.isSelected ? AppTheme.primaryBlue.withOpacity(0.1) : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: widget.isSelected ? Border.all(color: AppTheme.primaryBlue, width: 2) : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: AppDurations.fast,
                  child: Icon(
                    _getIcon(),
                    key: ValueKey(widget.isSelected),
                    size: 32,
                    color: widget.isSelected ? AppTheme.primaryBlue : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedDefaultTextStyle(
                  duration: AppDurations.fast,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.normal,
                    color: widget.isSelected ? AppTheme.primaryBlue : Colors.grey[700],
                  ),
                  child: Text(
                    widget.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
