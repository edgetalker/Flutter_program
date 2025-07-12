import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../constants.dart';

class NotificationOptionsScreen extends StatefulWidget {
  const NotificationOptionsScreen({super.key});

  @override
  State<NotificationOptionsScreen> createState() => _NotificationOptionsScreenState();
}

class _NotificationOptionsScreenState extends State<NotificationOptionsScreen> {
  bool _orderUpdates = true;
  bool _promotions = false;
  bool _newProducts = true;
  bool _marketingEmails = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("通知设置"),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(defaultPadding),
          children: [
            Text(
              "推送通知",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: defaultPadding),
            _buildNotificationTile(
              "订单更新",
              "接收订单状态变化通知",
              _orderUpdates,
              (value) => setState(() => _orderUpdates = value),
            ),
            _buildNotificationTile(
              "促销活动",
              "接收特价商品和折扣信息",
              _promotions,
              (value) => setState(() => _promotions = value),
            ),
            _buildNotificationTile(
              "新品上架",
              "第一时间了解新商品信息",
              _newProducts,
              (value) => setState(() => _newProducts = value),
            ),
            const SizedBox(height: defaultPadding),
            const Divider(),
            const SizedBox(height: defaultPadding),
            Text(
              "邮件通知",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: defaultPadding),
            _buildNotificationTile(
              "营销邮件",
              "接收产品推荐和营销邮件",
              _marketingEmails,
              (value) => setState(() => _marketingEmails = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall,
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: defaultPadding / 2),
        child: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
      trailing: CupertinoSwitch(
        value: value,
        onChanged: onChanged,
        activeColor: primaryColor,
      ),
    );
  }
}
