/// Product condition enum
enum ProductCondition {
  newProduct,
  likeNew,
  good,
  fair;

  String get label {
    switch (this) {
      case ProductCondition.newProduct:
        return 'Mới';
      case ProductCondition.likeNew:
        return 'Như mới';
      case ProductCondition.good:
        return 'Tốt';
      case ProductCondition.fair:
        return 'Khá';
    }
  }

  static ProductCondition fromString(String? value) {
    return ProductCondition.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ProductCondition.good,
    );
  }
}

/// Product status enum
enum ProductStatus {
  available,
  pending,
  sold;

  String get label {
    switch (this) {
      case ProductStatus.available:
        return 'Đang bán';
      case ProductStatus.pending:
        return 'Đang chờ';
      case ProductStatus.sold:
        return 'Đã bán';
    }
  }

  static ProductStatus fromString(String? value) {
    return ProductStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ProductStatus.available,
    );
  }
}

class ProductEntity {
  final String id;
  final String sellerId;
  final String sellerName;
  final String? sellerProfileImage;
  final String title;
  final String description;
  final double price;
  final String category;
  final ProductCondition condition;
  final ProductStatus status;
  final List<String> images;
  final String? location;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int viewCount;
  final List<String> savedBy; // User IDs who saved this product

  const ProductEntity({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    this.sellerProfileImage,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    this.condition = ProductCondition.good,
    this.status = ProductStatus.available,
    this.images = const [],
    this.location,
    this.latitude,
    this.longitude,
    required this.createdAt,
    this.updatedAt,
    this.viewCount = 0,
    this.savedBy = const [],
  });

  bool isSavedBy(String userId) => savedBy.contains(userId);

  ProductEntity copyWith({
    String? id,
    String? sellerId,
    String? sellerName,
    String? sellerProfileImage,
    String? title,
    String? description,
    double? price,
    String? category,
    ProductCondition? condition,
    ProductStatus? status,
    List<String>? images,
    String? location,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? viewCount,
    List<String>? savedBy,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      sellerProfileImage: sellerProfileImage ?? this.sellerProfileImage,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      condition: condition ?? this.condition,
      status: status ?? this.status,
      images: images ?? this.images,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      viewCount: viewCount ?? this.viewCount,
      savedBy: savedBy ?? this.savedBy,
    );
  }
}

/// Product categories
class ProductCategories {
  static const List<Map<String, dynamic>> categories = [
    {'id': 'vehicles', 'name': 'Xe cộ', 'icon': 'directions_car'},
    {'id': 'electronics', 'name': 'Đồ điện tử', 'icon': 'phone_android'},
    {'id': 'property', 'name': 'Bất động sản', 'icon': 'home'},
    {'id': 'fashion', 'name': 'Thời trang', 'icon': 'checkroom'},
    {'id': 'furniture', 'name': 'Đồ gia dụng', 'icon': 'chair'},
    {'id': 'pets', 'name': 'Thú cưng', 'icon': 'pets'},
    {'id': 'sports', 'name': 'Thể thao', 'icon': 'sports_soccer'},
    {'id': 'books', 'name': 'Sách', 'icon': 'menu_book'},
    {'id': 'toys', 'name': 'Đồ chơi', 'icon': 'toys'},
    {'id': 'other', 'name': 'Khác', 'icon': 'more_horiz'},
  ];

  static String getCategoryName(String id) {
    final category = categories.firstWhere(
      (c) => c['id'] == id,
      orElse: () => {'name': 'Khác'},
    );
    return category['name'] as String;
  }
}
