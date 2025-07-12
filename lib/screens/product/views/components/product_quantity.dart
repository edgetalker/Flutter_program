import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../constants.dart';

// 商品数量
class ProductQuantity extends StatelessWidget {
  const ProductQuantity({// 构造函数
    super.key,
    required this.numOfItem,
    required this.onIncrement,
    required this.onDecrement,
  });

  final int numOfItem;
  final VoidCallback onIncrement, onDecrement;

  @override
  Widget build(BuildContext context) {
    return Column(// 垂直布局
      crossAxisAlignment: CrossAxisAlignment.start,// 交叉轴对齐
      children: [
        Text(// 文本
          "Quantity",
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: defaultPadding),
        Row(// 水平布局
          children: [
            SizedBox(// 尺寸
              height: 40,
              width: 40,
              child: OutlinedButton(
                onPressed: onDecrement,
                style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(defaultPadding / 2)),
                child: SvgPicture.asset(
                  "assets/icons/Minus.svg",
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
            ),
            SizedBox(
              width: 40,
              child: Center(
                child: Text(
                  numOfItem.toString(),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(fontWeight: FontWeight.w500),
                ),
              ),
            ),
            SizedBox(
              height: 40,
              width: 40,
              child: OutlinedButton(
                onPressed: onIncrement,
                style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(defaultPadding / 2)),
                child: SvgPicture.asset(
                  "assets/icons/Plus1.svg",
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
