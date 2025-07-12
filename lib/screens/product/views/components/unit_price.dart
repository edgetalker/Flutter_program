import 'package:flutter/material.dart';

import '../../../../constants.dart';

// 单价
class UnitPrice extends StatelessWidget {
  const UnitPrice({// 构造函数
    super.key,
    required this.price,
    this.priceAfterDiscount,
  });

  final double price;// 价格
  final double? priceAfterDiscount;// 折扣后价格

  @override
  Widget build(BuildContext context) {
    return Column(// 垂直布局
      crossAxisAlignment: CrossAxisAlignment.start,// 交叉轴对齐
      children: [
        Text(// 文本
          "Unit price",
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: defaultPadding / 1),
        Text.rich(// 文本
          TextSpan(
            text: priceAfterDiscount == null
                ? "\$${price.toStringAsFixed(2)}  "
                : "\$${priceAfterDiscount!.toStringAsFixed(2)}  ",
            style: Theme.of(context).textTheme.titleLarge,
            children: [
              if (priceAfterDiscount != null)
                TextSpan(// 文本
                  text: "\$${price.toStringAsFixed(2)}",
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                      decoration: TextDecoration.lineThrough),
                ),
            ],
          ),
        )
      ],
    );
  }
}
