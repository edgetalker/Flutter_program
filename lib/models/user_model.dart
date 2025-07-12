class UserModel {
  final String id; // 用户唯一标识
  final String email; // 邮箱地址
  final String passwordHash; // 密码哈希值
  final String name; // 用户名
  final String? phone; // 手机号
  final String? avatar; // 头像
  final bool isActive; // 是否激活
  final DateTime createdAt; // 创建时间
  final DateTime updatedAt; // 更新时间

  UserModel({
    required this.id,
    required this.email,
    required this.passwordHash,
    required this.name,
    this.phone,
    this.avatar,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  // 转换为数据库Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password_hash': passwordHash,
      'name': name,
      'phone': phone,
      'avatar': avatar,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // 从数据库Map创建对象
  static UserModel fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      email: map['email'],
      passwordHash: map['password_hash'],
      name: map['name'],
      phone: map['phone'],
      avatar: map['avatar'],
      isActive: map['is_active'] == 1,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  // 创建副本
  UserModel copyWith({
    String? id,
    String? email,
    String? passwordHash,
    String? name,
    String? phone,
    String? avatar,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // 获取显示名称
  String get displayName => name.isNotEmpty ? name : email.split('@')[0];

  // 获取头像URL或默认头像
  String get avatarUrl => avatar ?? 'assets/images/default_avatar.png';

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, name: $name, isActive: $isActive)';
  }
}

// 用户会话模型
class UserSession {
  final String id; // 会话唯一标识
  final String userId; // 用户唯一标识
  final String? deviceId; // 设备唯一标识
  final DateTime loginAt; // 登录时间
  final DateTime lastActivity; // 最后活动时间
  final bool isActive; // 是否激活

  UserSession({
    required this.id,
    required this.userId,
    this.deviceId,
    required this.loginAt,
    required this.lastActivity,
    this.isActive = true,
  });

  // 转换为数据库Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'device_id': deviceId,
      'login_at': loginAt.toIso8601String(),
      'last_activity': lastActivity.toIso8601String(),
      'is_active': isActive ? 1 : 0,
    };
  }

  // 从数据库Map创建对象
  static UserSession fromMap(Map<String, dynamic> map) {
    return UserSession(
      id: map['id'],
      userId: map['user_id'],
      deviceId: map['device_id'],
      loginAt: DateTime.parse(map['login_at']),
      lastActivity: DateTime.parse(map['last_activity']),
      isActive: map['is_active'] == 1,
    );
  }

  // 创建副本
  UserSession copyWith({
    String? id,
    String? userId,
    String? deviceId,
    DateTime? loginAt,
    DateTime? lastActivity,
    bool? isActive,
  }) {
    return UserSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      deviceId: deviceId ?? this.deviceId,
      loginAt: loginAt ?? this.loginAt,
      lastActivity: lastActivity ?? this.lastActivity,
      isActive: isActive ?? this.isActive,
    );
  }

  // 检查会话是否过期（24小时）
  bool get isExpired {
    final now = DateTime.now();
    final difference = now.difference(lastActivity);
    return difference.inHours > 24;
  }

  @override
  String toString() {
    return 'UserSession(id: $id, userId: $userId, isActive: $isActive)';
  }
} 