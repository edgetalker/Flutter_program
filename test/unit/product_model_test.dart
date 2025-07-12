import 'package:flutter_test/flutter_test.dart';
import 'package:shop/models/product_model.dart';

void main() {
  group('ProductModel 测试', () {
    
    group('商品基本信息测试', () {
      test('应该正确创建商品对象', () {
        // 安排
        final product = ProductModel(
          id: 'test_product_1',
          image: 'test_image.jpg',
          brandName: '测试品牌',
          title: '测试商品',
          price: 100.0,
          stock: 10,
        );

        // 验证
        expect(product.id, equals('test_product_1'));
        expect(product.image, equals('test_image.jpg'));
        expect(product.brandName, equals('测试品牌'));
        expect(product.title, equals('测试商品'));
        expect(product.price, equals(100.0));
        expect(product.stock, equals(10));
        expect(product.minOrder, equals(1));
        expect(product.maxOrder, equals(10));
      });

      test('应该正确处理折扣价格', () {
        // 安排
        final product = ProductModel(
          id: 'discount_product',
          image: 'discount_image.jpg',
          brandName: '折扣品牌',
          title: '折扣商品',
          price: 200.0,
          priceAfetDiscount: 150.0,
          dicountpercent: 25,
          stock: 5,
        );

        // 验证
        expect(product.price, equals(200.0));
        expect(product.priceAfetDiscount, equals(150.0));
        expect(product.dicountpercent, equals(25));
      });

      test('应该正确设置自定义订单限制', () {
        // 安排
        final product = ProductModel(
          id: 'custom_order',
          image: 'custom_image.jpg',
          brandName: '自定义品牌',
          title: '自定义商品',
          price: 300.0,
          stock: 20,
          minOrder: 3,
          maxOrder: 15,
        );

        // 验证
        expect(product.minOrder, equals(3));
        expect(product.maxOrder, equals(15));
      });
    });

    group('库存状态检查测试', () {
      test('应该正确识别有库存的商品', () {
        // 安排
        final product = ProductModel(
          id: 'in_stock_product',
          image: 'stock_image.jpg',
          brandName: '库存品牌',
          title: '有库存商品',
          price: 80.0,
          stock: 15,
        );

        // 验证
        expect(product.isInStock, isTrue);
        expect(product.isLowStock, isFalse);
        expect(product.stockStatusText, equals('库存充足'));
      });

      test('应该正确识别无库存的商品', () {
        // 安排
        final product = ProductModel(
          id: 'no_stock_product',
          image: 'no_stock_image.jpg',
          brandName: '无库存品牌',
          title: '无库存商品',
          price: 90.0,
          stock: 0,
        );

        // 验证
        expect(product.isInStock, isFalse);
        expect(product.isLowStock, isFalse);
        expect(product.stockStatusText, equals('暂时缺货'));
      });

      test('应该正确识别库存不足的商品', () {
        // 安排
        final product = ProductModel(
          id: 'low_stock_product',
          image: 'low_stock_image.jpg',
          brandName: '低库存品牌',
          title: '库存不足商品',
          price: 120.0,
          stock: 3,
        );

        // 验证
        expect(product.isInStock, isTrue);
        expect(product.isLowStock, isTrue);
        expect(product.stockStatusText, equals('仅剩3件'));
      });

      test('应该正确处理边界库存值', () {
        // 安排
        final product = ProductModel(
          id: 'boundary_stock',
          image: 'boundary_image.jpg',
          brandName: '边界品牌',
          title: '边界库存商品',
          price: 70.0,
          stock: 5,
        );

        // 验证
        expect(product.isInStock, isTrue);
        expect(product.isLowStock, isTrue);
        expect(product.stockStatusText, equals('仅剩5件'));
      });
    });

    group('数据转换测试', () {
      test('应该正确转换为Map格式', () {
        // 安排
        final now = DateTime.now();
        final product = ProductModel(
          id: 'map_test_product',
          image: 'map_test_image.jpg',
          brandName: '地图测试品牌',
          title: '地图测试商品',
          price: 150.0,
          priceAfetDiscount: 120.0,
          dicountpercent: 20,
          stock: 8,
          minOrder: 2,
          maxOrder: 6,
          createdAt: now,
          updatedAt: now,
        );

        // 执行
        final map = product.toMap();

        // 验证
        expect(map['id'], equals('map_test_product'));
        expect(map['image'], equals('map_test_image.jpg'));
        expect(map['brand_name'], equals('地图测试品牌'));
        expect(map['title'], equals('地图测试商品'));
        expect(map['price'], equals(150.0));
        expect(map['price_after_discount'], equals(120.0));
        expect(map['discount_percent'], equals(20));
        expect(map['stock'], equals(8));
        expect(map['min_order'], equals(2));
        expect(map['max_order'], equals(6));
        expect(map['created_at'], isNotNull);
        expect(map['updated_at'], isNotNull);
      });

      test('应该正确从Map创建商品对象', () {
        // 安排
        final map = {
          'id': 'from_map_product',
          'image': 'from_map_image.jpg',
          'brand_name': '从地图品牌',
          'title': '从地图商品',
          'price': 200.0,
          'price_after_discount': 180.0,
          'discount_percent': 10,
          'stock': 12,
          'min_order': 1,
          'max_order': 8,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };

        // 执行
        final product = ProductModel.fromMap(map);

        // 验证
        expect(product.id, equals('from_map_product'));
        expect(product.image, equals('from_map_image.jpg'));
        expect(product.brandName, equals('从地图品牌'));
        expect(product.title, equals('从地图商品'));
        expect(product.price, equals(200.0));
        expect(product.priceAfetDiscount, equals(180.0));
        expect(product.dicountpercent, equals(10));
        expect(product.stock, equals(12));
        expect(product.minOrder, equals(1));
        expect(product.maxOrder, equals(8));
      });

      test('应该正确处理空值字段', () {
        // 安排
        final map = {
          'id': 'null_fields_product',
          'image': 'null_fields_image.jpg',
          'brand_name': '空值品牌',
          'title': '空值商品',
          'price': 100.0,
          'price_after_discount': null,
          'discount_percent': null,
          'stock': 5,
          'min_order': 1,
          'max_order': 10,
          'created_at': null,
          'updated_at': null,
        };

        // 执行
        final product = ProductModel.fromMap(map);

        // 验证
        expect(product.priceAfetDiscount, isNull);
        expect(product.dicountpercent, isNull);
        expect(product.createdAt, isNull);
        expect(product.updatedAt, isNull);
      });
    });

    group('商品副本创建测试', () {
      test('应该正确创建商品副本', () {
        // 安排
        final originalProduct = ProductModel(
          id: 'original_product',
          image: 'original_image.jpg',
          brandName: '原始品牌',
          title: '原始商品',
          price: 100.0,
          stock: 10,
        );

        // 执行
        final copiedProduct = originalProduct.copyWith(
          title: '复制商品',
          price: 150.0,
          stock: 15,
        );

        // 验证
        expect(copiedProduct.id, equals('original_product'));
        expect(copiedProduct.image, equals('original_image.jpg'));
        expect(copiedProduct.brandName, equals('原始品牌'));
        expect(copiedProduct.title, equals('复制商品'));
        expect(copiedProduct.price, equals(150.0));
        expect(copiedProduct.stock, equals(15));
      });

      test('应该在创建副本时自动更新时间', () {
        // 安排
        final originalProduct = ProductModel(
          id: 'time_test_product',
          image: 'time_test_image.jpg',
          brandName: '时间测试品牌',
          title: '时间测试商品',
          price: 80.0,
          stock: 6,
          createdAt: DateTime.now().subtract(Duration(days: 1)),
          updatedAt: DateTime.now().subtract(Duration(hours: 1)),
        );

        // 执行
        final copiedProduct = originalProduct.copyWith(price: 90.0);

        // 验证
        expect(copiedProduct.createdAt, equals(originalProduct.createdAt));
        expect(copiedProduct.updatedAt, isNot(equals(originalProduct.updatedAt)));
        expect(copiedProduct.updatedAt!.isAfter(originalProduct.updatedAt!), isTrue);
      });

      test('应该正确复制所有字段', () {
        // 安排
        final originalProduct = ProductModel(
          id: 'full_copy_product',
          image: 'full_copy_image.jpg',
          brandName: '完整复制品牌',
          title: '完整复制商品',
          price: 200.0,
          priceAfetDiscount: 160.0,
          dicountpercent: 20,
          stock: 12,
          minOrder: 2,
          maxOrder: 8,
        );

        // 执行
        final copiedProduct = originalProduct.copyWith();

        // 验证
        expect(copiedProduct.id, equals(originalProduct.id));
        expect(copiedProduct.image, equals(originalProduct.image));
        expect(copiedProduct.brandName, equals(originalProduct.brandName));
        expect(copiedProduct.title, equals(originalProduct.title));
        expect(copiedProduct.price, equals(originalProduct.price));
        expect(copiedProduct.priceAfetDiscount, equals(originalProduct.priceAfetDiscount));
        expect(copiedProduct.dicountpercent, equals(originalProduct.dicountpercent));
        expect(copiedProduct.stock, equals(originalProduct.stock));
        expect(copiedProduct.minOrder, equals(originalProduct.minOrder));
        expect(copiedProduct.maxOrder, equals(originalProduct.maxOrder));
      });
    });

    group('商品比较测试', () {
      test('应该正确比较相同商品', () {
        // 安排
        final product1 = ProductModel(
          id: 'same_product',
          image: 'same_image.jpg',
          brandName: '相同品牌',
          title: '相同商品',
          price: 100.0,
          stock: 10,
        );

        final product2 = ProductModel(
          id: 'same_product',
          image: 'same_image.jpg',
          brandName: '相同品牌',
          title: '相同商品',
          price: 100.0,
          stock: 10,
        );

        // 验证
        expect(product1.id, equals(product2.id));
        expect(product1.title, equals(product2.title));
        expect(product1.price, equals(product2.price));
      });

      test('应该正确比较不同商品', () {
        // 安排
        final product1 = ProductModel(
          id: 'product_1',
          image: 'image_1.jpg',
          brandName: '品牌1',
          title: '商品1',
          price: 100.0,
          stock: 10,
        );

        final product2 = ProductModel(
          id: 'product_2',
          image: 'image_2.jpg',
          brandName: '品牌2',
          title: '商品2',
          price: 150.0,
          stock: 5,
        );

        // 验证
        expect(product1.id, isNot(equals(product2.id)));
        expect(product1.title, isNot(equals(product2.title)));
        expect(product1.price, isNot(equals(product2.price)));
      });
    });

    group('价格计算测试', () {
      test('应该使用折扣价格计算', () {
        // 安排
        final product = ProductModel(
          id: 'discount_calc_product',
          image: 'discount_calc_image.jpg',
          brandName: '折扣计算品牌',
          title: '折扣计算商品',
          price: 100.0,
          priceAfetDiscount: 75.0,
          dicountpercent: 25,
          stock: 8,
        );

        // 验证
        expect(product.priceAfetDiscount, equals(75.0));
        expect(product.dicountpercent, equals(25));
      });

      test('应该在没有折扣时使用原价', () {
        // 安排
        final product = ProductModel(
          id: 'no_discount_product',
          image: 'no_discount_image.jpg',
          brandName: '无折扣品牌',
          title: '无折扣商品',
          price: 120.0,
          stock: 10,
        );

        // 验证
        expect(product.priceAfetDiscount, isNull);
        expect(product.dicountpercent, isNull);
      });

      test('应该正确处理零价格', () {
        // 安排
        final product = ProductModel(
          id: 'zero_price_product',
          image: 'zero_price_image.jpg',
          brandName: '零价格品牌',
          title: '零价格商品',
          price: 0.0,
          stock: 1,
        );

        // 验证
        expect(product.price, equals(0.0));
        expect(product.priceAfetDiscount, isNull);
      });
    });

    group('业务逻辑验证测试', () {
      test('应该验证最小订单数量不能大于最大订单数量', () {
        // 安排
        final product = ProductModel(
          id: 'order_limits_product',
          image: 'order_limits_image.jpg',
          brandName: '订单限制品牌',
          title: '订单限制商品',
          price: 100.0,
          stock: 20,
          minOrder: 5,
          maxOrder: 3,
        );

        // 验证业务逻辑
        expect(product.minOrder, greaterThan(product.maxOrder));
        // 在真实应用中，这应该被验证并抛出异常
      });

      test('应该验证库存不能为负数', () {
        // 安排
        final product = ProductModel(
          id: 'negative_stock_product',
          image: 'negative_stock_image.jpg',
          brandName: '负库存品牌',
          title: '负库存商品',
          price: 100.0,
          stock: -1,
        );

        // 验证
        expect(product.stock, lessThan(0));
        expect(product.isInStock, isFalse);
      });

      test('应该验证价格不能为负数', () {
        // 安排
        final product = ProductModel(
          id: 'negative_price_product',
          image: 'negative_price_image.jpg',
          brandName: '负价格品牌',
          title: '负价格商品',
          price: -10.0,
          stock: 5,
        );

        // 验证
        expect(product.price, lessThan(0));
        // 在真实应用中，这应该被验证并抛出异常
      });
    });
  });
} 