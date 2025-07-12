import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/route/screen_export.dart';
import 'package:shop/providers/product_provider.dart';

import '../../../../constants.dart';

class PopularProducts extends StatelessWidget {
  const PopularProducts({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // 热门商品
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: defaultPadding / 2),// 顶部间距
            Padding(// 标题
              padding: const EdgeInsets.all(defaultPadding),
              child: Text(
                "热门商品",
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            SizedBox(// 商品列表
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: productProvider.popularProducts.length,
                itemBuilder: (context, index) {
                  final product = productProvider.popularProducts[index];
                  return Padding(
                    padding: EdgeInsets.only(// 左右间距
                      left: defaultPadding,
                      right: index == productProvider.popularProducts.length - 1
                          ? defaultPadding
                          : 0,
                    ),
                    child: ProductCard(// 商品卡片
                      product: product,
                      press: () {// 路由到商品详情页面
                        Navigator.pushNamed(
                          context, 
                          productDetailsScreenRoute,
                          arguments: product,
                        );
                      },
                    ),
                  );
                },
              ),
            )
          ],
        );
      },
    );
  }
}
