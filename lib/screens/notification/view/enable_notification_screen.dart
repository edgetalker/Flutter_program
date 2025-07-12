import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../constants.dart';

class EnableNotificationScreen extends StatelessWidget {
  const EnableNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("启用通知"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                "assets/icons/Notification.svg",
                height: 120,
                colorFilter: ColorFilter.mode(
                  primaryColor,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(height: defaultPadding * 2),
              Text(
                "启用通知",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: defaultPadding),
              Text(
                "开启通知以便及时接收订单状态、优惠活动和重要消息。",
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: defaultPadding * 3),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // 这里可以添加启用通知的逻辑
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("通知已启用")),
                    );
                    Navigator.pop(context);
                  },
                  child: const Text("启用通知"),
                ),
              ),
              const SizedBox(height: defaultPadding),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("稍后再说"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
