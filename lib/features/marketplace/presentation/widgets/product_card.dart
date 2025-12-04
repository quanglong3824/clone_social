import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/product_entity.dart';
import 'package:clone_social/core/themes/app_theme.dart';
import 'package:clone_social/core/animations/app_animations.dart';

class ProductCard extends StatefulWidget {
  final ProductEntity product;
  final VoidCallback? onTap;
  final VoidCallback? onSave;
  final bool isSaved;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onSave,
    this.isSaved = false,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> with SingleTickerProviderStateMixin {
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

  String _formatPrice(double price) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(price)} đ';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Card(
          clipBehavior: Clip.antiAlias,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  widget.product.images.isNotEmpty
                      ? _buildProductImage(widget.product.images.first)
                      : _buildPlaceholder(),
                  // Save button
                  if (widget.onSave != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: TapScale(
                        onTap: widget.onSave,
                        child: AnimatedContainer(
                          duration: AppDurations.fast,
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                          ),
                          child: AnimatedSwitcher(
                            duration: AppDurations.fast,
                            transitionBuilder: (child, animation) {
                              return ScaleTransition(scale: animation, child: child);
                            },
                            child: Icon(
                              widget.isSaved ? Icons.bookmark : Icons.bookmark_border,
                              key: ValueKey(widget.isSaved),
                              size: 20,
                              color: widget.isSaved ? AppTheme.primaryBlue : Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Sold badge
                  if (widget.product.status == ProductStatus.sold)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black54,
                        child: const Center(
                          child: Text(
                            'ĐÃ BÁN',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Product info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatPrice(widget.product.price),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        widget.product.title,
                        style: const TextStyle(fontSize: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.product.location != null)
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 12, color: Colors.grey[600]),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              widget.product.location!,
                              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildProductImage(String imageUrl) {
    // Check if it's a base64 image
    if (imageUrl.startsWith('data:image')) {
      try {
        final base64Data = imageUrl.split(',').last;
        return Image.memory(
          base64Decode(base64Data),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholder(),
        );
      } catch (e) {
        return _buildPlaceholder();
      }
    }
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 4),
          Text('Không có ảnh', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
        ],
      ),
    );
  }
}
