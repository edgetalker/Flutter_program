import 'package:flutter/material.dart';

import '../../../constants.dart';

class ProductReturnsScreen extends StatelessWidget {
  const ProductReturnsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: defaultPadding),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: defaultPadding / 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(
                    width: 40,
                    child: BackButton(),
                  ),
                  Text(
                    "退换货政策",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(defaultPadding),
              child: Text(
                "我们提供7天无理由退换货服务。商品需保持原有包装和标签完整，未经使用。定制商品不支持退换货。退货时请联系客服获取退货地址，我们将在收到商品后3-5个工作日内处理退款。退款将原路返回到您的付款账户。如有质量问题，我们将承担退货运费。",
              ),
            )
          ],
        ),
      ),
    );
  }
}
