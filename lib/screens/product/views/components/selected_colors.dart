import 'package:flutter/material.dart';

import '../../../../constants.dart';
import 'color_dot.dart';

// 已选颜色
class SelectedColors extends StatelessWidget {
  const SelectedColors({// 构造函数
    super.key,
    required this.colors,
    required this.selectedColorIndex,
    required this.press,
  });
  final List<Color> colors;// 颜色列表
  final int selectedColorIndex;// 已选颜色索引
  final ValueChanged<int> press;// 点击事件

  @override
  Widget build(BuildContext context) {
    return Column(// 垂直布局
      crossAxisAlignment: CrossAxisAlignment.start,// 交叉轴对齐
      children: [
        Padding(// 间距
          padding: const EdgeInsets.all(defaultPadding),
          child: Text(
            "选择颜色",
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(
              colors.length,
              (index) => Padding(
                padding: EdgeInsets.only(
                    left: index == 0 ? defaultPadding : defaultPadding / 2),
                child: ColorDot(
                  color: colors[index],
                  isActive: selectedColorIndex == index,
                  press: () => press(index),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
