import '../database/user_dao.dart';
import '../models/user_model.dart';

class AuthService {
  // 检查是否已登录
  static Future<bool> isLoggedIn() async {
    final user = await UserDao.getCurrentUser();
    return user != null;
  }

  // 获取当前用户信息
  static Future<Map<String, String?>> getCurrentUser() async {
    final user = await UserDao.getCurrentUser();
    if (user != null) {
      return {
        'email': user.email,
        'name': user.name,
        'id': user.id,
        'phone': user.phone,
        'avatar': user.avatar,
      };
    }
    return {
      'email': null,
      'name': null,
      'id': null,
      'phone': null,
      'avatar': null,
    };
  }

  // 登录
  static Future<AuthResult> login(String email, String password) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(seconds: 1));

    try {
      final user = await UserDao.login(email, password);
      
      if (user != null) {
        return AuthResult(
          success: true,
          message: '登录成功',
          user: UserInfo(
            id: user.id,
            email: user.email,
            name: user.name,
            phone: user.phone,
            avatar: user.avatar,
          ),
        );
      } else {
        return AuthResult(
          success: false,
          message: '邮箱或密码错误',
        );
      }
    } catch (e) {
      return AuthResult(
        success: false,
        message: '登录失败: ${e.toString()}',
      );
    }
  }

  // 注册
  static Future<AuthResult> register(String email, String password, {String? name}) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(seconds: 1));

    try {
      final userName = name ?? email.split('@')[0];
      final user = await UserDao.register(email, password, userName);
      
      if (user != null) {
        return AuthResult(
          success: true,
          message: '注册成功',
          user: UserInfo(
            id: user.id,
            email: user.email,
            name: user.name,
            phone: user.phone,
            avatar: user.avatar,
          ),
        );
      } else {
        return AuthResult(
          success: false,
          message: '该邮箱已被注册',
        );
      }
    } catch (e) {
      return AuthResult(
        success: false,
        message: '注册失败: ${e.toString()}',
      );
    }
  }

  // 发送密码重置邮件
  static Future<AuthResult> sendPasswordResetEmail(String email) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(seconds: 1));

    try {
      final success = await UserDao.requestPasswordReset(email);
      
      if (success) {
        return AuthResult(
          success: true,
          message: '密码重置邮件已发送',
        );
      } else {
        return AuthResult(
          success: false,
          message: '该邮箱未注册',
        );
      }
    } catch (e) {
      return AuthResult(
        success: false,
        message: '发送失败: ${e.toString()}',
      );
    }
  }

  // 退出登录
  static Future<void> logout() async {
    await UserDao.logout();
  }

  // 更新用户信息
  static Future<AuthResult> updateUserInfo(UserModel user) async {
    try {
      final success = await UserDao.updateUser(user);
      
      if (success) {
        return AuthResult(
          success: true,
          message: '用户信息更新成功',
        );
      } else {
        return AuthResult(
          success: false,
          message: '更新失败',
        );
      }
    } catch (e) {
      return AuthResult(
        success: false,
        message: '更新失败: ${e.toString()}',
      );
    }
  }

  // 更新密码
  static Future<AuthResult> updatePassword(String userId, String newPassword) async {
    try {
      final success = await UserDao.updatePassword(userId, newPassword);
      
      if (success) {
        return AuthResult(
          success: true,
          message: '密码更新成功',
        );
      } else {
        return AuthResult(
          success: false,
          message: '密码更新失败',
        );
      }
    } catch (e) {
      return AuthResult(
        success: false,
        message: '密码更新失败: ${e.toString()}',
      );
    }
  }

  // 清理过期会话
  static Future<void> cleanupExpiredSessions() async {
    await UserDao.cleanupExpiredSessions();
  }
}

// 认证结果类
class AuthResult {
  final bool success;
  final String message;
  final UserInfo? user;

  AuthResult({
    required this.success,
    required this.message,
    this.user,
  });
}

// 用户信息类
class UserInfo {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String? avatar;

  UserInfo({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.avatar,
  });
} 