import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/marketplace_repository.dart';
import 'package:clone_social/core/services/firebase_service.dart';

class MarketplaceRepositoryImpl implements MarketplaceRepository {
  final FirebaseService _firebaseService;

  MarketplaceRepositoryImpl({
    FirebaseService? firebaseService,
  }) : _firebaseService = firebaseService ?? FirebaseService();

  DatabaseReference get _productsRef => _firebaseService.database.child('products');

  @override
  Stream<List<ProductEntity>> getProducts() {
    return _productsRef
        .orderByChild('createdAt')
        .onValue
        .map((event) => _parseProducts(event));
  }

  @override
  Stream<List<ProductEntity>> getProductsByCategory(String category) {
    return _productsRef
        .orderByChild('category')
        .equalTo(category)
        .onValue
        .map((event) => _parseProducts(event));
  }

  @override
  Stream<List<ProductEntity>> getProductsBySeller(String sellerId) {
    return _productsRef
        .orderByChild('sellerId')
        .equalTo(sellerId)
        .onValue
        .map((event) => _parseProducts(event));
  }

  @override
  Stream<List<ProductEntity>> getSavedProducts(String userId) {
    return _firebaseService.database
        .child('savedProducts')
        .child(userId)
        .onValue
        .asyncMap((event) async {
      final products = <ProductEntity>[];
      if (event.snapshot.value != null) {
        final savedIds = Map<String, dynamic>.from(event.snapshot.value as Map);
        for (var productId in savedIds.keys) {
          final product = await getProductById(productId);
          if (product != null) {
            products.add(product);
          }
        }
      }
      return products;
    });
  }

  @override
  Future<List<ProductEntity>> searchProducts(String query) async {
    final snapshot = await _productsRef.get();
    if (!snapshot.exists || snapshot.value == null) return [];

    final products = <ProductEntity>[];
    final data = Map<String, dynamic>.from(snapshot.value as Map);
    final lowerQuery = query.toLowerCase();

    data.forEach((key, value) {
      final productData = Map<String, dynamic>.from(value);
      final title = (productData['title'] ?? '').toString().toLowerCase();
      final description = (productData['description'] ?? '').toString().toLowerCase();
      
      if (title.contains(lowerQuery) || description.contains(lowerQuery)) {
        products.add(_mapToProductEntity(key, productData));
      }
    });

    products.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return products;
  }

  @override
  Future<ProductEntity?> getProductById(String productId) async {
    final snapshot = await _productsRef.child(productId).get();
    if (!snapshot.exists || snapshot.value == null) return null;
    return _mapToProductEntity(productId, Map<String, dynamic>.from(snapshot.value as Map));
  }

  @override
  Future<String> createProduct({
    required String title,
    required String description,
    required double price,
    required String category,
    required ProductCondition condition,
    String? location,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Get user info
    final userSnapshot = await _firebaseService.userRef(user.uid).get();
    String sellerName = user.displayName ?? 'User';
    String? sellerProfileImage = user.photoURL;

    if (userSnapshot.exists && userSnapshot.value != null) {
      final userData = Map<String, dynamic>.from(userSnapshot.value as Map);
      sellerName = userData['name'] ?? sellerName;
      sellerProfileImage = userData['profileImage'] ?? sellerProfileImage;
    }

    final productId = _productsRef.push().key!;

    final productData = {
      'sellerId': user.uid,
      'sellerName': sellerName,
      'sellerProfileImage': sellerProfileImage,
      'title': title,
      'description': description,
      'price': price,
      'category': category,
      'condition': condition.name,
      'status': ProductStatus.available.name,
      'images': <String>[],
      'location': location,
      'createdAt': ServerValue.timestamp,
      'viewCount': 0,
    };

    await _productsRef.child(productId).set(productData);
    return productId;
  }

  @override
  Future<void> updateProduct(String productId, Map<String, dynamic> data) async {
    data['updatedAt'] = ServerValue.timestamp;
    await _productsRef.child(productId).update(data);
  }

  @override
  Future<void> deleteProduct(String productId) async {
    await _productsRef.child(productId).remove();
  }

  @override
  Future<void> markAsSold(String productId) async {
    await _productsRef.child(productId).update({
      'status': ProductStatus.sold.name,
      'updatedAt': ServerValue.timestamp,
    });
  }

  @override
  Future<void> toggleSaveProduct(String productId, String userId) async {
    final savedRef = _firebaseService.database
        .child('savedProducts')
        .child(userId)
        .child(productId);
    
    final snapshot = await savedRef.get();
    if (snapshot.exists) {
      await savedRef.remove();
      // Remove from product's savedBy list
      await _productsRef.child(productId).child('savedBy').child(userId).remove();
    } else {
      await savedRef.set(ServerValue.timestamp);
      // Add to product's savedBy list
      await _productsRef.child(productId).child('savedBy').child(userId).set(true);
    }
  }

  @override
  Future<void> incrementViewCount(String productId) async {
    await _productsRef.child(productId).child('viewCount').set(ServerValue.increment(1));
  }

  @override
  Future<String> contactSeller(String productId, String buyerId, String message) async {
    final product = await getProductById(productId);
    if (product == null) throw Exception('Product not found');

    // Create or get existing chat
    final chatSnapshot = await _firebaseService.userChatsRef(buyerId).get();
    String? existingChatId;
    
    if (chatSnapshot.exists && chatSnapshot.value != null) {
      final chats = Map<String, dynamic>.from(chatSnapshot.value as Map);
      for (var entry in chats.entries) {
        final chatData = Map<String, dynamic>.from(entry.value);
        final participants = List<String>.from(chatData['participants'] ?? []);
        if (participants.contains(product.sellerId)) {
          existingChatId = entry.key;
          break;
        }
      }
    }

    if (existingChatId != null) {
      // Send message to existing chat
      final messageId = _firebaseService.database.child('messages').child(existingChatId).push().key!;
      await _firebaseService.database.child('messages').child(existingChatId).child(messageId).set({
        'senderId': buyerId,
        'content': message,
        'productId': productId,
        'createdAt': ServerValue.timestamp,
        'read': false,
      });
      return existingChatId;
    }

    // Create new chat
    final chatId = _firebaseService.database.child('chats').push().key!;
    
    // Get buyer info
    final buyerSnapshot = await _firebaseService.userRef(buyerId).get();
    final buyerData = buyerSnapshot.exists 
        ? Map<String, dynamic>.from(buyerSnapshot.value as Map)
        : <String, dynamic>{};

    final chatData = {
      'participants': [buyerId, product.sellerId],
      'lastMessage': message,
      'lastMessageTime': ServerValue.timestamp,
      'lastMessageSenderId': buyerId,
      'createdAt': ServerValue.timestamp,
      'participantInfo': {
        buyerId: {
          'name': buyerData['name'] ?? 'User',
          'profileImage': buyerData['profileImage'],
        },
        product.sellerId: {
          'name': product.sellerName,
          'profileImage': product.sellerProfileImage,
        },
      },
    };

    await _firebaseService.userChatsRef(buyerId).child(chatId).set(chatData);
    await _firebaseService.userChatsRef(product.sellerId).child(chatId).set(chatData);

    // Send first message
    final messageId = _firebaseService.database.child('messages').child(chatId).push().key!;
    await _firebaseService.database.child('messages').child(chatId).child(messageId).set({
      'senderId': buyerId,
      'content': message,
      'productId': productId,
      'createdAt': ServerValue.timestamp,
      'read': false,
    });

    return chatId;
  }

  List<ProductEntity> _parseProducts(DatabaseEvent event) {
    final products = <ProductEntity>[];
    if (event.snapshot.value != null) {
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      data.forEach((key, value) {
        final product = _mapToProductEntity(key, Map<String, dynamic>.from(value));
        // Only show available products
        if (product.status == ProductStatus.available) {
          products.add(product);
        }
      });
    }
    products.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return products;
  }

  ProductEntity _mapToProductEntity(String id, Map<String, dynamic> data) {
    List<String> savedBy = [];
    if (data['savedBy'] != null) {
      savedBy = Map<String, dynamic>.from(data['savedBy']).keys.toList();
    }

    return ProductEntity(
      id: id,
      sellerId: data['sellerId'] ?? '',
      sellerName: data['sellerName'] ?? 'Unknown',
      sellerProfileImage: data['sellerProfileImage'],
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      category: data['category'] ?? 'other',
      condition: ProductCondition.fromString(data['condition']),
      status: ProductStatus.fromString(data['status']),
      images: data['images'] != null ? List<String>.from(data['images']) : [],
      location: data['location'],
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] ?? 0),
      updatedAt: data['updatedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(data['updatedAt'])
          : null,
      viewCount: data['viewCount'] ?? 0,
      savedBy: savedBy,
    );
  }
}
