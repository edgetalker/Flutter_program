import 'package:flutter/material.dart';

import '../../../../constants.dart';

// 商品可用性标签
class ProductAvailabilityTag extends StatelessWidget {
  const ProductAvailabilityTag({// 构造函数
    super.key,
    required this.isAvailable,
  });

  final bool isAvailable;

  @override
  Widget build(BuildContext context) {
    return Container(// 容器
      padding: const EdgeInsets.all(defaultPadding / 2),// 内边距
      decoration: BoxDecoration(// 装饰
        color: isAvailable ? successColor : errorColor,
        borderRadius: const BorderRadius.all(
          Radius.circular(defaultBorderRadious / 2),
        ),
      ),
      child: Text(// 文本
        isAvailable ? "Available in stock" : "Currently unavailable",
        style: Theme.of(context)
            .textTheme
            .labelSmall!
            .copyWith(color: Colors.white, fontWeight: FontWeight.w500),
      ),
    );
  }
}
