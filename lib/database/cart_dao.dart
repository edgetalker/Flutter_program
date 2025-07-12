import '../models/cart_model.dart';
import 'database_helper.dart';
import 'product_dao.dart';

class CartDao {
  static final DatabaseHelper _databaseHelper = DatabaseHelper();

  // 获取所有购物车项目
  static Future<List<CartItem>> getAllCartItems() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('cart_items');
    
    List<CartItem> cartItems = [];
    for (final map in maps) {
      final product = await ProductDao.getProductById(map['product_id']);
      if (product != null) {
        cartItems.add(CartItem.fromMap(map, product));
      }
    }
    return cartItems;
  }

  // 添加商品到购物车
  static Future<bool> addToCart(CartItem cartItem) async {
    final db = await _databaseHelper.database;
    
    // 检查是否已存在相同的商品项（同样的商品、规格）
    final existing = await _findExistingCartItem(
      cartItem.product.id,
      cartItem.selectedSize,
      cartItem.selectedColor,
    );
    
    if (existing != null) {
      // 如果存在，更新数量
      final newQuantity = existing.quantity + cartItem.quantity;
      return await updateCartItemQuantity(existing.id, newQuantity);
    } else {
      // 如果不存在，插入新记录
      final result = await db.insert('cart_items', {
        'id': cartItem.id,
        'product_id': cartItem.product.id,
        'quantity': cartItem.quantity,
        'selected_size': cartItem.selectedSize,
        'selected_color': cartItem.selectedColor,
        'added_at': cartItem.addedAt.toIso8601String(),
      });
      return result > 0;
    }
  }

  // 更新购物车项目数量
  static Future<bool> updateCartItemQuantity(String cartItemId, int newQuantity) async {
    final db = await _databaseHelper.database;
    final result = await db.update(
      'cart_items',
      {'quantity': newQuantity},
      where: 'id = ?',
      whereArgs: [cartItemId],
    );
    return result > 0;
  }

  // 从购物车移除商品
  static Future<bool> removeFromCart(String cartItemId) async {
    final db = await _databaseHelper.database;
    final result = await db.delete(
      'cart_items',
      where: 'id = ?',
      whereArgs: [cartItemId],
    );
    return result > 0;
  }

  // 清空购物车
  static Future<bool> clearCart() async {
    final db = await _databaseHelper.database;
    final result = await db.delete('cart_items');
    return result >= 0;
  }

  // 获取购物车商品总数
  static Future<int> getCartItemCount() async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery('SELECT SUM(quantity) as total FROM cart_items');
    final total = result.first['total'];
    if (total == null) return 0;
    if (total is int) return total;
    if (total is double) return total.round();
    return int.tryParse(total.toString()) ?? 0;
  }

  // 获取购物车总价
  static Future<double> getCartTotalPrice() async {
    final cartItems = await getAllCartItems();
    return cartItems.fold<double>(0.0, (sum, item) => sum + item.totalPrice);
  }

  // 检查商品是否在购物车中
  static Future<bool> isProductInCart(
    String productId, {
    String? selectedSize,
    String? selectedColor,
  }) async {
    final existing = await _findExistingCartItem(productId, selectedSize, selectedColor);
    return existing != null;
  }

  // 获取商品在购物车中的数量
  static Future<int> getProductQuantityInCart(
    String productId, {
    String? selectedSize,
    String? selectedColor,
  }) async {
    final existing = await _findExistingCartItem(productId, selectedSize, selectedColor);
    return existing?.quantity ?? 0;
  }

  // 查找已存在的购物车项目
  static Future<CartItem?> _findExistingCartItem(
    String productId,
    String? selectedSize,
    String? selectedColor,
  ) async {
    final db = await _databaseHelper.database;
    
    String whereClause = 'product_id = ?';
    List<dynamic> whereArgs = [productId];
    
    if (selectedSize != null) {
      whereClause += ' AND selected_size = ?';
      whereArgs.add(selectedSize);
    } else {
      whereClause += ' AND selected_size IS NULL';
    }
    
    if (selectedColor != null) {
      whereClause += ' AND selected_color = ?';
      whereArgs.add(selectedColor);
    } else {
      whereClause += ' AND selected_color IS NULL';
    }
    
    final List<Map<String, dynamic>> maps = await db.query(
      'cart_items',
      where: whereClause,
      whereArgs: whereArgs,
    );
    
    if (maps.isNotEmpty) {
      final product = await ProductDao.getProductById(productId);
      if (product != null) {
        return CartItem.fromMap(maps.first, product);
      }
    }
    
    return null;
  }

  // 验证购物车数据完整性
  static Future<void> validateCartItems() async {
    final db = await _databaseHelper.database;
    
    // 删除对应商品不存在的购物车项目
    await db.execute('''
      DELETE FROM cart_items 
      WHERE product_id NOT IN (SELECT id FROM products)
    ''');
    
    // 更新购物车项目中商品库存不足的情况
    final cartItems = await getAllCartItems();
    for (final item in cartItems) {
      if (item.quantity > item.product.stock) {
        if (item.product.stock > 0) {
          // 如果还有库存，调整为最大可用数量
          await updateCartItemQuantity(item.id, item.product.stock);
        } else {
          // 如果没有库存，移除该项目
          await removeFromCart(item.id);
        }
      }
    }
  }
} 