import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/providers/product_provider.dart';
import 'package:shop/route/screen_export.dart';

import '../../../../constants.dart';

// 畅销商品组件
class BestSellers extends StatelessWidget {
  const BestSellers({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        return Column(// 垂直布局
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: defaultPadding / 2),
            Padding(// 标题区域
              padding: const EdgeInsets.all(defaultPadding),
              child: Text(
                "畅销商品",
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            SizedBox(// 商品列表
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: productProvider.bestSellersProducts.length,
                itemBuilder: (context, index) {// 动态构建
                  final product = productProvider.bestSellersProducts[index];
                  return Padding(
                    padding: EdgeInsets.only(// 左右间距
                      left: defaultPadding,
                      right: index == productProvider.bestSellersProducts.length - 1
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
