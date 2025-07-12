import 'package:flutter/material.dart';

import '../../../../constants.dart';
import 'categories.dart';
import 'offers_carousel.dart';
// 优惠轮播图和分类组件
class OffersCarouselAndCategories extends StatelessWidget {
  const OffersCarouselAndCategories({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(// 垂直布局
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const OffersCarousel(),// 优惠轮播图
        const SizedBox(height: defaultPadding / 2),// 顶部间距
        Padding(// 标题区域
          padding: const EdgeInsets.all(defaultPadding),
          child: Text(
            "商品分类",
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        const Categories(),
      ],
    );
  }
}
