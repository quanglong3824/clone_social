import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/marketplace_repository.dart';
import '../../data/repositories/marketplace_repository_impl.dart';

class MarketplaceProvider extends ChangeNotifier {
  final MarketplaceRepository _repository;

  List<ProductEntity> _products = [];
  List<ProductEntity> _savedProducts = [];
  List<ProductEntity> _myProducts = [];
  List<ProductEntity> _searchResults = [];
  bool _isLoading = false;
  String? _error;
  String? _selectedCategory;
  StreamSubscription? _productsSubscription;
  StreamSubscription? _savedSubscription;
  StreamSubscription? _myProductsSubscription;

  MarketplaceProvider({MarketplaceRepository? repository})
      : _repository = repository ?? MarketplaceRepositoryImpl();

  List<ProductEntity> get products => _selectedCategory != null
      ? _products.where((p) => p.category == _selectedCategory).toList()
      : _products;
  List<ProductEntity> get savedProducts => _savedProducts;
  List<ProductEntity> get myProducts => _myProducts;
  List<ProductEntity> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedCategory => _selectedCategory;

  void init(String userId) {
    _productsSubscription?.cancel();
    _savedSubscription?.cancel();
    _myProductsSubscription?.cancel();

    _isLoading = true;
    notifyListeners();

    _productsSubscription = _repository.getProducts().listen((products) {
      _products = products;
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    });

    _savedSubscription = _repository.getSavedProducts(userId).listen((products) {
      _savedProducts = products;
      notifyListeners();
    });

    _myProductsSubscription = _repository.getProductsBySeller(userId).listen((products) {
      _myProducts = products;
      notifyListeners();
    });
  }

  void setCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> searchProducts(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _searchResults = await _repository.searchProducts(query);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ProductEntity?> getProductById(String productId) async {
    try {
      return await _repository.getProductById(productId);
    } catch (e) {
      _error = e.toString();
      return null;
    }
  }

  Future<String?> createProduct({
    required String title,
    required String description,
    required double price,
    required String category,
    required ProductCondition condition,
    String? location,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final productId = await _repository.createProduct(
        title: title,
        description: description,
        price: price,
        category: category,
        condition: condition,
        location: location,
      );
      _isLoading = false;
      notifyListeners();
      return productId;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateProduct(String productId, Map<String, dynamic> data) async {
    try {
      await _repository.updateProduct(productId, data);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<bool> deleteProduct(String productId) async {
    try {
      await _repository.deleteProduct(productId);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<bool> markAsSold(String productId) async {
    try {
      await _repository.markAsSold(productId);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<void> toggleSaveProduct(String productId, String userId) async {
    try {
      await _repository.toggleSaveProduct(productId, userId);
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<void> incrementViewCount(String productId) async {
    try {
      await _repository.incrementViewCount(productId);
    } catch (e) {
      debugPrint('Error incrementing view count: $e');
    }
  }

  Future<String?> contactSeller(String productId, String buyerId, String message) async {
    try {
      return await _repository.contactSeller(productId, buyerId, message);
    } catch (e) {
      _error = e.toString();
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _productsSubscription?.cancel();
    _savedSubscription?.cancel();
    _myProductsSubscription?.cancel();
    super.dispose();
  }
}
