import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/cart_model.dart';
import '../models/product_model.dart';
import '../database/cart_dao.dart';
import '../database/product_dao.dart';
import 'product_provider.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];
  final ProductProvider _productProvider;
  bool _isLoading = false;
  
  CartProvider(this._productProvider) {
    // 延迟加载，避免阻塞主线程
    Future.microtask(() => _loadCartFromDatabase());
  }

  // 获取购物车商品列表
  List<CartItem> get items => List.unmodifiable(_items);

  // 获取购物车商品总数
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  // 获取购物车总价
  double get totalPrice => _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  // 获取运费（满200免运费）
  double get shippingFee => totalPrice >= 200 ? 0.0 : 15.0;

  // 获取最终总价
  double get finalTotalPrice => totalPrice + shippingFee;

  // 检查购物车是否为空
  bool get isEmpty => _items.isEmpty;

  // 是否正在加载
  bool get isLoading => _isLoading;

  // 核心逻辑：添加商品到购物车
  Future<bool> addToCart({
    required ProductModel product,
    int quantity = 1,
    String? selectedSize,
    String? selectedColor,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // 1. 验证商品信息
      final latestProduct = await ProductDao.getProductById(product.id);
      if (latestProduct == null) {
        _showMessage('商品不存在');
        return false;
      }

      // 2. 检查商品是否有库存
      if (!latestProduct.isInStock) {
        _showMessage('商品暂时缺货');
        return false;
      }

      // 3. 检查数量是否合法
      if (quantity < latestProduct.minOrder || quantity > latestProduct.maxOrder) {
        _showMessage('购买数量不符合要求（${latestProduct.minOrder}-${latestProduct.maxOrder}件）');
        return false;
      }

      // 4. 检查库存是否充足
      if (quantity > latestProduct.stock) {
        _showMessage('库存不足，仅剩${latestProduct.stock}件');
        return false;
      }

      // 5. 创建购物车项目
      final cartItem = CartItem(
        id: const Uuid().v4(),
        product: latestProduct,
        quantity: quantity,
        selectedSize: selectedSize,
        selectedColor: selectedColor,
      );

      // 6. 添加到数据库
      final success = await CartDao.addToCart(cartItem);
      if (success) {
        await _loadCartFromDatabase();
        _showMessage('已添加到购物车');
        return true;
      } else {
        _showMessage('添加到购物车失败');
        return false;
      }
    } catch (e) {
      debugPrint('添加到购物车失败: $e');
      _showMessage('添加到购物车时发生错误');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 核心逻辑：更新购物车商品数量
  Future<bool> updateQuantity(String cartItemId, int newQuantity) async {
    try {
      _isLoading = true;
      notifyListeners();

      // 找到购物车项目
      final item = _items.firstWhere(
        (item) => item.id == cartItemId,
        orElse: () => throw Exception('购物车项目不存在'),
      );

      final product = item.product;

      // 检查新数量是否合法
      if (newQuantity < product.minOrder) {
        _showMessage('最少购买${product.minOrder}件');
        return false;
      }

      if (newQuantity > product.maxOrder) {
        _showMessage('最多购买${product.maxOrder}件');
        return false;
      }

      // 检查库存
      if (newQuantity > product.stock) {
        _showMessage('库存不足，仅剩${product.stock}件');
        return false;
      }

      // 更新数据库
      final success = await CartDao.updateCartItemQuantity(cartItemId, newQuantity);
      if (success) {
        await _loadCartFromDatabase();
        return true;
      } else {
        _showMessage('更新数量失败');
        return false;
      }
    } catch (e) {
      debugPrint('更新购物车数量失败: $e');
      _showMessage('更新数量时发生错误');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 从购物车移除商品
  Future<void> removeFromCart(String cartItemId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final success = await CartDao.removeFromCart(cartItemId);
      if (success) {
        await _loadCartFromDatabase();
        _showMessage('已从购物车移除');
      } else {
        _showMessage('移除失败');
      }
    } catch (e) {
      debugPrint('移除购物车项目失败: $e');
      _showMessage('移除时发生错误');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 清空购物车
  Future<void> clearCart() async {
    try {
      _isLoading = true;
      notifyListeners();

      final success = await CartDao.clearCart();
      if (success) {
        _items.clear();
        _showMessage('购物车已清空');
      } else {
        _showMessage('清空失败');
      }
    } catch (e) {
      debugPrint('清空购物车失败: $e');
      _showMessage('清空时发生错误');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 核心逻辑：结算（创建订单并扣减库存）
  Future<String?> checkout({String shippingAddress = "默认收货地址"}) async {
    if (_items.isEmpty) {
      _showMessage('购物车为空');
      return null;
    }

    try {
      _isLoading = true;
      notifyListeners();

      // 1. 验证购物车数据完整性
      await CartDao.validateCartItems();
      await _loadCartFromDatabase();

      if (_items.isEmpty) {
        _showMessage('购物车中的商品已售完');
        return null;
      }

      // 2. 再次验证所有商品的库存
      for (final item in _items) {
        final latestProduct = await ProductDao.getProductById(item.product.id);
        if (latestProduct == null) {
          _showMessage('商品${item.product.title}不存在');
          return null;
        }

        if (!await ProductDao.hasEnoughStock(item.product.id, item.quantity)) {
          _showMessage('商品${item.product.title}库存不足');
          return null;
        }
      }

      // 3. 扣减库存
      for (final item in _items) {
        final success = await ProductDao.decreaseStock(item.product.id, item.quantity);
        if (!success) {
          _showMessage('结算失败，库存已发生变化');
          return null;
        }
      }

      // 4. 创建订单（这里返回订单ID，由调用方处理订单创建）
      final orderData = {
        'items': List.from(_items),
        'shippingFee': shippingFee,
        'shippingAddress': shippingAddress,
      };

      // 5. 清空购物车
      await CartDao.clearCart();
      _items.clear();
      
      _showMessage('订单提交成功！');
      return 'checkout_success'; // 返回成功标识
    } catch (e) {
      debugPrint('结算失败: $e');
      _showMessage('结算时发生错误');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 获取当前购物车项目的副本（用于订单创建）
  List<CartItem> getCartItemsForOrder() {
    return List.from(_items);
  }

  // 获取指定商品在购物车中的数量
  Future<int> getProductQuantityInCart(String productId, {String? size, String? color}) async {
    return await CartDao.getProductQuantityInCart(
      productId,
      selectedSize: size,
      selectedColor: color,
    );
  }

  // 检查商品是否在购物车中
  Future<bool> isProductInCart(String productId, {String? size, String? color}) async {
    return await CartDao.isProductInCart(
      productId,
      selectedSize: size,
      selectedColor: color,
    );
  }

  // 从数据库加载购物车数据
  Future<void> _loadCartFromDatabase() async {
    try {
      _items = await CartDao.getAllCartItems();
      // 验证数据完整性
      await CartDao.validateCartItems();
      // 重新加载以获取最新的数据
      _items = await CartDao.getAllCartItems();
    } catch (e) {
      debugPrint('加载购物车数据失败: $e');
      _items = [];
    }
  }

  // 刷新购物车数据
  Future<void> refreshCart() async {
    _isLoading = true;
    notifyListeners();
    
    await _loadCartFromDatabase();
    
    _isLoading = false;
    notifyListeners();
  }

  // 显示消息（使用调试输出）
  void _showMessage(String message) {
    debugPrint('🛒 Cart Message: $message');
    // 注意：在Provider中无法直接访问BuildContext显示SnackBar
    // UI层需要监听添加结果并显示相应消息
  }

  // 获取购物车摘要信息
  Map<String, dynamic> getCartSummary() {
    return {
      'itemCount': itemCount,
      'totalPrice': totalPrice,
      'shippingFee': shippingFee,
      'finalTotal': finalTotalPrice,
      'isEmpty': isEmpty,
      'isLoading': isLoading,
    };
  }
} 