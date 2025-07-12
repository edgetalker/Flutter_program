import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shop/constants.dart';

// 通知模型
class NotificationItem {
  final String id;
  final String title;
  final String content;
  final DateTime time;
  final String type; // order, promotion, system
  final bool isRead;
  final String? imageUrl;

  NotificationItem({
    required this.id,
    required this.title,
    required this.content,
    required this.time,
    required this.type,
    this.isRead = false,
    this.imageUrl,
  });
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationItem> _notifications = [
    NotificationItem(
      id: "1",
      title: "订单发货通知",
      content: "您的订单 #20231201001 已发货，预计2-3天内送达。",
      time: DateTime.now().subtract(const Duration(hours: 1)),
      type: "order",
      isRead: false,
      imageUrl: "assets/icons/Delivery.svg",
    ),
    NotificationItem(
      id: "2",
      title: "促销活动开始",
      content: "双12大促开始啦！全场商品最高享受7折优惠，快来选购吧！",
      time: DateTime.now().subtract(const Duration(hours: 3)),
      type: "promotion",
      isRead: false,
      imageUrl: "assets/icons/Discount.svg",
    ),
    NotificationItem(
      id: "3",
      title: "新品上架",
      content: "春季新款已上架，时尚潮流等你来发现！",
      time: DateTime.now().subtract(const Duration(days: 1)),
      type: "promotion",
      isRead: true,
      imageUrl: "assets/icons/Product.svg",
    ),
    NotificationItem(
      id: "4",
      title: "订单完成",
      content: "您的订单 #20231128003 已完成，感谢您的购买！",
      time: DateTime.now().subtract(const Duration(days: 2)),
      type: "order",
      isRead: true,
      imageUrl: "assets/icons/Bag.svg",
    ),
    NotificationItem(
      id: "5",
      title: "系统更新",
      content: "APP已更新至最新版本，新增了更多实用功能。",
      time: DateTime.now().subtract(const Duration(days: 3)),
      type: "system",
      isRead: true,
      imageUrl: "assets/icons/Settings.svg",
    ),
  ];

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text("通知消息"),
            if (_unreadCount > 0)
              Text(
                "$_unreadCount 条未读",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: primaryColor,
                ),
              ),
          ],
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton(
            onSelected: (value) {
              switch (value) {
                case 'mark_all_read':
                  _markAllAsRead();
                  break;
                case 'clear_all':
                  _clearAllNotifications();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'mark_all_read',
                child: Row(
                  children: [
                    Icon(Icons.mark_email_read, size: 20),
                    SizedBox(width: 8),
                    Text("全部已读"),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.clear_all, size: 20),
                    SizedBox(width: 8),
                    Text("清空全部"),
                  ],
                ),
              ),
            ],
            child: SvgPicture.asset(
              "assets/icons/DotsV.svg",
              height: 24,
              colorFilter: ColorFilter.mode(
                Theme.of(context).iconTheme.color!,
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _notifications.isEmpty ? _buildEmptyState() : _buildNotificationList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            "assets/icons/Notification.svg",
            height: 80,
            colorFilter: ColorFilter.mode(
              Theme.of(context).iconTheme.color!.withValues(alpha: 0.3),
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: defaultPadding),
          Text(
            "暂无通知消息",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: defaultPadding / 2),
          Text(
            "新的通知消息会在这里显示",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList() {
    // 按日期分组
    Map<String, List<NotificationItem>> groupedNotifications = {};
    
    for (var notification in _notifications) {
      String dateKey = _getDateKey(notification.time);
      if (!groupedNotifications.containsKey(dateKey)) {
        groupedNotifications[dateKey] = [];
      }
      groupedNotifications[dateKey]!.add(notification);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(defaultPadding),
      itemCount: groupedNotifications.length,
      itemBuilder: (context, index) {
        String dateKey = groupedNotifications.keys.elementAt(index);
        List<NotificationItem> notifications = groupedNotifications[dateKey]!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 日期分组头
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                dateKey,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.6),
                ),
              ),
            ),
            
            // 该日期的通知列表
            ...notifications.map((notification) => _buildNotificationItem(notification)),
            
            const SizedBox(height: defaultPadding),
          ],
        );
      },
    );
  }

  Widget _buildNotificationItem(NotificationItem notification) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _onNotificationTap(notification),
        borderRadius: BorderRadius.circular(defaultBorderRadious),
        child: Container(
          padding: const EdgeInsets.all(defaultPadding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(defaultBorderRadious),
            color: notification.isRead 
                ? null 
                : Theme.of(context).primaryColor.withValues(alpha: 0.05),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 图标
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getTypeColor(notification.type).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    notification.imageUrl ?? "assets/icons/Notification.svg",
                    width: 20,
                    height: 20,
                    colorFilter: ColorFilter.mode(
                      _getTypeColor(notification.type),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // 内容
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.content,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.8),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(notification.time),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              
              // 操作按钮
              PopupMenuButton(
                onSelected: (value) {
                  switch (value) {
                    case 'mark_read':
                      _markAsRead(notification.id);
                      break;
                    case 'delete':
                      _deleteNotification(notification.id);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  if (!notification.isRead)
                    const PopupMenuItem(
                      value: 'mark_read',
                      child: Text("标记已读"),
                    ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text("删除"),
                  ),
                ],
                child: Icon(
                  Icons.more_vert,
                  color: Theme.of(context).iconTheme.color!.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'order':
        return const Color(0xFF4CAF50);
      case 'promotion':
        return const Color(0xFFFF9800);
      case 'system':
        return const Color(0xFF2196F3);
      default:
        return primaryColor;
    }
  }

  String _getDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final notificationDate = DateTime(date.year, date.month, date.day);
    
    if (notificationDate == today) {
      return "今天";
    } else if (notificationDate == yesterday) {
      return "昨天";
    } else {
      return "${date.month}月${date.day}日";
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    
    if (diff.inMinutes < 60) {
      return "${diff.inMinutes}分钟前";
    } else if (diff.inHours < 24) {
      return "${diff.inHours}小时前";
    } else {
      return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    }
  }

  void _onNotificationTap(NotificationItem notification) {
    if (!notification.isRead) {
      _markAsRead(notification.id);
    }
    
    // 根据通知类型进行相应的跳转
    switch (notification.type) {
      case 'order':
        // 跳转到订单详情
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("跳转到订单详情")),
        );
        break;
      case 'promotion':
        // 跳转到促销页面
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("跳转到促销页面")),
        );
        break;
      default:
        break;
    }
  }

  void _markAsRead(String id) {
    setState(() {
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index] = NotificationItem(
          id: _notifications[index].id,
          title: _notifications[index].title,
          content: _notifications[index].content,
          time: _notifications[index].time,
          type: _notifications[index].type,
          isRead: true,
          imageUrl: _notifications[index].imageUrl,
        );
      }
    });
  }

  void _markAllAsRead() {
    setState(() {
      _notifications = _notifications.map((notification) => 
        NotificationItem(
          id: notification.id,
          title: notification.title,
          content: notification.content,
          time: notification.time,
          type: notification.type,
          isRead: true,
          imageUrl: notification.imageUrl,
        )
      ).toList();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("已全部标记为已读")),
    );
  }

  void _deleteNotification(String id) {
    setState(() {
      _notifications.removeWhere((n) => n.id == id);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("通知已删除")),
    );
  }

  void _clearAllNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("清空全部通知"),
        content: const Text("确定要清空所有通知消息吗？此操作不可撤销。"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("取消"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _notifications.clear();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("已清空所有通知")),
              );
            },
            child: const Text("确定"),
          ),
        ],
      ),
    );
  }
}
