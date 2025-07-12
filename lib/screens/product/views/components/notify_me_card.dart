import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../constants.dart';

// 通知我卡片
class NotifyMeCard extends StatelessWidget {
  const NotifyMeCard({// 构造函数
    super.key,
    this.isNotify = false,
    required this.onChanged,
  });

  final bool isNotify;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SafeArea(// 安全区域
      child: Padding(// 间距
        padding: const EdgeInsets.symmetric(// 对称间距
            horizontal: defaultPadding, vertical: defaultPadding / 2),
        child: Container(// 容器
          decoration: BoxDecoration(// 装饰
            color: isNotify ? primaryColor : Colors.transparent,
            borderRadius: const BorderRadius.all(
              Radius.circular(defaultBorderRadious),
            ),
            border: Border.all(
              color: isNotify
                  ? Colors.transparent
                  : Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .color!
                      .withOpacity(0.1),
            ),
          ),
          child: Padding(// 间距
            padding: const EdgeInsets.all(defaultPadding),
            child: Row(// 水平布局
              children: [
                SizedBox(// 尺寸
                  height: 40,// 高度
                  width: 40,// 宽度
                  child: OutlinedButton(// 按钮
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: EdgeInsets.zero,
                      side: const BorderSide(color: Colors.white10),
                    ),
                    child: SvgPicture.asset(
                      "assets/icons/Notification.svg",
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: defaultPadding),
                Expanded(// 扩展
                  child: Text(
                    "有库存时通知我",
                    style: TextStyle(
                        color: isNotify
                            ? Colors.white
                            : Theme.of(context).textTheme.bodyLarge!.color,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                CupertinoSwitch(// 开关
                  onChanged: onChanged,
                  value: isNotify,
                  activeColor: primaryMaterialColor.shade900,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
