import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shop/database/database_helper.dart';

class TestDatabaseHelper {
  static Database? _testDatabase;
  static String? _testDbPath;

  // 初始化测试数据库
  static Future<void> initializeTestDatabase() async {
    _testDbPath = join(await getDatabasesPath(), 'test_shop.db');
    
    // 删除已存在的测试数据库
    if (await databaseExists(_testDbPath!)) {
      await deleteDatabase(_testDbPath!);
    }

    // 创建新的测试数据库
    _testDatabase = await openDatabase(
      _testDbPath!,
      version: 1,
      onCreate: (db, version) async {
        // 创建所有测试表
        await _createTestTables(db);
      },
    );
  }

  // 创建测试表
  static Future<void> _createTestTables(Database db) async {
    // 创建商品表
    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        image TEXT NOT NULL,
        brand_name TEXT NOT NULL,
        title TEXT NOT NULL,
        price REAL NOT NULL,
        price_after_discount REAL,
        discount_percent INTEGER,
        stock INTEGER NOT NULL DEFAULT 0,
        min_order INTEGER NOT NULL DEFAULT 1,
        max_order INTEGER NOT NULL DEFAULT 10,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 创建购物车表
    await db.execute('''
      CREATE TABLE cart_items (
        id TEXT PRIMARY KEY,
        product_id TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        selected_size TEXT,
        selected_color TEXT,
        added_at TEXT NOT NULL,
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');

    // 创建订单表
    await db.execute('''
      CREATE TABLE orders (
        id TEXT PRIMARY KEY,
        order_number TEXT NOT NULL UNIQUE,
        order_date TEXT NOT NULL,
        status INTEGER NOT NULL DEFAULT 0,
        total_amount REAL NOT NULL,
        shipping_fee REAL NOT NULL DEFAULT 0,
        shipping_address TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 创建订单项表
    await db.execute('''
      CREATE TABLE order_items (
        id TEXT PRIMARY KEY,
        order_id TEXT NOT NULL,
        product_id TEXT NOT NULL,
        product_name TEXT NOT NULL,
        product_image TEXT NOT NULL,
        brand_name TEXT NOT NULL,
        price REAL NOT NULL,
        price_after_discount REAL,
        quantity INTEGER NOT NULL,
        selected_size TEXT,
        selected_color TEXT,
        FOREIGN KEY (order_id) REFERENCES orders (id),
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');

    // 创建用户表
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        name TEXT NOT NULL,
        phone TEXT,
        avatar TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  // 获取测试数据库实例
  static Future<Database> get database async {
    if (_testDatabase == null) {
      await initializeTestDatabase();
    }
    return _testDatabase!;
  }

  // 清空测试数据库
  static Future<void> clearTestDatabase() async {
    if (_testDatabase != null) {
      await _testDatabase!.delete('cart_items');
      await _testDatabase!.delete('order_items');
      await _testDatabase!.delete('orders');
      await _testDatabase!.delete('products');
      await _testDatabase!.delete('users');
    }
  }

  // 关闭测试数据库
  static Future<void> closeTestDatabase() async {
    if (_testDatabase != null) {
      await _testDatabase!.close();
      _testDatabase = null;
    }
    
    if (_testDbPath != null && await databaseExists(_testDbPath!)) {
      await deleteDatabase(_testDbPath!);
      _testDbPath = null;
    }
  }

  // 插入测试数据
  static Future<void> insertTestData(Database db) async {
    // 插入测试商品
    await db.insert('products', {
      'id': 'test_product_1',
      'image': 'test_image_1.jpg',
      'brand_name': '测试品牌1',
      'title': '测试商品1',
      'price': 100.0,
      'price_after_discount': 80.0,
      'discount_percent': 20,
      'stock': 50,
      'min_order': 1,
      'max_order': 10,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });

    await db.insert('products', {
      'id': 'test_product_2',
      'image': 'test_image_2.jpg',
      'brand_name': '测试品牌2',
      'title': '测试商品2',
      'price': 200.0,
      'stock': 30,
      'min_order': 1,
      'max_order': 5,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });

    // 插入测试用户
    await db.insert('users', {
      'id': 'test_user_1',
      'email': 'test@example.com',
      'password': 'hashed_password',
      'name': '测试用户',
      'phone': '13800138000',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  // 验证测试数据
  static Future<bool> validateTestData() async {
    try {
      final db = await database;
      
      // 检查商品表
      final products = await db.query('products');
      if (products.isEmpty) return false;
      
      // 检查用户表
      final users = await db.query('users');
      if (users.isEmpty) return false;
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // 获取测试统计信息
  static Future<Map<String, int>> getTestStatistics() async {
    final db = await database;
    
    return {
      'products': (await db.query('products')).length,
      'cart_items': (await db.query('cart_items')).length,
      'orders': (await db.query('orders')).length,
      'order_items': (await db.query('order_items')).length,
      'users': (await db.query('users')).length,
    };
  }
} 