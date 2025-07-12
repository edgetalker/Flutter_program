// For demo only
import 'package:shop/constants.dart';

class ProductModel {
  final String id;// 商品ID
  final String image, brandName, title;// 商品图片，品牌名称，商品标题
  final double price;// 商品价格
  final double? priceAfetDiscount;// 折扣后价格
  final int? dicountpercent;// 折扣百分比
  final int stock;// 库存
  final int minOrder;// 最小订单数量
  final int maxOrder;// 最大订单数量
  final DateTime? createdAt;// 创建时间
  final DateTime? updatedAt;// 更新时间

  ProductModel({
    required this.id,
    required this.image,
    required this.brandName,
    required this.title,
    required this.price,
    this.priceAfetDiscount,
    this.dicountpercent,
    required this.stock,
    this.minOrder = 1,
    this.maxOrder = 10,
    this.createdAt,
    this.updatedAt,
  });

  // 检查是否有库存
  bool get isInStock => stock > 0;
  
  // 检查是否库存不足（少于5件）
  bool get isLowStock => stock > 0 && stock <= 5;
  
  // 获取库存状态文本
  String get stockStatusText {
    if (stock == 0) return "暂时缺货";
    if (isLowStock) return "仅剩${stock}件";
    return "库存充足";
  }

  // 转换为数据库Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'image': image,
      'brand_name': brandName,
      'title': title,
      'price': price,
      'price_after_discount': priceAfetDiscount,
      'discount_percent': dicountpercent,
      'stock': stock,
      'min_order': minOrder,
      'max_order': maxOrder,
      'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
      'updated_at': (updatedAt ?? DateTime.now()).toIso8601String(),
    };
  }

  // 从数据库Map创建对象
  static ProductModel fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'],
      image: map['image'],
      brandName: map['brand_name'],
      title: map['title'],
      price: map['price'],
      priceAfetDiscount: map['price_after_discount'],
      dicountpercent: map['discount_percent'],
      stock: map['stock'],
      minOrder: map['min_order'],
      maxOrder: map['max_order'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  // 创建副本
  ProductModel copyWith({
    String? id,
    String? image,
    String? brandName,
    String? title,
    double? price,
    double? priceAfetDiscount,
    int? dicountpercent,
    int? stock,
    int? minOrder,
    int? maxOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      image: image ?? this.image,
      brandName: brandName ?? this.brandName,
      title: title ?? this.title,
      price: price ?? this.price,
      priceAfetDiscount: priceAfetDiscount ?? this.priceAfetDiscount,
      dicountpercent: dicountpercent ?? this.dicountpercent,
      stock: stock ?? this.stock,
      minOrder: minOrder ?? this.minOrder,
      maxOrder: maxOrder ?? this.maxOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

List<ProductModel> demoPopularProducts = [// 热门商品列表
  ProductModel(
    id: "product_001",
    image: productDemoImg1,
    title: "女士户外登山夹克",
    brandName: "户外专家",
    price: 540,
    priceAfetDiscount: 420,
    dicountpercent: 20,
    stock: 25,
    maxOrder: 5,
  ),
  ProductModel(
    id: "product_002",
    image: productDemoImg4,
    title: "男士户外防风外套",
    brandName: "户外专家",
    price: 800,
    stock: 8,
    maxOrder: 3,
  ),
  ProductModel(
    id: "product_003",
    image: productDemoImg5,
    title: "Nike Air Max 270 跑步鞋",
    brandName: "耐克",
    price: 650.62,
    priceAfetDiscount: 390.36,
    dicountpercent: 40,
    stock: 45,
    maxOrder: 8,
  ),
  ProductModel(
    id: "product_004",
    image: productDemoImg6,
    title: "绿色荷叶边前襟上衣",
    brandName: "时尚女装",
    price: 1264,
    priceAfetDiscount: 1200.8,
    dicountpercent: 5,
    stock: 3,
    maxOrder: 2,
  ),
  ProductModel(
    id: "product_005",
    image: "assets/Illustration/Illustration-0.png",
    title: "休闲百搭T恤",
    brandName: "潮流服饰",
    price: 650.62,
    priceAfetDiscount: 390.36,
    dicountpercent: 40,
    stock: 15,
    maxOrder: 4,
  ),
  ProductModel(
    id: "product_006",
    image: "assets/Illustration/Illustration-1.png",
    title: "白色缎面紧身上衣",
    brandName: "优雅女装",
    price: 1264,
    priceAfetDiscount: 1200.8,
    dicountpercent: 5,
    stock: 0,
    maxOrder: 3,
  ),
];
List<ProductModel> demoFlashSaleProducts = [// 闪购商品列表
  ProductModel(
    id: "flash_001",
    image: productDemoImg5,
    title: "限时特价 - Nike Air Max 270",
    brandName: "耐克",
    price: 650.62,
    priceAfetDiscount: 390.36,
    dicountpercent: 40,
    stock: 12,
    maxOrder: 5,
  ),
  ProductModel(
    id: "flash_002",
    image: productDemoImg6,
    title: "闪购特惠 - 时尚连衣裙",
    brandName: "时尚女装",
    price: 1264,
    priceAfetDiscount: 1200.8,
    dicountpercent: 5,
    stock: 6,
    maxOrder: 3,
  ),
  ProductModel(
    id: "flash_003",
    image: productDemoImg4,
    title: "Mountain Beta Warehouse",
    brandName: "Lipsy london",
    price: 800,
    priceAfetDiscount: 680,
    dicountpercent: 15,
    stock: 18,
    maxOrder: 4,
  ),
];
List<ProductModel> demoBestSellersProducts = [// 畅销商品列表
  ProductModel(
    id: "best_001",
    image: "assets/Illustration/Illustration-2.png",
    title: "Green Poplin Ruched Front",
    brandName: "Lipsy london",
    price: 650.62,
    priceAfetDiscount: 390.36,
    dicountpercent: 40,
    stock: 20,
    maxOrder: 6,
  ),
  ProductModel(
    id: "best_002",
    image: "assets/Illustration/Illustration-3.png",
    title: "white satin corset top",
    brandName: "Lipsy london",
    price: 1264,
    priceAfetDiscount: 1200.8,
    dicountpercent: 5,
    stock: 4,
    maxOrder: 2,
  ),
  ProductModel(
    id: "best_003",
    image: productDemoImg4,
    title: "Mountain Beta Warehouse",
    brandName: "Lipsy london",
    price: 800,
    priceAfetDiscount: 680,
    dicountpercent: 15,
    stock: 35,
    maxOrder: 5,
  ),
];
List<ProductModel> kidsProducts = [ // 儿童商品列表 
  ProductModel(
    id: "kids_001",
    image: "assets/Illustration/Illustration-4.png",
    title: "Green Poplin Ruched Front",
    brandName: "Lipsy london",
    price: 650.62,
    priceAfetDiscount: 590.36,
    dicountpercent: 24,
    stock: 28,
    maxOrder: 4,
  ),
  ProductModel(
    id: "kids_002",
    image: "assets/Illustration/success.png",
    title: "Printed Sleeveless Tiered Swing Dress",
    brandName: "Lipsy london",
    price: 650.62,
    stock: 15,
    maxOrder: 3,
  ),
  ProductModel(
    id: "kids_003",
    image: "assets/Illustration/Illustration-0.png",
    title: "Ruffle-Sleeve Ponte-Knit Sheath ",
    brandName: "Lipsy london",
    price: 400,
    stock: 42,
    maxOrder: 6,
  ),
  ProductModel(
    id: "kids_004",
    image: "assets/Illustration/Illustration-1.png",
    title: "Green Mountain Beta Warehouse",
    brandName: "Lipsy london",
    price: 400,
    priceAfetDiscount: 360,
    dicountpercent: 20,
    stock: 2,
    maxOrder: 2,
  ),
  ProductModel(
    id: "kids_005",
    image: "assets/Illustration/Illustration-2.png",
    title: "Printed Sleeveless Tiered Swing Dress",
    brandName: "Lipsy london",
    price: 654,
    stock: 22,
    maxOrder: 4,
  ),
  ProductModel(
    id: "kids_006",
    image: "assets/Illustration/Illustration-3.png",
    title: "Mountain Beta Warehouse",
    brandName: "Lipsy london",
    price: 250,
    stock: 38,
    maxOrder: 5,
  ),
];
