import 'package:flutter/material.dart';
import 'package:shop/components/check_mark.dart';

import '../../../../constants.dart';
// 颜色点
class ColorDot extends StatelessWidget {
  const ColorDot({
    super.key,
    required this.color,
    this.isActive = false,
    this.press,
  });
  final Color color;
  final bool isActive;
  final VoidCallback? press;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(// 手势检测
      onTap: press,
      child: AnimatedContainer(// 动画容器
        duration: defaultDuration,
        padding: EdgeInsets.all(isActive ? defaultPadding / 4 : 0),
        height: 40,
        width: 40,
        decoration: BoxDecoration(// 装饰
          shape: BoxShape.circle,
          border:
              Border.all(color: isActive ? primaryColor : Colors.transparent),
        ),
        child: Stack(// 堆叠
          alignment: Alignment.center,
          children: [
            CircleAvatar(// 圆形头像
              backgroundColor: color,
            ),
            AnimatedOpacity(// 动画透明度
              opacity: isActive ? 1 : 0,
              duration: defaultDuration,
              child: const CheckMark(),
            ),
          ],
        ),
      ),
    );
  }
}
