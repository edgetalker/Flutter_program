import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
// 用户权限
class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false; // 是否登录
  bool _isLoading = false; // 是否加载
  String? _userEmail; // 用户邮箱
  String? _userName; // 用户名
  String? _errorMessage; // 错误消息

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get userEmail => _userEmail;
  String? get userName => _userName;
  String? get errorMessage => _errorMessage;

  // 初始化时检查登录状态
  AuthProvider() {
    _checkLoginStatus();
  }

  // 检查登录状态
  Future<void> _checkLoginStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      _isLoggedIn = await AuthService.isLoggedIn();
      if (_isLoggedIn) {
        final user = await AuthService.getCurrentUser();
        _userEmail = user['email'];
        _userName = user['name'];
      }
    } catch (e) {
      _errorMessage = '检查登录状态失败: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 登录
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await AuthService.login(email, password);
      
      if (result.success) {
        _isLoggedIn = true;
        _userEmail = result.user?.email;
        _userName = result.user?.name;
        _errorMessage = null;
      } else {
        _errorMessage = result.message;
      }
      
      return result.success;
    } catch (e) {
      _errorMessage = '登录失败: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 注册
  Future<bool> register(String email, String password, String name) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await AuthService.register(email, password, name: name);
      
      if (result.success) {
        _isLoggedIn = true;
        _userEmail = result.user?.email;
        _userName = result.user?.name;
        _errorMessage = null;
      } else {
        _errorMessage = result.message;
      }
      
      return result.success;
    } catch (e) {
      _errorMessage = '注册失败: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 发送密码重置邮件
  Future<bool> sendPasswordResetEmail(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {// 发送密码重置邮件
      final result = await AuthService.sendPasswordResetEmail(email);
      
      if (!result.success) {
        _errorMessage = result.message;
      }
      
      return result.success;
    } catch (e) {
      _errorMessage = '发送重置邮件失败: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 退出登录
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await AuthService.logout();
      _isLoggedIn = false;
      _userEmail = null;
      _userName = null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = '退出登录失败: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 清除错误消息
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
} 