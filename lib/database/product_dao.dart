import '../models/product_model.dart';
import 'database_helper.dart';

class ProductDao {
  static final DatabaseHelper _databaseHelper = DatabaseHelper();

  // 获取所有商品
  static Future<List<ProductModel>> getAllProducts() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('products');
    return List.generate(maps.length, (i) => ProductModel.fromMap(maps[i]));
  }
  // 根据ID获取商品
  static Future<ProductModel?> getProductById(String id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return ProductModel.fromMap(maps.first);
    }
    return null;
  }
  // 搜索商品
  static Future<List<ProductModel>> searchProducts(String query) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'title LIKE ? OR brand_name LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return List.generate(maps.length, (i) => ProductModel.fromMap(maps[i]));
  }
  // 获取有库存的商品
  static Future<List<ProductModel>> getInStockProducts() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'stock > 0',
    );
    return List.generate(maps.length, (i) => ProductModel.fromMap(maps[i]));
  }
  // 获取促销商品
  static Future<List<ProductModel>> getDiscountProducts() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'price_after_discount IS NOT NULL',
    );
    return List.generate(maps.length, (i) => ProductModel.fromMap(maps[i]));
  }
  // 添加商品
  static Future<int> insertProduct(ProductModel product) async {
    final db = await _databaseHelper.database;
    return await db.insert('products', product.toMap());
  }
  // 更新商品
  static Future<int> updateProduct(ProductModel product) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'products',
      product.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }
  // 更新库存
  static Future<bool> updateStock(String productId, int newStock) async {
    final db = await _databaseHelper.database;
    final result = await db.update(
      'products',
      {
        'stock': newStock,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [productId],
    );
    return result > 0;
  }
  // 扣减库存
  static Future<bool> decreaseStock(String productId, int quantity) async {
    final product = await getProductById(productId);
    if (product == null || product.stock < quantity) {
      return false;
    }
    
    return await updateStock(productId, product.stock - quantity);
  }
  // 增加库存
  static Future<bool> increaseStock(String productId, int quantity) async {
    final product = await getProductById(productId);
    if (product == null) {
      return false;
    }
    
    return await updateStock(productId, product.stock + quantity);
  }
  // 删除商品
  static Future<int> deleteProduct(String productId) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [productId],
    );
  }
  // 检查商品是否存在
  static Future<bool> productExists(String productId) async {
    final product = await getProductById(productId);
    return product != null;
  }
  // 检查库存是否充足
  static Future<bool> hasEnoughStock(String productId, int quantity) async {
    final product = await getProductById(productId);
    return product != null && product.stock >= quantity;
  }
} 