import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import 'database_helper.dart';

class UserDao {
  static final DatabaseHelper _databaseHelper = DatabaseHelper();
  static const Uuid _uuid = Uuid();

  // 根据邮箱查找用户
  static Future<UserModel?> getUserByEmail(String email) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ? AND is_active = 1',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  // 根据ID查找用户
  static Future<UserModel?> getUserById(String userId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ? AND is_active = 1',
      whereArgs: [userId],
    );

    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  // 验证用户密码
  static Future<bool> verifyPassword(String password, String hashedPassword) async {
    // 简化的密码验证
    final hashedInput = _hashPassword(password);
    return hashedInput == hashedPassword;
  }

  // 用户登录
  static Future<UserModel?> login(String email, String password) async {
    final user = await getUserByEmail(email);
    if (user == null) {
      return null;
    }

    // 验证密码
    final isValid = await verifyPassword(password, user.passwordHash);
    if (!isValid) {
      return null;
    }

    // 创建或更新用户会话
    await _createUserSession(user.id);
    
    return user;
  }

  // 用户注册
  static Future<UserModel?> register(String email, String password, String name) async {
    final db = await _databaseHelper.database;
    
    // 检查邮箱是否已存在
    final existingUser = await getUserByEmail(email);
    if (existingUser != null) {
      return null; // 邮箱已存在
    }

    // 创建新用户
    final now = DateTime.now();
    final userId = _uuid.v4();
    final hashedPassword = _hashPassword(password);
    
    final newUser = UserModel(
      id: userId,
      email: email,
      passwordHash: hashedPassword,
      name: name,
      createdAt: now,
      updatedAt: now,
    );

    try {
      await db.insert('users', newUser.toMap());
      
      // 创建用户会话
      await _createUserSession(userId);
      
      return newUser;
    } catch (e) {
      print('注册失败: $e');
      return null;
    }
  }

  // 更新用户信息
  static Future<bool> updateUser(UserModel user) async {
    final db = await _databaseHelper.database;
    
    try {
      final result = await db.update(
        'users',
        user.copyWith(updatedAt: DateTime.now()).toMap(),
        where: 'id = ?',
        whereArgs: [user.id],
      );
      return result > 0;
    } catch (e) {
      print('更新用户信息失败: $e');
      return false;
    }
  }

  // 更新用户密码
  static Future<bool> updatePassword(String userId, String newPassword) async {
    final db = await _databaseHelper.database;
    
    try {
      final hashedPassword = _hashPassword(newPassword);
      final result = await db.update(
        'users',
        {
          'password_hash': hashedPassword,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [userId],
      );
      return result > 0;
    } catch (e) {
      print('更新密码失败: $e');
      return false;
    }
  }

  // 检查用户是否已登录
  static Future<UserModel?> getCurrentUser() async {
    final session = await _getActiveSession();
    if (session == null) {
      return null;
    }

    return await getUserById(session.userId);
  }

  // 用户登出
  static Future<bool> logout() async {
    final db = await _databaseHelper.database;
    
    try {
      // 将所有活动会话设为非活动
      final result = await db.update(
        'user_sessions',
        {'is_active': 0},
        where: 'is_active = 1',
      );
      return result >= 0;
    } catch (e) {
      print('登出失败: $e');
      return false;
    }
  }

  // 创建用户会话
  static Future<UserSession> _createUserSession(String userId) async {
    final db = await _databaseHelper.database;
    final now = DateTime.now();
    
    // 先将该用户的其他会话设为非活动
    await db.update(
      'user_sessions',
      {'is_active': 0},
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    // 创建新会话
    final session = UserSession(
      id: _uuid.v4(),
      userId: userId,
      loginAt: now,
      lastActivity: now,
      isActive: true,
    );

    await db.insert('user_sessions', session.toMap());
    return session;
  }

  // 获取当前活动会话
  static Future<UserSession?> _getActiveSession() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_sessions',
      where: 'is_active = 1',
      orderBy: 'last_activity DESC',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      final session = UserSession.fromMap(maps.first);
      
      // 检查会话是否过期
      if (session.isExpired) {
        await _deactivateSession(session.id);
        return null;
      }
      
      // 更新最后活动时间
      await _updateSessionActivity(session.id);
      return session;
    }
    return null;
  }

  // 更新会话活动时间
  static Future<void> _updateSessionActivity(String sessionId) async {
    final db = await _databaseHelper.database;
    await db.update(
      'user_sessions',
      {'last_activity': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  // 停用会话
  static Future<void> _deactivateSession(String sessionId) async {
    final db = await _databaseHelper.database;
    await db.update(
      'user_sessions',
      {'is_active': 0},
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  // 简化的密码加密（实际项目中应使用更安全的方式）
  static String _hashPassword(String password) {
    final bytes = utf8.encode(password + 'salt_key'); // 添加盐值
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // 密码重置（发送重置邮件的模拟）
  static Future<bool> requestPasswordReset(String email) async {
    final user = await getUserByEmail(email);
    if (user == null) {
      return false;
    }
    // 这里只是模拟成功
    print('密码重置邮件已发送到: $email');
    return true;
  }

  // 清理过期会话
  static Future<void> cleanupExpiredSessions() async {
    final db = await _databaseHelper.database;
    final oneDayAgo = DateTime.now().subtract(const Duration(days: 1));
    
    await db.update(
      'user_sessions',
      {'is_active': 0},
      where: 'last_activity < ?',
      whereArgs: [oneDayAgo.toIso8601String()],
    );
  }

  // 获取用户统计信息
  static Future<Map<String, int>> getUserStats() async {
    final db = await _databaseHelper.database;
    
    final totalUsers = await db.rawQuery('SELECT COUNT(*) as count FROM users WHERE is_active = 1');
    final activeUsers = await db.rawQuery('SELECT COUNT(*) as count FROM users WHERE is_active = 1');
    final activeSessions = await db.rawQuery('SELECT COUNT(*) as count FROM user_sessions WHERE is_active = 1');
    
    return {
      'totalUsers': totalUsers.first['count'] as int,
      'activeUsers': activeUsers.first['count'] as int,
      'activeSessions': activeSessions.first['count'] as int,
    };
  }
} 