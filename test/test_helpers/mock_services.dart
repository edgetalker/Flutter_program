import 'package:shop/models/product_model.dart';
import 'package:shop/models/cart_model.dart';
import 'package:shop/models/order_model.dart';
import 'package:shop/services/auth_service.dart';

// Mock认证服务
class MockAuthService {
  Map<String, String> _users = {};
  String? _currentUser;
  bool _loginSuccess = true;
  bool _registerSuccess = true;
  bool _passwordResetSuccess = true;
  String? _errorMessage;
  Duration? _delay;

  void setupLoginSuccess(String email, String name) {
    _users[email] = name;
    _loginSuccess = true;
    _errorMessage = null;
  }

  void setupLoginFailure(String message) {
    _loginSuccess = false;
    _errorMessage = message;
  }

  void setupLoginError(String message) {
    _loginSuccess = false;
    _errorMessage = message;
  }

  void setupLoginDelay(Duration delay) {
    _delay = delay;
  }

  void setupRegisterSuccess(String email, String name) {
    _registerSuccess = true;
    _users[email] = name;
    _errorMessage = null;
  }

  void setupRegisterFailure(String message) {
    _registerSuccess = false;
    _errorMessage = message;
  }

  void setupPasswordResetSuccess() {
    _passwordResetSuccess = true;
    _errorMessage = null;
  }

  void setupPasswordResetFailure(String message) {
    _passwordResetSuccess = false;
    _errorMessage = message;
  }

  void setupLoginStatusCheck(bool isLoggedIn) {
    _currentUser = isLoggedIn ? 'test@example.com' : null;
  }

  void setupSessionExpiry() {
    Future.delayed(Duration(milliseconds: 50), () {
      _currentUser = null;
    });
  }

  Future<AuthResult> login(String email, String password) async {
    if (_delay != null) {
      await Future.delayed(_delay!);
    }

    if (!_loginSuccess) {
      return AuthResult(
        success: false,
        message: _errorMessage ?? '登录失败',
      );
    }

    if (_users.containsKey(email)) {
      _currentUser = email;
      return AuthResult(
        success: true,
        message: '登录成功',
        user: UserInfo(
          id: 'user_id_' + email.replaceAll('@', '_'),
          email: email,
          name: _users[email]!,
        ),
      );
    }

    return AuthResult(
      success: false,
      message: '邮箱或密码错误',
    );
  }

  Future<AuthResult> register(String email, String password, String name) async {
    if (_delay != null) {
      await Future.delayed(_delay!);
    }

    if (!_registerSuccess) {
      return AuthResult(
        success: false,
        message: _errorMessage ?? '注册失败',
      );
    }

    if (_users.containsKey(email)) {
      return AuthResult(
        success: false,
        message: '该邮箱已被注册',
      );
    }

    _users[email] = name;
    _currentUser = email;
    return AuthResult(
      success: true,
      message: '注册成功',
      user: UserInfo(
        id: 'user_id_' + email.replaceAll('@', '_'),
        email: email,
        name: name,
      ),
    );
  }

  Future<AuthResult> sendPasswordResetEmail(String email) async {
    if (_delay != null) {
      await Future.delayed(_delay!);
    }

    if (!_passwordResetSuccess) {
      return AuthResult(
        success: false,
        message: _errorMessage ?? '发送失败',
      );
    }

    if (!_users.containsKey(email)) {
      return AuthResult(
        success: false,
        message: '该邮箱未注册',
      );
    }

    return AuthResult(
      success: true,
      message: '密码重置邮件已发送',
    );
  }

  Future<void> logout() async {
    _currentUser = null;
  }

  Future<bool> isLoggedIn() async {
    return _currentUser != null;
  }

  Future<Map<String, String?>> getCurrentUser() async {
    if (_currentUser != null) {
      return {
        'email': _currentUser,
        'name': _users[_currentUser!],
        'id': 'user_id_' + _currentUser!.replaceAll('@', '_'),
      };
    }
    return {
      'email': null,
      'name': null,
      'id': null,
    };
  }

  void reset() {
    _users.clear();
    _currentUser = null;
    _loginSuccess = true;
    _registerSuccess = true;
    _passwordResetSuccess = true;
    _errorMessage = null;
    _delay = null;
  }
}

// Mock购物车DAO
class MockCartDao {
  List<CartItem> _cartItems = [];
  bool _addToCartSuccess = true;
  bool _updateQuantitySuccess = true;
  bool _removeFromCartSuccess = true;
  bool _clearCartSuccess = true;
  bool _checkoutSuccess = true;
  String? _errorMessage;
  Duration? _delay;

  void setupAddToCartSuccess() {
    _addToCartSuccess = true;
    _errorMessage = null;
  }

  void setupAddToCartFailure(String message) {
    _addToCartSuccess = false;
    _errorMessage = message;
  }

  void setupAddToCartDelay(Duration delay) {
    _delay = delay;
  }

  void setupUpdateQuantitySuccess() {
    _updateQuantitySuccess = true;
    _errorMessage = null;
  }

  void setupUpdateQuantityFailure(String message) {
    _updateQuantitySuccess = false;
    _errorMessage = message;
  }

  void setupCheckoutSuccess() {
    _checkoutSuccess = true;
    _errorMessage = null;
  }

  void setupCheckoutStockError() {
    _checkoutSuccess = false;
    _errorMessage = '库存不足';
  }

  void setupNetworkError() {
    _addToCartSuccess = false;
    _errorMessage = '网络连接失败';
  }

  void setupPersistedCartData(List<CartItem> items) {
    _cartItems = List.from(items);
  }

  void setupMixedCartData(List<CartItem> items) {
    _cartItems = items.where((item) => item.product.stock > 0).toList();
  }

  Future<bool> addToCart(CartItem cartItem) async {
    if (_delay != null) {
      await Future.delayed(_delay!);
    }

    if (!_addToCartSuccess) {
      throw Exception(_errorMessage ?? '添加到购物车失败');
    }

    _cartItems.add(cartItem);
    return true;
  }

  Future<bool> updateCartItemQuantity(String cartItemId, int newQuantity) async {
    if (!_updateQuantitySuccess) {
      throw Exception(_errorMessage ?? '更新数量失败');
    }

    final index = _cartItems.indexWhere((item) => item.id == cartItemId);
    if (index != -1) {
      _cartItems[index].quantity = newQuantity;
      return true;
    }
    return false;
  }

  Future<bool> removeFromCart(String cartItemId) async {
    if (!_removeFromCartSuccess) {
      throw Exception(_errorMessage ?? '移除商品失败');
    }

    _cartItems.removeWhere((item) => item.id == cartItemId);
    return true;
  }

  Future<bool> clearCart() async {
    if (!_clearCartSuccess) {
      throw Exception(_errorMessage ?? '清空购物车失败');
    }

    _cartItems.clear();
    return true;
  }

  Future<List<CartItem>> getAllCartItems() async {
    return List.from(_cartItems);
  }

  Future<String?> checkout() async {
    if (!_checkoutSuccess) {
      throw Exception(_errorMessage ?? '结算失败');
    }

    _cartItems.clear();
    return 'order_id_' + DateTime.now().millisecondsSinceEpoch.toString();
  }

  void reset() {
    _cartItems.clear();
    _addToCartSuccess = true;
    _updateQuantitySuccess = true;
    _removeFromCartSuccess = true;
    _clearCartSuccess = true;
    _checkoutSuccess = true;
    _errorMessage = null;
    _delay = null;
  }
}

// Mock商品服务
class MockProductService {
  Map<String, ProductModel> _products = {};
  bool _getProductSuccess = true;
  String? _errorMessage;

  void setupProduct(ProductModel product) {
    _products[product.id] = product;
    _getProductSuccess = true;
    _errorMessage = null;
  }

  void setupProductNotFound(String productId) {
    _products.remove(productId);
    _getProductSuccess = false;
    _errorMessage = '商品不存在';
  }

  void setupNetworkError() {
    _getProductSuccess = false;
    _errorMessage = '网络连接失败';
  }

  Future<ProductModel?> getProductById(String productId) async {
    if (!_getProductSuccess) {
      throw Exception(_errorMessage ?? '获取商品失败');
    }

    return _products[productId];
  }

  Future<List<ProductModel>> getAllProducts() async {
    return List.from(_products.values);
  }

  Future<bool> hasEnoughStock(String productId, int quantity) async {
    final product = _products[productId];
    if (product == null) return false;
    return product.stock >= quantity;
  }

  Future<bool> decreaseStock(String productId, int quantity) async {
    final product = _products[productId];
    if (product == null) return false;
    
    if (product.stock < quantity) return false;
    
    _products[productId] = product.copyWith(
      stock: product.stock - quantity,
    );
    return true;
  }

  void reset() {
    _products.clear();
    _getProductSuccess = true;
    _errorMessage = null;
  }
}

// Mock订单服务
class MockOrderService {
  Map<String, OrderModel> _orders = {};
  bool _createOrderSuccess = true;
  bool _updateOrderSuccess = true;
  String? _errorMessage;

  void setupCreateOrderSuccess() {
    _createOrderSuccess = true;
    _errorMessage = null;
  }

  void setupCreateOrderFailure(String message) {
    _createOrderSuccess = false;
    _errorMessage = message;
  }

  void setupUpdateOrderSuccess() {
    _updateOrderSuccess = true;
    _errorMessage = null;
  }

  void setupUpdateOrderFailure(String message) {
    _updateOrderSuccess = false;
    _errorMessage = message;
  }

  Future<String?> createOrder(OrderModel order) async {
    if (!_createOrderSuccess) {
      throw Exception(_errorMessage ?? '创建订单失败');
    }

    final orderId = 'order_' + DateTime.now().millisecondsSinceEpoch.toString();
    _orders[orderId] = order.copyWith(id: orderId);
    return orderId;
  }

  Future<bool> updateOrderStatus(String orderId, OrderStatus status) async {
    if (!_updateOrderSuccess) {
      throw Exception(_errorMessage ?? '更新订单状态失败');
    }

    final order = _orders[orderId];
    if (order == null) return false;

    _orders[orderId] = order.copyWith(status: status);
    return true;
  }

  Future<OrderModel?> getOrderById(String orderId) async {
    return _orders[orderId];
  }

  Future<List<OrderModel>> getUserOrders(String userId) async {
    return _orders.values.toList();
  }

  void reset() {
    _orders.clear();
    _createOrderSuccess = true;
    _updateOrderSuccess = true;
    _errorMessage = null;
  }
} 