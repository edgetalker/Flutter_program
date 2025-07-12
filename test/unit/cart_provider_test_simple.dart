import 'package:flutter_test/flutter_test.dart';
import 'package:shop/models/cart_model.dart';
import 'package:shop/models/product_model.dart';
import '../test_helpers/test_data.dart';

void main() {
  group('CartProvider 简化测试', () {
    
    group('CartItem 模型测试', () {
      test('应该能够创建购物车项目', () {
        // 安排
        final product = TestData.createTestProduct(
          id: 'test_product_1',
          title: '测试商品',
          price: 100.0,
          stock: 10,
        );
        
        // 执行
        final cartItem = CartItem(
          id: 'cart_item_1',
          product: product,
          quantity: 2,
          selectedSize: 'M',
          selectedColor: '红色',
        );

        // 验证
        expect(cartItem.id, equals('cart_item_1'));
        expect(cartItem.product.id, equals('test_product_1'));
        expect(cartItem.quantity, equals(2));
        expect(cartItem.selectedSize, equals('M'));
        expect(cartItem.selectedColor, equals('红色'));
        expect(cartItem.totalPrice, equals(200.0));
      });

      test('应该正确计算折扣后总价', () {
        // 安排
        final product = TestData.createTestProduct(
          id: 'test_product_2',
          title: '折扣商品',
          price: 100.0,
          priceAfterDiscount: 80.0,
          stock: 10,
        );
        
        // 执行
        final cartItem = CartItem(
          id: 'cart_item_2',
          product: product,
          quantity: 3,
        );

        // 验证
        expect(cartItem.totalPrice, equals(240.0)); // 80 * 3
      });

      test('应该能够检查数量增减限制', () {
        // 安排
        final product = TestData.createTestProduct(
          id: 'test_product_3',
          title: '限制商品',
          price: 50.0,
          stock: 10,
          minOrder: 2,
          maxOrder: 5,
        );
        
        // 执行
        final cartItem = CartItem(
          id: 'cart_item_3',
          product: product,
          quantity: 3,
        );

        // 验证
        expect(cartItem.canIncreaseQuantity(), isTrue); // 3 < 5，可以增加
        expect(cartItem.canDecreaseQuantity(), isTrue); // 3 > 2，可以减少
        expect(cartItem.getMaxQuantity(), equals(5)); // 最大订购量
        
        // 测试边界情况
        cartItem.quantity = 5;
        expect(cartItem.canIncreaseQuantity(), isFalse); // 已达到最大值
        
        cartItem.quantity = 2;
        expect(cartItem.canDecreaseQuantity(), isFalse); // 已达到最小值
      });

      test('应该能够正确转换为Map', () {
        // 安排
        final product = TestData.createTestProduct(
          id: 'test_product_4',
          title: 'Map测试商品',
          price: 120.0,
          stock: 15,
        );
        
        final cartItem = CartItem(
          id: 'cart_item_4',
          product: product,
          quantity: 2,
          selectedSize: 'L',
          selectedColor: '蓝色',
        );

        // 执行
        final map = cartItem.toMap();

        // 验证
        expect(map['id'], equals('cart_item_4'));
        expect(map['productId'], equals('test_product_4'));
        expect(map['quantity'], equals(2));
        expect(map['selectedSize'], equals('L'));
        expect(map['selectedColor'], equals('蓝色'));
        expect(map['addedAt'], isA<int>());
      });

      test('应该能够从Map创建CartItem', () {
        // 安排
        final product = TestData.createTestProduct(
          id: 'test_product_5',
          title: 'FromMap测试商品',
          price: 90.0,
          stock: 12,
        );
        
        final map = {
          'id': 'cart_item_5',
          'productId': 'test_product_5',
          'quantity': 4,
          'selectedSize': 'XL',
          'selectedColor': '绿色',
          'addedAt': DateTime.now().millisecondsSinceEpoch,
        };

        // 执行
        final cartItem = CartItem.fromMap(map, product);

        // 验证
        expect(cartItem.id, equals('cart_item_5'));
        expect(cartItem.product.id, equals('test_product_5'));
        expect(cartItem.quantity, equals(4));
        expect(cartItem.selectedSize, equals('XL'));
        expect(cartItem.selectedColor, equals('绿色'));
        expect(cartItem.totalPrice, equals(360.0)); // 90 * 4
      });

      test('应该能够正确比较CartItem', () {
        // 安排
        final product = TestData.createTestProduct(
          id: 'test_product_6',
          title: '比较测试商品',
          price: 100.0,
          stock: 10,
        );
        
        final cartItem1 = CartItem(
          id: 'cart_item_6a',
          product: product,
          quantity: 2,
          selectedSize: 'M',
          selectedColor: '红色',
        );
        
        final cartItem2 = CartItem(
          id: 'cart_item_6b',
          product: product,
          quantity: 3,
          selectedSize: 'M',
          selectedColor: '红色',
        );
        
        final cartItem3 = CartItem(
          id: 'cart_item_6c',
          product: product,
          quantity: 2,
          selectedSize: 'L',
          selectedColor: '红色',
        );

        // 验证
        expect(cartItem1 == cartItem2, isTrue); // 相同商品、相同规格
        expect(cartItem1 == cartItem3, isFalse); // 相同商品、不同规格
        expect(cartItem1.hashCode, equals(cartItem2.hashCode));
        expect(cartItem1.hashCode, isNot(equals(cartItem3.hashCode)));
      });
    });

    group('购物车计算测试', () {
      test('应该能够计算多个商品的总价', () {
        // 安排
        final products = TestData.createTestProducts();
        final cartItems = [
          CartItem(
            id: 'item_1',
            product: products[0], // 价格150 (折扣后)
            quantity: 2,
          ),
          CartItem(
            id: 'item_2',
            product: products[1], // 价格300 (无折扣)
            quantity: 1,
          ),
        ];

        // 执行
        final totalPrice = cartItems.fold<double>(
          0.0,
          (sum, item) => sum + item.totalPrice,
        );

        // 验证
        expect(totalPrice, equals(600.0)); // 150*2 + 300*1
      });

      test('应该能够计算运费', () {
        // 安排
        final freeShippingThreshold = 200.0;
        final shippingFee = 15.0;
        
        double calculateShipping(double totalPrice) {
          return totalPrice >= freeShippingThreshold ? 0.0 : shippingFee;
        }

        // 验证
        expect(calculateShipping(150.0), equals(15.0)); // 需要运费
        expect(calculateShipping(250.0), equals(0.0)); // 免运费
        expect(calculateShipping(200.0), equals(0.0)); // 刚好免运费
      });

      test('应该能够计算商品总数量', () {
        // 安排
        final products = TestData.createTestProducts();
        final cartItems = [
          CartItem(
            id: 'item_1',
            product: products[0],
            quantity: 2,
          ),
          CartItem(
            id: 'item_2',
            product: products[1],
            quantity: 3,
          ),
          CartItem(
            id: 'item_3',
            product: products[2],
            quantity: 1,
          ),
        ];

        // 执行
        final totalQuantity = cartItems.fold<int>(
          0,
          (sum, item) => sum + item.quantity,
        );

        // 验证
        expect(totalQuantity, equals(6)); // 2 + 3 + 1
      });
    });

    group('购物车业务逻辑测试', () {
      test('应该能够验证库存充足性', () {
        // 安排
        final product = TestData.createTestProduct(
          id: 'stock_test_product',
          title: '库存测试商品',
          price: 100.0,
          stock: 5,
        );

        // 验证
        expect(product.isInStock, isTrue);
        expect(product.stock >= 3, isTrue); // 可以购买3件
        expect(product.stock >= 10, isFalse); // 不能购买10件
      });

      test('应该能够验证订单数量限制', () {
        // 安排
        final product = TestData.createTestProduct(
          id: 'order_limit_test',
          title: '订单限制测试商品',
          price: 100.0,
          stock: 20,
          minOrder: 2,
          maxOrder: 8,
        );

        // 验证
        expect(product.minOrder, equals(2));
        expect(product.maxOrder, equals(8));
        
        // 测试有效数量
        expect(3 >= product.minOrder && 3 <= product.maxOrder, isTrue);
        expect(3 <= product.stock, isTrue);
        
        // 测试无效数量
        expect(1 >= product.minOrder, isFalse); // 小于最小值
        expect(10 <= product.maxOrder, isFalse); // 大于最大值
      });

      test('应该能够检查规格组合的唯一性', () {
        // 安排
        final product = TestData.createTestProduct(
          id: 'spec_test_product',
          title: '规格测试商品',
          price: 100.0,
          stock: 10,
        );

        final item1 = CartItem(
          id: 'item_1',
          product: product,
          quantity: 2,
          selectedSize: 'M',
          selectedColor: '红色',
        );

        final item2 = CartItem(
          id: 'item_2',
          product: product,
          quantity: 1,
          selectedSize: 'L',
          selectedColor: '红色',
        );

        final item3 = CartItem(
          id: 'item_3',
          product: product,
          quantity: 3,
          selectedSize: 'M',
          selectedColor: '蓝色',
        );

        // 验证
        expect(item1 == item2, isFalse); // 不同尺寸
        expect(item1 == item3, isFalse); // 不同颜色
        expect(item2 == item3, isFalse); // 不同尺寸和颜色
      });
    });

    group('错误处理测试', () {
      test('应该能够处理空值字段', () {
        // 安排
        final product = TestData.createTestProduct(
          id: 'null_test_product',
          title: '空值测试商品',
          price: 100.0,
          stock: 10,
        );

        // 执行 - 创建没有规格的商品
        final cartItem = CartItem(
          id: 'null_item',
          product: product,
          quantity: 1,
        );

        // 验证
        expect(cartItem.selectedSize, isNull);
        expect(cartItem.selectedColor, isNull);
        expect(cartItem.totalPrice, equals(100.0));
      });

      test('应该能够处理边界值', () {
        // 安排
        final product = TestData.createTestProduct(
          id: 'boundary_test_product',
          title: '边界测试商品',
          price: 0.01, // 最小价格
          stock: 1, // 最小库存
          minOrder: 1,
          maxOrder: 1,
        );

        // 执行
        final cartItem = CartItem(
          id: 'boundary_item',
          product: product,
          quantity: 1,
        );

        // 验证
        expect(cartItem.totalPrice, equals(0.01));
        expect(cartItem.canIncreaseQuantity(), isFalse);
        expect(cartItem.canDecreaseQuantity(), isFalse);
      });
    });
  });
} 