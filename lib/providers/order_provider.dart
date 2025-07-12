import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/order_model.dart';
import '../models/cart_model.dart';
import '../database/order_dao.dart';
import '../database/product_dao.dart';

class OrderProvider extends ChangeNotifier {
  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  // 获取订单列表
  List<OrderModel> get orders => List.unmodifiable(_orders);

  // 是否正在加载
  bool get isLoading => _isLoading;

  // 错误信息
  String? get errorMessage => _errorMessage;

  // 检查是否有订单
  bool get hasOrders => _orders.isNotEmpty;

  // 获取不同状态的订单数量
  int get processingCount => _orders.where((order) => order.status == OrderStatus.processing).length;
  int get shippedCount => _orders.where((order) => order.status == OrderStatus.shipped).length;
  int get deliveredCount => _orders.where((order) => order.status == OrderStatus.delivered).length;
  int get cancelledCount => _orders.where((order) => order.status == OrderStatus.cancelled).length;

  // 根据状态筛选订单
  List<OrderModel> getOrdersByStatus(OrderStatus? status) {
    if (status == null) return _orders;
    return _orders.where((order) => order.status == status).toList();
  }

  // 初始化时加载订单
  OrderProvider() {
    // 延迟加载，避免阻塞主线程
    Future.microtask(() => _loadOrders());
  }

  // 从数据库加载订单
  Future<void> _loadOrders() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _orders = await OrderDao.getAllOrders();
    } catch (e) {
      _errorMessage = '加载订单失败: $e';
      debugPrint(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 刷新订单列表
  Future<void> refreshOrders() async {
    await _loadOrders();
  }

  // 核心业务逻辑：从购物车创建订单
  Future<OrderModel?> createOrderFromCart(List<CartItem> cartItems, double shippingFee, String shippingAddress) async {
    if (cartItems.isEmpty) {
      _errorMessage = '购物车为空';
      notifyListeners();
      return null;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // 1. 生成订单ID和订单号
      final orderId = const Uuid().v4();
      final orderNumber = OrderDao.generateOrderNumber();
      final now = DateTime.now();

      // 2. 计算总金额
      final totalAmount = cartItems.fold<double>(0.0, (sum, item) => sum + item.totalPrice);

      // 3. 创建订单项
      List<OrderItemModel> orderItems = [];
      for (final cartItem in cartItems) {
        final orderItem = OrderItemModel.fromCartItem(
          orderId,
          const Uuid().v4(),
          cartItem.product,
          cartItem.quantity,
          cartItem.selectedSize,
          cartItem.selectedColor,
        );
        orderItems.add(orderItem);
      }

      // 4. 创建订单对象
      final order = OrderModel(
        id: orderId,
        orderNumber: orderNumber,
        orderDate: now,
        status: OrderStatus.processing,
        totalAmount: totalAmount,
        shippingFee: shippingFee,
        items: orderItems,
        shippingAddress: shippingAddress,
        updatedAt: now,
      );

      // 5. 保存到数据库
      final success = await OrderDao.createOrder(order);
      if (success) {
        // 6. 更新内存中的订单列表
        _orders.insert(0, order);
        _showMessage('订单创建成功');
        return order;
      } else {
        _errorMessage = '订单创建失败';
        return null;
      }
    } catch (e) {
      _errorMessage = '创建订单时发生错误: $e';
      debugPrint(_errorMessage);
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 取消订单
  Future<bool> cancelOrder(String orderId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // 1. 找到订单
      final orderIndex = _orders.indexWhere((order) => order.id == orderId);
      if (orderIndex == -1) {
        _errorMessage = '订单不存在';
        return false;
      }

      final order = _orders[orderIndex];
      if (!order.canCancel) {
        _errorMessage = '该订单无法取消';
        return false;
      }

      // 2. 更新数据库
      final success = await OrderDao.cancelOrder(orderId);
      if (success) {
        // 3. 恢复库存
        for (final item in order.items) {
          await ProductDao.increaseStock(item.productId, item.quantity);
        }

        // 4. 更新内存中的订单状态
        _orders[orderIndex] = order.copyWith(status: OrderStatus.cancelled);
        _showMessage('订单已取消');
        return true;
      } else {
        _errorMessage = '取消订单失败';
        return false;
      }
    } catch (e) {
      _errorMessage = '取消订单时发生错误: $e';
      debugPrint(_errorMessage);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 确认收货
  Future<bool> confirmDelivery(String orderId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // 1. 找到订单
      final orderIndex = _orders.indexWhere((order) => order.id == orderId);
      if (orderIndex == -1) {
        _errorMessage = '订单不存在';
        return false;
      }

      final order = _orders[orderIndex];
      if (!order.canConfirmDelivery) {
        _errorMessage = '该订单无法确认收货';
        return false;
      }

      // 2. 更新数据库
      final success = await OrderDao.confirmDelivery(orderId);
      if (success) {
        // 3. 更新内存中的订单状态
        _orders[orderIndex] = order.copyWith(status: OrderStatus.delivered);
        _showMessage('确认收货成功');
        return true;
      } else {
        _errorMessage = '确认收货失败';
        return false;
      }
    } catch (e) {
      _errorMessage = '确认收货时发生错误: $e';
      debugPrint(_errorMessage);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 更新订单状态（管理员功能）
  Future<bool> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // 1. 更新数据库
      final success = await OrderDao.updateOrderStatus(orderId, newStatus);
      if (success) {
        // 2. 更新内存中的订单状态
        final orderIndex = _orders.indexWhere((order) => order.id == orderId);
        if (orderIndex != -1) {
          _orders[orderIndex] = _orders[orderIndex].copyWith(status: newStatus);
        }
        _showMessage('订单状态已更新');
        return true;
      } else {
        _errorMessage = '更新订单状态失败';
        return false;
      }
    } catch (e) {
      _errorMessage = '更新订单状态时发生错误: $e';
      debugPrint(_errorMessage);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 根据ID获取订单
  OrderModel? getOrderById(String orderId) {
    try {
      return _orders.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }

  // 获取订单统计信息
  Future<Map<String, int>> getOrderStatistics() async {
    try {
      return await OrderDao.getOrderStatistics();
    } catch (e) {
      debugPrint('获取订单统计失败: $e');
      return {
        'total': 0,
        'processing': 0,
        'shipped': 0,
        'delivered': 0,
        'cancelled': 0,
      };
    }
  }

  // 清除错误信息
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // 显示消息（可以通过全局消息系统实现）
  void _showMessage(String message) {
    debugPrint('📦 订单消息: $message');
    // 这里可以集成全局消息系统
  }

  // 模拟订单状态变更（用于测试）
  Future<void> simulateOrderProgress(String orderId) async {
    final order = getOrderById(orderId);
    if (order == null) return;

    switch (order.status) {
      case OrderStatus.processing:
        await updateOrderStatus(orderId, OrderStatus.shipped);
        break;
      case OrderStatus.shipped:
        await updateOrderStatus(orderId, OrderStatus.delivered);
        break;
      default:
        break;
    }
  }
} 