import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:clone_social/core/themes/app_theme.dart';
import 'package:clone_social/features/auth/presentation/providers/auth_provider.dart';
import '../providers/marketplace_provider.dart';
import '../../domain/entities/product_entity.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  ProductEntity? _product;
  bool _isLoading = true;
  int _currentImageIndex = 0;
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadProduct() async {
    final product = await context.read<MarketplaceProvider>().getProductById(widget.productId);
    if (mounted) {
      setState(() {
        _product = product;
        _isLoading = false;
      });
      if (product != null) {
        context.read<MarketplaceProvider>().incrementViewCount(widget.productId);
      }
    }
  }

  String _formatPrice(double price) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(price)} đ';
  }

  Future<void> _contactSeller() async {
    final currentUser = context.read<AuthProvider>().currentUser;
    if (currentUser == null || _product == null) return;

    if (currentUser.id == _product!.sellerId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đây là sản phẩm của bạn')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nhắn tin cho người bán',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Xin chào, tôi quan tâm đến "${_product!.title}"',
                  border: const OutlineInputBorder(),
                ),
                minLines: 2,
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Hủy'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final message = _messageController.text.trim().isEmpty
                            ? 'Xin chào, tôi quan tâm đến "${_product!.title}"'
                            : _messageController.text.trim();
                        
                        Navigator.pop(ctx);
                        
                        final chatId = await context.read<MarketplaceProvider>().contactSeller(
                          widget.productId,
                          currentUser.id,
                          message,
                        );
                        
                        if (chatId != null && mounted) {
                          context.push('/chat/$chatId');
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
                      child: const Text('Gửi'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthProvider>().currentUser;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_product == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Sản phẩm không tồn tại')),
      );
    }

    final isOwner = currentUser?.id == _product!.sellerId;
    final isSaved = currentUser != null && _product!.isSavedBy(currentUser.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Image gallery
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            actions: [
              if (!isOwner)
                IconButton(
                  icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border),
                  onPressed: currentUser != null
                      ? () {
                          context.read<MarketplaceProvider>().toggleSaveProduct(
                            widget.productId,
                            currentUser.id,
                          );
                          setState(() {
                            // Toggle local state
                          });
                        }
                      : null,
                ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tính năng chia sẻ sẽ sớm có')),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _product!.images.isNotEmpty
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        PageView.builder(
                          itemCount: _product!.images.length,
                          onPageChanged: (index) {
                            setState(() => _currentImageIndex = index);
                          },
                          itemBuilder: (context, index) {
                            return _buildImage(_product!.images[index]);
                          },
                        ),
                        if (_product!.images.length > 1)
                          Positioned(
                            bottom: 16,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                _product!.images.length,
                                (index) => Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _currentImageIndex == index
                                        ? Colors.white
                                        : Colors.white54,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image, size: 64),
                    ),
            ),
          ),

          // Product info
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price
                  Text(
                    _formatPrice(_product!.price),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Title
                  Text(
                    _product!.title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),

                  // Meta info
                  Row(
                    children: [
                      _buildInfoChip(Icons.category, ProductCategories.getCategoryName(_product!.category)),
                      const SizedBox(width: 8),
                      _buildInfoChip(Icons.star, _product!.condition.label),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Location & time
                  Row(
                    children: [
                      if (_product!.location != null) ...[
                        Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(_product!.location!, style: TextStyle(color: Colors.grey[600])),
                        const SizedBox(width: 16),
                      ],
                      Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        timeago.format(_product!.createdAt),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const Spacer(),
                      Icon(Icons.visibility, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text('${_product!.viewCount}', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),

                  const Divider(height: 32),

                  // Description
                  const Text(
                    'Mô tả',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(_product!.description, style: const TextStyle(height: 1.5)),

                  const Divider(height: 32),

                  // Seller info
                  const Text(
                    'Người bán',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      radius: 28,
                      backgroundImage: _product!.sellerProfileImage != null
                          ? NetworkImage(_product!.sellerProfileImage!)
                          : null,
                      backgroundColor: Colors.grey[300],
                      child: _product!.sellerProfileImage == null
                          ? const Icon(Icons.person, color: Colors.white)
                          : null,
                    ),
                    title: Text(
                      _product!.sellerName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text('Xem trang cá nhân'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/profile/${_product!.sellerId}'),
                  ),

                  const SizedBox(height: 100), // Space for bottom bar
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _product!.status == ProductStatus.sold
          ? Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[200],
              child: const Text(
                'Sản phẩm này đã được bán',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            )
          : isOwner
              ? _buildOwnerActions()
              : _buildBuyerActions(),
    );
  }

  Widget _buildImage(String imageUrl) {
    if (imageUrl.startsWith('data:image')) {
      try {
        final base64Data = imageUrl.split(',').last;
        return Image.memory(
          base64Decode(base64Data),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
        );
      } catch (e) {
        return _buildImagePlaceholder();
      }
    }
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(child: Icon(Icons.image, size: 64, color: Colors.grey)),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[700]),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildOwnerActions() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Xóa sản phẩm'),
                      content: const Text('Bạn có chắc muốn xóa sản phẩm này?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Hủy'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                          child: const Text('Xóa'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && mounted) {
                    await context.read<MarketplaceProvider>().deleteProduct(widget.productId);
                    if (mounted) context.pop();
                  }
                },
                icon: const Icon(Icons.delete, color: Colors.red),
                label: const Text('Xóa', style: TextStyle(color: Colors.red)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Đánh dấu đã bán'),
                      content: const Text('Xác nhận sản phẩm này đã được bán?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Hủy'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Xác nhận'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && mounted) {
                    await context.read<MarketplaceProvider>().markAsSold(widget.productId);
                    _loadProduct();
                  }
                },
                icon: const Icon(Icons.check),
                label: const Text('Đã bán'),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBuyerActions() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          onPressed: _contactSeller,
          icon: const Icon(Icons.message),
          label: const Text('Nhắn tin cho người bán'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryBlue,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }
}
