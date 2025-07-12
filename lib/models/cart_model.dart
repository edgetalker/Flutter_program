import 'product_model.dart';

class CartItem {
  final String id;// 购物车项目唯一标识
  final ProductModel product;// 关联商品
  int quantity;// 商品数量
  final String? selectedSize;// 已选尺寸
  final String? selectedColor;// 已选颜色
  final DateTime addedAt;// 添加时间

  CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    this.selectedSize,
    this.selectedColor,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();

  // 计算单项总价
  double get totalPrice => 
      (product.priceAfetDiscount ?? product.price) * quantity.toDouble();

  // 检查是否可以增加数量
  bool canIncreaseQuantity() {
    return quantity < product.maxOrder && quantity < product.stock;
  }

  // 检查是否可以减少数量
  bool canDecreaseQuantity() {
    return quantity > product.minOrder;
  }

  // 获取最大可添加数量
  int getMaxQuantity() {
    return product.stock > product.maxOrder ? product.maxOrder : product.stock;
  }

  // 转换为Map用于存储
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': product.id,
      'quantity': quantity,
      'selectedSize': selectedSize,
      'selectedColor': selectedColor,
      'addedAt': addedAt.millisecondsSinceEpoch,
    };
  }

  // 从Map创建CartItem（需要传入product对象）
  static CartItem fromMap(Map<String, dynamic> map, ProductModel product) {
    return CartItem(
      id: map['id'] ?? '',
      product: product,
      quantity: map['quantity'] ?? 1,
      selectedSize: map['selectedSize'] ?? map['selected_size'],
      selectedColor: map['selectedColor'] ?? map['selected_color'],
      addedAt: map['addedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['addedAt'])
          : map['added_at'] != null
              ? DateTime.tryParse(map['added_at']) ?? DateTime.now()
              : DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem && 
           other.product.id == product.id && 
           other.selectedSize == selectedSize && 
           other.selectedColor == selectedColor;
  }

  @override
  int get hashCode {
    return product.id.hashCode ^ 
           (selectedSize?.hashCode ?? 0) ^ 
           (selectedColor?.hashCode ?? 0);
  }
} 