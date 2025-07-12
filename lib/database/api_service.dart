import '../models/product_model.dart';
import '../models/cart_model.dart';
import 'product_dao.dart';
import 'cart_dao.dart';
import 'package:uuid/uuid.dart';

/// 统一的API服务层，封装主要业务流程
class ApiService {
  static final ApiService _instance = ApiService._internal();
  ApiService._internal();
  factory ApiService() => _instance;

  // ========== 商品相关API ==========

  /// 获取所有商品
  Future<List<ProductModel>> getAllProducts() async {
    return await ProductDao.getAllProducts();
  }

  /// 根据ID获取商品详情
  Future<ProductModel?> getProductDetails(String productId) async {
    return await ProductDao.getProductById(productId);
  }

  /// 搜索商品
  Future<List<ProductModel>> searchProducts(String keyword) async {
    return await ProductDao.searchProducts(keyword);
  }

  /// 获取促销商品
  Future<List<ProductModel>> getDiscountProducts() async {
    return await ProductDao.getDiscountProducts();
  }

  /// 获取有库存的商品
  Future<List<ProductModel>> getInStockProducts() async {
    return await ProductDao.getInStockProducts();
  }

  /// 检查库存是否充足
  Future<bool> checkStock(String productId, int quantity) async {
    return await ProductDao.hasEnoughStock(productId, quantity);
  }

  // ========== 购物车相关API ==========

  /// 添加商品到购物车
  Future<ApiResponse<bool>> addToCart({
    required String productId,
    int quantity = 1,
    String? selectedSize,
    String? selectedColor,
  }) async {
    try {
      // 1. 获取商品信息
      final product = await ProductDao.getProductById(productId);
      if (product == null) {
        return ApiResponse.error('商品不存在');
      }

      // 2. 验证库存
      if (!product.isInStock) {
        return ApiResponse.error('商品暂时缺货');
      }

      if (quantity > product.stock) {
        return ApiResponse.error('库存不足，仅剩${product.stock}件');
      }

      // 3. 验证购买数量
      if (quantity < product.minOrder || quantity > product.maxOrder) {
        return ApiResponse.error('购买数量应在${product.minOrder}-${product.maxOrder}件之间');
      }

      // 4. 创建购物车项目
      final cartItem = CartItem(
        id: const Uuid().v4(),
        product: product,
        quantity: quantity,
        selectedSize: selectedSize,
        selectedColor: selectedColor,
      );

      // 5. 添加到数据库
      final success = await CartDao.addToCart(cartItem);
      
      if (success) {
        return ApiResponse.success(true, '已添加到购物车');
      } else {
        return ApiResponse.error('添加失败');
      }
    } catch (e) {
      return ApiResponse.error('添加时发生错误: $e');
    }
  }

  /// 获取购物车列表
  Future<ApiResponse<List<CartItem>>> getCartItems() async {
    try {
      final items = await CartDao.getAllCartItems();
      return ApiResponse.success(items);
    } catch (e) {
      return ApiResponse.error('获取购物车失败: $e');
    }
  }

  /// 更新购物车商品数量
  Future<ApiResponse<bool>> updateCartQuantity(String cartItemId, int newQuantity) async {
    try {
      final success = await CartDao.updateCartItemQuantity(cartItemId, newQuantity);
      if (success) {
        return ApiResponse.success(true, '数量已更新');
      } else {
        return ApiResponse.error('更新失败');
      }
    } catch (e) {
      return ApiResponse.error('更新时发生错误: $e');
    }
  }

  /// 从购物车移除商品
  Future<ApiResponse<bool>> removeFromCart(String cartItemId) async {
    try {
      final success = await CartDao.removeFromCart(cartItemId);
      if (success) {
        return ApiResponse.success(true, '已移除');
      } else {
        return ApiResponse.error('移除失败');
      }
    } catch (e) {
      return ApiResponse.error('移除时发生错误: $e');
    }
  }

  /// 清空购物车
  Future<ApiResponse<bool>> clearCart() async {
    try {
      final success = await CartDao.clearCart();
      if (success) {
        return ApiResponse.success(true, '购物车已清空');
      } else {
        return ApiResponse.error('清空失败');
      }
    } catch (e) {
      return ApiResponse.error('清空时发生错误: $e');
    }
  }

  /// 获取购物车统计信息
  Future<ApiResponse<CartSummary>> getCartSummary() async {
    try {
      final items = await CartDao.getAllCartItems();
      final itemCount = await CartDao.getCartItemCount();
      final totalPrice = await CartDao.getCartTotalPrice();
      final shippingFee = totalPrice >= 200 ? 0.0 : 15.0;
      
      final summary = CartSummary(
        itemCount: itemCount,
        totalPrice: totalPrice,
        shippingFee: shippingFee,
        finalTotal: totalPrice + shippingFee,
        isEmpty: items.isEmpty,
      );
      
      return ApiResponse.success(summary);
    } catch (e) {
      return ApiResponse.error('获取购物车统计失败: $e');
    }
  }

  // ========== 订单相关API ==========

  /// 结算购物车（创建订单）
  Future<ApiResponse<OrderResult>> checkout() async {
    try {
      // 1. 获取购物车商品
      final cartItems = await CartDao.getAllCartItems();
      if (cartItems.isEmpty) {
        return ApiResponse.error('购物车为空');
      }

      // 2. 验证库存
      for (final item in cartItems) {
        final hasStock = await ProductDao.hasEnoughStock(item.product.id, item.quantity);
        if (!hasStock) {
          return ApiResponse.error('商品${item.product.title}库存不足');
        }
      }

      // 3. 扣减库存
      for (final item in cartItems) {
        final success = await ProductDao.decreaseStock(item.product.id, item.quantity);
        if (!success) {
          return ApiResponse.error('扣减库存失败');
        }
      }

      // 4. 清空购物车
      await CartDao.clearCart();

      // 5. 创建订单结果
      final orderResult = OrderResult(
        orderId: const Uuid().v4(),
        items: cartItems,
        totalAmount: cartItems.fold(0.0, (sum, item) => sum + item.totalPrice),
        orderTime: DateTime.now(),
      );

      return ApiResponse.success(orderResult, '订单创建成功');
    } catch (e) {
      return ApiResponse.error('结算失败: $e');
    }
  }

  /// 验证购物车数据完整性
  Future<ApiResponse<bool>> validateCart() async {
    try {
      await CartDao.validateCartItems();
      return ApiResponse.success(true, '购物车验证完成');
    } catch (e) {
      return ApiResponse.error('验证失败: $e');
    }
  }
}

/// API响应包装类
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String message;

  ApiResponse.success(this.data, [this.message = '操作成功']) : success = true;
  ApiResponse.error(this.message) : success = false, data = null;
}

/// 购物车统计信息
class CartSummary {
  final int itemCount;
  final double totalPrice;
  final double shippingFee;
  final double finalTotal;
  final bool isEmpty;

  CartSummary({
    required this.itemCount,
    required this.totalPrice,
    required this.shippingFee,
    required this.finalTotal,
    required this.isEmpty,
  });
}

/// 订单结果
class OrderResult {
  final String orderId;
  final List<CartItem> items;
  final double totalAmount;
  final DateTime orderTime;

  OrderResult({
    required this.orderId,
    required this.items,
    required this.totalAmount,
    required this.orderTime,
  });
} 