import 'package:flutter/material.dart';

import '../../../../constants.dart';

// 已选尺寸
class SelectedSize extends StatelessWidget {
  const SelectedSize({// 构造函数
    super.key,
    required this.sizes,
    required this.selectedIndex,
    required this.press,
  });

  final List<String> sizes;// 尺寸列表
  final int selectedIndex;// 已选尺寸索引
  final ValueChanged<int> press;// 点击事件

  @override
  Widget build(BuildContext context) {
    return Column(// 垂直布局
      crossAxisAlignment: CrossAxisAlignment.start,// 交叉轴对齐
      children: [
        const SizedBox(height: defaultPadding),// 间距
        Padding(// 间距
          padding: const EdgeInsets.all(defaultPadding),
          child: Text(
            "选择尺寸",
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        Row(
          children: List.generate(
            sizes.length,
            (index) => Padding(
              padding: EdgeInsets.only(
                  left: index == 0 ? defaultPadding : defaultPadding / 2),
              child: SizeButton(
                text: sizes[index],
                isActive: selectedIndex == index,
                press: () => press(index),
              ),
            ),
          ),
        )
      ],
    );
  }
}

// 尺寸按钮
class SizeButton extends StatelessWidget {
  const SizeButton({// 构造函数
    super.key,
    required this.text,
    required this.isActive,
    required this.press,
  });

  final String text;
  final bool isActive;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      width: 40,
      child: OutlinedButton(
        onPressed: press,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: const CircleBorder(),
          side: isActive ? const BorderSide(color: primaryColor) : null,
        ),
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
              color: isActive
                  ? primaryColor
                  : Theme.of(context).textTheme.bodyLarge!.color),
        ),
      ),
    );
  }
}
