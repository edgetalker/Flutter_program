import 'product_model.dart';

// 订单状态枚举
enum OrderStatus {
  processing,  // 处理中
  shipped,     // 已发货
  delivered,   // 已送达
  cancelled,   // 已取消
}

// 订单模型
class OrderModel {
  final String id;// 订单唯一标识
  final String orderNumber;// 订单编号
  final DateTime orderDate;// 订单日期
  final OrderStatus status;// 订单状态
  final double totalAmount;// 订单总金额
  final double shippingFee;// 运费
  final List<OrderItemModel> items;// 订单项
  final String shippingAddress;// 收货地址
  final DateTime? updatedAt;// 更新时间

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.orderDate,
    required this.status,
    required this.totalAmount,
    required this.shippingFee,
    required this.items,
    required this.shippingAddress,
    this.updatedAt,
  });

  // 获取订单总价（商品价格 + 运费）
  double get finalTotal => totalAmount + shippingFee;

  // 获取商品总数量
  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);

  // 检查是否可以取消
  bool get canCancel => status == OrderStatus.processing;

  // 检查是否可以确认收货
  bool get canConfirmDelivery => status == OrderStatus.shipped;

  // 获取状态文本
  String get statusText {
    switch (status) {
      case OrderStatus.processing:
        return "处理中";
      case OrderStatus.shipped:
        return "已发货";
      case OrderStatus.delivered:
        return "已送达";
      case OrderStatus.cancelled:
        return "已取消";
    }
  }

  // 转换为数据库Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_number': orderNumber,
      'order_date': orderDate.toIso8601String(),
      'status': status.index,
      'total_amount': totalAmount,
      'shipping_fee': shippingFee,
      'shipping_address': shippingAddress,
      'updated_at': (updatedAt ?? DateTime.now()).toIso8601String(),
    };
  }

  // 从数据库Map创建对象
  static OrderModel fromMap(Map<String, dynamic> map, List<OrderItemModel> items) {
    return OrderModel(
      id: map['id'],
      orderNumber: map['order_number'],
      orderDate: DateTime.parse(map['order_date']),
      status: OrderStatus.values[map['status']],
      totalAmount: map['total_amount'],
      shippingFee: map['shipping_fee'],
      items: items,
      shippingAddress: map['shipping_address'],
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  // 创建副本
  OrderModel copyWith({
    String? id,
    String? orderNumber,
    DateTime? orderDate,
    OrderStatus? status,
    double? totalAmount,
    double? shippingFee,
    List<OrderItemModel>? items,
    String? shippingAddress,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      orderDate: orderDate ?? this.orderDate,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      shippingFee: shippingFee ?? this.shippingFee,
      items: items ?? this.items,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

// 订单项模型
class OrderItemModel {
  final String id;// 订单项唯一标识
  final String orderId;// 订单ID
  final String productId;// 商品ID
  final String productName;// 商品名称
  final String productImage;// 商品图片
  final String brandName;// 品牌名称
  final double price;// 商品价格
  final double? priceAfterDiscount;// 折扣后价格
  final int quantity;// 商品数量
  final String? selectedSize;// 已选尺寸
  final String? selectedColor;// 已选颜色

  OrderItemModel({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.brandName,
    required this.price,
    this.priceAfterDiscount,
    required this.quantity,
    this.selectedSize,
    this.selectedColor,
  });

  // 获取单项总价
  double get totalPrice => (priceAfterDiscount ?? price) * quantity;

  // 转换为数据库Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'product_name': productName,
      'product_image': productImage,
      'brand_name': brandName,
      'price': price,
      'price_after_discount': priceAfterDiscount,
      'quantity': quantity,
      'selected_size': selectedSize,
      'selected_color': selectedColor,
    };
  }

  // 从数据库Map创建对象
  static OrderItemModel fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      id: map['id'],
      orderId: map['order_id'],
      productId: map['product_id'],
      productName: map['product_name'],
      productImage: map['product_image'],
      brandName: map['brand_name'],
      price: map['price'],
      priceAfterDiscount: map['price_after_discount'],
      quantity: map['quantity'],
      selectedSize: map['selected_size'],
      selectedColor: map['selected_color'],
    );
  }

  // 从购物车项创建订单项
  static OrderItemModel fromCartItem(String orderId, String itemId, ProductModel product, int quantity, String? selectedSize, String? selectedColor) {
    return OrderItemModel(
      id: itemId,
      orderId: orderId,
      productId: product.id,
      productName: product.title,
      productImage: product.image,
      brandName: product.brandName,
      price: product.price,
      priceAfterDiscount: product.priceAfetDiscount,
      quantity: quantity,
      selectedSize: selectedSize,
      selectedColor: selectedColor,
    );
  }
} 