import 'package:shop/models/product_model.dart';
import 'package:shop/models/cart_model.dart';
import 'package:shop/models/order_model.dart';
import 'package:uuid/uuid.dart';

class TestData {
  static const _uuid = Uuid();

  // 创建测试商品
  static ProductModel createTestProduct({
    String? id,
    String? title,
    String? brandName,
    String? image,
    double? price,
    double? priceAfterDiscount,
    int? discountPercent,
    int? stock,
    int? minOrder,
    int? maxOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? _uuid.v4(),
      title: title ?? '测试商品',
      brandName: brandName ?? '测试品牌',
      image: image ?? 'test_image.jpg',
      price: price ?? 100.0,
      priceAfetDiscount: priceAfterDiscount,
      dicountpercent: discountPercent,
      stock: stock ?? 10,
      minOrder: minOrder ?? 1,
      maxOrder: maxOrder ?? 10,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // 创建测试购物车项目
  static CartItem createTestCartItem({
    String? id,
    ProductModel? product,
    int? quantity,
    String? selectedSize,
    String? selectedColor,
    DateTime? addedAt,
  }) {
    return CartItem(
      id: id ?? _uuid.v4(),
      product: product ?? createTestProduct(),
      quantity: quantity ?? 1,
      selectedSize: selectedSize,
      selectedColor: selectedColor,
      addedAt: addedAt,
    );
  }

  // 创建测试订单
  static OrderModel createTestOrder({
    String? id,
    String? orderNumber,
    List<CartItem>? items,
    OrderStatus? status,
    double? totalAmount,
    double? shippingFee,
    String? shippingAddress,
    DateTime? orderDate,
    DateTime? updatedAt,
  }) {
    final cartItems = items ?? [createTestCartItem()];
    final calculatedTotal = totalAmount ?? 
        cartItems.fold<double>(0.0, (sum, item) => sum + item.totalPrice);
    
    // 将CartItem转换为OrderItemModel
    final orderItems = cartItems.map((cartItem) => 
      OrderItemModel.fromCartItem(
        id ?? _uuid.v4(),
        _uuid.v4(),
        cartItem.product,
        cartItem.quantity,
        cartItem.selectedSize,
        cartItem.selectedColor,
      )
    ).toList();
    
    return OrderModel(
      id: id ?? _uuid.v4(),
      orderNumber: orderNumber ?? 'TEST${DateTime.now().millisecondsSinceEpoch}',
      orderDate: orderDate ?? DateTime.now(),
      status: status ?? OrderStatus.processing,
      totalAmount: calculatedTotal ?? 0.0,
      shippingFee: shippingFee ?? 15.0,
      items: orderItems,
      shippingAddress: shippingAddress ?? '测试收货地址',
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // 创建预设的测试商品集合
  static List<ProductModel> createTestProducts() {
    return [
      createTestProduct(
        id: 'popular_product_1',
        title: '热门商品1',
        brandName: '知名品牌',
        price: 200.0,
        priceAfterDiscount: 150.0,
        discountPercent: 25,
        stock: 50,
        maxOrder: 5,
      ),
      createTestProduct(
        id: 'popular_product_2',
        title: '热门商品2',
        brandName: '优质品牌',
        price: 300.0,
        stock: 20,
        maxOrder: 3,
      ),
      createTestProduct(
        id: 'low_stock_product',
        title: '库存不足商品',
        brandName: '限量品牌',
        price: 500.0,
        stock: 2,
        maxOrder: 1,
      ),
      createTestProduct(
        id: 'out_of_stock_product',
        title: '缺货商品',
        brandName: '断货品牌',
        price: 150.0,
        stock: 0,
        maxOrder: 5,
      ),
      createTestProduct(
        id: 'flash_sale_product',
        title: '闪购商品',
        brandName: '闪购品牌',
        price: 100.0,
        priceAfterDiscount: 60.0,
        discountPercent: 40,
        stock: 100,
        maxOrder: 10,
      ),
    ];
  }

  // 创建测试购物车
  static List<CartItem> createTestCart() {
    final products = createTestProducts();
    return [
      createTestCartItem(
        product: products[0],
        quantity: 2,
        selectedSize: 'M',
        selectedColor: '红色',
      ),
      createTestCartItem(
        product: products[1],
        quantity: 1,
        selectedSize: 'L',
        selectedColor: '蓝色',
      ),
      createTestCartItem(
        product: products[4],
        quantity: 3,
      ),
    ];
  }

  // 创建测试订单集合
  static List<OrderModel> createTestOrders() {
    final products = createTestProducts();
    return [
      createTestOrder(
        id: 'order_1',
        orderNumber: 'TEST001',
        items: [
          createTestCartItem(product: products[0], quantity: 1),
          createTestCartItem(product: products[1], quantity: 2),
        ],
        status: OrderStatus.delivered,
        totalAmount: 750.0,
        shippingFee: 0.0,
        orderDate: DateTime.now().subtract(Duration(days: 1)),
      ),
      createTestOrder(
        id: 'order_2',
        orderNumber: 'TEST002',
        items: [
          createTestCartItem(product: products[4], quantity: 5),
        ],
        status: OrderStatus.shipped,
        totalAmount: 300.0,
        shippingFee: 15.0,
        orderDate: DateTime.now().subtract(Duration(hours: 2)),
      ),
      createTestOrder(
        id: 'order_3',
        orderNumber: 'TEST003',
        items: [
          createTestCartItem(product: products[0], quantity: 2),
        ],
        status: OrderStatus.shipped,
        totalAmount: 300.0,
        shippingFee: 15.0,
        orderDate: DateTime.now().subtract(Duration(hours: 6)),
      ),
    ];
  }

  // 创建测试用户数据
  static Map<String, String> createTestUser({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? avatar,
  }) {
    return {
      'id': id ?? 'test_user_id',
      'email': email ?? 'test@example.com',
      'name': name ?? '测试用户',
      'phone': phone ?? '13800138000',
      'avatar': avatar ?? 'default_avatar.png',
    };
  }

  // 创建测试地址数据
  static Map<String, String> createTestAddress({
    String? id,
    String? name,
    String? phone,
    String? province,
    String? city,
    String? district,
    String? detail,
    bool? isDefault,
  }) {
    return {
      'id': id ?? _uuid.v4(),
      'name': name ?? '测试收货人',
      'phone': phone ?? '13800138000',
      'province': province ?? '北京市',
      'city': city ?? '北京市',
      'district': district ?? '朝阳区',
      'detail': detail ?? '测试街道123号',
      'isDefault': (isDefault ?? false).toString(),
    };
  }

  // 创建测试评论数据
  static Map<String, dynamic> createTestReview({
    String? id,
    String? userId,
    String? productId,
    String? orderId,
    double? rating,
    String? content,
    List<String>? images,
    DateTime? createdAt,
  }) {
    return {
      'id': id ?? _uuid.v4(),
      'userId': userId ?? 'test_user_id',
      'productId': productId ?? 'test_product_id',
      'orderId': orderId ?? 'test_order_id',
      'rating': rating ?? 5.0,
      'content': content ?? '非常好的商品，推荐购买！',
      'images': images ?? [],
      'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
    };
  }

  // 创建测试优惠券数据
  static Map<String, dynamic> createTestCoupon({
    String? id,
    String? title,
    String? description,
    double? discount,
    double? minAmount,
    DateTime? startDate,
    DateTime? endDate,
    bool? isUsed,
  }) {
    return {
      'id': id ?? _uuid.v4(),
      'title': title ?? '满100减20',
      'description': description ?? '购买任意商品满100元可使用',
      'discount': discount ?? 20.0,
      'minAmount': minAmount ?? 100.0,
      'startDate': (startDate ?? DateTime.now()).toIso8601String(),
      'endDate': (endDate ?? DateTime.now().add(Duration(days: 30))).toIso8601String(),
      'isUsed': isUsed ?? false,
    };
  }

  // 创建测试分类数据
  static Map<String, dynamic> createTestCategory({
    String? id,
    String? name,
    String? icon,
    String? parentId,
    int? sortOrder,
  }) {
    return {
      'id': id ?? _uuid.v4(),
      'name': name ?? '测试分类',
      'icon': icon ?? 'test_category_icon.svg',
      'parentId': parentId,
      'sortOrder': sortOrder ?? 0,
    };
  }

  // 创建测试品牌数据
  static Map<String, dynamic> createTestBrand({
    String? id,
    String? name,
    String? logo,
    String? description,
  }) {
    return {
      'id': id ?? _uuid.v4(),
      'name': name ?? '测试品牌',
      'logo': logo ?? 'test_brand_logo.png',
      'description': description ?? '这是一个测试品牌',
    };
  }

  // 创建测试搜索历史
  static List<String> createTestSearchHistory() {
    return [
      '手机',
      '电脑',
      '服装',
      '鞋子',
      '化妆品',
      '书籍',
      '家电',
      '运动器材',
    ];
  }

  // 创建测试通知数据
  static Map<String, dynamic> createTestNotification({
    String? id,
    String? title,
    String? content,
    String? type,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return {
      'id': id ?? _uuid.v4(),
      'title': title ?? '测试通知',
      'content': content ?? '这是一条测试通知内容',
      'type': type ?? 'system',
      'isRead': isRead ?? false,
      'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
    };
  }

  // 创建测试钱包数据
  static Map<String, dynamic> createTestWallet({
    String? userId,
    double? balance,
    List<Map<String, dynamic>>? transactions,
  }) {
    return {
      'userId': userId ?? 'test_user_id',
      'balance': balance ?? 500.0,
      'transactions': transactions ?? [
        {
          'id': _uuid.v4(),
          'type': 'income',
          'amount': 100.0,
          'description': '充值',
          'createdAt': DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
        },
        {
          'id': _uuid.v4(),
          'type': 'expense',
          'amount': 50.0,
          'description': '购买商品',
          'createdAt': DateTime.now().subtract(Duration(hours: 2)).toIso8601String(),
        },
      ],
    };
  }

  // 清理测试数据
  static void cleanup() {
    // 这里可以添加清理逻辑，比如删除测试文件、清空缓存等
  }
} 