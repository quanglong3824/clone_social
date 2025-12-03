import '../entities/product_entity.dart';

abstract class MarketplaceRepository {
  /// Get all products
  Stream<List<ProductEntity>> getProducts();
  
  /// Get products by category
  Stream<List<ProductEntity>> getProductsByCategory(String category);
  
  /// Get products by seller
  Stream<List<ProductEntity>> getProductsBySeller(String sellerId);
  
  /// Get saved products for a user
  Stream<List<ProductEntity>> getSavedProducts(String userId);
  
  /// Search products
  Future<List<ProductEntity>> searchProducts(String query);
  
  /// Get product by ID
  Future<ProductEntity?> getProductById(String productId);
  
  /// Create a new product listing
  Future<String> createProduct({
    required String title,
    required String description,
    required double price,
    required String category,
    required ProductCondition condition,
    String? location,
  });
  
  /// Update a product
  Future<void> updateProduct(String productId, Map<String, dynamic> data);
  
  /// Delete a product
  Future<void> deleteProduct(String productId);
  
  /// Mark product as sold
  Future<void> markAsSold(String productId);
  
  /// Save/unsave a product
  Future<void> toggleSaveProduct(String productId, String userId);
  
  /// Increment view count
  Future<void> incrementViewCount(String productId);
  
  /// Send message to seller
  Future<String> contactSeller(String productId, String buyerId, String message);
}
