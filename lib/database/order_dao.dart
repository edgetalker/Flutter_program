import '../models/order_model.dart';
import 'database_helper.dart';

class OrderDao {
  static final DatabaseHelper _databaseHelper = DatabaseHelper();

  // 创建订单
  static Future<bool> createOrder(OrderModel order) async {
    final db = await _databaseHelper.database;
    
    try {
      await db.transaction((txn) async {
        // 插入订单主表
        await txn.insert('orders', order.toMap());
        
        // 插入订单项
        for (final item in order.items) {
          await txn.insert('order_items', item.toMap());
        }
      });
      return true;
    } catch (e) {
      print('创建订单失败: $e');
      return false;
    }
  }

  // 获取所有订单
  static Future<List<OrderModel>> getAllOrders() async {
    final db = await _databaseHelper.database;
    
    // 获取订单列表，按创建时间倒序
    final List<Map<String, dynamic>> orderMaps = await db.query(
      'orders',
      orderBy: 'order_date DESC',
    );
    
    List<OrderModel> orders = [];
    for (final orderMap in orderMaps) {
      final items = await getOrderItems(orderMap['id']);
      orders.add(OrderModel.fromMap(orderMap, items));
    }
    
    return orders;
  }

  // 根据ID获取订单
  static Future<OrderModel?> getOrderById(String orderId) async {
    final db = await _databaseHelper.database;
    
    final List<Map<String, dynamic>> orderMaps = await db.query(
      'orders',
      where: 'id = ?',
      whereArgs: [orderId],
    );
    
    if (orderMaps.isEmpty) return null;
    
    final items = await getOrderItems(orderId);
    return OrderModel.fromMap(orderMaps.first, items);
  }

  // 获取订单项
  static Future<List<OrderItemModel>> getOrderItems(String orderId) async {
    final db = await _databaseHelper.database;
    
    final List<Map<String, dynamic>> itemMaps = await db.query(
      'order_items',
      where: 'order_id = ?',
      whereArgs: [orderId],
    );
    
    return itemMaps.map((map) => OrderItemModel.fromMap(map)).toList();
  }

  // 根据状态获取订单
  static Future<List<OrderModel>> getOrdersByStatus(OrderStatus status) async {
    final db = await _databaseHelper.database;
    
    final List<Map<String, dynamic>> orderMaps = await db.query(
      'orders',
      where: 'status = ?',
      whereArgs: [status.index],
      orderBy: 'order_date DESC',
    );
    
    List<OrderModel> orders = [];
    for (final orderMap in orderMaps) {
      final items = await getOrderItems(orderMap['id']);
      orders.add(OrderModel.fromMap(orderMap, items));
    }
    
    return orders;
  }

  // 更新订单状态
  static Future<bool> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    final db = await _databaseHelper.database;
    
    try {
      final result = await db.update(
        'orders',
        {
          'status': newStatus.index,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [orderId],
      );
      return result > 0;
    } catch (e) {
      print('更新订单状态失败: $e');
      return false;
    }
  }

  // 取消订单
  static Future<bool> cancelOrder(String orderId) async {
    return await updateOrderStatus(orderId, OrderStatus.cancelled);
  }

  // 确认收货
  static Future<bool> confirmDelivery(String orderId) async {
    return await updateOrderStatus(orderId, OrderStatus.delivered);
  }

  // 获取订单统计
  static Future<Map<String, int>> getOrderStatistics() async {
    final db = await _databaseHelper.database;
    
    final result = await db.rawQuery('''
      SELECT status, COUNT(*) as count 
      FROM orders 
      GROUP BY status
    ''');
    
    Map<String, int> stats = {
      'total': 0,
      'processing': 0,
      'shipped': 0,
      'delivered': 0,
      'cancelled': 0,
    };
    
    for (final row in result) {
      final status = OrderStatus.values[row['status'] as int];
      final count = row['count'] as int;
      stats['total'] = (stats['total'] ?? 0) + count;
      
      switch (status) {
        case OrderStatus.processing:
          stats['processing'] = count;
          break;
        case OrderStatus.shipped:
          stats['shipped'] = count;
          break;
        case OrderStatus.delivered:
          stats['delivered'] = count;
          break;
        case OrderStatus.cancelled:
          stats['cancelled'] = count;
          break;
      }
    }
    
    return stats;
  }

  // 生成订单号
  static String generateOrderNumber() {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch;
    return '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${timestamp.toString().substring(timestamp.toString().length - 6)}';
  }

  // 检查订单是否存在
  static Future<bool> orderExists(String orderId) async {
    final order = await getOrderById(orderId);
    return order != null;
  }

  // 删除订单（仅用于测试，生产环境不建议物理删除）
  static Future<bool> deleteOrder(String orderId) async {
    final db = await _databaseHelper.database;
    
    try {
      await db.transaction((txn) async {
        // 删除订单项
        await txn.delete(
          'order_items',
          where: 'order_id = ?',
          whereArgs: [orderId],
        );
        
        // 删除订单
        await txn.delete(
          'orders',
          where: 'id = ?',
          whereArgs: [orderId],
        );
      });
      return true;
    } catch (e) {
      print('删除订单失败: $e');
      return false;
    }
  }

  // 获取用户最近的订单
  static Future<List<OrderModel>> getRecentOrders({int limit = 10}) async {
    final db = await _databaseHelper.database;
    
    final List<Map<String, dynamic>> orderMaps = await db.query(
      'orders',
      orderBy: 'order_date DESC',
      limit: limit,
    );
    
    List<OrderModel> orders = [];
    for (final orderMap in orderMaps) {
      final items = await getOrderItems(orderMap['id']);
      orders.add(OrderModel.fromMap(orderMap, items));
    }
    
    return orders;
  }
} 