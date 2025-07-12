import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../database/product_dao.dart';

class ProductProvider extends ChangeNotifier {
  List<ProductModel> _allProducts = [];// 所有商品
  List<ProductModel> _popularProducts = [];// 热门商品
  List<ProductModel> _flashSaleProducts = [];// 闪购商品
  List<ProductModel> _bestSellersProducts = [];// 畅销商品
  List<ProductModel> _kidsProducts = [];// 儿童商品
  
  bool _isLoading = false;
  
  ProductProvider() {
    // 延迟加载，避免阻塞主线程
    Future.microtask(() => _loadProducts());
  }

  // Getters
  List<ProductModel> get allProducts => _allProducts;
  List<ProductModel> get popularProducts => _popularProducts;
  List<ProductModel> get flashSaleProducts => _flashSaleProducts;
  List<ProductModel> get bestSellersProducts => _bestSellersProducts;
  List<ProductModel> get kidsProductsList => _kidsProducts;
  bool get isLoading => _isLoading;

  // 加载所有商品数据
  Future<void> _loadProducts() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _allProducts = await ProductDao.getAllProducts();
      
      // 根据不同标准分类商品
      _popularProducts = _allProducts.take(8).toList();
      _flashSaleProducts = await ProductDao.getDiscountProducts();
      _bestSellersProducts = _allProducts.where((p) => p.stock > 20).take(8).toList();
      _kidsProducts = _allProducts.where((p) => 
        p.title.toLowerCase().contains('儿童') || 
        p.brandName.toLowerCase().contains('kids') ||
        p.title.toLowerCase().contains('kids')).toList();
      
    } catch (e) {
      debugPrint('加载商品数据失败: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 刷新商品数据
  Future<void> refreshProducts() async {
    await _loadProducts();
  }

  // 根据ID获取商品
  Future<ProductModel?> getProductById(String productId) async {
    // 先从内存中查找
    ProductModel? product;
    try {
      product = _allProducts.firstWhere((p) => p.id == productId);
    } catch (e) {
      product = null;
    }
    
    // 如果内存中没有，从数据库查找
    if (product == null) {
      product = await ProductDao.getProductById(productId);
      if (product != null) {
        // 更新内存中的数据
        await _loadProducts();
      }
    }
    
    return product;
  }

  // 搜索商品
  Future<List<ProductModel>> searchProducts(String query) async {
    if (query.isEmpty) return [];
    return await ProductDao.searchProducts(query);
  }

  // 检查商品是否有库存
  Future<bool> isProductInStock(String productId) async {
    final product = await getProductById(productId);
    return product != null && product.isInStock;
  }

  // 检查是否可以购买指定数量
  Future<bool> canPurchaseQuantity(String productId, int quantity) async {
    final product = await getProductById(productId);
    if (product == null) return false;
    
    return quantity <= product.stock && 
           quantity >= product.minOrder && 
           quantity <= product.maxOrder;
  }

  // 获取商品的最大可购买数量
  Future<int> getMaxPurchaseQuantity(String productId) async {
    final product = await getProductById(productId);
    if (product == null) return 0;
    
    return product.stock > product.maxOrder ? product.maxOrder : product.stock;
  }

  // 核心业务逻辑：购买商品（扣减库存）
  Future<bool> purchaseProduct(String productId, int quantity) async {
    // 检查是否可以购买
    if (!await canPurchaseQuantity(productId, quantity)) {
      return false;
    }
    
    // 检查库存是否充足
    if (!await ProductDao.hasEnoughStock(productId, quantity)) {
      return false;
    }
    
    // 扣减库存
    final success = await ProductDao.decreaseStock(productId, quantity);
    if (success) {
      // 更新内存中的数据
      await _loadProducts();
    }
    
    return success;
  }

  // 核心业务逻辑：恢复库存（取消订单时调用）
  Future<bool> restoreStock(String productId, int quantity) async {
    final success = await ProductDao.increaseStock(productId, quantity);
    if (success) {
      // 更新内存中的数据
      await _loadProducts();
    }
    return success;
  }

  // 添加新商品
  Future<bool> addProduct(ProductModel product) async {
    try {
      await ProductDao.insertProduct(product);
      await _loadProducts();
      return true;
    } catch (e) {
      debugPrint('添加商品失败: $e');
      return false;
    }
  }

  // 更新商品信息
  Future<bool> updateProduct(ProductModel product) async {
    try {
      await ProductDao.updateProduct(product);
      await _loadProducts();
      return true;
    } catch (e) {
      debugPrint('更新商品失败: $e');
      return false;
    }
  }

  // 删除商品
  Future<bool> deleteProduct(String productId) async {
    try {
      await ProductDao.deleteProduct(productId);
      await _loadProducts();
      return true;
    } catch (e) {
      debugPrint('删除商品失败: $e');
      return false;
    }
  }

  // 按分类获取商品
  Future<List<ProductModel>> getProductsByCategory(String category) async {
    switch (category.toLowerCase()) {
      case 'popular':
        return popularProducts;
      case 'flash':
      case 'sale':
      case '促销商品':
        return await ProductDao.getDiscountProducts();
      case 'bestsellers':
        return bestSellersProducts;
      case 'kids':
      case '儿童装':
        return kidsProductsList;
      case 'women':
      case '女装':
        return _allProducts.where((p) => 
          p.title.contains('女士') || 
          p.title.contains('女款') ||
          (p.brandName.contains('Zara') && !p.title.contains('男士')) ||
          p.title.contains('连衣裙') ||
          p.title.contains('毛衣') ||
          p.title.contains('衬衫') ||
          p.title.contains('开衫') ||
          p.title.contains('风衣')).toList();
      case 'men':
      case '男装':
        return _allProducts.where((p) => 
          p.title.contains('男士') || 
          p.title.contains('男款') ||
          p.title.contains('西装')).toList();
      case 'shoes':
      case '鞋类':
        return _allProducts.where((p) => 
          p.title.contains('鞋') ||
          p.title.contains('运动鞋') ||
          p.title.contains('跑步鞋') ||
          p.title.contains('帆布鞋') ||
          p.title.contains('高跟鞋')).toList();
      case 'accessories':
      case '配饰':
        return _allProducts.where((p) => 
          p.title.contains('背包') ||
          p.title.contains('手提包') ||
          p.title.contains('手表') ||
          p.title.contains('太阳镜')).toList();
      case 'sports':
      case '运动用品':
        return _allProducts.where((p) => 
          p.title.contains('运动') ||
          p.title.contains('健身') ||
          p.title.contains('瑜伽') ||
          p.title.contains('卫衣') ||
          p.title.contains('紧身裤') ||
          p.title.contains('水壶')).toList();
      case 'instock':
        return await ProductDao.getInStockProducts();
      default:
        return _allProducts;
    }
  }

  // 获取促销商品
  Future<List<ProductModel>> getDiscountProducts() async {
    return await ProductDao.getDiscountProducts();
  }

  // 获取有库存的商品
  Future<List<ProductModel>> getInStockProducts() async {
    return await ProductDao.getInStockProducts();
  }
} 