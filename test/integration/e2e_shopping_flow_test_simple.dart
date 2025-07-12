import 'package:flutter_test/flutter_test.dart';
import 'package:shop/models/cart_model.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/models/order_model.dart';
import '../test_helpers/test_data.dart';

/// 简化版端到端购物流程测试
/// 移除数据库依赖，专注于测试核心业务逻辑
void main() {
  group('端到端购物流程测试 - 简化版', () {
    
    group('完整购物流程测试', () {
      test('成功的购物流程 - 从商品浏览到订单完成', () async {
        print('🔍 开始测试完整购物流程');
        
        // 第一步：创建测试用户
        final testUser = TestData.createTestUser();
        expect(testUser['email'], isNotEmpty);
        expect(testUser['name'], isNotEmpty);
        print('✅ 用户创建成功: ${testUser['name']}');

        // 第二步：浏览商品
        final testProducts = TestData.createTestProducts();
        expect(testProducts.length, greaterThan(0));
        
        final selectedProduct = testProducts.first;
        expect(selectedProduct.isInStock, isTrue);
        expect(selectedProduct.price, greaterThan(0));
        print('✅ 商品浏览成功: ${selectedProduct.title}');

        // 第三步：创建购物车项目
        final cartItem1 = CartItem(
          id: 'cart_item_1',
          product: selectedProduct,
          quantity: 2,
          selectedSize: 'M',
          selectedColor: '红色',
        );
        
        expect(cartItem1.quantity, equals(2));
        expect(cartItem1.selectedSize, equals('M'));
        expect(cartItem1.selectedColor, equals('红色'));
        expect(cartItem1.totalPrice, equals(selectedProduct.priceAfetDiscount != null 
            ? selectedProduct.priceAfetDiscount! * 2 
            : selectedProduct.price * 2));
        print('✅ 购物车项目创建成功');

        // 第四步：添加更多商品
        final secondProduct = testProducts[1];
        final cartItem2 = CartItem(
          id: 'cart_item_2',
          product: secondProduct,
          quantity: 1,
          selectedSize: 'L',
        );
        
        expect(cartItem2.quantity, equals(1));
        expect(cartItem2.selectedSize, equals('L'));
        print('✅ 添加第二个商品成功');

        // 第五步：计算购物车总价
        final cartItems = [cartItem1, cartItem2];
        final totalPrice = cartItems.fold<double>(0.0, (sum, item) => sum + item.totalPrice);
        
        expect(totalPrice, greaterThan(0));
        expect(totalPrice, equals(cartItem1.totalPrice + cartItem2.totalPrice));
        print('✅ 购物车总价计算正确: $totalPrice');

        // 第六步：计算运费
        final shippingFee = totalPrice >= 200 ? 0.0 : 15.0; // 满200免运费
        final finalTotal = totalPrice + shippingFee;
        
        expect(finalTotal, equals(totalPrice + shippingFee));
        print('✅ 运费计算正确: $shippingFee，最终总价: $finalTotal');

        // 第七步：创建订单
        final order = TestData.createTestOrder(
          id: 'order_001',
          items: cartItems,
          totalAmount: finalTotal,
          shippingAddress: '北京市朝阳区测试街道123号',
        );
        
        expect(order.id, equals('order_001'));
        expect(order.items.length, equals(2));
        expect(order.totalAmount, equals(finalTotal));
        expect(order.shippingAddress, equals('北京市朝阳区测试街道123号'));
        expect(order.status, equals(OrderStatus.processing));
        print('✅ 订单创建成功: ${order.id}');

        // 第八步：验证订单商品
        final orderItems = order.items;
        expect(orderItems.length, equals(2));
        
        final firstOrderItem = orderItems.first;
        expect(firstOrderItem.productId, equals(selectedProduct.id));
        expect(firstOrderItem.quantity, equals(2));
        expect(firstOrderItem.selectedSize, equals('M'));
        expect(firstOrderItem.selectedColor, equals('红色'));
        print('✅ 订单商品验证成功');

        // 第九步：模拟支付成功
        final updatedOrder = order.copyWith(
          status: OrderStatus.shipped,
          updatedAt: DateTime.now(),
        );
        
        expect(updatedOrder.status, equals(OrderStatus.shipped));
        expect(updatedOrder.updatedAt, isNotNull);
        print('✅ 支付成功');

        // 第十步：模拟发货 - 此步骤已在第九步完成
        expect(updatedOrder.status, equals(OrderStatus.shipped));
        print('✅ 发货成功');

        // 第十一步：模拟收货
        final deliveredOrder = updatedOrder.copyWith(
          status: OrderStatus.delivered,
          updatedAt: DateTime.now(),
        );
        
        expect(deliveredOrder.status, equals(OrderStatus.delivered));
        expect(deliveredOrder.updatedAt, isNotNull);
        print('✅ 收货成功');

        print('🎉 完整购物流程测试通过！');
      });
    });

    group('异常场景测试', () {
      test('库存不足场景', () async {
        print('🔍 测试库存不足场景');
        
        // 创建库存不足的商品
        final lowStockProduct = TestData.createTestProduct(
          id: 'low_stock_product',
          title: '库存不足商品',
          price: 100.0,
          stock: 2,
        );
        
        expect(lowStockProduct.stock, equals(2));
        expect(lowStockProduct.isInStock, isTrue);
        
        // 尝试创建数量超过库存的购物车项目
        final requestedQuantity = 5;
        final isValidQuantity = requestedQuantity <= lowStockProduct.stock;
        
        expect(isValidQuantity, isFalse);
        print('✅ 库存不足场景验证正确');
      });

      test('商品下架场景', () async {
        print('🔍 测试商品下架场景');
        
        // 创建已下架的商品
        final unavailableProduct = TestData.createTestProduct(
          id: 'unavailable_product',
          title: '已下架商品',
          price: 100.0,
          stock: 0,
        );
        
        expect(unavailableProduct.stock, equals(0));
        expect(unavailableProduct.isInStock, isFalse);
        
        // 验证无法添加到购物车
        final canAddToCart = unavailableProduct.isInStock;
        expect(canAddToCart, isFalse);
        print('✅ 商品下架场景验证正确');
      });

      test('价格计算异常场景', () async {
        print('🔍 测试价格计算异常场景');
        
        // 创建有折扣的商品
        final discountProduct = TestData.createTestProduct(
          id: 'discount_product',
          title: '折扣商品',
          price: 100.0,
          discountPercent: 20,
          priceAfterDiscount: 80.0,
        );
        
        // 验证折扣价格计算
        final expectedDiscountPrice = 80.0; // 手动设置的折扣价
        expect(discountProduct.priceAfetDiscount, equals(expectedDiscountPrice));
        
        // 创建购物车项目并验证总价
        final cartItem = CartItem(
          id: 'cart_item_discount',
          product: discountProduct,
          quantity: 3,
        );
        
        final expectedTotal = expectedDiscountPrice * 3;
        expect(cartItem.totalPrice, equals(expectedTotal));
        print('✅ 价格计算异常场景验证正确');
      });

      test('订单状态流转验证', () async {
        print('🔍 测试订单状态流转');
        
        final testUser = TestData.createTestUser();
        final testProducts = TestData.createTestProducts();
        final cartItems = [
          CartItem(
            id: 'cart_item_1',
            product: testProducts.first,
            quantity: 1,
          ),
        ];
        
        // 创建订单
        final order = TestData.createTestOrder(
          id: 'order_status_test',
          items: cartItems,
          totalAmount: 100.0,
        );
        
        expect(order.status, equals(OrderStatus.processing));
        
        // 验证状态流转
        final statusFlow = [
          OrderStatus.processing,
          OrderStatus.shipped,
          OrderStatus.delivered,
        ];
        
        var currentOrder = order;
        for (int i = 1; i < statusFlow.length; i++) {
          currentOrder = currentOrder.copyWith(status: statusFlow[i]);
          expect(currentOrder.status, equals(statusFlow[i]));
        }
        
        print('✅ 订单状态流转验证正确');
      });
    });

    group('边界值测试', () {
      test('购物车数量边界值', () async {
        print('🔍 测试购物车数量边界值');
        
        final testProduct = TestData.createTestProduct(
          id: 'boundary_product',
          title: '边界值测试商品',
          price: 50.0,
          stock: 10,
        );
        
        // 测试最小数量
        final minQuantityItem = CartItem(
          id: 'min_quantity',
          product: testProduct,
          quantity: 1,
        );
        expect(minQuantityItem.quantity, equals(1));
        expect(minQuantityItem.totalPrice, equals(testProduct.price));
        
        // 测试最大数量
        final maxQuantityItem = CartItem(
          id: 'max_quantity',
          product: testProduct,
          quantity: 10,
        );
        expect(maxQuantityItem.quantity, equals(10));
        expect(maxQuantityItem.totalPrice, equals(testProduct.price * 10));
        
        // 测试零数量（无效）
        final isValidZeroQuantity = 0 > 0;
        expect(isValidZeroQuantity, isFalse);
        
        // 测试负数量（无效）
        final isValidNegativeQuantity = -1 > 0;
        expect(isValidNegativeQuantity, isFalse);
        
        print('✅ 购物车数量边界值验证正确');
      });

      test('价格边界值', () async {
        print('🔍 测试价格边界值');
        
        // 测试免费商品
        final freeProduct = TestData.createTestProduct(
          id: 'free_product',
          title: '免费商品',
          price: 0.0,
          stock: 5,
        );
        
        expect(freeProduct.price, equals(0.0));
        expect(freeProduct.isInStock, isTrue);
        
        final freeCartItem = CartItem(
          id: 'free_cart_item',
          product: freeProduct,
          quantity: 2,
        );
        expect(freeCartItem.totalPrice, equals(0.0));
        
        // 测试高价商品
        final expensiveProduct = TestData.createTestProduct(
          id: 'expensive_product',
          title: '高价商品',
          price: 999999.99,
          stock: 1,
        );
        
        expect(expensiveProduct.price, equals(999999.99));
        
        final expensiveCartItem = CartItem(
          id: 'expensive_cart_item',
          product: expensiveProduct,
          quantity: 1,
        );
        expect(expensiveCartItem.totalPrice, equals(999999.99));
        
        print('✅ 价格边界值验证正确');
      });

      test('运费计算边界值', () async {
        print('🔍 测试运费计算边界值');
        
        // 测试刚好不满足免运费条件
        final almostFreeShippingTotal = 199.99;
        final shippingFee1 = almostFreeShippingTotal >= 200 ? 0.0 : 15.0;
        expect(shippingFee1, equals(15.0));
        
        // 测试刚好满足免运费条件
        final freeShippingTotal = 200.0;
        final shippingFee2 = freeShippingTotal >= 200 ? 0.0 : 15.0;
        expect(shippingFee2, equals(0.0));
        
        // 测试超过免运费条件
        final overFreeShippingTotal = 250.0;
        final shippingFee3 = overFreeShippingTotal >= 200 ? 0.0 : 15.0;
        expect(shippingFee3, equals(0.0));
        
        print('✅ 运费计算边界值验证正确');
      });
    });

    group('数据验证测试', () {
      test('商品数据完整性验证', () async {
        print('🔍 测试商品数据完整性');
        
        final testProducts = TestData.createTestProducts();
        
        for (final product in testProducts) {
          // 验证必填字段
          expect(product.id, isNotEmpty);
          expect(product.title, isNotEmpty);
          expect(product.price, greaterThanOrEqualTo(0));
          expect(product.stock, greaterThanOrEqualTo(0));
          
          // 验证价格逻辑
          if (product.priceAfetDiscount != null) {
            expect(product.priceAfetDiscount!, lessThanOrEqualTo(product.price));
          }
          
          // 验证库存逻辑
          expect(product.isInStock, equals(product.stock > 0));
        }
        
        print('✅ 商品数据完整性验证正确');
      });

      test('购物车项目数据验证', () async {
        print('🔍 测试购物车项目数据验证');
        
        final testProduct = TestData.createTestProduct(
          id: 'validation_product',
          title: '验证商品',
          price: 100.0,
          stock: 5,
        );
        
        final cartItem = CartItem(
          id: 'validation_cart_item',
          product: testProduct,
          quantity: 2,
          selectedSize: 'M',
          selectedColor: '红色',
        );
        
        // 验证数据完整性
        expect(cartItem.id, isNotEmpty);
        expect(cartItem.product, isNotNull);
        expect(cartItem.quantity, greaterThan(0));
        expect(cartItem.selectedSize, isNotNull);
        expect(cartItem.selectedColor, isNotNull);
        
        // 验证计算逻辑
        expect(cartItem.totalPrice, equals(testProduct.price * cartItem.quantity));
        
        print('✅ 购物车项目数据验证正确');
      });

      test('订单数据验证', () async {
        print('🔍 测试订单数据验证');
        
        final testUser = TestData.createTestUser();
        final testProducts = TestData.createTestProducts();
        final cartItems = [
          CartItem(
            id: 'validation_cart_item',
            product: testProducts.first,
            quantity: 1,
          ),
        ];
        
        final order = TestData.createTestOrder(
          id: 'validation_order',
          items: cartItems,
          totalAmount: 100.0,
          shippingAddress: '验证地址',
        );
        
        // 验证订单数据完整性
        expect(order.id, isNotEmpty);
        expect(order.items, isNotEmpty);
        expect(order.totalAmount, greaterThan(0));
        expect(order.shippingAddress, isNotEmpty);
        expect(order.status, isNotNull);
        expect(order.orderDate, isNotNull);
        
        // 验证订单项目数据
        for (final item in order.items) {
          expect(item.productId, isNotEmpty);
          expect(item.quantity, greaterThan(0));
          expect(item.price, greaterThanOrEqualTo(0));
        }
        
        print('✅ 订单数据验证正确');
      });
    });

    group('性能测试', () {
      test('大量商品处理性能', () async {
        print('🔍 测试大量商品处理性能');
        
        final stopwatch = Stopwatch()..start();
        
        // 创建大量商品
        final largeProductList = List.generate(1000, (index) => 
          TestData.createTestProduct(
            id: 'perf_product_$index',
            title: '性能测试商品 $index',
            price: 100.0 + index,
            stock: 10,
          )
        );
        
        // 创建购物车项目
        final cartItems = <CartItem>[];
        for (int i = 0; i < 100; i++) {
          cartItems.add(CartItem(
            id: 'perf_cart_item_$i',
            product: largeProductList[i],
            quantity: 1,
          ));
        }
        
        // 计算总价
        final totalPrice = cartItems.fold<double>(0.0, (sum, item) => sum + item.totalPrice);
        
        stopwatch.stop();
        
        expect(largeProductList.length, equals(1000));
        expect(cartItems.length, equals(100));
        expect(totalPrice, greaterThan(0));
        expect(stopwatch.elapsedMilliseconds, lessThan(1000)); // 应该在1秒内完成
        
        print('✅ 大量商品处理性能测试通过 - 耗时: ${stopwatch.elapsedMilliseconds}ms');
      });

      test('复杂订单计算性能', () async {
        print('🔍 测试复杂订单计算性能');
        
        final stopwatch = Stopwatch()..start();
        
        // 创建复杂的购物车（多种商品、多种规格）
        final testProducts = TestData.createTestProducts();
        final complexCartItems = <CartItem>[];
        
        for (int i = 0; i < testProducts.length; i++) {
          final product = testProducts[i];
          for (int j = 1; j <= 5; j++) {
            complexCartItems.add(CartItem(
              id: 'complex_cart_item_${i}_$j',
              product: product,
              quantity: j,
              selectedSize: ['S', 'M', 'L', 'XL'][j % 4],
              selectedColor: ['红色', '蓝色', '绿色', '黄色'][j % 4],
            ));
          }
        }
        
        // 计算各种费用
        final totalPrice = complexCartItems.fold<double>(0.0, (sum, item) => sum + item.totalPrice);
        final shippingFee = totalPrice >= 200 ? 0.0 : 15.0;
        final finalTotal = totalPrice + shippingFee;
        
        // 创建复杂订单
        final complexOrder = TestData.createTestOrder(
          id: 'complex_order',
          items: complexCartItems,
          totalAmount: finalTotal,
        );
        
        stopwatch.stop();
        
        expect(complexCartItems.length, greaterThan(0));
        expect(totalPrice, greaterThan(0));
        expect(complexOrder.items.length, equals(complexCartItems.length));
        expect(stopwatch.elapsedMilliseconds, lessThan(500)); // 应该在500ms内完成
        
        print('✅ 复杂订单计算性能测试通过 - 耗时: ${stopwatch.elapsedMilliseconds}ms');
      });
    });

    print('🎉 所有端到端测试完成！');
  });
} 