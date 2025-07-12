import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'shop.db');

    return await openDatabase(
      path,
      version: 7,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 创建用户表
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        email TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        name TEXT NOT NULL,
        phone TEXT,
        avatar TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 创建用户会话表
    await db.execute('''
      CREATE TABLE user_sessions (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        device_id TEXT,
        login_at TEXT NOT NULL,
        last_activity TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

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

    // 创建分类表
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        image TEXT,
        svg_src TEXT,
        parent_id INTEGER,
        sort_order INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        FOREIGN KEY (parent_id) REFERENCES categories (id)
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

    // 插入初始数据
    await _insertInitialData(db);
    await _insertDefaultUsers(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 7) {
      // 创建用户表（如果不存在）
      await db.execute('''
        CREATE TABLE IF NOT EXISTS users (
          id TEXT PRIMARY KEY,
          email TEXT NOT NULL UNIQUE,
          password_hash TEXT NOT NULL,
          name TEXT NOT NULL,
          phone TEXT,
          avatar TEXT,
          is_active INTEGER NOT NULL DEFAULT 1,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');

      // 创建用户会话表（如果不存在）
      await db.execute('''
        CREATE TABLE IF NOT EXISTS user_sessions (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL,
          device_id TEXT,
          login_at TEXT NOT NULL,
          last_activity TEXT NOT NULL,
          is_active INTEGER NOT NULL DEFAULT 1,
          FOREIGN KEY (user_id) REFERENCES users (id)
        )
      ''');

      // 插入默认用户数据
      await _insertDefaultUsers(db);
    }

    if (oldVersion < 6) {
      // 创建订单表（如果不存在）
      await db.execute('''
        CREATE TABLE IF NOT EXISTS orders (
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

      // 创建订单项表（如果不存在）
      await db.execute('''
        CREATE TABLE IF NOT EXISTS order_items (
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
    }
    
    if (oldVersion < 5) {
      // 清空旧的商品数据
      await db.delete('products');
      await db.delete('categories');
      
      // 重新插入新的商品数据
      await _insertInitialData(db);
    }
  }

  Future<void> _insertInitialData(Database db) async {
    final now = DateTime.now().toIso8601String();
    
    // 插入丰富的商品数据
    final initialProducts = [
      // === 女装系列 ===
      {
        'id': 'product_001',
        'image': 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=400&h=400&fit=crop',
        'brand_name': 'Zara',
        'title': '女士优雅连衣裙',
        'price': 299.0,
        'price_after_discount': 239.0,
        'discount_percent': 20,
        'stock': 25,
        'min_order': 1,
        'max_order': 5,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': 'product_002',
        'image': 'https://images.unsplash.com/photo-1434389677669-e08b4cac3105?w=400&h=400&fit=crop',
        'brand_name': 'Uniqlo',
        'title': '女士羊毛毛衣',
        'price': 159.0,
        'price_after_discount': null,
        'discount_percent': null,
        'stock': 20,
        'min_order': 1,
        'max_order': 4,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': 'product_003',
        'image': 'https://images.unsplash.com/photo-1551698618-1dfe5d97d256?w=400&h=400&fit=crop',
        'brand_name': 'H&M',
        'title': '女士白色衬衫',
        'price': 129.0,
        'price_after_discount': 99.0,
        'discount_percent': 23,
        'stock': 35,
        'min_order': 1,
        'max_order': 6,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': 'product_004',
        'image': 'https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=400&h=400&fit=crop',
        'brand_name': 'Zara',
        'title': '女士针织开衫',
        'price': 199.0,
        'price_after_discount': 149.0,
        'discount_percent': 25,
        'stock': 28,
        'min_order': 1,
        'max_order': 4,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': 'product_005',
        'image': 'https://images.unsplash.com/photo-1539008835657-9e8e9680c956?w=400&h=400&fit=crop',
        'brand_name': 'Mango',
        'title': '女士风衣外套',
        'price': 459.0,
        'price_after_discount': null,
        'discount_percent': null,
        'stock': 12,
        'min_order': 1,
        'max_order': 2,
        'created_at': now,
        'updated_at': now,
      },

      // === 男装系列 ===
      {
        'id': 'product_006',
        'image': 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400&h=400&fit=crop',
        'brand_name': 'H&M',
        'title': '男士休闲T恤',
        'price': 89.0,
        'price_after_discount': 69.0,
        'discount_percent': 22,
        'stock': 45,
        'min_order': 1,
        'max_order': 8,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': 'product_007',
        'image': 'https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=400&h=400&fit=crop',
        'brand_name': 'Levi\'s',
        'title': '男士经典牛仔裤',
        'price': 399.0,
        'price_after_discount': 319.0,
        'discount_percent': 20,
        'stock': 18,
        'min_order': 1,
        'max_order': 3,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': 'product_008',
        'image': 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=400&h=400&fit=crop',
        'brand_name': 'Uniqlo',
        'title': '男士商务衬衫',
        'price': 149.0,
        'price_after_discount': null,
        'discount_percent': null,
        'stock': 32,
        'min_order': 1,
        'max_order': 5,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': 'product_009',
        'image': 'https://images.unsplash.com/photo-1618354691373-d851c5c3a990?w=400&h=400&fit=crop',
        'brand_name': 'Nike',
        'title': '男士运动卫衣',
        'price': 259.0,
        'price_after_discount': 199.0,
        'discount_percent': 23,
        'stock': 22,
        'min_order': 1,
        'max_order': 4,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': 'product_010',
        'image': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop',
        'brand_name': 'Zara',
        'title': '男士西装外套',
        'price': 699.0,
        'price_after_discount': null,
        'discount_percent': null,
        'stock': 8,
        'min_order': 1,
        'max_order': 2,
        'created_at': now,
        'updated_at': now,
      },

      // === 鞋类系列 ===
      {
        'id': 'product_011',
        'image': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400&h=400&fit=crop',
        'brand_name': 'Nike',
        'title': 'Air Max 270 运动鞋',
        'price': 899.0,
        'price_after_discount': 719.0,
        'discount_percent': 20,
        'stock': 15,
        'min_order': 1,
        'max_order': 3,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': 'product_012',
        'image': 'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=400&h=400&fit=crop',
        'brand_name': 'Adidas',
        'title': 'Ultra Boost 跑步鞋',
        'price': 1299.0,
        'price_after_discount': null,
        'discount_percent': null,
        'stock': 12,
        'min_order': 1,
        'max_order': 2,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': 'product_013',
        'image': 'https://images.unsplash.com/photo-1551107696-a4b0c5a0d9a2?w=400&h=400&fit=crop',
        'brand_name': 'Converse',
        'title': '经典帆布鞋',
        'price': 299.0,
        'price_after_discount': 239.0,
        'discount_percent': 20,
        'stock': 40,
        'min_order': 1,
        'max_order': 5,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': 'product_014',
        'image': 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=400&h=400&fit=crop',
        'brand_name': 'Clarks',
        'title': '女士高跟鞋',
        'price': 459.0,
        'price_after_discount': 369.0,
        'discount_percent': 20,
        'stock': 16,
        'min_order': 1,
        'max_order': 3,
        'created_at': now,
        'updated_at': now,
      },

      // === 配饰系列 ===
      {
        'id': 'product_015',
        'image': 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400&h=400&fit=crop',
        'brand_name': 'Adidas',
        'title': '运动背包',
        'price': 199.0,
        'price_after_discount': 159.0,
        'discount_percent': 20,
        'stock': 30,
        'min_order': 1,
        'max_order': 5,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': 'product_016',
        'image': 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=400&h=400&fit=crop',
        'brand_name': 'Michael Kors',
        'title': '女士手提包',
        'price': 899.0,
        'price_after_discount': null,
        'discount_percent': null,
        'stock': 14,
        'min_order': 1,
        'max_order': 2,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': 'product_017',
        'image': 'https://images.unsplash.com/photo-1434056886845-dac89ffe9b56?w=400&h=400&fit=crop',
        'brand_name': 'Casio',
        'title': '智能手表',
        'price': 1299.0,
        'price_after_discount': 999.0,
        'discount_percent': 23,
        'stock': 8,
        'min_order': 1,
        'max_order': 2,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': 'product_018',
        'image': 'https://images.unsplash.com/photo-1511499767150-a48a237f0083?w=400&h=400&fit=crop',
        'brand_name': 'Ray-Ban',
        'title': '经典太阳镜',
        'price': 699.0,
        'price_after_discount': 559.0,
        'discount_percent': 20,
        'stock': 25,
        'min_order': 1,
        'max_order': 3,
        'created_at': now,
        'updated_at': now,
      },

      // === 儿童装系列 ===
      {
        'id': 'product_019',
        'image': 'https://images.unsplash.com/photo-1519238263530-99bdd11df2ea?w=400&h=400&fit=crop',
        'brand_name': 'Carter\'s',
        'title': '儿童连体衣',
        'price': 89.0,
        'price_after_discount': 69.0,
        'discount_percent': 22,
        'stock': 50,
        'min_order': 1,
        'max_order': 8,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': 'product_020',
        'image': 'https://images.unsplash.com/photo-1503944583220-79d8926ad5e2?w=400&h=400&fit=crop',
        'brand_name': 'H&M Kids',
        'title': '儿童T恤套装',
        'price': 129.0,
        'price_after_discount': null,
        'discount_percent': null,
        'stock': 35,
        'min_order': 1,
        'max_order': 6,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': 'product_021',
        'image': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=400&fit=crop',
        'brand_name': 'Nike Kids',
        'title': '儿童运动鞋',
        'price': 299.0,
        'price_after_discount': 239.0,
        'discount_percent': 20,
        'stock': 28,
        'min_order': 1,
        'max_order': 4,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': 'product_022',
        'image': 'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=400&h=400&fit=crop',
        'brand_name': 'Zara Kids',
        'title': '儿童外套',
        'price': 199.0,
        'price_after_discount': 159.0,
        'discount_percent': 20,
        'stock': 22,
        'min_order': 1,
        'max_order': 4,
        'created_at': now,
        'updated_at': now,
      },

      // === 运动系列 ===
      {
        'id': 'product_023',
        'image': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=400&fit=crop',
        'brand_name': 'Under Armour',
        'title': '运动紧身裤',
        'price': 199.0,
        'price_after_discount': null,
        'discount_percent': null,
        'stock': 30,
        'min_order': 1,
        'max_order': 5,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': 'product_024',
        'image': 'https://images.unsplash.com/photo-1601925260368-ae2f83cf8b7f?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
        'brand_name': 'Adidas',
        'title': '瑜伽垫',
        'price': 129.0,
        'price_after_discount': 99.0,
        'discount_percent': 23,
        'stock': 40,
        'min_order': 1,
        'max_order': 6,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': 'product_025',
        'image': 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=400&h=400&fit=crop',
        'brand_name': 'Nike',
        'title': '健身水壶',
        'price': 59.0,
        'price_after_discount': 45.0,
        'discount_percent': 24,
        'stock': 60,
        'min_order': 1,
        'max_order': 10,
        'created_at': now,
        'updated_at': now,
      },
    ];

    for (final product in initialProducts) {
      await db.insert('products', product);
    }

    // 插入丰富的分类数据
    final initialCategories = [
      {
        'title': '促销商品',
        'svg_src': 'assets/icons/Sale.svg',
        'parent_id': null,
        'sort_order': 1,
        'created_at': now,
      },
      {
        'title': '女装',
        'svg_src': 'assets/icons/Man&Woman.svg',
        'parent_id': null,
        'sort_order': 2,
        'created_at': now,
      },
      {
        'title': '男装',
        'svg_src': 'assets/icons/Man&Woman.svg',
        'parent_id': null,
        'sort_order': 3,
        'created_at': now,
      },
      {
        'title': '鞋类',
        'svg_src': 'assets/icons/Category.svg',
        'parent_id': null,
        'sort_order': 4,
        'created_at': now,
      },
      {
        'title': '配饰',
        'svg_src': 'assets/icons/Bag.svg',
        'parent_id': null,
        'sort_order': 5,
        'created_at': now,
      },
      {
        'title': '儿童装',
        'svg_src': 'assets/icons/Child.svg',
        'parent_id': null,
        'sort_order': 6,
        'created_at': now,
      },
      {
        'title': '运动用品',
        'svg_src': 'assets/icons/Category.svg',
        'parent_id': null,
        'sort_order': 7,
        'created_at': now,
      },
    ];

    for (final category in initialCategories) {
      await db.insert('categories', category);
    }
  }

  // 插入默认用户数据
  Future<void> _insertDefaultUsers(Database db) async {
    final now = DateTime.now().toIso8601String();
    
    // 插入默认测试用户（使用简单的密码加密）
    // 密码都是 "password"，使用与UserDao相同的加密方式
    final defaultUsers = [
      {
        'id': 'user_001',
        'email': 'admin@shop.com',
        'password_hash': 'e80b5017098950fc58aad83c8c14978e2e36a4e6b4b7c13f8d5c8c27f7e6b4c8', // password: password
        'name': '管理员',
        'phone': '13800138000',
        'avatar': null,
        'is_active': 1,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': 'user_002',
        'email': 'user@shop.com',
        'password_hash': 'e80b5017098950fc58aad83c8c14978e2e36a4e6b4b7c13f8d5c8c27f7e6b4c8', // password: password
        'name': '测试用户',
        'phone': '13800138001',
        'avatar': null,
        'is_active': 1,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': 'user_003',
        'email': 'test@shop.com',
        'password_hash': 'e80b5017098950fc58aad83c8c14978e2e36a4e6b4b7c13f8d5c8c27f7e6b4c8', // password: password
        'name': '演示用户',
        'phone': '13800138002',
        'avatar': null,
        'is_active': 1,
        'created_at': now,
        'updated_at': now,
      },
    ];

    for (final user in defaultUsers) {
      await db.insert('users', user);
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  // 测试相关方法
  static Future<void> initializeTestDatabase() async {
    // 初始化测试数据库（可以重复使用现有逻辑）
    final instance = DatabaseHelper._instance;
    if (_database == null) {
      await instance._initDatabase();
    }
  }

  static Future<void> clearTestDatabase() async {
    final db = await DatabaseHelper._instance.database;
    await db.delete('cart_items');
    await db.delete('order_items');
    await db.delete('orders');
    await db.delete('products');
    // 检查users表是否存在
    final userTableExists = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='users'"
    );
    if (userTableExists.isNotEmpty) {
      await db.delete('users');
    }
  }
} 